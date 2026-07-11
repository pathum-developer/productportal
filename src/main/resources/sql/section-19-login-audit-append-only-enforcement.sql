-- Section 19 login audit append-only enforcement.
-- Hibernate @Immutable and a restricted repository API protect normal application code paths.
-- These triggers protect the audit table from direct UPDATE/DELETE statements as well.

DROP TRIGGER IF EXISTS trg_pp_a_login_attempt_prevent_update;
DROP TRIGGER IF EXISTS trg_pp_a_login_attempt_prevent_delete;

DELIMITER $$

CREATE TRIGGER trg_pp_a_login_attempt_prevent_update
BEFORE UPDATE ON pp_a_login_attempt
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'pp_a_login_attempt is append-only; UPDATE is not allowed';
END$$

CREATE TRIGGER trg_pp_a_login_attempt_prevent_delete
BEFORE DELETE ON pp_a_login_attempt
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'pp_a_login_attempt is append-only; DELETE is not allowed';
END$$

DELIMITER ;

-- Production privilege hardening should also remove UPDATE and DELETE grants from the
-- application database user for pp_a_login_attempt. User/host names are environment-specific,
-- so keep the actual REVOKE statements in deployment-managed infrastructure scripts.
