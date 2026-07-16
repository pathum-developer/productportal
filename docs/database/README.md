# Database documentation

This directory contains the maintained documentation for the Product Portal PostgreSQL database.

## Source of truth

The authoritative schema is the Liquibase master changelog at
`src/main/resources/db/changelog/db.changelog-master.yaml`. JPA entities and diagrams are consumers of that schema;
they are not allowed to mutate or redefine the production database structure.

## Maintained artifacts

| Artifact | Purpose | Maintenance model |
|---|---|---|
| [Product Portal ERD](product-portal-erd.md) | Complete physical ERD, keys, relationships, and constraint catalogs | Generated and verified from a migrated PostgreSQL database |
| [Flyway-to-Liquibase handover](flyway-to-liquibase-handover.md) | Migration ownership and cutover decisions | Manually maintained architecture record |
| [MySQL-to-PostgreSQL cutover plan](mysql-to-postgresql-cutover-plan.md) | Database-platform migration procedure | Manually maintained operational record |

## Updating the ERD

Requirements:

- Docker must be running because generation uses a temporary PostgreSQL 17 Testcontainer.
- Use the repository Maven wrapper and the project-supported JDK.

After adding an append-only Liquibase schema changeset and including it in the master changelog, regenerate the ERD.

PowerShell:

```powershell
.\mvnw.cmd "-Dtest=DatabaseErDiagramDocumentationTest" "-Derd.write=true" test
```

Bash:

```bash
./mvnw -Dtest=DatabaseErDiagramDocumentationTest -Derd.write=true test
```

Then review and commit both the migration and the regenerated ERD. Do not manually edit the generated ERD because
the verification test will replace or reject those changes.

## Drift protection

`DatabaseErDiagramDocumentationTest` applies the Liquibase master changelog with the production-safe `reference`
context to a clean PostgreSQL instance and recreates the expected document in memory. A normal Maven test run fails
when the committed ERD no longer matches the migrated schema. This makes database documentation part of the
schema-change definition of done.

The generator includes only application tables matching `pp_%`. Liquibase bookkeeping tables are intentionally
excluded. Functions, triggers, views, and general-purpose indexes require separate documentation because they are
not entity relationships.
