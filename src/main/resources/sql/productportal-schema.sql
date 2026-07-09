-- User-domain tables are dropped in reverse dependency order for local schema rebuilds.
-- In production, apply equivalent changes through Flyway/Liquibase migrations instead.
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_au;
DROP TRIGGER IF EXISTS trg_pp_usm_user_roles_ad;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_ai;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_au;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_ad;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_bi;
DROP TRIGGER IF EXISTS trg_pp_org_user_memberships_bu;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ai;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_au;
DROP TRIGGER IF EXISTS trg_pp_usm_role_permissions_ad;
DROP TABLE IF EXISTS pp_m_products;
DROP TABLE IF EXISTS pp_usm_addresses;
DROP TABLE IF EXISTS pp_usm_user_role_audits;
DROP TABLE IF EXISTS pp_usm_role_permission_audits;
DROP TABLE IF EXISTS pp_org_user_membership_audits;
DROP TABLE IF EXISTS pp_usm_user_roles;
DROP TABLE IF EXISTS pp_org_user_memberships;
DROP TABLE IF EXISTS pp_usm_role_permissions;
DROP TABLE IF EXISTS pp_usm_users;
DROP TABLE IF EXISTS pp_usr_user_statuses;
DROP TABLE IF EXISTS pp_org_membership_statuses;
DROP TABLE IF EXISTS pp_usm_permission_scopes;
DROP TABLE IF EXISTS pp_usm_permissions;
DROP TABLE IF EXISTS pp_usm_roles;
DROP TABLE IF EXISTS pp_org_organizations;

CREATE TABLE IF NOT EXISTS pp_usm_roles
(
    role_code    VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_roles PRIMARY KEY (role_code),
    CONSTRAINT uk_pp_usm_roles_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_usm_roles_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_roles_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_usm_roles_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_usm_permissions
(
    permission_code VARCHAR(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    display_name    VARCHAR(150)      NOT NULL,
    description     VARCHAR(255)      NULL,
    resource_code   VARCHAR(60)       NOT NULL,
    action_code     VARCHAR(60)       NOT NULL,
    sort_order      SMALLINT UNSIGNED NOT NULL,
    is_active       BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by      VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at      TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by      VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_permissions PRIMARY KEY (permission_code),
    CONSTRAINT uk_pp_usm_permissions_display_name UNIQUE (display_name),
    CONSTRAINT uk_pp_usm_permissions_resource_action UNIQUE (resource_code, action_code),
    CONSTRAINT chk_pp_usm_permissions_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_usm_permissions_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_usm_permissions_resource_code_not_blank
        CHECK (TRIM(resource_code) <> ''),
    CONSTRAINT chk_pp_usm_permissions_action_code_not_blank
        CHECK (TRIM(action_code) <> ''),
    CONSTRAINT chk_pp_usm_permissions_sort_order_positive
        CHECK (sort_order > 0),

    INDEX idx_pp_usm_permissions_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

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

CREATE TABLE IF NOT EXISTS pp_usr_user_statuses
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

    CONSTRAINT pk_pp_usr_user_statuses PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_usr_user_statuses_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_usr_user_statuses_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_usr_user_statuses_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_usr_user_statuses_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

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

CREATE TABLE IF NOT EXISTS pp_usm_users
(
    user_id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    username                VARCHAR(100)    NOT NULL,
    full_name               VARCHAR(150)    NOT NULL,
    email                   VARCHAR(254)    NOT NULL,
    phone_number            VARCHAR(30)     NULL,
    password_hash           VARCHAR(255)    NOT NULL,
    status                  VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE',
    primary_organization_id BIGINT UNSIGNED NULL     DEFAULT NULL,
    version                 BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at              TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by              VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at              TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by              VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_users PRIMARY KEY (user_id),
    CONSTRAINT uk_pp_usm_users_username UNIQUE (username),
    CONSTRAINT uk_pp_usm_users_email UNIQUE (email),
    CONSTRAINT uk_pp_usm_users_phone_number UNIQUE (phone_number),
    CONSTRAINT fk_pp_usm_users_status
        FOREIGN KEY (status) REFERENCES pp_usr_user_statuses (status_code),
    CONSTRAINT fk_pp_usm_users_primary_organization
        FOREIGN KEY (primary_organization_id) REFERENCES pp_org_organizations (organization_id) ON DELETE SET NULL,
    CONSTRAINT chk_pp_usm_users_full_name_not_blank
        CHECK (TRIM(full_name) <> ''),
    CONSTRAINT chk_pp_usm_users_username_not_blank
        CHECK (TRIM(username) <> ''),
    CONSTRAINT chk_pp_usm_users_email_not_blank
        CHECK (TRIM(email) <> ''),
    CONSTRAINT chk_pp_usm_users_password_hash_not_blank
        CHECK (TRIM(password_hash) <> ''),
    CONSTRAINT chk_pp_usm_users_phone_number_not_blank
        CHECK (phone_number IS NULL OR TRIM(phone_number) <> ''),

    INDEX idx_pp_usm_users_status (status),
    INDEX idx_pp_usm_users_primary_organization_id (primary_organization_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

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

CREATE TABLE IF NOT EXISTS pp_usm_user_roles
(
    user_id    BIGINT UNSIGNED NOT NULL,
    organization_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
    role_code  VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    is_active  BOOLEAN         NOT NULL DEFAULT TRUE,
    valid_from TIMESTAMP(6)    NULL     DEFAULT NULL,
    valid_until TIMESTAMP(6)   NULL     DEFAULT NULL,
    assigned_by VARCHAR(100)   NOT NULL DEFAULT 'SYSTEM',
    assigned_reason VARCHAR(255) NULL,
    revoked_by VARCHAR(100)    NULL     DEFAULT NULL,
    revoked_reason VARCHAR(255) NULL,
    created_at TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_user_roles PRIMARY KEY (user_id, organization_id, role_code),
    CONSTRAINT fk_pp_usm_user_roles_user
        FOREIGN KEY (user_id) REFERENCES pp_usm_users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_usm_user_roles_organization
        FOREIGN KEY (organization_id) REFERENCES pp_org_organizations (organization_id),
    CONSTRAINT fk_pp_usm_user_roles_membership
        FOREIGN KEY (user_id, organization_id) REFERENCES pp_org_user_memberships (user_id, organization_id),
    CONSTRAINT fk_pp_usm_user_roles_role
        FOREIGN KEY (role_code) REFERENCES pp_usm_roles (role_code),
    CONSTRAINT chk_pp_usm_user_roles_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_user_roles_valid_window
        CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_pp_usm_user_roles_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_usm_user_roles_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_usm_user_roles_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_usm_user_roles_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_usm_user_roles_role_code (role_code),
    INDEX idx_pp_usm_user_roles_user_org_active_validity (user_id, organization_id, is_active, valid_from, valid_until),
    INDEX idx_pp_usm_user_roles_org_role_active (organization_id, role_code, is_active),
    INDEX idx_pp_usm_user_roles_role_active (role_code, is_active),
    INDEX idx_pp_usm_user_roles_assigned_by (assigned_by),
    INDEX idx_pp_usm_user_roles_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_usm_role_permissions
(
    role_code       VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    permission_code VARCHAR(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    scope_code      VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ORGANIZATION',
    is_active       BOOLEAN      NOT NULL DEFAULT TRUE,
    assigned_by     VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    assigned_reason VARCHAR(255) NULL,
    revoked_by      VARCHAR(100) NULL     DEFAULT NULL,
    revoked_reason  VARCHAR(255) NULL,
    created_at      TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by      VARCHAR(100) NOT NULL DEFAULT 'SYSTEM',
    updated_at      TIMESTAMP(6) NULL     DEFAULT NULL,
    updated_by      VARCHAR(100) NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_role_permissions PRIMARY KEY (role_code, permission_code),
    CONSTRAINT fk_pp_usm_role_permissions_role
        FOREIGN KEY (role_code) REFERENCES pp_usm_roles (role_code),
    CONSTRAINT fk_pp_usm_role_permissions_permission
        FOREIGN KEY (permission_code) REFERENCES pp_usm_permissions (permission_code),
    CONSTRAINT fk_pp_usm_role_permissions_scope
        FOREIGN KEY (scope_code) REFERENCES pp_usm_permission_scopes (scope_code),
    CONSTRAINT chk_pp_usm_role_permissions_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_scope_code_not_blank
        CHECK (TRIM(scope_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_usm_role_permissions_permission_code (permission_code),
    INDEX idx_pp_usm_role_permissions_scope_code (scope_code),
    INDEX idx_pp_usm_role_permissions_role_active (role_code, is_active),
    INDEX idx_pp_usm_role_permissions_permission_scope_active (permission_code, scope_code, is_active),
    INDEX idx_pp_usm_role_permissions_permission_active (permission_code, is_active),
    INDEX idx_pp_usm_role_permissions_assigned_by (assigned_by),
    INDEX idx_pp_usm_role_permissions_revoked_by (revoked_by)
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

CREATE TABLE IF NOT EXISTS pp_usm_user_role_audits
(
    audit_id        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED NOT NULL,
    organization_id BIGINT UNSIGNED NOT NULL,
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

    INDEX idx_pp_usm_user_role_audits_user_org_time (user_id, organization_id, changed_at),
    INDEX idx_pp_usm_user_role_audits_org_time (organization_id, changed_at),
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
    previous_scope_code VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
    new_scope_code      VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
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
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'SCOPE_CHANGED', 'REVOKED', 'MIGRATED')),
    CONSTRAINT chk_pp_usm_role_permission_audits_previous_scope_code_not_blank
        CHECK (previous_scope_code IS NULL OR TRIM(previous_scope_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permission_audits_new_scope_code_not_blank
        CHECK (new_scope_code IS NULL OR TRIM(new_scope_code) <> ''),
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
    INDEX idx_pp_usm_role_permission_audits_scope_time (new_scope_code, changed_at),
    INDEX idx_pp_usm_role_permission_audits_event_time (event_type, changed_at),
    INDEX idx_pp_usm_role_permission_audits_correlation_id (correlation_id),
    INDEX idx_pp_usm_role_permission_audits_assigned_by (assigned_by),
    INDEX idx_pp_usm_role_permission_audits_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

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
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_reason, NEW.revoked_reason, @rbac_audit_reason), 255)
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
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, NEW.revoked_reason), 255)
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

CREATE TABLE IF NOT EXISTS pp_usm_addresses
(
    address_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id                 BIGINT UNSIGNED NOT NULL,
    recipient_name          VARCHAR(150)    NOT NULL,
    phone_number            VARCHAR(30)     NOT NULL,
    address_line_1          VARCHAR(255)    NOT NULL,
    address_line_2          VARCHAR(255)    NULL,
    city                    VARCHAR(100)    NOT NULL,
    district                VARCHAR(100)    NULL,
    province                VARCHAR(100)    NULL,
    postal_code             VARCHAR(20)     NULL,
    country                 VARCHAR(100)    NOT NULL,
    is_default              BOOLEAN         NOT NULL DEFAULT FALSE,
    version                 BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at              TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by              VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at              TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by              VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_addresses PRIMARY KEY (address_id),
    CONSTRAINT fk_pp_usm_addresses_user
        FOREIGN KEY (user_id) REFERENCES pp_usm_users (user_id) ON DELETE CASCADE,
    CONSTRAINT chk_pp_usm_addresses_recipient_name_not_blank
        CHECK (TRIM(recipient_name) <> ''),
    CONSTRAINT chk_pp_usm_addresses_phone_number_not_blank
        CHECK (TRIM(phone_number) <> ''),
    CONSTRAINT chk_pp_usm_addresses_address_line_1_not_blank
        CHECK (TRIM(address_line_1) <> ''),
    CONSTRAINT chk_pp_usm_addresses_city_not_blank
        CHECK (TRIM(city) <> ''),
    CONSTRAINT chk_pp_usm_addresses_country_not_blank
        CHECK (TRIM(country) <> ''),
    CONSTRAINT chk_pp_usm_addresses_address_line_2_not_blank
        CHECK (address_line_2 IS NULL OR TRIM(address_line_2) <> ''),
    CONSTRAINT chk_pp_usm_addresses_district_not_blank
        CHECK (district IS NULL OR TRIM(district) <> ''),
    CONSTRAINT chk_pp_usm_addresses_province_not_blank
        CHECK (province IS NULL OR TRIM(province) <> ''),
    CONSTRAINT chk_pp_usm_addresses_postal_code_not_blank
        CHECK (postal_code IS NULL OR TRIM(postal_code) <> ''),

    INDEX idx_pp_usm_addresses_user_id (user_id),
    INDEX idx_pp_usm_addresses_user_default (user_id, is_default),
    INDEX idx_pp_usm_addresses_city (city),
    INDEX idx_pp_usm_addresses_postal_code (postal_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_category_statuses
(
    status_code  VARCHAR(30)       NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_r_category_statuses PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_category_statuses_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_category_statuses_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_category_statuses_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_category_statuses_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_brand_statuses
(
    status_code  VARCHAR(30)       NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_r_brand_statuses PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_brand_statuses_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_brand_statuses_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_brand_statuses_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_brand_statuses_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_product_statuses
(
    status_code  VARCHAR(30)       NOT NULL,
    display_name VARCHAR(100)      NOT NULL,
    description  VARCHAR(255)      NULL,
    sort_order   SMALLINT UNSIGNED NOT NULL,
    is_active    BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)      NOT NULL DEFAULT 'SYSTEM',
    updated_at   TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_r_product_statuses PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_product_statuses_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_product_statuses_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_product_statuses_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_product_statuses_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_categories
(
    category_id        BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    parent_category_id BIGINT UNSIGNED   NULL,
    name               VARCHAR(150)      NOT NULL,
    slug               VARCHAR(180)      NOT NULL,
    status_code        VARCHAR(30)       NOT NULL DEFAULT 'ACTIVE',
    sort_order         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    version            BIGINT UNSIGNED   NOT NULL DEFAULT 0,
    created_at         TIMESTAMP(6)      NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by         VARCHAR(100)      NOT NULL,
    updated_at         TIMESTAMP(6)      NULL     DEFAULT NULL,
    updated_by         VARCHAR(100)      NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_m_categories PRIMARY KEY (category_id),
    CONSTRAINT uk_pp_m_categories_slug UNIQUE (slug),
    CONSTRAINT fk_pp_m_categories_parent
        FOREIGN KEY (parent_category_id) REFERENCES pp_m_categories (category_id),
    CONSTRAINT fk_pp_m_categories_status
        FOREIGN KEY (status_code) REFERENCES pp_r_category_statuses (status_code),
    CONSTRAINT chk_pp_m_categories_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_categories_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_categories_parent_id (parent_category_id),
    INDEX idx_pp_m_categories_status (status_code),
    INDEX idx_pp_m_categories_parent_status (parent_category_id, status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_brands
(
    brand_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name        VARCHAR(150)    NOT NULL,
    slug        VARCHAR(180)    NOT NULL,
    description TEXT            NULL,
    logo_url    VARCHAR(500)    NULL,
    status_code VARCHAR(30)     NOT NULL DEFAULT 'ACTIVE',
    version     BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at  TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by  VARCHAR(100)    NOT NULL,
    updated_at  TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by  VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_m_brands PRIMARY KEY (brand_id),
    CONSTRAINT uk_pp_m_brands_name UNIQUE (name),
    CONSTRAINT uk_pp_m_brands_slug UNIQUE (slug),
    CONSTRAINT fk_pp_m_brands_status
        FOREIGN KEY (status_code) REFERENCES pp_r_brand_statuses (status_code),
    CONSTRAINT chk_pp_m_brands_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_brands_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_brands_status (status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_products
(
    product_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    organization_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
    owner_user_id BIGINT UNSIGNED NULL,
    category_id  BIGINT UNSIGNED NOT NULL,
    brand_id     BIGINT UNSIGNED NULL,
    name         VARCHAR(255)    NOT NULL,
    slug         VARCHAR(300)    NOT NULL,
    description  TEXT            NULL,
    model_number VARCHAR(100)    NULL,
    sku_code     VARCHAR(100)    NULL,
    status_code  VARCHAR(30)     NOT NULL DEFAULT 'DRAFT',
    version      BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at   TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by   VARCHAR(100)    NOT NULL,
    updated_at   TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by   VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_m_products PRIMARY KEY (product_id),
    CONSTRAINT uk_pp_m_products_org_slug UNIQUE (organization_id, slug),
    CONSTRAINT uk_pp_m_products_org_sku_code UNIQUE (organization_id, sku_code),
    CONSTRAINT fk_pp_m_products_organization
        FOREIGN KEY (organization_id) REFERENCES pp_org_organizations (organization_id),
    CONSTRAINT fk_pp_m_products_owner_user
        FOREIGN KEY (owner_user_id) REFERENCES pp_usm_users (user_id) ON DELETE SET NULL,
    CONSTRAINT fk_pp_m_products_category
        FOREIGN KEY (category_id) REFERENCES pp_m_categories (category_id),
    CONSTRAINT fk_pp_m_products_brand
        FOREIGN KEY (brand_id) REFERENCES pp_m_brands (brand_id),
    CONSTRAINT fk_pp_m_products_status
        FOREIGN KEY (status_code) REFERENCES pp_r_product_statuses (status_code),
    CONSTRAINT chk_pp_m_products_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_products_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_products_organization_id (organization_id),
    INDEX idx_pp_m_products_owner_user_id (owner_user_id),
    INDEX idx_pp_m_products_org_owner_status (organization_id, owner_user_id, status_code),
    INDEX idx_pp_m_products_category_id (category_id),
    INDEX idx_pp_m_products_brand_id (brand_id),
    INDEX idx_pp_m_products_status (status_code),
    INDEX idx_pp_m_products_org_status (organization_id, status_code),
    INDEX idx_pp_m_products_org_category_status (organization_id, category_id, status_code),
    INDEX idx_pp_m_products_category_status (category_id, status_code),
    INDEX idx_pp_m_products_brand_status (brand_id, status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
