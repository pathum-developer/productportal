-- Section 16 RBAC migration.
-- Preserves existing user-role assignments before removing pp_usm_users.role_code.

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

CREATE TABLE IF NOT EXISTS pp_usm_user_roles
(
    user_id    BIGINT UNSIGNED NOT NULL,
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

    CONSTRAINT pk_pp_usm_user_roles PRIMARY KEY (user_id, role_code),
    CONSTRAINT fk_pp_usm_user_roles_user
        FOREIGN KEY (user_id) REFERENCES pp_usm_users (user_id) ON DELETE CASCADE,
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
    INDEX idx_pp_usm_user_roles_user_active_validity (user_id, is_active, valid_from, valid_until),
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
    CONSTRAINT chk_pp_usm_role_permissions_role_code_not_blank
        CHECK (TRIM(role_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_permission_code_not_blank
        CHECK (TRIM(permission_code) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_assigned_by_not_blank
        CHECK (TRIM(assigned_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_assigned_reason_not_blank
        CHECK (assigned_reason IS NULL OR TRIM(assigned_reason) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_revoked_by_not_blank
        CHECK (revoked_by IS NULL OR TRIM(revoked_by) <> ''),
    CONSTRAINT chk_pp_usm_role_permissions_revoked_reason_not_blank
        CHECK (revoked_reason IS NULL OR TRIM(revoked_reason) <> ''),

    INDEX idx_pp_usm_role_permissions_permission_code (permission_code),
    INDEX idx_pp_usm_role_permissions_role_active (role_code, is_active),
    INDEX idx_pp_usm_role_permissions_permission_active (permission_code, is_active),
    INDEX idx_pp_usm_role_permissions_assigned_by (assigned_by),
    INDEX idx_pp_usm_role_permissions_revoked_by (revoked_by)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

INSERT IGNORE INTO pp_usm_permissions
    (permission_code, display_name, description, resource_code, action_code, sort_order)
VALUES
    ('PROFILE_READ', 'Read Profile', 'View own user profile details.', 'PROFILE', 'READ', 1),
    ('PROFILE_UPDATE', 'Update Profile', 'Update own user profile details.', 'PROFILE', 'UPDATE', 2),
    ('ADDRESS_MANAGE', 'Manage Addresses', 'Create, update, and remove own address records.', 'ADDRESS', 'MANAGE', 3),
    ('CATEGORY_READ', 'Read Categories', 'View active catalog categories.', 'CATEGORY', 'READ', 4),
    ('CATEGORY_CREATE', 'Create Categories', 'Create catalog categories.', 'CATEGORY', 'CREATE', 5),
    ('CATEGORY_UPDATE', 'Update Categories', 'Update catalog categories.', 'CATEGORY', 'UPDATE', 6),
    ('CATEGORY_DELETE', 'Delete Categories', 'Remove catalog categories.', 'CATEGORY', 'DELETE', 7),
    ('BRAND_READ', 'Read Brands', 'View active product brands.', 'BRAND', 'READ', 8),
    ('BRAND_CREATE', 'Create Brands', 'Create product brands.', 'BRAND', 'CREATE', 9),
    ('BRAND_UPDATE', 'Update Brands', 'Update product brands.', 'BRAND', 'UPDATE', 10),
    ('BRAND_DELETE', 'Delete Brands', 'Remove product brands.', 'BRAND', 'DELETE', 11),
    ('PRODUCT_READ', 'Read Products', 'View product catalog data.', 'PRODUCT', 'READ', 12),
    ('PRODUCT_CREATE', 'Create Products', 'Create product catalog records.', 'PRODUCT', 'CREATE', 13),
    ('PRODUCT_UPDATE', 'Update Products', 'Update product catalog records.', 'PRODUCT', 'UPDATE', 14),
    ('PRODUCT_DELETE', 'Delete Products', 'Remove product catalog records.', 'PRODUCT', 'DELETE', 15),
    ('USER_READ', 'Read Users', 'View user account details.', 'USER', 'READ', 16),
    ('USER_CREATE', 'Create Users', 'Create user accounts.', 'USER', 'CREATE', 17),
    ('USER_UPDATE', 'Update Users', 'Update user accounts.', 'USER', 'UPDATE', 18),
    ('USER_DELETE', 'Delete Users', 'Remove user accounts.', 'USER', 'DELETE', 19),
    ('ROLE_READ', 'Read Roles', 'View role definitions.', 'ROLE', 'READ', 20),
    ('ROLE_ASSIGN', 'Assign Roles', 'Assign roles to users.', 'ROLE', 'ASSIGN', 21),
    ('ROLE_MANAGE', 'Manage Roles', 'Create, update, and deactivate roles.', 'ROLE', 'MANAGE', 22),
    ('PERMISSION_READ', 'Read Permissions', 'View permission definitions.', 'PERMISSION', 'READ', 23),
    ('PERMISSION_MANAGE', 'Manage Permissions', 'Create, update, and deactivate permissions.', 'PERMISSION', 'MANAGE', 24);

INSERT IGNORE INTO pp_usm_role_permissions
    (role_code, permission_code)
VALUES
    ('BUYER', 'PROFILE_READ'),
    ('BUYER', 'PROFILE_UPDATE'),
    ('BUYER', 'ADDRESS_MANAGE'),
    ('BUYER', 'CATEGORY_READ'),
    ('BUYER', 'BRAND_READ'),
    ('BUYER', 'PRODUCT_READ'),
    ('SELLER', 'PROFILE_READ'),
    ('SELLER', 'PROFILE_UPDATE'),
    ('SELLER', 'ADDRESS_MANAGE'),
    ('SELLER', 'CATEGORY_READ'),
    ('SELLER', 'BRAND_READ'),
    ('SELLER', 'PRODUCT_READ'),
    ('SELLER', 'PRODUCT_CREATE'),
    ('SELLER', 'PRODUCT_UPDATE'),
    ('ADMIN', 'PROFILE_READ'),
    ('ADMIN', 'PROFILE_UPDATE'),
    ('ADMIN', 'ADDRESS_MANAGE'),
    ('ADMIN', 'CATEGORY_READ'),
    ('ADMIN', 'CATEGORY_CREATE'),
    ('ADMIN', 'CATEGORY_UPDATE'),
    ('ADMIN', 'CATEGORY_DELETE'),
    ('ADMIN', 'BRAND_READ'),
    ('ADMIN', 'BRAND_CREATE'),
    ('ADMIN', 'BRAND_UPDATE'),
    ('ADMIN', 'BRAND_DELETE'),
    ('ADMIN', 'PRODUCT_READ'),
    ('ADMIN', 'PRODUCT_CREATE'),
    ('ADMIN', 'PRODUCT_UPDATE'),
    ('ADMIN', 'PRODUCT_DELETE'),
    ('ADMIN', 'USER_READ'),
    ('ADMIN', 'USER_CREATE'),
    ('ADMIN', 'USER_UPDATE'),
    ('ADMIN', 'USER_DELETE'),
    ('ADMIN', 'ROLE_READ'),
    ('ADMIN', 'ROLE_ASSIGN'),
    ('ADMIN', 'ROLE_MANAGE'),
    ('ADMIN', 'PERMISSION_READ'),
    ('ADMIN', 'PERMISSION_MANAGE');

INSERT IGNORE INTO pp_usm_user_roles
    (user_id, role_code, created_by)
SELECT user_id, role_code, 'SYSTEM'
FROM pp_usm_users;

ALTER TABLE pp_usm_users DROP FOREIGN KEY fk_pp_usm_users_role;
ALTER TABLE pp_usm_users DROP INDEX idx_pp_usm_users_role_status;
ALTER TABLE pp_usm_users DROP INDEX idx_pp_usm_users_role_code;
ALTER TABLE pp_usm_users DROP COLUMN role_code;
