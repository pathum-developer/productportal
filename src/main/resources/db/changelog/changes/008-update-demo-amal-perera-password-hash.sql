--liquibase formatted sql
--changeset elvencode:008-update-demo-amal-perera-password-hash context:demo splitStatements:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM pp_m_user WHERE username = 'amal.perera' AND password_hash = '$2a$10$5m0qTRhIsTTqTo4yvn87Vel3FR4lU2hlEwG7q7W3ni4d4KqGBqEfS'
--comment: Demo-only password update. Runs only when the seeded Amal Perera account has not already been updated to the target password hash.

-- Updates the seeded demo Amal Perera account password hash.
-- Keep this as a separate Liquibase changeset to avoid changing checksums for already-applied changesets.

DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    UPDATE pp_m_user
    SET password_hash = '$2a$10$5m0qTRhIsTTqTo4yvn87Vel3FR4lU2hlEwG7q7W3ni4d4KqGBqEfS',
        credentials_changed_at = CURRENT_TIMESTAMP(6),
        updated_at = CURRENT_TIMESTAMP(6),
        updated_by = 'SYSTEM',
        version = version + 1
    WHERE username = 'amal.perera';

    GET DIAGNOSTICS updated_count = ROW_COUNT;

    IF updated_count <> 1 THEN
        RAISE EXCEPTION 'Expected to update exactly one pp_m_user row for username %, updated %',
            'amal.perera',
            updated_count;
    END IF;
END $$;
