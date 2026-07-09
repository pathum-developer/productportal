-- Section 16 RBAC tenant/organization scope migration.
-- Preserves existing single-tenant data under organization_id = 1.

CREATE TABLE IF NOT EXISTS pp_org_organizations
(
    organization_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    organization_code VARCHAR(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    display_name      VARCHAR(150)     NOT NULL,
    legal_name        VARCHAR(200)     NULL,
    description       VARCHAR(255)     NULL,
    is_active         BOOLEAN          NOT NULL DEFAULT TRUE,
    version           BIGINT UNSIGNED  NOT NULL DEFAULT 0,
    created_at        TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by        VARCHAR(100)     NOT NULL DEFAULT 'SYSTEM',
    updated_at        TIMESTAMP(6)     NULL     DEFAULT NULL,
    updated_by        VARCHAR(100)     NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_org_organizations PRIMARY KEY (organization_id),
    CONSTRAINT uk_pp_org_organizations_code UNIQUE (organization_code),
    CONSTRAINT uk_pp_org_organizations_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_org_organizations_code_not_blank
        CHECK (TRIM(organization_code) <> ''),
    CONSTRAINT chk_pp_org_organizations_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_org_organizations_legal_name_not_blank
        CHECK (legal_name IS NULL OR TRIM(legal_name) <> ''),

    INDEX idx_pp_org_organizations_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

INSERT INTO pp_org_organizations
    (organization_id, organization_code, display_name, legal_name, description, created_by)
VALUES
    (1, 'DEFAULT', 'Default Organization', 'Product Portal',
     'Default organization for existing single-tenant product portal data.', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    legal_name = VALUES(legal_name),
    description = VALUES(description),
    updated_by = 'SYSTEM';

DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_au;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ad;

ALTER TABLE pp_usm_user_roles
    ADD COLUMN organization_id BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER user_id;

ALTER TABLE pp_usm_user_roles
    DROP PRIMARY KEY,
    DROP INDEX idx_pp_usm_user_roles_user_active_validity,
    ADD PRIMARY KEY (user_id, organization_id, role_code),
    ADD INDEX idx_pp_usm_user_roles_user_org_active_validity (user_id, organization_id, is_active, valid_from, valid_until),
    ADD INDEX idx_pp_usm_user_roles_org_role_active (organization_id, role_code, is_active),
    ADD CONSTRAINT fk_pp_usm_user_roles_organization
        FOREIGN KEY (organization_id) REFERENCES pp_org_organizations (organization_id);

ALTER TABLE pp_usm_user_role_audits
    ADD COLUMN organization_id BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER user_id;

ALTER TABLE pp_usm_user_role_audits
    DROP INDEX idx_pp_usm_user_role_audits_user_time,
    ADD INDEX idx_pp_usm_user_role_audits_user_org_time (user_id, organization_id, changed_at),
    ADD INDEX idx_pp_usm_user_role_audits_org_time (organization_id, changed_at);

ALTER TABLE pp_m_products
    ADD COLUMN organization_id BIGINT UNSIGNED NOT NULL DEFAULT 1 AFTER product_id;

ALTER TABLE pp_m_products
    DROP INDEX uk_pp_m_products_slug,
    DROP INDEX uk_pp_m_products_sku_code,
    ADD UNIQUE KEY uk_pp_m_products_org_slug (organization_id, slug),
    ADD UNIQUE KEY uk_pp_m_products_org_sku_code (organization_id, sku_code),
    ADD INDEX idx_pp_m_products_organization_id (organization_id),
    ADD INDEX idx_pp_m_products_org_status (organization_id, status_code),
    ADD INDEX idx_pp_m_products_org_category_status (organization_id, category_id, status_code),
    ADD CONSTRAINT fk_pp_m_products_organization
        FOREIGN KEY (organization_id) REFERENCES pp_org_organizations (organization_id);

DELIMITER $$

CREATE TRIGGER trg_pp_usm_user_roles_ai
AFTER INSERT ON pp_usm_user_roles
FOR EACH ROW
BEGIN
    INSERT INTO pp_usm_user_role_audits
        (user_id, organization_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.organization_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
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
            (user_id, organization_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id, NEW.role_code,
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
        (user_id, organization_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (OLD.user_id, OLD.organization_id, OLD.role_code, 'REVOKED', OLD.is_active, NULL,
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

DELIMITER ;
