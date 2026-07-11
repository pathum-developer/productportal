-- Section 18 login audit append-only hardening migration.
-- Existing databases created from the first Section 17 migration had mutable update columns
-- and a restrictive user foreign key. This migration aligns the table with append-only audit semantics.

ALTER TABLE pp_a_login_attempt
    DROP FOREIGN KEY fk_pp_a_login_attempt_user;

ALTER TABLE pp_a_login_attempt
    DROP COLUMN updated_at,
    DROP COLUMN updated_by;

ALTER TABLE pp_a_login_attempt
    ADD CONSTRAINT fk_pp_a_login_attempt_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE SET NULL;
