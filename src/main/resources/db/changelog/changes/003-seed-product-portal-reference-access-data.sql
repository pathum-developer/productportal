--liquibase formatted sql
--changeset elvencode:003-seed-product-portal-reference-access-data context:reference

-- Production-safe reference data for Product Portal access control.
-- This changeset is intentionally idempotent and uses explicit conflict targets.
-- It reconciles controlled reference rows without creating users or demo catalog data.

INSERT INTO pp_m_role
    (role_code, display_name, description, sort_order, is_active)
VALUES
    ('BUYER', 'Buyer', 'Customer account that can browse and purchase products.', 1, TRUE),
    ('SELLER', 'Seller', 'Merchant account that can manage seller-owned catalog data.', 2, TRUE),
    ('ADMIN', 'Admin', 'Administrative account with elevated product portal privileges.', 3, TRUE)
ON CONFLICT (role_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_role.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_m_role.description IS DISTINCT FROM EXCLUDED.description
   OR pp_m_role.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_m_role.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_m_permission
    (permission_code, display_name, description, resource_code, action_code, sort_order, is_active)
VALUES
    ('PROFILE_READ', 'Read Profile', 'View own user profile details.', 'PROFILE', 'READ', 1, TRUE),
    ('PROFILE_UPDATE', 'Update Profile', 'Update own user profile details.', 'PROFILE', 'UPDATE', 2, TRUE),
    ('ADDRESS_MANAGE', 'Manage Addresses', 'Create, update, and remove own address records.', 'ADDRESS', 'MANAGE', 3, TRUE),
    ('CATEGORY_READ', 'Read Categories', 'View active catalog categories.', 'CATEGORY', 'READ', 4, TRUE),
    ('CATEGORY_CREATE', 'Create Categories', 'Create catalog categories.', 'CATEGORY', 'CREATE', 5, TRUE),
    ('CATEGORY_UPDATE', 'Update Categories', 'Update catalog categories.', 'CATEGORY', 'UPDATE', 6, TRUE),
    ('CATEGORY_DELETE', 'Delete Categories', 'Remove catalog categories.', 'CATEGORY', 'DELETE', 7, TRUE),
    ('BRAND_READ', 'Read Brands', 'View active product brands.', 'BRAND', 'READ', 8, TRUE),
    ('BRAND_CREATE', 'Create Brands', 'Create product brands.', 'BRAND', 'CREATE', 9, TRUE),
    ('BRAND_UPDATE', 'Update Brands', 'Update product brands.', 'BRAND', 'UPDATE', 10, TRUE),
    ('BRAND_DELETE', 'Delete Brands', 'Remove product brands.', 'BRAND', 'DELETE', 11, TRUE),
    ('PRODUCT_READ', 'Read Products', 'View product catalog data.', 'PRODUCT', 'READ', 12, TRUE),
    ('PRODUCT_CREATE', 'Create Products', 'Create product catalog records.', 'PRODUCT', 'CREATE', 13, TRUE),
    ('PRODUCT_UPDATE', 'Update Products', 'Update product catalog records.', 'PRODUCT', 'UPDATE', 14, TRUE),
    ('PRODUCT_DELETE', 'Delete Products', 'Remove product catalog records.', 'PRODUCT', 'DELETE', 15, TRUE),
    ('USER_READ', 'Read Users', 'View user account details.', 'USER', 'READ', 16, TRUE),
    ('USER_CREATE', 'Create Users', 'Create user accounts.', 'USER', 'CREATE', 17, TRUE),
    ('USER_UPDATE', 'Update Users', 'Update user accounts.', 'USER', 'UPDATE', 18, TRUE),
    ('USER_DELETE', 'Delete Users', 'Remove user accounts.', 'USER', 'DELETE', 19, TRUE),
    ('ROLE_READ', 'Read Roles', 'View role definitions.', 'ROLE', 'READ', 20, TRUE),
    ('ROLE_ASSIGN', 'Assign Roles', 'Assign roles to users.', 'ROLE', 'ASSIGN', 21, TRUE),
    ('ROLE_MANAGE', 'Manage Roles', 'Create, update, and deactivate roles.', 'ROLE', 'MANAGE', 22, TRUE),
    ('PERMISSION_READ', 'Read Permissions', 'View permission definitions.', 'PERMISSION', 'READ', 23, TRUE),
    ('PERMISSION_MANAGE', 'Manage Permissions', 'Create, update, and deactivate permissions.', 'PERMISSION', 'MANAGE', 24, TRUE)
ON CONFLICT (permission_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    resource_code = EXCLUDED.resource_code,
    action_code = EXCLUDED.action_code,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_permission.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_m_permission.description IS DISTINCT FROM EXCLUDED.description
   OR pp_m_permission.resource_code IS DISTINCT FROM EXCLUDED.resource_code
   OR pp_m_permission.action_code IS DISTINCT FROM EXCLUDED.action_code
   OR pp_m_permission.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_m_permission.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_r_permission_scope
    (scope_code, display_name, description, sort_order, is_active)
VALUES
    ('SELF', 'Self', 'Permission applies only to the current user account or profile.', 1, TRUE),
    ('OWNED', 'Owned Resource', 'Permission applies only to resources owned by the current user.', 2, TRUE),
    ('ORGANIZATION', 'Organization', 'Permission applies to resources inside the selected organization.', 3, TRUE),
    ('GLOBAL', 'Global', 'Permission applies across all organizations in the platform.', 4, TRUE)
ON CONFLICT (scope_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_permission_scope.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_permission_scope.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_permission_scope.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_permission_scope.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_t_role_permission_grant
    (role_code, permission_code, scope_code, is_active)
VALUES
    ('BUYER', 'PROFILE_READ', 'SELF', TRUE),
    ('BUYER', 'PROFILE_UPDATE', 'SELF', TRUE),
    ('BUYER', 'ADDRESS_MANAGE', 'SELF', TRUE),
    ('BUYER', 'CATEGORY_READ', 'ORGANIZATION', TRUE),
    ('BUYER', 'BRAND_READ', 'ORGANIZATION', TRUE),
    ('BUYER', 'PRODUCT_READ', 'ORGANIZATION', TRUE),
    ('SELLER', 'PROFILE_READ', 'SELF', TRUE),
    ('SELLER', 'PROFILE_UPDATE', 'SELF', TRUE),
    ('SELLER', 'ADDRESS_MANAGE', 'SELF', TRUE),
    ('SELLER', 'CATEGORY_READ', 'ORGANIZATION', TRUE),
    ('SELLER', 'BRAND_READ', 'ORGANIZATION', TRUE),
    ('SELLER', 'PRODUCT_READ', 'ORGANIZATION', TRUE),
    ('SELLER', 'PRODUCT_CREATE', 'ORGANIZATION', TRUE),
    ('SELLER', 'PRODUCT_UPDATE', 'OWNED', TRUE),
    ('ADMIN', 'PROFILE_READ', 'SELF', TRUE),
    ('ADMIN', 'PROFILE_UPDATE', 'SELF', TRUE),
    ('ADMIN', 'ADDRESS_MANAGE', 'SELF', TRUE),
    ('ADMIN', 'CATEGORY_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'CATEGORY_CREATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'CATEGORY_UPDATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'CATEGORY_DELETE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'BRAND_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'BRAND_CREATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'BRAND_UPDATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'BRAND_DELETE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PRODUCT_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PRODUCT_CREATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PRODUCT_UPDATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PRODUCT_DELETE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'USER_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'USER_CREATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'USER_UPDATE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'USER_DELETE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'ROLE_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'ROLE_ASSIGN', 'ORGANIZATION', TRUE),
    ('ADMIN', 'ROLE_MANAGE', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PERMISSION_READ', 'ORGANIZATION', TRUE),
    ('ADMIN', 'PERMISSION_MANAGE', 'ORGANIZATION', TRUE)
ON CONFLICT (role_code, permission_code) DO UPDATE SET
    scope_code = EXCLUDED.scope_code,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_t_role_permission_grant.scope_code IS DISTINCT FROM EXCLUDED.scope_code
   OR pp_t_role_permission_grant.is_active IS DISTINCT FROM EXCLUDED.is_active;
