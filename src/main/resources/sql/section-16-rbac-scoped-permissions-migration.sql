-- Section 16 RBAC scoped permissions migration.
-- Adds permission scopes and product ownership for resource-level authorization checks.

CREATE TABLE IF NOT EXISTS pp_usm_permission_scopes
(
    scope_code   VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_permission_scopes PRIMARY KEY (scope_code),
    CONSTRAINT uk_pp_usm_permission_scopes_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_usm_permission_scopes_code_not_blank
        CHECK (TRIM(scope_code) <> ''),
    CONSTRAINT chk_pp_usm_permission_scopes_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_usm_permission_scopes_sort_order_positive
        CHECK (sort_order > 0),

    INDEX idx_pp_usm_permission_scopes_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

INSERT IGNORE INTO pp_usm_permission_scopes
    (scope_code, display_name, description, sort_order)
VALUES
    ('SELF', 'Self', 'Permission applies only to the current user account or profile.', 1),
    ('OWNED', 'Owned Resource', 'Permission applies only to resources owned by the current user.', 2),
    ('ORGANIZATION', 'Organization', 'Permission applies to resources inside the selected organization.', 3),
    ('GLOBAL', 'Global', 'Permission applies across all organizations in the platform.', 4);

DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_au;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ad;

ALTER TABLE pp_usm_role_permissions
    ADD COLUMN scope_code VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
        NOT NULL DEFAULT 'ORGANIZATION' AFTER permission_code,
    ADD CONSTRAINT chk_pp_usm_role_permissions_scope_code_not_blank
        CHECK (TRIM(scope_code) <> '');

UPDATE pp_usm_role_permissions
SET scope_code = 'SELF'
WHERE permission_code IN ('PROFILE_READ', 'PROFILE_UPDATE', 'ADDRESS_MANAGE');

UPDATE pp_usm_role_permissions
SET scope_code = 'OWNED'
WHERE role_code = 'SELLER'
  AND permission_code = 'PRODUCT_UPDATE';

UPDATE pp_usm_role_permissions
SET scope_code = 'ORGANIZATION'
WHERE scope_code NOT IN ('SELF', 'OWNED');

ALTER TABLE pp_usm_role_permissions
    ADD INDEX idx_pp_usm_role_permissions_scope_code (scope_code),
    ADD INDEX idx_pp_usm_role_permissions_permission_scope_active (permission_code, scope_code, is_active),
    ADD CONSTRAINT fk_pp_usm_role_permissions_scope
        FOREIGN KEY (scope_code) REFERENCES pp_usm_permission_scopes (scope_code);

ALTER TABLE pp_usm_role_permission_audits
    ADD COLUMN previous_scope_code VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
        NULL DEFAULT NULL AFTER new_active,
    ADD COLUMN new_scope_code VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci
        NULL DEFAULT NULL AFTER previous_scope_code,
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_previous_scope_code_not_blank
        CHECK (previous_scope_code IS NULL OR TRIM(previous_scope_code) <> ''),
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_new_scope_code_not_blank
        CHECK (new_scope_code IS NULL OR TRIM(new_scope_code) <> '');

ALTER TABLE pp_usm_role_permission_audits
    DROP CHECK chk_pp_usm_role_permission_audits_event_type,
    ADD CONSTRAINT chk_pp_usm_role_permission_audits_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'SCOPE_CHANGED', 'REVOKED', 'MIGRATED')),
    ADD INDEX idx_pp_usm_role_permission_audits_scope_time (new_scope_code, changed_at);

UPDATE pp_usm_role_permission_audits audit
JOIN pp_usm_role_permissions permission
    ON permission.role_code = audit.role_code
   AND permission.permission_code = audit.permission_code
SET audit.new_scope_code = permission.scope_code
WHERE audit.event_type IN ('ASSIGNED', 'ACTIVATED', 'MIGRATED')
  AND audit.new_scope_code IS NULL;

UPDATE pp_usm_role_permission_audits audit
JOIN pp_usm_role_permissions permission
    ON permission.role_code = audit.role_code
   AND permission.permission_code = audit.permission_code
SET audit.previous_scope_code = permission.scope_code
WHERE audit.event_type IN ('DEACTIVATED', 'REVOKED')
  AND audit.previous_scope_code IS NULL;

ALTER TABLE pp_m_products
    ADD COLUMN owner_user_id BIGINT UNSIGNED NULL AFTER organization_id,
    ADD INDEX idx_pp_m_products_owner_user_id (owner_user_id),
    ADD INDEX idx_pp_m_products_org_owner_status (organization_id, owner_user_id, status_code),
    ADD CONSTRAINT fk_pp_m_products_owner_user
        FOREIGN KEY (owner_user_id) REFERENCES pp_usm_users (user_id) ON DELETE SET NULL;

UPDATE pp_m_products
SET owner_user_id = CASE
        WHEN product_id BETWEEN 3001 AND 3008 THEN 5003
        WHEN product_id BETWEEN 3009 AND 3015 THEN 5004
        ELSE owner_user_id
    END
WHERE owner_user_id IS NULL;

DELIMITER $$

CREATE TRIGGER trg_pp_usm_role_permissions_ai
AFTER INSERT ON pp_usm_role_permissions
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_role_permission_audits
        (role_code, permission_code, event_type, previous_active, new_active,
         previous_scope_code, new_scope_code,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.role_code, NEW.permission_code, 'ASSIGNED', NULL, NEW.is_active,
         NULL, NEW.scope_code,
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
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.scope_code <=> NEW.scope_code) THEN
        INSERT INTO pp_usm_role_permission_audits
            (role_code, permission_code, event_type, previous_active, new_active,
             previous_scope_code, new_scope_code,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.role_code, NEW.permission_code,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NEW.is_active THEN 'ACTIVATED'
                 WHEN NOT (OLD.is_active <=> NEW.is_active) THEN 'DEACTIVATED'
                 ELSE 'SCOPE_CHANGED'
             END,
             OLD.is_active, NEW.is_active,
             OLD.scope_code, NEW.scope_code,
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

CREATE TRIGGER trg_pp_usm_role_permissions_ad
AFTER DELETE ON pp_usm_role_permissions
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_role_permission_audits
        (role_code, permission_code, event_type, previous_active, new_active,
         previous_scope_code, new_scope_code,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (OLD.role_code, OLD.permission_code, 'REVOKED', OLD.is_active, NULL,
         OLD.scope_code, NULL,
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
