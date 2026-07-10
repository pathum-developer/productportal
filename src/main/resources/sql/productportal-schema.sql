-- User-domain tables are dropped in reverse dependency order for local schema rebuilds.
-- In production, apply equivalent changes through Flyway/Liquibase migrations instead.
DROP TRIGGER IF EXISTS trg_pp_t_user_role_assignment_ai;
DROP TRIGGER IF EXISTS trg_pp_t_user_role_assignment_au;
DROP TRIGGER IF EXISTS trg_pp_t_user_role_assignment_ad;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_ai;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_au;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_ad;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_bi;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_bu;
DROP TRIGGER IF EXISTS trg_pp_t_role_permission_grant_ai;
DROP TRIGGER IF EXISTS trg_pp_t_role_permission_grant_au;
DROP TRIGGER IF EXISTS trg_pp_t_role_permission_grant_ad;
DROP TABLE IF EXISTS pp_m_product;
DROP TABLE IF EXISTS pp_m_user_address;
DROP TABLE IF EXISTS pp_t_user_role_assignment_audit;
DROP TABLE IF EXISTS pp_t_role_permission_grant_audit;
DROP TABLE IF EXISTS pp_t_user_organization_membership_audit;
DROP TABLE IF EXISTS pp_t_user_role_assignment;
DROP TABLE IF EXISTS pp_t_user_organization_membership;
DROP TABLE IF EXISTS pp_t_role_permission_grant;
DROP TABLE IF EXISTS pp_m_user;
DROP TABLE IF EXISTS pp_r_user_status;
DROP TABLE IF EXISTS pp_r_membership_status;
DROP TABLE IF EXISTS pp_r_permission_scope;
DROP TABLE IF EXISTS pp_m_permission;
DROP TABLE IF EXISTS pp_m_role;
DROP TABLE IF EXISTS pp_m_organization;

CREATE TABLE IF NOT EXISTS pp_m_role
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

    CONSTRAINT pk_pp_m_role PRIMARY KEY (role_code),
    CONSTRAINT uk_pp_m_role_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_m_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_m_role_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_m_role_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_permission
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

    CONSTRAINT pk_pp_m_permission PRIMARY KEY (permission_code),
    CONSTRAINT uk_pp_m_permission_display_name UNIQUE (display_name),
    CONSTRAINT uk_pp_m_permission_resource_action UNIQUE (resource_code, action_code),
    CONSTRAINT chk_pp_m_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_m_permission_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_m_permission_resource_code_not_blank
        CHECK (TRIM(resource_code) <> ''),
    CONSTRAINT chk_pp_m_permission_action_code_not_blank
        CHECK (TRIM(action_code) <> ''),
    CONSTRAINT chk_pp_m_permission_sort_order_positive
        CHECK (sort_order > 0),

    INDEX idx_pp_m_permission_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_permission_scope
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

    CONSTRAINT pk_pp_r_permission_scope PRIMARY KEY (scope_code),
    CONSTRAINT uk_pp_r_permission_scope_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_permission_scope_code_not_blank
        CHECK (TRIM(scope_code) <> ''),
    CONSTRAINT chk_pp_r_permission_scope_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_permission_scope_sort_order_positive
        CHECK (sort_order > 0),

    INDEX idx_pp_r_permission_scope_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_user_status
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

    CONSTRAINT pk_pp_r_user_status PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_user_status_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_user_status_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_user_status_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_user_status_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_organization
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

    CONSTRAINT pk_pp_m_organization PRIMARY KEY (organization_id),
    CONSTRAINT uk_pp_m_organization_code UNIQUE (organization_code),
    CONSTRAINT uk_pp_m_organization_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_m_organization_code_not_blank
        CHECK (TRIM(organization_code) <> ''),
    CONSTRAINT chk_pp_m_organization_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_m_organization_legal_name_not_blank
        CHECK (legal_name IS NULL OR TRIM(legal_name) <> ''),

    INDEX idx_pp_m_organization_active (is_active)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_membership_status
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

    CONSTRAINT pk_pp_r_membership_status PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_membership_status_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_membership_status_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_membership_status_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_membership_status_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_user
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

    CONSTRAINT pk_pp_m_user PRIMARY KEY (user_id),
    CONSTRAINT uk_pp_m_user_username UNIQUE (username),
    CONSTRAINT uk_pp_m_user_email UNIQUE (email),
    CONSTRAINT uk_pp_m_user_phone_number UNIQUE (phone_number),
    CONSTRAINT fk_pp_m_user_status
        FOREIGN KEY (status) REFERENCES pp_r_user_status (status_code),
    CONSTRAINT fk_pp_m_user_primary_organization
        FOREIGN KEY (primary_organization_id) REFERENCES pp_m_organization (organization_id) ON DELETE SET NULL,
    CONSTRAINT chk_pp_m_user_full_name_not_blank
        CHECK (TRIM(full_name) <> ''),
    CONSTRAINT chk_pp_m_user_username_not_blank
        CHECK (TRIM(username) <> ''),
    CONSTRAINT chk_pp_m_user_email_not_blank
        CHECK (TRIM(email) <> ''),
    CONSTRAINT chk_pp_m_user_password_hash_not_blank
        CHECK (TRIM(password_hash) <> ''),
    CONSTRAINT chk_pp_m_user_phone_number_not_blank
        CHECK (phone_number IS NULL OR TRIM(phone_number) <> ''),

    INDEX idx_pp_m_user_status (status),
    INDEX idx_pp_m_user_primary_organization_id (primary_organization_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_user_organization_membership
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

    CONSTRAINT pk_pp_t_user_organization_membership PRIMARY KEY (user_id, organization_id),
    CONSTRAINT fk_pp_t_user_organization_membership_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_t_user_organization_membership_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    CONSTRAINT fk_pp_t_user_organization_membership_status
        FOREIGN KEY (membership_status) REFERENCES pp_r_membership_status (status_code),
    CONSTRAINT chk_pp_t_user_organization_membership_invited_by_not_blank
        CHECK (invited_by IS NULL OR TRIM(invited_by) <> ''),

    INDEX idx_pp_t_user_organization_membership_status (membership_status),
    INDEX idx_pp_t_user_organization_membership_org_status (organization_id, membership_status),
    INDEX idx_pp_t_user_organization_membership_user_status (user_id, membership_status),
    INDEX idx_pp_t_user_organization_membership_primary (user_id, is_primary),
    INDEX idx_pp_t_user_organization_membership_invited_by (invited_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_user_role_assignment
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

    CONSTRAINT pk_pp_t_user_role_assignment PRIMARY KEY (user_id, organization_id, role_code),
    CONSTRAINT fk_pp_t_user_role_assignment_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_pp_t_user_role_assignment_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    CONSTRAINT fk_pp_t_user_role_assignment_membership
        FOREIGN KEY (user_id, organization_id) REFERENCES pp_t_user_organization_membership (user_id, organization_id),
    CONSTRAINT fk_pp_t_user_role_assignment_role
        FOREIGN KEY (role_code) REFERENCES pp_m_role (role_code),
    CONSTRAINT chk_pp_t_user_role_assignment_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_valid_window
        CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until > valid_from),
    CONSTRAINT chk_pp_t_user_role_assignment_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_t_user_role_assignment_role_code (role_code),
    INDEX idx_pp_t_user_role_assignment_user_org_active_validity (user_id, organization_id, is_active, valid_from, valid_until),
    INDEX idx_pp_t_user_role_assignment_org_role_active (organization_id, role_code, is_active),
    INDEX idx_pp_t_user_role_assignment_role_active (role_code, is_active),
    INDEX idx_pp_t_user_role_assignment_assigned_by (assigned_by),
    INDEX idx_pp_t_user_role_assignment_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_role_permission_grant
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

    CONSTRAINT pk_pp_t_role_permission_grant PRIMARY KEY (role_code, permission_code),
    CONSTRAINT fk_pp_t_role_permission_grant_role
        FOREIGN KEY (role_code) REFERENCES pp_m_role (role_code),
    CONSTRAINT fk_pp_t_role_permission_grant_permission
        FOREIGN KEY (permission_code) REFERENCES pp_m_permission (permission_code),
    CONSTRAINT fk_pp_t_role_permission_grant_scope
        FOREIGN KEY (scope_code) REFERENCES pp_r_permission_scope (scope_code),
    CONSTRAINT chk_pp_t_role_permission_grant_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_scope_code_not_blank
        CHECK (TRIM(scope_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_t_role_permission_grant_permission_code (permission_code),
    INDEX idx_pp_t_role_permission_grant_scope_code (scope_code),
    INDEX idx_pp_t_role_permission_grant_role_active (role_code, is_active),
    INDEX idx_pp_t_role_permission_grant_permission_scope_active (permission_code, scope_code, is_active),
    INDEX idx_pp_t_role_permission_grant_permission_active (permission_code, is_active),
    INDEX idx_pp_t_role_permission_grant_assigned_by (assigned_by),
    INDEX idx_pp_t_role_permission_grant_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_user_organization_membership_audit
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

    CONSTRAINT pk_pp_t_user_organization_membership_audit PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_t_user_organization_membership_audit_event_type
        CHECK (event_type IN ('INVITED', 'JOINED', 'ACTIVATED', 'SUSPENDED', 'LEFT', 'REMOVED',
                              'PRIMARY_CHANGED', 'DETAILS_CHANGED', 'MIGRATED')),
    CONSTRAINT chk_pp_t_user_org_mship_aud_prev_status_nb
        CHECK (previous_membership_status IS NULL OR TRIM(previous_membership_status) <> ''),
    CONSTRAINT chk_pp_t_user_organization_membership_audit_new_status_not_blank
        CHECK (new_membership_status IS NULL OR TRIM(new_membership_status) <> ''),
    CONSTRAINT chk_pp_t_user_organization_membership_audit_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_t_user_org_mship_aud_db_user_nb
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_t_user_org_mship_aud_source_nb
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_t_user_org_mship_aud_prev_inv_by_nb
        CHECK (previous_invited_by IS NULL OR TRIM(previous_invited_by) <> ''),
    CONSTRAINT chk_pp_t_user_org_mship_aud_new_inv_by_nb
        CHECK (new_invited_by IS NULL OR TRIM(new_invited_by) <> ''),

    INDEX idx_pp_t_user_organization_membership_audit_user_org_time (user_id, organization_id, changed_at),
    INDEX idx_pp_t_user_organization_membership_audit_org_time (organization_id, changed_at),
    INDEX idx_pp_t_user_organization_membership_audit_event_time (event_type, changed_at),
    INDEX idx_pp_t_user_organization_membership_audit_correlation_id (correlation_id),
    INDEX idx_pp_t_user_organization_membership_audit_changed_by (changed_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_user_role_assignment_audit
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

    CONSTRAINT pk_pp_t_user_role_assignment_audit PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'VALIDITY_CHANGED', 'REVOKED', 'MIGRATED')),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_database_user_not_blank
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_source_code_not_blank
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_previous_valid_window
        CHECK (previous_valid_until IS NULL OR previous_valid_from IS NULL OR previous_valid_until > previous_valid_from),
    CONSTRAINT chk_pp_t_user_role_assignment_audit_new_valid_window
        CHECK (new_valid_until IS NULL OR new_valid_from IS NULL OR new_valid_until > new_valid_from),

    INDEX idx_pp_t_user_role_assignment_audit_user_org_time (user_id, organization_id, changed_at),
    INDEX idx_pp_t_user_role_assignment_audit_org_time (organization_id, changed_at),
    INDEX idx_pp_t_user_role_assignment_audit_role_time (role_code, changed_at),
    INDEX idx_pp_t_user_role_assignment_audit_event_time (event_type, changed_at),
    INDEX idx_pp_t_user_role_assignment_audit_correlation_id (correlation_id),
    INDEX idx_pp_t_user_role_assignment_audit_assigned_by (assigned_by),
    INDEX idx_pp_t_user_role_assignment_audit_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_t_role_permission_grant_audit
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

    CONSTRAINT pk_pp_t_role_permission_grant_audit PRIMARY KEY (audit_id),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'SCOPE_CHANGED', 'REVOKED', 'MIGRATED')),
    CONSTRAINT chk_pp_t_role_perm_grant_aud_prev_scope_nb
        CHECK (previous_scope_code IS NULL OR TRIM(previous_scope_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_new_scope_code_not_blank
        CHECK (new_scope_code IS NULL OR TRIM(new_scope_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_changed_by_not_blank
        CHECK (TRIM(changed_by) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_database_user_not_blank
        CHECK (TRIM(database_user) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_source_code_not_blank
        CHECK (TRIM(source_code) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_assigned_by_not_blank
        CHECK (assigned_by IS NULL OR TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_t_role_permission_grant_audit_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_t_role_permission_grant_audit_role_time (role_code, changed_at),
    INDEX idx_pp_t_role_permission_grant_audit_permission_time (permission_code, changed_at),
    INDEX idx_pp_t_role_permission_grant_audit_scope_time (new_scope_code, changed_at),
    INDEX idx_pp_t_role_permission_grant_audit_event_time (event_type, changed_at),
    INDEX idx_pp_t_role_permission_grant_audit_correlation_id (correlation_id),
    INDEX idx_pp_t_role_permission_grant_audit_assigned_by (assigned_by),
    INDEX idx_pp_t_role_permission_grant_audit_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

DELIMITER $$

CREATE TRIGGER trg_pp_t_user_organization_membership_bi
BEFORE INSERT ON pp_t_user_organization_membership
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_t_user_organization_membership existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END$$

CREATE TRIGGER trg_pp_t_user_organization_membership_bu
BEFORE UPDATE ON pp_t_user_organization_membership
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_t_user_organization_membership existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
             AND NOT (existing_membership.user_id <=> OLD.user_id
                      AND existing_membership.organization_id <=> OLD.organization_id)
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END$$

CREATE TRIGGER trg_pp_t_user_organization_membership_ai
AFTER INSERT ON pp_t_user_organization_membership
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    END IF;

    INSERT INTO pp_t_user_organization_membership_audit
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

CREATE TRIGGER trg_pp_t_user_organization_membership_au
AFTER UPDATE ON pp_t_user_organization_membership
FOR EACH ROW
BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    ELSEIF OLD.is_primary
        AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
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
        INSERT INTO pp_t_user_organization_membership_audit
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

CREATE TRIGGER trg_pp_t_user_organization_membership_ad
AFTER DELETE ON pp_t_user_organization_membership
FOR EACH ROW
BEGIN
    IF OLD.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NULL,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100)
        WHERE user_id = OLD.user_id
          AND primary_organization_id = OLD.organization_id;
    END IF;

    INSERT INTO pp_t_user_organization_membership_audit
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

CREATE TRIGGER trg_pp_t_user_role_assignment_ai
AFTER INSERT ON pp_t_user_role_assignment
FOR EACH ROW
BEGIN
    INSERT INTO pp_t_user_role_assignment_audit
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

CREATE TRIGGER trg_pp_t_user_role_assignment_au
AFTER UPDATE ON pp_t_user_role_assignment
FOR EACH ROW
BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.valid_from <=> NEW.valid_from)
        OR NOT (OLD.valid_until <=> NEW.valid_until) THEN
        INSERT INTO pp_t_user_role_assignment_audit
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

CREATE TRIGGER trg_pp_t_user_role_assignment_ad
AFTER DELETE ON pp_t_user_role_assignment
FOR EACH ROW
BEGIN
    INSERT INTO pp_t_user_role_assignment_audit
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

CREATE TRIGGER trg_pp_t_role_permission_grant_ai
AFTER INSERT ON pp_t_role_permission_grant
FOR EACH ROW
BEGIN
    INSERT INTO pp_t_role_permission_grant_audit
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

CREATE TRIGGER trg_pp_t_role_permission_grant_au
AFTER UPDATE ON pp_t_role_permission_grant
FOR EACH ROW
BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.scope_code <=> NEW.scope_code) THEN
        INSERT INTO pp_t_role_permission_grant_audit
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

CREATE TRIGGER trg_pp_t_role_permission_grant_ad
AFTER DELETE ON pp_t_role_permission_grant
FOR EACH ROW
BEGIN
    INSERT INTO pp_t_role_permission_grant_audit
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

CREATE TABLE IF NOT EXISTS pp_m_user_address
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

    CONSTRAINT pk_pp_m_user_address PRIMARY KEY (address_id),
    CONSTRAINT fk_pp_m_user_address_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    CONSTRAINT chk_pp_m_user_address_recipient_name_not_blank
        CHECK (TRIM(recipient_name) <> ''),
    CONSTRAINT chk_pp_m_user_address_phone_number_not_blank
        CHECK (TRIM(phone_number) <> ''),
    CONSTRAINT chk_pp_m_user_address_address_line_1_not_blank
        CHECK (TRIM(address_line_1) <> ''),
    CONSTRAINT chk_pp_m_user_address_city_not_blank
        CHECK (TRIM(city) <> ''),
    CONSTRAINT chk_pp_m_user_address_country_not_blank
        CHECK (TRIM(country) <> ''),
    CONSTRAINT chk_pp_m_user_address_address_line_2_not_blank
        CHECK (address_line_2 IS NULL OR TRIM(address_line_2) <> ''),
    CONSTRAINT chk_pp_m_user_address_district_not_blank
        CHECK (district IS NULL OR TRIM(district) <> ''),
    CONSTRAINT chk_pp_m_user_address_province_not_blank
        CHECK (province IS NULL OR TRIM(province) <> ''),
    CONSTRAINT chk_pp_m_user_address_postal_code_not_blank
        CHECK (postal_code IS NULL OR TRIM(postal_code) <> ''),

    INDEX idx_pp_m_user_address_user_id (user_id),
    INDEX idx_pp_m_user_address_user_default (user_id, is_default),
    INDEX idx_pp_m_user_address_city (city),
    INDEX idx_pp_m_user_address_postal_code (postal_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_category_status
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

    CONSTRAINT pk_pp_r_category_status PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_category_status_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_category_status_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_category_status_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_category_status_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_brand_status
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

    CONSTRAINT pk_pp_r_brand_status PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_brand_status_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_brand_status_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_brand_status_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_brand_status_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_r_product_status
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

    CONSTRAINT pk_pp_r_product_status PRIMARY KEY (status_code),
    CONSTRAINT uk_pp_r_product_status_display_name UNIQUE (display_name),
    CONSTRAINT chk_pp_r_product_status_code_not_blank
        CHECK (TRIM(status_code) <> ''),
    CONSTRAINT chk_pp_r_product_status_display_name_not_blank
        CHECK (TRIM(display_name) <> ''),
    CONSTRAINT chk_pp_r_product_status_sort_order_positive
        CHECK (sort_order > 0)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_category
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

    CONSTRAINT pk_pp_m_category PRIMARY KEY (category_id),
    CONSTRAINT uk_pp_m_category_slug UNIQUE (slug),
    CONSTRAINT fk_pp_m_category_parent
        FOREIGN KEY (parent_category_id) REFERENCES pp_m_category (category_id),
    CONSTRAINT fk_pp_m_category_status
        FOREIGN KEY (status_code) REFERENCES pp_r_category_status (status_code),
    CONSTRAINT chk_pp_m_category_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_category_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_category_parent_id (parent_category_id),
    INDEX idx_pp_m_category_status (status_code),
    INDEX idx_pp_m_category_parent_status (parent_category_id, status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_brand
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

    CONSTRAINT pk_pp_m_brand PRIMARY KEY (brand_id),
    CONSTRAINT uk_pp_m_brand_name UNIQUE (name),
    CONSTRAINT uk_pp_m_brand_slug UNIQUE (slug),
    CONSTRAINT fk_pp_m_brand_status
        FOREIGN KEY (status_code) REFERENCES pp_r_brand_status (status_code),
    CONSTRAINT chk_pp_m_brand_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_brand_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_brand_status (status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pp_m_product
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

    CONSTRAINT pk_pp_m_product PRIMARY KEY (product_id),
    CONSTRAINT uk_pp_m_product_org_slug UNIQUE (organization_id, slug),
    CONSTRAINT uk_pp_m_product_org_sku_code UNIQUE (organization_id, sku_code),
    CONSTRAINT fk_pp_m_product_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    CONSTRAINT fk_pp_m_product_owner_user
        FOREIGN KEY (owner_user_id) REFERENCES pp_m_user (user_id) ON DELETE SET NULL,
    CONSTRAINT fk_pp_m_product_category
        FOREIGN KEY (category_id) REFERENCES pp_m_category (category_id),
    CONSTRAINT fk_pp_m_product_brand
        FOREIGN KEY (brand_id) REFERENCES pp_m_brand (brand_id),
    CONSTRAINT fk_pp_m_product_status
        FOREIGN KEY (status_code) REFERENCES pp_r_product_status (status_code),
    CONSTRAINT chk_pp_m_product_name_not_blank
        CHECK (TRIM(name) <> ''),
    CONSTRAINT chk_pp_m_product_slug_not_blank
        CHECK (TRIM(slug) <> ''),

    INDEX idx_pp_m_product_organization_id (organization_id),
    INDEX idx_pp_m_product_owner_user_id (owner_user_id),
    INDEX idx_pp_m_product_org_owner_status (organization_id, owner_user_id, status_code),
    INDEX idx_pp_m_product_category_id (category_id),
    INDEX idx_pp_m_product_brand_id (brand_id),
    INDEX idx_pp_m_product_status (status_code),
    INDEX idx_pp_m_product_org_status (organization_id, status_code),
    INDEX idx_pp_m_product_org_category_status (organization_id, category_id, status_code),
    INDEX idx_pp_m_product_category_status (category_id, status_code),
    INDEX idx_pp_m_product_brand_status (brand_id, status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
