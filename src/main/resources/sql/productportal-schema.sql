-- User-domain tables are dropped in reverse dependency order for local schema rebuilds.
-- In production, apply equivalent changes through Flyway/Liquibase migrations instead.
DROP TABLE IF EXISTS pp_usm_addresses;
DROP TABLE IF EXISTS pp_usm_users;
DROP TABLE IF EXISTS pp_usr_user_statuses;
DROP TABLE IF EXISTS pp_usm_roles;

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

CREATE TABLE IF NOT EXISTS pp_usm_users
(
    user_id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    username      VARCHAR(100)    NOT NULL,
    full_name     VARCHAR(150)    NOT NULL,
    email         VARCHAR(254)    NOT NULL,
    phone_number  VARCHAR(30)     NULL,
    password_hash VARCHAR(255)    NOT NULL,
    role_code     VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
    status        VARCHAR(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE',
    version       BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at    TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    created_by    VARCHAR(100)    NOT NULL DEFAULT 'SYSTEM',
    updated_at    TIMESTAMP(6)    NULL     DEFAULT NULL,
    updated_by    VARCHAR(100)    NULL     DEFAULT NULL,

    CONSTRAINT pk_pp_usm_users PRIMARY KEY (user_id),
    CONSTRAINT uk_pp_usm_users_username UNIQUE (username),
    CONSTRAINT uk_pp_usm_users_email UNIQUE (email),
    CONSTRAINT uk_pp_usm_users_phone_number UNIQUE (phone_number),
    CONSTRAINT fk_pp_usm_users_role
        FOREIGN KEY (role_code) REFERENCES pp_usm_roles (role_code),
    CONSTRAINT fk_pp_usm_users_status
        FOREIGN KEY (status) REFERENCES pp_usr_user_statuses (status_code),
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

    INDEX idx_pp_usm_users_role_code (role_code),
    INDEX idx_pp_usm_users_status (status),
    INDEX idx_pp_usm_users_role_status (role_code, status)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;

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
    CONSTRAINT uk_pp_m_products_slug UNIQUE (slug),
    CONSTRAINT uk_pp_m_products_sku_code UNIQUE (sku_code),
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

    INDEX idx_pp_m_products_category_id (category_id),
    INDEX idx_pp_m_products_brand_id (brand_id),
    INDEX idx_pp_m_products_status (status_code),
    INDEX idx_pp_m_products_category_status (category_id, status_code),
    INDEX idx_pp_m_products_brand_status (brand_id, status_code)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;
