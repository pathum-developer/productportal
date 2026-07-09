-- Section 16 RBAC temporary role assignment migration.
-- Adds optional validity windows to user-role assignments and records window changes in audit history.

ALTER TABLE pp_usm_user_roles
    ADD COLUMN valid_from TIMESTAMP(6) NULL DEFAULT NULL AFTER is_active,
    ADD COLUMN valid_until TIMESTAMP(6) NULL DEFAULT NULL AFTER valid_from,
    ADD CONSTRAINT chk_pp_usm_user_roles_valid_window
        CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until > valid_from);

ALTER TABLE pp_usm_user_roles
    DROP INDEX idx_pp_usm_user_roles_user_active,
    ADD INDEX idx_pp_usm_user_roles_user_active_validity (user_id, is_active, valid_from, valid_until);

ALTER TABLE pp_usm_user_role_audits
    ADD COLUMN previous_valid_from TIMESTAMP(6) NULL DEFAULT NULL AFTER new_active,
    ADD COLUMN previous_valid_until TIMESTAMP(6) NULL DEFAULT NULL AFTER previous_valid_from,
    ADD COLUMN new_valid_from TIMESTAMP(6) NULL DEFAULT NULL AFTER previous_valid_until,
    ADD COLUMN new_valid_until TIMESTAMP(6) NULL DEFAULT NULL AFTER new_valid_from;

ALTER TABLE pp_usm_user_role_audits
    DROP CHECK chk_pp_usm_user_role_audits_event_type,
    ADD CONSTRAINT chk_pp_usm_user_role_audits_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'VALIDITY_CHANGED', 'REVOKED', 'MIGRATED')),
    ADD CONSTRAINT chk_pp_usm_user_role_audits_previous_valid_window
        CHECK (previous_valid_until IS NULL OR previous_valid_from IS NULL OR previous_valid_until > previous_valid_from),
    ADD CONSTRAINT chk_pp_usm_user_role_audits_new_valid_window
        CHECK (new_valid_until IS NULL OR new_valid_from IS NULL OR new_valid_until > new_valid_from);

DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_au;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ad;

DELIMITER $$

CREATE TRIGGER trg_pp_usm_user_roles_ai
AFTER INSERT ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_user_role_audits
        (user_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
         NULL, NULL, NEW.valid_from, NEW.valid_until,
         LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

CREATE TRIGGER trg_pp_usm_user_roles_au
AFTER UPDATE ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.valid_from <=> NEW.valid_from)
        OR NOT (OLD.valid_until <=> NEW.valid_until) THEN
        INSERT INTO pp_usm_user_role_audits
            (user_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.role_code,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NEW.is_active THEN 'ACTIVATED'
                 WHEN NOT (OLD.is_active <=> NEW.is_active) THEN 'DEACTIVATED'
                 ELSE 'VALIDITY_CHANGED'
             END,
             OLD.is_active, NEW.is_active,
             OLD.valid_from, OLD.valid_until, NEW.valid_from, NEW.valid_until,
             LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100),
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             LEFT(@rbac_audit_reason, 255),
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END$$

CREATE TRIGGER trg_pp_usm_user_roles_ad
AFTER DELETE ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_user_role_audits
        (user_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (OLD.user_id, OLD.role_code, 'REVOKED', OLD.is_active, NULL,
         OLD.valid_from, OLD.valid_until, NULL, NULL,
         LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

DELIMITER ;
