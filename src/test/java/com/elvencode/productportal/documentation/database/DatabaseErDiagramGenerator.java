package com.elvencode.productportal.documentation.database;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

/**
 * Generates deterministic Mermaid ERD documentation from the migrated PostgreSQL schema.
 *
 * <p>The live schema is deliberately used as the input so that every Liquibase change,
 * including later {@code ALTER TABLE} changesets, is reflected without parsing SQL.</p>
 */
final class DatabaseErDiagramGenerator {

    private static final String APPLICATION_TABLE_LIKE_PATTERN = "pp\\_%";

    private static final String COLUMN_SQL = """
            SELECT table_name,
                   column_name,
                   data_type,
                   udt_name,
                   character_maximum_length,
                   numeric_precision,
                   numeric_scale,
                   datetime_precision,
                   is_nullable,
                   ordinal_position
            FROM information_schema.columns
            WHERE table_schema = ?
              AND table_name LIKE ? ESCAPE '\\'
            ORDER BY table_name, ordinal_position
            """;

    private static final String KEY_MEMBERSHIP_SQL = """
            SELECT tc.table_name,
                   tc.constraint_name,
                   tc.constraint_type,
                   kcu.column_name,
                   kcu.ordinal_position
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON kcu.constraint_catalog = tc.constraint_catalog
             AND kcu.constraint_schema = tc.constraint_schema
             AND kcu.constraint_name = tc.constraint_name
            WHERE tc.table_schema = ?
              AND tc.table_name LIKE ? ESCAPE '\\'
              AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE', 'FOREIGN KEY')
            ORDER BY tc.table_name, tc.constraint_name, kcu.ordinal_position
            """;

    private static final String UNIQUE_CONSTRAINT_SQL = """
            SELECT tc.table_name,
                   tc.constraint_name,
                   tc.constraint_type,
                   kcu.column_name,
                   kcu.ordinal_position
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON kcu.constraint_catalog = tc.constraint_catalog
             AND kcu.constraint_schema = tc.constraint_schema
             AND kcu.constraint_name = tc.constraint_name
            WHERE tc.table_schema = ?
              AND tc.table_name LIKE ? ESCAPE '\\'
              AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
            ORDER BY tc.table_name, tc.constraint_name, kcu.ordinal_position
            """;

    private static final String FOREIGN_KEY_SQL = """
            SELECT fk_tc.constraint_name,
                   fk_tc.table_name AS child_table,
                   pk_tc.table_name AS parent_table,
                   fk_kcu.column_name AS child_column,
                   pk_kcu.column_name AS parent_column,
                   fk_kcu.ordinal_position,
                   rc.update_rule,
                   rc.delete_rule
            FROM information_schema.referential_constraints rc
            JOIN information_schema.table_constraints fk_tc
              ON fk_tc.constraint_catalog = rc.constraint_catalog
             AND fk_tc.constraint_schema = rc.constraint_schema
             AND fk_tc.constraint_name = rc.constraint_name
            JOIN information_schema.key_column_usage fk_kcu
              ON fk_kcu.constraint_catalog = fk_tc.constraint_catalog
             AND fk_kcu.constraint_schema = fk_tc.constraint_schema
             AND fk_kcu.constraint_name = fk_tc.constraint_name
            JOIN information_schema.table_constraints pk_tc
              ON pk_tc.constraint_catalog = rc.unique_constraint_catalog
             AND pk_tc.constraint_schema = rc.unique_constraint_schema
             AND pk_tc.constraint_name = rc.unique_constraint_name
            JOIN information_schema.key_column_usage pk_kcu
              ON pk_kcu.constraint_catalog = pk_tc.constraint_catalog
             AND pk_kcu.constraint_schema = pk_tc.constraint_schema
             AND pk_kcu.constraint_name = pk_tc.constraint_name
             AND pk_kcu.ordinal_position = fk_kcu.position_in_unique_constraint
            WHERE fk_tc.table_schema = ?
              AND fk_tc.table_name LIKE ? ESCAPE '\\'
              AND pk_tc.table_name LIKE ? ESCAPE '\\'
            ORDER BY fk_tc.table_name, fk_tc.constraint_name, fk_kcu.ordinal_position
            """;

    private final DataSource dataSource;

    DatabaseErDiagramGenerator(DataSource dataSource) {
        this.dataSource = Objects.requireNonNull(dataSource, "dataSource must not be null");
    }

    String generate() throws SQLException {
        try (Connection connection = dataSource.getConnection()) {
            String schemaName = resolveSchemaName(connection);
            Map<String, TableMetadata> tables = loadTables(connection, schemaName);
            loadKeyMemberships(connection, schemaName, tables);

            List<UniqueConstraintMetadata> uniqueConstraints = loadUniqueConstraints(connection, schemaName);
            List<ForeignKeyMetadata> foreignKeys = loadForeignKeys(connection, schemaName, tables, uniqueConstraints);

            return renderDocument(schemaName, tables, uniqueConstraints, foreignKeys);
        }
    }

    private String resolveSchemaName(Connection connection) throws SQLException {
        String schemaName = connection.getSchema();
        if (schemaName != null && !schemaName.isBlank()) {
            return schemaName;
        }

        try (PreparedStatement statement = connection.prepareStatement("SELECT current_schema()");
             ResultSet resultSet = statement.executeQuery()) {
            if (!resultSet.next()) {
                throw new SQLException("PostgreSQL did not return a current schema");
            }
            return resultSet.getString(1);
        }
    }

    private Map<String, TableMetadata> loadTables(Connection connection, String schemaName) throws SQLException {
        Map<String, TableMetadata> tables = new TreeMap<>();

        try (PreparedStatement statement = connection.prepareStatement(COLUMN_SQL)) {
            statement.setString(1, schemaName);
            statement.setString(2, APPLICATION_TABLE_LIKE_PATTERN);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String tableName = resultSet.getString("table_name");
                    TableMetadata table = tables.computeIfAbsent(tableName, TableMetadata::new);
                    table.addColumn(new ColumnMetadata(
                            resultSet.getString("column_name"),
                            formatDatabaseType(resultSet),
                            "YES".equals(resultSet.getString("is_nullable")),
                            resultSet.getInt("ordinal_position")));
                }
            }
        }

        if (tables.isEmpty()) {
            throw new SQLException("No application tables matching pp_% were found in schema " + schemaName);
        }
        return tables;
    }

    private void loadKeyMemberships(
            Connection connection,
            String schemaName,
            Map<String, TableMetadata> tables) throws SQLException {

        try (PreparedStatement statement = connection.prepareStatement(KEY_MEMBERSHIP_SQL)) {
            statement.setString(1, schemaName);
            statement.setString(2, APPLICATION_TABLE_LIKE_PATTERN);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    TableMetadata table = requireTable(tables, resultSet.getString("table_name"));
                    ColumnMetadata column = table.requireColumn(resultSet.getString("column_name"));
                    column.addKeyType(KeyType.fromConstraintType(resultSet.getString("constraint_type")));
                }
            }
        }
    }

    private List<UniqueConstraintMetadata> loadUniqueConstraints(
            Connection connection,
            String schemaName) throws SQLException {

        Map<String, UniqueConstraintBuilder> constraints = new LinkedHashMap<>();

        try (PreparedStatement statement = connection.prepareStatement(UNIQUE_CONSTRAINT_SQL)) {
            statement.setString(1, schemaName);
            statement.setString(2, APPLICATION_TABLE_LIKE_PATTERN);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String tableName = resultSet.getString("table_name");
                    String constraintName = resultSet.getString("constraint_name");
                    String constraintType = resultSet.getString("constraint_type");
                    String mapKey = tableName + "." + constraintName;

                    constraints.computeIfAbsent(mapKey, ignored -> new UniqueConstraintBuilder(
                                    constraintName,
                                    tableName,
                                    constraintType))
                            .addColumn(resultSet.getString("column_name"));
                }
            }
        }

        return constraints.values().stream()
                .map(UniqueConstraintBuilder::build)
                .sorted(Comparator.comparing(UniqueConstraintMetadata::tableName)
                        .thenComparing(UniqueConstraintMetadata::constraintName))
                .toList();
    }

    private List<ForeignKeyMetadata> loadForeignKeys(
            Connection connection,
            String schemaName,
            Map<String, TableMetadata> tables,
            List<UniqueConstraintMetadata> uniqueConstraints) throws SQLException {

        Map<String, ForeignKeyBuilder> foreignKeys = new LinkedHashMap<>();

        try (PreparedStatement statement = connection.prepareStatement(FOREIGN_KEY_SQL)) {
            statement.setString(1, schemaName);
            statement.setString(2, APPLICATION_TABLE_LIKE_PATTERN);
            statement.setString(3, APPLICATION_TABLE_LIKE_PATTERN);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    String childTable = resultSet.getString("child_table");
                    String constraintName = resultSet.getString("constraint_name");
                    String parentTable = resultSet.getString("parent_table");
                    String updateRule = resultSet.getString("update_rule");
                    String deleteRule = resultSet.getString("delete_rule");
                    String mapKey = childTable + "." + constraintName;

                    foreignKeys.computeIfAbsent(mapKey, ignored -> new ForeignKeyBuilder(
                                    constraintName,
                                    childTable,
                                    parentTable,
                                    updateRule,
                                    deleteRule))
                            .addColumnPair(
                                    resultSet.getString("child_column"),
                                    resultSet.getString("parent_column"));
                }
            }
        }

        List<ForeignKeyMetadata> result = new ArrayList<>();
        for (ForeignKeyBuilder builder : foreignKeys.values()) {
            ForeignKeyMetadata unclassified = builder.build(false, false);
            TableMetadata childTable = requireTable(tables, unclassified.childTable());
            boolean nullable = unclassified.childColumns().stream()
                    .map(childTable::requireColumn)
                    .anyMatch(ColumnMetadata::nullable);
            boolean unique = uniqueConstraints.stream()
                    .filter(constraint -> constraint.tableName().equals(unclassified.childTable()))
                    .anyMatch(constraint -> sameColumns(constraint.columns(), unclassified.childColumns()));

            result.add(builder.build(nullable, unique));
        }

        return result.stream()
                .sorted(Comparator.comparing(ForeignKeyMetadata::childTable)
                        .thenComparing(ForeignKeyMetadata::constraintName))
                .toList();
    }

    private String renderDocument(
            String schemaName,
            Map<String, TableMetadata> tables,
            List<UniqueConstraintMetadata> uniqueConstraints,
            List<ForeignKeyMetadata> foreignKeys) {

        int columnCount = tables.values().stream().mapToInt(table -> table.columns().size()).sum();
        long businessUniqueConstraintCount = uniqueConstraints.stream()
                .filter(constraint -> !constraint.primaryKey())
                .count();

        StringBuilder document = new StringBuilder(32_768);
        document.append("# Product Portal database ERD\n\n")
                .append("> Generated from the PostgreSQL schema produced by the Liquibase master changelog ")
                .append("using the production-safe `reference` context. ")
                .append("Do not edit the generated sections manually.\n\n")
                .append("## Source and scope\n\n")
                .append("- Source of truth: [Liquibase master changelog](../../src/main/resources/db/changelog/db.changelog-master.yaml)\n")
                .append("- Database engine: PostgreSQL 17\n")
                .append("- Schema: `").append(markdown(schemaName)).append("`\n")
                .append("- Included objects: application tables matching `pp_%`\n")
                .append("- Excluded objects: Liquibase bookkeeping tables, views, functions, triggers, and non-relational indexes\n")
                .append("- Tables: ").append(tables.size()).append("\n")
                .append("- Columns: ").append(columnCount).append("\n")
                .append("- Foreign keys: ").append(foreignKeys.size()).append("\n")
                .append("- Unique constraints (excluding primary keys): ")
                .append(businessUniqueConstraintCount).append("\n\n")
                .append("Key notation: `PK` = primary key, `FK` = foreign key, and `UK` = a column participating in a unique constraint. ")
                .append("For composite keys, every participating column carries the marker.\n\n")
                .append("Audit/history tables without database foreign keys are intentionally shown as disconnected. ")
                .append("This preserves audit records independently from mutable master data.\n\n")
                .append("## Complete physical ERD\n\n")
                .append("```mermaid\n")
                .append("erDiagram\n");

        for (TableMetadata table : tables.values()) {
            renderTable(document, table);
        }

        for (ForeignKeyMetadata foreignKey : foreignKeys) {
            renderRelationship(document, foreignKey);
        }

        document.append("```\n\n")
                .append("## Foreign-key relationship catalog\n\n")
                .append("| Constraint | Child columns | Parent columns | Parent required | Child multiplicity | On update | On delete |\n")
                .append("|---|---|---|---|---|---|---|\n");

        for (ForeignKeyMetadata foreignKey : foreignKeys) {
            document.append("| `").append(markdown(foreignKey.constraintName())).append("` | `")
                    .append(markdown(qualifiedColumns(foreignKey.childTable(), foreignKey.childColumns())))
                    .append("` | `")
                    .append(markdown(qualifiedColumns(foreignKey.parentTable(), foreignKey.parentColumns())))
                    .append("` | ")
                    .append(foreignKey.nullable() ? "No" : "Yes")
                    .append(" | ")
                    .append(foreignKey.childUnique() ? "Zero or one" : "Zero or many")
                    .append(" | ").append(markdown(foreignKey.updateRule()))
                    .append(" | ").append(markdown(foreignKey.deleteRule()))
                    .append(" |\n");
        }

        document.append("\n## Unique-constraint catalog\n\n")
                .append("Primary keys are already marked in the ERD and are omitted from this catalog.\n\n")
                .append("| Constraint | Table | Columns |\n")
                .append("|---|---|---|\n");

        uniqueConstraints.stream()
                .filter(constraint -> !constraint.primaryKey())
                .forEach(constraint -> document.append("| `")
                        .append(markdown(constraint.constraintName())).append("` | `")
                        .append(markdown(constraint.tableName())).append("` | `")
                        .append(markdown(String.join(", ", constraint.columns())))
                        .append("` |\n"));

        document.append("\n## Regeneration\n\n")
                .append("After adding a Liquibase schema migration, regenerate this file from the migrated database:\n\n")
                .append("```powershell\n")
                .append(".\\mvnw.cmd \"-Dtest=DatabaseErDiagramDocumentationTest\" \"-Derd.write=true\" test\n")
                .append("```\n\n")
                .append("```bash\n")
                .append("./mvnw -Dtest=DatabaseErDiagramDocumentationTest -Derd.write=true test\n")
                .append("```\n\n")
                .append("A normal `mvn test` regenerates the expected content in memory and fails if this committed document is stale.\n");

        return document.toString();
    }

    private void renderTable(StringBuilder document, TableMetadata table) {
        document.append("    ").append(table.name()).append(" {\n");
        table.columns().stream()
                .sorted(Comparator.comparingInt(ColumnMetadata::ordinalPosition))
                .forEach(column -> {
                    document.append("        ")
                            .append(toMermaidType(column.databaseType())).append(' ')
                            .append(column.name());

                    String keys = column.keyTypes().stream()
                            .sorted(Comparator.comparingInt(Enum::ordinal))
                            .map(KeyType::mermaidCode)
                            .collect(Collectors.joining(","));
                    if (!keys.isEmpty()) {
                        document.append(' ').append(keys);
                    }

                    document.append(" \"")
                            .append(column.nullable() ? "NULL" : "NOT NULL")
                            .append("\"\n");
                });
        document.append("    }\n");
    }

    private void renderRelationship(StringBuilder document, ForeignKeyMetadata foreignKey) {
        String parentCardinality = foreignKey.nullable() ? "o|" : "||";
        String childCardinality = foreignKey.childUnique() ? "o|" : "o{";

        document.append("    ")
                .append(foreignKey.parentTable()).append(' ')
                .append(parentCardinality).append("--").append(childCardinality).append(' ')
                .append(foreignKey.childTable())
                .append(" : \"").append(foreignKey.constraintName()).append("\"\n");
    }

    private String formatDatabaseType(ResultSet resultSet) throws SQLException {
        String dataType = resultSet.getString("data_type");
        Integer characterLength = nullableInteger(resultSet, "character_maximum_length");
        Integer numericPrecision = nullableInteger(resultSet, "numeric_precision");
        Integer numericScale = nullableInteger(resultSet, "numeric_scale");
        Integer datetimePrecision = nullableInteger(resultSet, "datetime_precision");

        return switch (dataType) {
            case "character varying" -> withOptionalSize("varchar", characterLength);
            case "character" -> withOptionalSize("char", characterLength);
            case "numeric", "decimal" -> numericType(dataType, numericPrecision, numericScale);
            case "timestamp without time zone" -> withOptionalSize("timestamp", datetimePrecision);
            case "timestamp with time zone" -> withOptionalSize("timestamptz", datetimePrecision);
            case "USER-DEFINED" -> resultSet.getString("udt_name");
            default -> dataType;
        };
    }

    private String numericType(String type, Integer precision, Integer scale) {
        if (precision == null) {
            return type;
        }
        if (scale == null) {
            return type + "(" + precision + ")";
        }
        return type + "(" + precision + "," + scale + ")";
    }

    private String withOptionalSize(String type, Integer size) {
        return size == null ? type : type + "(" + size + ")";
    }

    private Integer nullableInteger(ResultSet resultSet, String columnName) throws SQLException {
        int value = resultSet.getInt(columnName);
        return resultSet.wasNull() ? null : value;
    }

    private String toMermaidType(String databaseType) {
        return databaseType.toUpperCase(Locale.ROOT)
                .replaceAll("[^A-Z0-9]+", "_")
                .replaceAll("^_+|_+$", "");
    }

    private boolean sameColumns(List<String> left, List<String> right) {
        return new LinkedHashSet<>(left).equals(new LinkedHashSet<>(right));
    }

    private String qualifiedColumns(String tableName, List<String> columns) {
        return columns.stream()
                .map(column -> tableName + "." + column)
                .collect(Collectors.joining(", "));
    }

    private String markdown(String value) {
        return value.replace("|", "\\|").replace("`", "\\`");
    }

    private TableMetadata requireTable(Map<String, TableMetadata> tables, String tableName) {
        TableMetadata table = tables.get(tableName);
        if (table == null) {
            throw new IllegalStateException("Metadata references unknown application table " + tableName);
        }
        return table;
    }

    private enum KeyType {
        PRIMARY_KEY("PK"),
        FOREIGN_KEY("FK"),
        UNIQUE_KEY("UK");

        private final String mermaidCode;

        KeyType(String mermaidCode) {
            this.mermaidCode = mermaidCode;
        }

        String mermaidCode() {
            return mermaidCode;
        }

        static KeyType fromConstraintType(String constraintType) {
            return switch (constraintType) {
                case "PRIMARY KEY" -> PRIMARY_KEY;
                case "FOREIGN KEY" -> FOREIGN_KEY;
                case "UNIQUE" -> UNIQUE_KEY;
                default -> throw new IllegalArgumentException("Unsupported key constraint type: " + constraintType);
            };
        }
    }

    private static final class TableMetadata {

        private final String name;
        private final Map<String, ColumnMetadata> columns = new LinkedHashMap<>();

        private TableMetadata(String name) {
            this.name = name;
        }

        private void addColumn(ColumnMetadata column) {
            columns.put(column.name(), column);
        }

        private ColumnMetadata requireColumn(String columnName) {
            ColumnMetadata column = columns.get(columnName);
            if (column == null) {
                throw new IllegalStateException("Metadata references unknown column " + name + "." + columnName);
            }
            return column;
        }

        private String name() {
            return name;
        }

        private List<ColumnMetadata> columns() {
            return List.copyOf(columns.values());
        }
    }

    private static final class ColumnMetadata {

        private final String name;
        private final String databaseType;
        private final boolean nullable;
        private final int ordinalPosition;
        private final Set<KeyType> keyTypes = EnumSet.noneOf(KeyType.class);

        private ColumnMetadata(String name, String databaseType, boolean nullable, int ordinalPosition) {
            this.name = name;
            this.databaseType = databaseType;
            this.nullable = nullable;
            this.ordinalPosition = ordinalPosition;
        }

        private void addKeyType(KeyType keyType) {
            keyTypes.add(keyType);
        }

        private String name() {
            return name;
        }

        private String databaseType() {
            return databaseType;
        }

        private boolean nullable() {
            return nullable;
        }

        private int ordinalPosition() {
            return ordinalPosition;
        }

        private Set<KeyType> keyTypes() {
            return Set.copyOf(keyTypes);
        }
    }

    private record UniqueConstraintMetadata(
            String constraintName,
            String tableName,
            String constraintType,
            List<String> columns) {

        private boolean primaryKey() {
            return "PRIMARY KEY".equals(constraintType);
        }
    }

    private static final class UniqueConstraintBuilder {

        private final String constraintName;
        private final String tableName;
        private final String constraintType;
        private final List<String> columns = new ArrayList<>();

        private UniqueConstraintBuilder(String constraintName, String tableName, String constraintType) {
            this.constraintName = constraintName;
            this.tableName = tableName;
            this.constraintType = constraintType;
        }

        private UniqueConstraintBuilder addColumn(String columnName) {
            columns.add(columnName);
            return this;
        }

        private UniqueConstraintMetadata build() {
            return new UniqueConstraintMetadata(
                    constraintName,
                    tableName,
                    constraintType,
                    List.copyOf(columns));
        }
    }

    private record ForeignKeyMetadata(
            String constraintName,
            String childTable,
            List<String> childColumns,
            String parentTable,
            List<String> parentColumns,
            String updateRule,
            String deleteRule,
            boolean nullable,
            boolean childUnique) {
    }

    private static final class ForeignKeyBuilder {

        private final String constraintName;
        private final String childTable;
        private final String parentTable;
        private final String updateRule;
        private final String deleteRule;
        private final List<String> childColumns = new ArrayList<>();
        private final List<String> parentColumns = new ArrayList<>();

        private ForeignKeyBuilder(
                String constraintName,
                String childTable,
                String parentTable,
                String updateRule,
                String deleteRule) {
            this.constraintName = constraintName;
            this.childTable = childTable;
            this.parentTable = parentTable;
            this.updateRule = updateRule;
            this.deleteRule = deleteRule;
        }

        private ForeignKeyBuilder addColumnPair(String childColumn, String parentColumn) {
            childColumns.add(childColumn);
            parentColumns.add(parentColumn);
            return this;
        }

        private ForeignKeyMetadata build(boolean nullable, boolean childUnique) {
            return new ForeignKeyMetadata(
                    constraintName,
                    childTable,
                    List.copyOf(childColumns),
                    parentTable,
                    List.copyOf(parentColumns),
                    updateRule,
                    deleteRule,
                    nullable,
                    childUnique);
        }
    }
}
