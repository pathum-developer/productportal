-- Section 16 RBAC organization memberships migration.
-- Separates organization membership from organization-scoped role assignment.

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

CREATE TABLE IF NOT EXISTS pp_org_membership_statuses
(
    status_code  VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_org_membership_statuses PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_org_membership_statuses_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_org_membership_statuses_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_org_membership_statuses_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_org_membership_statuses_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

INSERT IGNORE INTO pp_org_membership_statuses
    (status_code, display_name, description, sort_order)
VALUES
    ('INVITED', 'Invited', 'User has been invited to the organization but has not joined yet.', 1),
    ('ACTIVE', 'Active', 'User is an active member of the organization.', 2),
    ('SUSPENDED', 'Suspended', 'User membership is temporarily blocked in the organization.', 3),
    ('LEFT', 'Left', 'User left the organization voluntarily.', 4),
    ('REMOVED', 'Removed', 'User was removed from the organization.', 5);

ALTER TABLE pp_usm_users
    ADD COLUMN primary_organization_id BIGINT UNSIGNED NULL DEFAULT NULL AFTER status,
    ADD INDEX idx_pp_usm_users_primary_organization_id (primary_organization_id),
    ADD CONSTRAINT fk_pp_usm_users_primary_organization
        FOREIGN KEY (primary_organization_id) REFERENCES pp_org_organizations (organization_id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS pp_org_user_memberships
(
    user_id           BIGINT UNSIGNED NOT NULL,
    organization_id   BIGINT UNSIGNED NOT NULL,
    membership_status VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE',
    is_primary        BOOLEAN         NOT NULL DEFAULT FALSE,
    joined_at         TIMESTAMP(6)    NULL     DEFAULT NULL,
    invited_by        VARCHAR(100)    NULL     DEFAULT NULL,
    invited_at        TIMESTAMP(6)    NULL     DEFAULT NULL,
    created_at        TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by        VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at        TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by        VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_org_user_memberships PRIMARY KEY (user_id, organization_id),
    CONSTRAINT fk_pp_org_user_memberships_user
        FOREIGN KEY (user_id) REFERENCES pp_usm_users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_org_user_memberships_organization
        FOREIGN KEY (organization_id) REFERENCES pp_org_organizations (organization_id),
    CONSTRAINT fk_pp_org_user_memberships_status
        FOREIGN KEY (membership_status) REFERENCES pp_org_membership_statuses (status_code),
    CONSTRAINT chk_pp_org_user_memberships_invited_by_not_blank
        CHECK (invited_by IS NULL OR TRIM(invited_by) <> ''),

    INDEX idx_pp_org_user_memberships_status (membership_status),
    INDEX idx_pp_org_user_memberships_org_status (organization_id, membership_status),
    INDEX idx_pp_org_user_memberships_user_status (user_id, membership_status),
    INDEX idx_pp_org_user_memberships_primary (user_id, is_primary),
    INDEX idx_pp_org_user_memberships_invited_by (invited_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_org_user_membership_audits
(
    audit_id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id                    BIGINT UNSIGNED NOT NULL,
    organization_id            BIGINT UNSIGNED NOT NULL,
    event_type                 VARCHAR(30)     NOT NULL,
    previous_membership_status VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    new_membership_status      VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    previous_primary           BOOLEAN         NULL,
    new_primary                BOOLEAN         NULL,
    previous_joined_at         TIMESTAMP(6)    NULL DEFAULT NULL,
    new_joined_at              TIMESTAMP(6)    NULL DEFAULT NULL,
    previous_invited_by        VARCHAR(100)    NULL DEFAULT NULL,
    new_invited_by             VARCHAR(100)    NULL DEFAULT NULL,
    previous_invited_at        TIMESTAMP(6)    NULL DEFAULT NULL,
    new_invited_at             TIMESTAMP(6)    NULL DEFAULT NULL,
    changed_at                 TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    changed_by                 VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    database_user              VARCHAR(100)    NOT NULL DEFAULT 'UNKNOWN',
    source_code                VARCHAR(30)     NOT NULL DEFAULT 'DATABASE_TRIGGER',
    change_reason              VARCHAR(255)    NULL,
    correlation_id             VARCHAR(100)    NULL,

    CONSTRAINT pk_pp_org_user_membership_audits PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_org_user_membership_audits_event_type
        CHECK (event_type IN ('INVITED', 'JOINED', 'ACTIVATED', 'SUSPENDED', 'LEFT', 'REMOVED',
                              'PRIMARY_CHANGED', 'DETAILS_CHANGED', 'MIGRATED')),
    CONSTRAINT chk_pp_org_user_membership_audits_previous_status_not_blank
        CHECK (previous_membership_status IS NULL OR TRIM(previous_membership_status) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_new_status_not_blank
        CHECK (new_membership_status IS NULL OR TRIM(new_membership_status) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_database_user_not_blank
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_source_code_not_blank
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_previous_invited_by_not_blank
        CHECK (previous_invited_by IS NULL OR TRIM(previous_invited_by) <> ''),
    CONSTRAINT chk_pp_org_user_membership_audits_new_invited_by_not_blank
        CHECK (new_invited_by IS NULL OR TRIM(new_invited_by) <> ''),

    INDEX idx_pp_org_user_membership_audits_user_org_time (user_id, organization_id, changed_at),
    INDEX idx_pp_org_user_membership_audits_org_time (organization_id, changed_at),
    INDEX idx_pp_org_user_membership_audits_event_time (event_type, changed_at),
    INDEX idx_pp_org_user_membership_audits_correlation_id (correlation_id),
    INDEX idx_pp_org_user_membership_audits_changed_by (changed_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_ai;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_au;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_ad;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_bi;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_bu;

DELIMITER $$

CREATE TRIGGER trg_pp_org_user_memberships_bi
BEFORE INSERT ON pp_org_user_memberships
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_org_user_memberships existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END$$

CREATE TRIGGER trg_pp_org_user_memberships_bu
BEFORE UPDATE ON pp_org_user_memberships
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_org_user_memberships existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
             AND NOT (existing_membership.user_id <=> OLD.user_id
                      AND existing_membership.organization_id <=> OLD.organization_id)
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END$$

CREATE TRIGGER trg_pp_org_user_memberships_ai
AFTER INSERT ON pp_org_user_memberships
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_usm_users
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    END IF;

    INSERT INTO pp_org_user_membership_audits
        (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
         previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
         new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
         source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.organization_id,
         LEFT(COALESCE(@org_membership_event_type,
              CASE
                  WHEN NEW.membership_status = 'INVITED' THEN 'INVITED'
                  WHEN NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                  WHEN NEW.membership_status = 'LEFT' THEN 'LEFT'
                  WHEN NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                  ELSE 'JOINED'
              END), 30),
         NULL, NEW.membership_status,
         NULL, NEW.is_primary,
         NULL, NEW.joined_at,
         NULL, NEW.invited_by,
         NULL, NEW.invited_at,
         LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, NEW.invited_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

CREATE TRIGGER trg_pp_org_user_memberships_au
AFTER UPDATE ON pp_org_user_memberships
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_usm_users
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    ELSEIF OLD.is_primary
        AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_usm_users
        SET primary_organization_id = NULL,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND primary_organization_id = OLD.organization_id;
    END IF;

    IF NOT (OLD.membership_status <=> NEW.membership_status)
        OR NOT (OLD.is_primary <=> NEW.is_primary)
        OR NOT (OLD.joined_at <=> NEW.joined_at)
        OR NOT (OLD.invited_by <=> NEW.invited_by)
        OR NOT (OLD.invited_at <=> NEW.invited_at) THEN
        INSERT INTO pp_org_user_membership_audits
            (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
             previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
             new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
             source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id,
             CASE
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'ACTIVE' THEN 'ACTIVATED'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'LEFT' THEN 'LEFT'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                 WHEN NOT (OLD.is_primary <=> NEW.is_primary) THEN 'PRIMARY_CHANGED'
                 ELSE 'DETAILS_CHANGED'
             END,
             OLD.membership_status, NEW.membership_status,
             OLD.is_primary, NEW.is_primary,
             OLD.joined_at, NEW.joined_at,
             OLD.invited_by, NEW.invited_by,
             OLD.invited_at, NEW.invited_at,
             LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100),
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             LEFT(@rbac_audit_reason, 255),
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END$$

CREATE TRIGGER trg_pp_org_user_memberships_ad
AFTER DELETE ON pp_org_user_memberships
FOR EACH ROW
BEGIN
    IF OLD.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_usm_users
        SET primary_organization_id = NULL,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100)
        WHERE user_id = OLD.user_id
          AND primary_organization_id = OLD.organization_id;
    END IF;

    INSERT INTO pp_org_user_membership_audits
        (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
         previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
         new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
         source_code, change_reason, correlation_id)
    VALUES
        (OLD.user_id, OLD.organization_id, 'REMOVED',
         OLD.membership_status, NULL,
         OLD.is_primary, NULL,
         OLD.joined_at, NULL,
         OLD.invited_by, NULL,
         OLD.invited_at, NULL,
         LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END$$

DELIMITER ;

SET @org_membership_event_type = 'MIGRATED';
SET @org_membership_skip_user_sync = TRUE;
SET @rbac_audit_actor = 'SYSTEM';
SET @rbac_audit_reason = 'Migrated from existing organization-scoped role assignments.';

INSERT IGNORE INTO pp_org_user_memberships
    (user_id, organization_id, membership_status, is_primary, joined_at, created_by)
SELECT existing_role_orgs.user_id,
       existing_role_orgs.organization_id,
       CASE user_account.status
           WHEN 'SUSPENDED' THEN 'SUSPENDED'
           WHEN 'DELETED' THEN 'REMOVED'
           ELSE 'ACTIVE'
       END,
       existing_role_orgs.organization_id = primary_role_org.organization_id,
       COALESCE(user_account.created_at, CURRENT_TIMESTAMP(6)),
       'SYSTEM'
FROM (
    SELECT DISTINCT user_id, organization_id
    FROM pp_usm_user_roles
) existing_role_orgs
JOIN (
    SELECT user_id, MIN(organization_id) AS organization_id
    FROM pp_usm_user_roles
    GROUP BY user_id
) primary_role_org
    ON primary_role_org.user_id = existing_role_orgs.user_id
JOIN pp_usm_users user_account
    ON user_account.user_id = existing_role_orgs.user_id;

INSERT IGNORE INTO pp_org_user_memberships
    (user_id, organization_id, membership_status, is_primary, joined_at, created_by)
SELECT user_account.user_id,
       COALESCE(user_account.primary_organization_id, 1),
       CASE user_account.status
           WHEN 'SUSPENDED' THEN 'SUSPENDED'
           WHEN 'DELETED' THEN 'REMOVED'
           ELSE 'ACTIVE'
       END,
       TRUE,
       COALESCE(user_account.created_at, CURRENT_TIMESTAMP(6)),
       'SYSTEM'
FROM pp_usm_users user_account
WHERE NOT EXISTS (
    SELECT 1
    FROM pp_org_user_memberships membership
    WHERE membership.user_id = user_account.user_id
);

SET @org_membership_event_type = NULL;
SET @org_membership_skip_user_sync = NULL;
SET @rbac_audit_actor = NULL;
SET @rbac_audit_reason = NULL;

UPDATE pp_usm_users user_account
JOIN pp_org_user_memberships membership
    ON membership.user_id = user_account.user_id
   AND membership.is_primary = TRUE
SET user_account.primary_organization_id = membership.organization_id
WHERE NOT (user_account.primary_organization_id <=> membership.organization_id);

ALTER TABLE pp_usm_user_roles
    ADD CONSTRAINT fk_pp_usm_user_roles_membership
        FOREIGN KEY (user_id, organization_id) REFERENCES pp_org_user_memberships (user_id, organization_id);
