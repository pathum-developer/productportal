# MySQL to PostgreSQL Production Cutover Plan

This document covers the production data cutover. Application code, PostgreSQL schema,
trigger migrations, and seed migrations are handled by Flyway in `src/main/resources/db/migration`.

## Preconditions

- Confirm the application is deployed from branch `migration/mysql-to-postgresql`.
- Confirm PostgreSQL version is compatible with the local target, currently PostgreSQL 17.
- Confirm application secrets are configured outside source control:
  - `JWT_SECRET`
  - `DATABASE_HOST`
  - `DATABASE_PORT`
  - `DATABASE_NAME`
  - `DATABASE_USERNAME`
  - `DATABASE_PASSWORD`
  - `SECURITY_CORS_ALLOWED_ORIGINS` or `SECURITY_CORS_ALLOWED_ORIGIN_PATTERNS`
- Confirm write freeze window with business owners.
- Confirm rollback window and owner.
- Confirm monitoring dashboards and alert recipients.

## Phase 1: Backup

1. Stop application writes or enable maintenance mode.
2. Take a verified MySQL backup.
3. Store the backup in an immutable location.
4. Record source database metadata:
   - MySQL version
   - schema name
   - table row counts
   - backup file checksum
   - backup timestamp

Example:

```bash
mysqldump \
  --single-transaction \
  --routines \
  --triggers \
  --hex-blob \
  --default-character-set=utf8mb4 \
  productportal > productportal-mysql-backup.sql
```

## Phase 2: Prepare PostgreSQL

1. Provision PostgreSQL.
2. Create the application database and user.
3. Apply least-privilege access.
4. Run the application once or run Flyway directly so schema version reaches `3`.
5. Confirm migration state:

```sql
SELECT version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;
```

## Phase 3: Data Export and Transform

Use a repeatable tool-based migration path. Recommended options:

1. `pgloader` for direct MySQL to PostgreSQL transfer.
2. Controlled CSV export/import for highly audited production environments.
3. Custom ETL only if business rules require transformation.

Validate the following MySQL-to-PostgreSQL differences:

- `TINYINT(1)` boolean conversion.
- `DATETIME` and timezone handling.
- `AUTO_INCREMENT` to PostgreSQL identity sequence alignment.
- MySQL zero dates or invalid dates.
- Case sensitivity differences in unique indexes.
- Enum/reference-code values.
- Large text/blob encoding.

## Phase 4: Import

1. Import business data into PostgreSQL.
2. Do not overwrite Flyway metadata.
3. Disable application traffic during import.
4. Reset identity sequences after import.

Example sequence reset pattern:

```sql
SELECT setval(
  pg_get_serial_sequence('table_name', 'id_column'),
  GREATEST((SELECT COALESCE(MAX(id_column), 1) FROM table_name), 1),
  TRUE
);
```

## Phase 5: Reconciliation

Run reconciliation before allowing writes:

```sql
SELECT 'table_name' AS table_name, COUNT(*) AS row_count
FROM table_name;
```

Validate:

- Row counts for every migrated table.
- Critical aggregate totals.
- Foreign key integrity.
- User login/authentication flow.
- Product/category listing flow.
- Role/permission checks.
- Audit trigger behavior.
- Insert/update/delete smoke paths.

## Phase 6: Application Cutover

1. Point application environment variables to PostgreSQL.
2. Start the application.
3. Confirm startup logs show:
   - PostgreSQL JDBC URL.
   - Flyway schema up to date.
   - Hibernate validation successful.
4. Run smoke tests.
5. Enable traffic gradually if infrastructure supports it.

## Phase 7: Rollback

Rollback is allowed only before new PostgreSQL-only writes are accepted, unless a reverse-sync
strategy has been implemented.

Rollback steps:

1. Disable application traffic.
2. Point application back to MySQL.
3. Restore from the verified MySQL backup if needed.
4. Restart the application.
5. Validate core flows.
6. Communicate rollback result and data timestamp.

## Phase 8: Post-Cutover Monitoring

Monitor for at least one business cycle:

- Error rate.
- Slow queries.
- Connection pool exhaustion.
- Deadlocks and lock waits.
- Login failures.
- Audit table growth.
- Sequence gaps or primary key conflicts.
- PostgreSQL CPU, memory, disk, and WAL growth.

## Sign-Off Checklist

- [ ] MySQL backup verified.
- [ ] PostgreSQL schema version verified.
- [ ] Data import completed.
- [ ] Row counts reconciled.
- [ ] Critical flows smoke-tested.
- [ ] Monitoring confirmed.
- [ ] Rollback owner confirmed.
- [ ] Business owner approval received.
- [ ] Application traffic enabled.
