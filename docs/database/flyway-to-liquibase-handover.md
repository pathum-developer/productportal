# Flyway to Liquibase Production Handover

Use this only for a database that has already been initialized by the previous Flyway-based application version.
Clean databases do not need this handover; Liquibase will create `databasechangelog` automatically on startup.

## Goal

Transfer migration ownership from Flyway metadata to Liquibase metadata without re-running schema, trigger, or seed SQL against an already initialized database.

The application defaults to the `reference` Liquibase context. This runs production-safe reference data only. Demo users and demo catalog rows require the explicit `demo` context.

## Preconditions

- The deployed application artifact contains `src/main/resources/db/changelog/db.changelog-master.yaml`.
- The database schema was created by the previous Flyway migrations and is not partially applied.
- `flyway_schema_history` shows all expected migrations as successful.
- A verified database backup exists.
- Application writes are stopped during the handover.

## Verify Existing Flyway State

```sql
SELECT version, description, success
FROM flyway_schema_history
ORDER BY installed_rank;
```

Expected successful versions before handover:

- `1` - create product portal schema
- `2` - create product portal audit triggers
- `3` - seed product portal data
- `4` - update Amal Perera password hash

If any migration is missing or failed, stop and reconcile the schema before continuing.

## Mark Liquibase Changesets as Already Applied

Run Liquibase `changelog-sync` once from a controlled operator workstation or deployment job using the same changelog that the application uses.

Production example:

```bash
liquibase \
  --changelog-file=src/main/resources/db/changelog/db.changelog-master.yaml \
  --url=jdbc:postgresql://<host>:<port>/<database> \
  --username=<database-user> \
  --password=<database-password> \
  --context-filter=reference \
  changelog-sync
```

This creates Liquibase metadata rows in `databasechangelog` without executing the SQL changesets.

For a local/demo database that intentionally uses seeded demo users and catalog rows, use:

```bash
liquibase \
  --changelog-file=src/main/resources/db/changelog/db.changelog-master.yaml \
  --url=jdbc:postgresql://<host>:<port>/<database> \
  --username=<database-user> \
  --password=<database-password> \
  --context-filter=reference,demo \
  changelog-sync
```

## Validate Liquibase Metadata

```sql
SELECT id, author, filename, exectype
FROM databasechangelog
ORDER BY dateexecuted, orderexecuted;
```

Expected changeset IDs:

- `001-create-product-portal-schema`
- `002-create-product-portal-audit-triggers`
- `003-seed-product-portal-reference-access-data`
- `004-seed-product-portal-reference-status-data`
- `005-seed-product-portal-default-organization`

Additional expected IDs for local/demo databases synced with `reference,demo`:

- `006-seed-product-portal-demo-users`
- `007-seed-product-portal-demo-catalog`
- `008-update-demo-amal-perera-password-hash`

## Start the New Application Version

Start the application with Liquibase enabled:

```properties
spring.liquibase.enabled=true
spring.liquibase.change-log=classpath:db/changelog/db.changelog-master.yaml
spring.liquibase.contexts=reference
```

Use `spring.liquibase.contexts=reference,demo` only for local/demo datasets.

Startup should report that Liquibase is up to date, followed by successful Hibernate schema validation.

## Rollback

Rollback before accepting writes:

1. Stop the new application version.
2. Restore the verified backup, or remove the new Liquibase metadata only if no application writes occurred and the schema was not changed.
3. Redeploy the previous Flyway-based application version.
4. Validate login, user listing, category hierarchy, and RBAC flows.
