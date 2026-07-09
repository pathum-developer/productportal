-- Section 16 RBAC assignment audit migration.
-- Adds append-only audit history for user-role and role-permission assignment changes.

CREATE TABLE IF NOT EXISTS pp_usm_user_role_audits
(
    audit_id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED NOT NULL,
    role_code       VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    event_type      VARCHAR(30)     NOT NULL,
    previous_active BOOLEAN         NULL,
    new_active      BOOLEAN         NULL,
    previous_valid_from  TIMESTAMP(6) NULL DEFAULT NULL,
    previous_valid_until TIMESTAMP(6) NULL DEFAULT NULL,
    new_valid_from       TIMESTAMP(6) NULL DEFAULT NULL,
    new_valid_until      TIMESTAMP(6) NULL DEFAULT NULL,
    assigned_by     VARCHAR(100)    NULL     DEFAULT NULL,
    assigned_reason VARCHAR(255)    NULL,
    revoked_by      VARCHAR(100)    NULL     DEFAULT NULL,
    revoked_reason  VARCHAR(255)    NULL,
    changed_at      TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    changed_by      VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    database_user   VARCHAR(100)    NOT NULL DEFAULT 'UNKNOWN',
    source_code     VARCHAR(30)     NOT NULL DEFAULT 'DATABASE_TRIGGER',
    change_reason   VARCHAR(255)    NULL,
    correlation_id  VARCHAR(100)    NULL,

    CONSTRAINT pk_pp_usm_user_role_audits PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_usm_user_role_audits_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'VALIDITY_CHANGED', 'REVOKED', 'MIGRATED')),
    CONSTRAINT chk_pp_usm_user_role_audits_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_database_user_not_blank
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_source_code_not_blank
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),
    CONSTRAINT chk_pp_usm_user_role_audits_previous_valid_window
        CHECK (previous_valid_until IS NULL OR previous_valid_from IS NULL OR previous_valid_until > previous_valid_from),
    CONSTRAINT chk_pp_usm_user_role_audits_new_valid_window
        CHECK (new_valid_until IS NULL OR new_valid_from IS NULL OR new_valid_until > new_valid_from),

    INDEX idx_pp_usm_user_role_audits_user_time (user_id, changed_at),
    INDEX idx_pp_usm_user_role_audits_role_time (role_code, changed_at),
    INDEX idx_pp_usm_user_role_audits_event_time (event_type, changed_at),
    INDEX idx_pp_usm_user_role_audits_correlation_id (correlation_id),
    INDEX idx_pp_usm_user_role_audits_assigned_by (assigned_by),
    INDEX idx_pp_usm_user_role_audits_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_usm_role_permission_audits
(
    audit_id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    role_code       VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    permission_code VARCHAR(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    event_type      VARCHAR(30)     NOT NULL,
    previous_active BOOLEAN         NULL,
    new_active      BOOLEAN         NULL,
    assigned_by     VARCHAR(100)    NULL     DEFAULT NULL,
    assigned_reason VARCHAR(255)    NULL,
    revoked_by      VARCHAR(100)    NULL     DEFAULT NULL,
    revoked_reason  VARCHAR(255)    NULL,
    changed_at      TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    changed_by      VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    database_user   VARCHAR(100)    NOT NULL DEFAULT 'UNKNOWN',
    source_code     VARCHAR(30)     NOT NULL DEFAULT 'DATABASE_TRIGGER',
    change_reason   VARCHAR(255)    NULL,
    correlation_id  VARCHAR(100)    NULL,

    CONSTRAINT pk_pp_usm_role_permission_audits PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_usm_role_permission_audits_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'REVOKED', 'MIGRATED')),
    CONSTRAINT chk_pp_usm_role_permission_audits_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_database_user_not_blank
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_source_code_not_blank
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_usm_role_permission_audits_role_time (role_code, changed_at),
    INDEX idx_pp_usm_role_permission_audits_permission_time (permission_code, changed_at),
    INDEX idx_pp_usm_role_permission_audits_event_time (event_type, changed_at),
    INDEX idx_pp_usm_role_permission_audits_correlation_id (correlation_id),
    INDEX idx_pp_usm_role_permission_audits_assigned_by (assigned_by),
    INDEX idx_pp_usm_role_permission_audits_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

INSERT INTO pp_usm_user_role_audits
    (user_id, role_code, event_type, previous_active, new_active,
     previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
     assigned_by, assigned_reason, revoked_by, revoked_reason, changed_at,
     changed_by, database_user, source_code, change_reason)
SELECT
    ur.user_id,
    ur.role_code,
    'MIGRATED',
    NULL,
    ur.is_active,
    NULL,
    NULL,
    ur.valid_from,
    ur.valid_until,
    ur.assigned_by,
    ur.assigned_reason,
    ur.revoked_by,
    ur.revoked_reason,
    ur.created_at,
    ur.created_by,
    'MIGRATION',
    'MIGRATION',
    'Baseline RBAC user-role assignment backfill.'
FROM pp_usm_user_roles ur
WHERE NOT EXISTS (
    SELECT 1
    FROM pp_usm_user_role_audits audit
    WHERE audit.user_id = ur.user_id
      AND audit.role_code = ur.role_code
      AND audit.event_type = 'MIGRATED'
);

INSERT INTO pp_usm_role_permission_audits
    (role_code, permission_code, event_type, previous_active, new_active,
     assigned_by, assigned_reason, revoked_by, revoked_reason, changed_at,
     changed_by, database_user, source_code, change_reason)
SELECT
    rp.role_code,
    rp.permission_code,
    'MIGRATED',
    NULL,
    rp.is_active,
    rp.assigned_by,
    rp.assigned_reason,
    rp.revoked_by,
    rp.revoked_reason,
    rp.created_at,
    rp.created_by,
    'MIGRATION',
    'MIGRATION',
    'Baseline RBAC role-permission assignment backfill.'
FROM pp_usm_role_permissions rp
WHERE NOT EXISTS (
    SELECT 1
    FROM pp_usm_role_permission_audits audit
    WHERE audit.role_code = rp.role_code
      AND audit.permission_code = rp.permission_code
      AND audit.event_type = 'MIGRATED'
);

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
