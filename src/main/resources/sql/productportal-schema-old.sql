-- we don't know how to generate root <with-no-name> (class Root) :(

create table pp_r_brand_statuses
(
    status_code  varchar(30)                               not null
        primary key,
    display_name varchar(100)                              not null,
    description  varchar(255)                              null,
    sort_order   smallint unsigned                         not null,
    is_active    tinyint(1)   default 1                    not null,
    created_at   timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100) default 'SYSTEM'             not null,
    updated_at   timestamp(6)                              null,
    updated_by   varchar(100)                              null,
    constraint uk_pp_r_brand_statuses_display_name
        unique (display_name),
    constraint chk_pp_r_brand_statuses_code_not_blank
        check (trim(`status_code`) <> _utf8mb4\'\'),
    constraint chk_pp_r_brand_statuses_display_name_not_blank
        check (trim(`display_name`) <> _utf8mb4\'\'),
    constraint chk_pp_r_brand_statuses_sort_order_positive
        check (`sort_order` > 0)
);

create table pp_m_brands
(
    brand_id    bigint unsigned auto_increment
        primary key,
    name        varchar(150)                                 not null,
    slug        varchar(180)                                 not null,
    description text                                         null,
    logo_url    varchar(500)                                 null,
    status_code varchar(30)     default 'ACTIVE'             not null,
    version     bigint unsigned default '0'                  not null,
    created_at  timestamp(6)    default CURRENT_TIMESTAMP(6) not null,
    created_by  varchar(100)                                 not null,
    updated_at  timestamp(6)                                 null,
    updated_by  varchar(100)                                 null,
    constraint uk_pp_m_brands_name
        unique (name),
    constraint uk_pp_m_brands_slug
        unique (slug),
    constraint fk_pp_m_brands_status
        foreign key (status_code) references pp_r_brand_statuses (status_code),
    constraint chk_pp_m_brands_name_not_blank
        check (trim(`name`) <> _utf8mb4\'\'),
    constraint chk_pp_m_brands_slug_not_blank
        check (trim(`slug`) <> _utf8mb4\'\')
);

create index idx_pp_m_brands_status
    on pp_m_brands (status_code);

create table pp_r_category_statuses
(
    status_code  varchar(30)                               not null
        primary key,
    display_name varchar(100)                              not null,
    description  varchar(255)                              null,
    sort_order   smallint unsigned                         not null,
    is_active    tinyint(1)   default 1                    not null,
    created_at   timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100) default 'SYSTEM'             not null,
    updated_at   timestamp(6)                              null,
    updated_by   varchar(100)                              null,
    constraint uk_pp_r_category_statuses_display_name
        unique (display_name),
    constraint chk_pp_r_category_statuses_code_not_blank
        check (trim(`status_code`) <> _utf8mb4\'\'),
    constraint chk_pp_r_category_statuses_display_name_not_blank
        check (trim(`display_name`) <> _utf8mb4\'\'),
    constraint chk_pp_r_category_statuses_sort_order_positive
        check (`sort_order` > 0)
);

create table pp_m_categories
(
    category_id        bigint unsigned auto_increment
        primary key,
    parent_category_id bigint unsigned                                null,
    name               varchar(150)                                   not null,
    slug               varchar(180)                                   not null,
    status_code        varchar(30)       default 'ACTIVE'             not null,
    sort_order         smallint unsigned default '0'                  not null,
    version            bigint unsigned   default '0'                  not null,
    created_at         timestamp(6)      default CURRENT_TIMESTAMP(6) not null,
    created_by         varchar(100)                                   not null,
    updated_at         timestamp(6)                                   null,
    updated_by         varchar(100)                                   null,
    constraint uk_pp_m_categories_slug
        unique (slug),
    constraint fk_pp_m_categories_parent
        foreign key (parent_category_id) references pp_m_categories (category_id),
    constraint fk_pp_m_categories_status
        foreign key (status_code) references pp_r_category_statuses (status_code),
    constraint chk_pp_m_categories_name_not_blank
        check (trim(`name`) <> _utf8mb4\'\'),
    constraint chk_pp_m_categories_slug_not_blank
        check (trim(`slug`) <> _utf8mb4\'\')
);

create index idx_pp_m_categories_parent_id
    on pp_m_categories (parent_category_id);

create index idx_pp_m_categories_parent_status
    on pp_m_categories (parent_category_id, status_code);

create index idx_pp_m_categories_status
    on pp_m_categories (status_code);

create table pp_r_product_statuses
(
    status_code  varchar(30)                               not null
        primary key,
    display_name varchar(100)                              not null,
    description  varchar(255)                              null,
    sort_order   smallint unsigned                         not null,
    is_active    tinyint(1)   default 1                    not null,
    created_at   timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100) default 'SYSTEM'             not null,
    updated_at   timestamp(6)                              null,
    updated_by   varchar(100)                              null,
    constraint uk_pp_r_product_statuses_display_name
        unique (display_name),
    constraint chk_pp_r_product_statuses_code_not_blank
        check (trim(`status_code`) <> _utf8mb4\'\'),
    constraint chk_pp_r_product_statuses_display_name_not_blank
        check (trim(`display_name`) <> _utf8mb4\'\'),
    constraint chk_pp_r_product_statuses_sort_order_positive
        check (`sort_order` > 0)
);

create table pp_m_products
(
    product_id   bigint unsigned auto_increment
        primary key,
    category_id  bigint unsigned                              not null,
    brand_id     bigint unsigned                              null,
    name         varchar(255)                                 not null,
    slug         varchar(300)                                 not null,
    description  text                                         null,
    model_number varchar(100)                                 null,
    sku_code     varchar(100)                                 null,
    status_code  varchar(30)     default 'DRAFT'              not null,
    version      bigint unsigned default '0'                  not null,
    created_at   timestamp(6)    default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100)                                 not null,
    updated_at   timestamp(6)                                 null,
    updated_by   varchar(100)                                 null,
    constraint uk_pp_m_products_sku_code
        unique (sku_code),
    constraint uk_pp_m_products_slug
        unique (slug),
    constraint fk_pp_m_products_brand
        foreign key (brand_id) references pp_m_brands (brand_id),
    constraint fk_pp_m_products_category
        foreign key (category_id) references pp_m_categories (category_id),
    constraint fk_pp_m_products_status
        foreign key (status_code) references pp_r_product_statuses (status_code),
    constraint chk_pp_m_products_name_not_blank
        check (trim(`name`) <> _utf8mb4\'\'),
    constraint chk_pp_m_products_slug_not_blank
        check (trim(`slug`) <> _utf8mb4\'\')
);

create index idx_pp_m_products_brand_id
    on pp_m_products (brand_id);

create index idx_pp_m_products_brand_status
    on pp_m_products (brand_id, status_code);

create index idx_pp_m_products_category_id
    on pp_m_products (category_id);

create index idx_pp_m_products_category_status
    on pp_m_products (category_id, status_code);

create index idx_pp_m_products_status
    on pp_m_products (status_code);

create table pp_usm_roles
(
    role_code    varchar(30)                               not null
        primary key,
    display_name varchar(100)                              not null,
    description  varchar(255)                              null,
    sort_order   smallint unsigned                         not null,
    is_active    tinyint(1)   default 1                    not null,
    created_at   timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100) default 'SYSTEM'             not null,
    updated_at   timestamp(6)                              null,
    updated_by   varchar(100)                              null,
    constraint uk_pp_usm_roles_display_name
        unique (display_name),
    constraint chk_pp_usm_roles_code_not_blank
        check (trim(`role_code`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_roles_display_name_not_blank
        check (trim(`display_name`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_roles_sort_order_positive
        check (`sort_order` > 0)
);

create table pp_usr_user_statuses
(
    status_code  varchar(30)                               not null
        primary key,
    display_name varchar(100)                              not null,
    description  varchar(255)                              null,
    sort_order   smallint unsigned                         not null,
    is_active    tinyint(1)   default 1                    not null,
    created_at   timestamp(6) default CURRENT_TIMESTAMP(6) not null,
    created_by   varchar(100) default 'SYSTEM'             not null,
    updated_at   timestamp(6)                              null,
    updated_by   varchar(100)                              null,
    constraint uk_pp_usr_user_statuses_display_name
        unique (display_name),
    constraint chk_pp_usr_user_statuses_code_not_blank
        check (trim(`status_code`) <> _utf8mb4\'\'),
    constraint chk_pp_usr_user_statuses_display_name_not_blank
        check (trim(`display_name`) <> _utf8mb4\'\'),
    constraint chk_pp_usr_user_statuses_sort_order_positive
        check (`sort_order` > 0)
);

create table pp_usm_users
(
    user_id       bigint unsigned auto_increment
        primary key,
    username      varchar(100)                                 not null,
    full_name     varchar(150)                                 not null,
    email         varchar(254)                                 not null,
    phone_number  varchar(30)                                  null,
    password_hash varchar(255)                                 not null,
    role_code     varchar(30)                                  not null,
    status        varchar(30)     default 'ACTIVE'             not null,
    version       bigint unsigned default '0'                  not null,
    created_at    timestamp(6)    default CURRENT_TIMESTAMP(6) not null,
    created_by    varchar(100)    default 'SYSTEM'             not null,
    updated_at    timestamp(6)                                 null,
    updated_by    varchar(100)                                 null,
    constraint uk_pp_usm_users_email
        unique (email),
    constraint uk_pp_usm_users_phone_number
        unique (phone_number),
    constraint uk_pp_usm_users_username
        unique (username),
    constraint fk_pp_usm_users_role
        foreign key (role_code) references pp_usm_roles (role_code),
    constraint fk_pp_usm_users_status
        foreign key (status) references pp_usr_user_statuses (status_code),
    constraint chk_pp_usm_users_email_not_blank
        check (trim(`email`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_users_full_name_not_blank
        check (trim(`full_name`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_users_password_hash_not_blank
        check (trim(`password_hash`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_users_phone_number_not_blank
        check ((`phone_number` is null) or (trim(`phone_number`) <> _utf8mb4\'\')),
    constraint chk_pp_usm_users_username_not_blank
        check (trim(`username`) <> _utf8mb4\'\')
);

create table pp_usm_addresses
(
    address_id     bigint unsigned auto_increment
        primary key,
    user_id        bigint unsigned                              not null,
    recipient_name varchar(150)                                 not null,
    phone_number   varchar(30)                                  not null,
    address_line_1 varchar(255)                                 not null,
    address_line_2 varchar(255)                                 null,
    city           varchar(100)                                 not null,
    district       varchar(100)                                 null,
    province       varchar(100)                                 null,
    postal_code    varchar(20)                                  null,
    country        varchar(100)                                 not null,
    is_default     tinyint(1)      default 0                    not null,
    version        bigint unsigned default '0'                  not null,
    created_at     timestamp(6)    default CURRENT_TIMESTAMP(6) not null,
    created_by     varchar(100)    default 'SYSTEM'             not null,
    updated_at     timestamp(6)                                 null,
    updated_by     varchar(100)                                 null,
    constraint fk_pp_usm_addresses_user
        foreign key (user_id) references pp_usm_users (user_id)
            on delete cascade,
    constraint chk_pp_usm_addresses_address_line_1_not_blank
        check (trim(`address_line_1`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_addresses_address_line_2_not_blank
        check ((`address_line_2` is null) or (trim(`address_line_2`) <> _utf8mb4\'\')),
    constraint chk_pp_usm_addresses_city_not_blank
        check (trim(`city`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_addresses_country_not_blank
        check (trim(`country`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_addresses_district_not_blank
        check ((`district` is null) or (trim(`district`) <> _utf8mb4\'\')),
    constraint chk_pp_usm_addresses_phone_number_not_blank
        check (trim(`phone_number`) <> _utf8mb4\'\'),
    constraint chk_pp_usm_addresses_postal_code_not_blank
        check ((`postal_code` is null) or (trim(`postal_code`) <> _utf8mb4\'\')),
    constraint chk_pp_usm_addresses_province_not_blank
        check ((`province` is null) or (trim(`province`) <> _utf8mb4\'\')),
    constraint chk_pp_usm_addresses_recipient_name_not_blank
        check (trim(`recipient_name`) <> _utf8mb4\'\')
);

create index idx_pp_usm_addresses_city
    on pp_usm_addresses (city);

create index idx_pp_usm_addresses_postal_code
    on pp_usm_addresses (postal_code);

create index idx_pp_usm_addresses_user_default
    on pp_usm_addresses (user_id, is_default);

create index idx_pp_usm_addresses_user_id
    on pp_usm_addresses (user_id);

create index idx_pp_usm_users_role_code
    on pp_usm_users (role_code);

create index idx_pp_usm_users_role_status
    on pp_usm_users (role_code, status);

create index idx_pp_usm_users_status
    on pp_usm_users (status);

