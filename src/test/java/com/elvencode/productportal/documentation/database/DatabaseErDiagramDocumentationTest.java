package com.elvencode.productportal.documentation.database;

import liquibase.integration.spring.SpringLiquibase;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Guards the committed database ERD against drift from the schema produced by Liquibase.
 */
@Testcontainers
class DatabaseErDiagramDocumentationTest {

    private static final String CHANGELOG = "classpath:db/changelog/db.changelog-master.yaml";
    private static final String WRITE_PROPERTY = "erd.write";
    private static final Path DOCUMENT_PATH = Path.of("docs", "database", "product-portal-erd.md");

    @Container
    static final PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:17-alpine")
            .withDatabaseName("productportal_erd")
            .withUsername("productportal")
            .withPassword("productportal");

    private static DatabaseErDiagramGenerator generator;

    @BeforeAll
    static void migrateDatabase() throws Exception {
        DataSource dataSource = dataSource();

        SpringLiquibase liquibase = new SpringLiquibase();
        liquibase.setDataSource(dataSource);
        liquibase.setChangeLog(CHANGELOG);
        liquibase.setContexts("reference");
        liquibase.setDefaultSchema("public");
        liquibase.afterPropertiesSet();

        generator = new DatabaseErDiagramGenerator(dataSource);
    }

    @Test
    void committedErDiagramShouldMatchTheFullyMigratedDatabase() throws Exception {
        String generatedDocument = normalizeLineEndings(generator.generate());

        if (Boolean.getBoolean(WRITE_PROPERTY)) {
            Files.createDirectories(DOCUMENT_PATH.getParent());
            Files.writeString(DOCUMENT_PATH, generatedDocument, StandardCharsets.UTF_8);
        }

        assertThat(Files.exists(DOCUMENT_PATH))
                .as("ERD document must exist; generate it with -Derd.write=true")
                .isTrue();

        String committedDocument = normalizeLineEndings(
                Files.readString(DOCUMENT_PATH, StandardCharsets.UTF_8));

        assertThat(committedDocument)
                .as("Database ERD is stale; regenerate it with -Derd.write=true and commit the result")
                .isEqualTo(generatedDocument);
    }

    private static DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUrl(postgres.getJdbcUrl());
        dataSource.setUsername(postgres.getUsername());
        dataSource.setPassword(postgres.getPassword());
        return dataSource;
    }

    private static String normalizeLineEndings(String value) {
        return value.replace("\r\n", "\n").replace('\r', '\n');
    }
}
