-- Section 16 RBAC workflow context migration.
-- Adds explicit assigned/revoked actor and reason fields for RBAC assignment workflows.

ALTER TABLE pp_usm_user_roles
    ADD COLUMN assigned_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM' AFTER valid_until,
    ADD COLUMN assigned_reason VARCHAR(255) NULL AFTER assigned_by,
    ADD COLUMN revoked_by VARCHAR(100) NULL DEFAULT NULL AFTER assigned_reason,
    ADD COLUMN revoked_reason VARCHAR(255) NULL AFTER revoked_by,
    ADD CONSTRAINT chk_pp_usm_user_roles_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_roles_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_roles_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_roles_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> '');

ALTER TABLE pp_usm_user_roles
    ADD INDEX idx_pp_usm_user_roles_assigned_by (assigned_by),
    ADD INDEX idx_pp_usm_user_roles_revoked_by (revoked_by);

ALTER TABLE pp_usm_role_permissions
    ADD COLUMN assigned_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM' AFTER is_active,
    ADD COLUMN assigned_reason VARCHAR(255) NULL AFTER assigned_by,
    ADD COLUMN revoked_by VARCHAR(100) NULL DEFAULT NULL AFTER assigned_reason,
    ADD COLUMN revoked_reason VARCHAR(255) NULL AFTER revoked_by,
    ADD CONSTRAINT chk_pp_usm_role_permissions_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permissions_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permissions_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permissions_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> '');

ALTER TABLE pp_usm_role_permissions
    ADD INDEX idx_pp_usm_role_permissions_assigned_by (assigned_by),
    ADD INDEX idx_pp_usm_role_permissions_revoked_by (revoked_by);

ALTER TABLE pp_usm_user_role_audits
    ADD COLUMN assigned_by VARCHAR(100) NULL DEFAULT NULL AFTER new_valid_until,
    ADD COLUMN assigned_reason VARCHAR(255) NULL AFTER assigned_by,
    ADD COLUMN revoked_by VARCHAR(100) NULL DEFAULT NULL AFTER assigned_reason,
    ADD COLUMN revoked_reason VARCHAR(255) NULL AFTER revoked_by,
    ADD CONSTRAINT chk_pp_usm_user_role_audits_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_role_audits_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_role_audits_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_user_role_audits_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> '');

ALTER TABLE pp_usm_user_role_audits
    ADD INDEX idx_pp_usm_user_role_audits_assigned_by (assigned_by),
    ADD INDEX idx_pp_usm_user_role_audits_revoked_by (revoked_by);

ALTER TABLE pp_usm_role_permission_audits
    ADD COLUMN assigned_by VARCHAR(100) NULL DEFAULT NULL AFTER new_active,
    ADD COLUMN assigned_reason VARCHAR(255) NULL AFTER assigned_by,
    ADD COLUMN revoked_by VARCHAR(100) NULL DEFAULT NULL AFTER assigned_reason,
    ADD COLUMN revoked_reason VARCHAR(255) NULL AFTER revoked_by,
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> '');

ALTER TABLE pp_usm_role_permission_audits
    ADD INDEX idx_pp_usm_role_permission_audits_assigned_by (assigned_by),
    ADD INDEX idx_pp_usm_role_permission_audits_revoked_by (revoked_by);

UPDATE pp_usm_user_roles
SET assigned_by = COALESCE(NULLIF(created_by, ''), 'SYSTEM')
WHERE assigned_by = 'SYSTEM';

UPDATE pp_usm_role_permissions
SET assigned_by = COALESCE(NULLIF(created_by, ''), 'SYSTEM')
WHERE assigned_by = 'SYSTEM';

UPDATE pp_usm_user_role_audits
SET assigned_by = changed_by,
    assigned_reason = change_reason
WHERE event_type IN ('ASSIGNED', 'ACTIVATED', 'MIGRATED')
  AND assigned_by IS NULL;

UPDATE pp_usm_user_role_audits
SET revoked_by = changed_by,
    revoked_reason = change_reason
WHERE event_type IN ('DEACTIVATED', 'REVOKED')
  AND revoked_by IS NULL;

UPDATE pp_usm_role_permission_audits
SET assigned_by = changed_by,
    assigned_reason = change_reason
WHERE event_type IN ('ASSIGNED', 'ACTIVATED', 'MIGRATED')
  AND assigned_by IS NULL;

UPDATE pp_usm_role_permission_audits
SET revoked_by = changed_by,
    revoked_reason = change_reason
WHERE event_type IN ('DEACTIVATED', 'REVOKED')
  AND revoked_by IS NULL;

DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_au;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ad;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_au;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ad;

DELIMITER $$

CREATE TRIGGER trg_pp_usm_user_roles_ai
AFTER INSERT ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_user_role_audits
        (user_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
         NULL, NULL, NEW.valid_from, NEW.valid_until,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255),
         NULL,
         NULL,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255),
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
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
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
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_reason, NEW.revoked_reason, @rbac_audit_reason), 255)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.assigned_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, NEW.revoked_reason), 255)
                 ELSE LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255)
             END,
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END$$

CREATE TRIGGER trg_pp_usm_user_roles_ad
AFTER DELETE ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_user_role_audits
        (user_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (OLD.user_id, OLD.role_code, 'REVOKED', OLD.is_active, NULL,
         OLD.valid_from, OLD.valid_until, NULL, NULL,
         OLD.assigned_by,
         OLD.assigned_reason,
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_revoked_reason, OLD.revoked_reason, @rbac_audit_reason), 255),
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, OLD.revoked_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

CREATE TRIGGER trg_pp_usm_role_permissions_ai
AFTER INSERT ON pp_usm_role_permissions
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_role_permission_audits
        (role_code, permission_code, event_type, previous_active, new_active,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.role_code, NEW.permission_code, 'ASSIGNED', NULL, NEW.is_active,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255),
         NULL,
         NULL,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

CREATE TRIGGER trg_pp_usm_role_permissions_au
AFTER UPDATE ON pp_usm_role_permissions
FOR EACH ROW
BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active) THEN
        INSERT INTO pp_usm_role_permission_audits
            (role_code, permission_code, event_type, previous_active, new_active,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.role_code, NEW.permission_code,
             CASE WHEN NEW.is_active THEN 'ACTIVATED' ELSE 'DEACTIVATED' END,
             OLD.is_active, NEW.is_active,
             CASE
                 WHEN NEW.is_active THEN LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NEW.is_active THEN LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_reason, NEW.revoked_reason, @rbac_audit_reason), 255)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.assigned_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             CASE
                 WHEN NOT NEW.is_active THEN LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, NEW.revoked_reason), 255)
                 ELSE LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255)
             END,
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END$$

CREATE TRIGGER trg_pp_usm_role_permissions_ad
AFTER DELETE ON pp_usm_role_permissions
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_role_permission_audits
        (role_code, permission_code, event_type, previous_active, new_active,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (OLD.role_code, OLD.permission_code, 'REVOKED', OLD.is_active, NULL,
         OLD.assigned_by,
         OLD.assigned_reason,
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_revoked_reason, OLD.revoked_reason, @rbac_audit_reason), 255),
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, OLD.revoked_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

DELIMITER ;
