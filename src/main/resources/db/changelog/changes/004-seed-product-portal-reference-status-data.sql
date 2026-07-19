--liquibase formatted sql
--changeset elvencode:004-seed-product-portal-reference-status-data context:reference

-- Production-safe reference statuses for users, organizations, and catalog records.

INSERT INTO pp_r_user_status
    (status_code, display_name, description, sort_order, is_active)
VALUES
    ('ACTIVE', 'Active', 'User can authenticate and use permitted product portal features.', 1, TRUE),
    ('INACTIVE', 'Inactive', 'User account is retained but cannot authenticate.', 2, TRUE),
    ('SUSPENDED', 'Suspended', 'User account is temporarily blocked due to policy or risk.', 3, TRUE),
    ('DELETED', 'Deleted', 'User account is logically removed and retained only for audit history.', 4, TRUE)
ON CONFLICT (status_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_user_status.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_user_status.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_user_status.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_user_status.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_r_membership_status
    (status_code, display_name, description, sort_order, is_active)
VALUES
    ('INVITED', 'Invited', 'User has been invited to the organization but has not joined yet.', 1, TRUE),
    ('ACTIVE', 'Active', 'User is an active member of the organization.', 2, TRUE),
    ('SUSPENDED', 'Suspended', 'User membership is temporarily blocked in the organization.', 3, TRUE),
    ('LEFT', 'Left', 'User left the organization voluntarily.', 4, TRUE),
    ('REMOVED', 'Removed', 'User was removed from the organization.', 5, TRUE)
ON CONFLICT (status_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_membership_status.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_membership_status.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_membership_status.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_membership_status.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_r_category_status
    (status_code, display_name, description, sort_order, is_active)
VALUES
    ('ACTIVE', 'Active', 'Category is visible and available for product assignment.', 1, TRUE),
    ('INACTIVE', 'Inactive', 'Category is retained but hidden from active catalog flows.', 2, TRUE)
ON CONFLICT (status_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_category_status.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_category_status.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_category_status.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_category_status.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_r_brand_status
    (status_code, display_name, description, sort_order, is_active)
VALUES
    ('ACTIVE', 'Active', 'Brand is visible and available for product assignment.', 1, TRUE),
    ('INACTIVE', 'Inactive', 'Brand is retained but hidden from active catalog flows.', 2, TRUE)
ON CONFLICT (status_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_brand_status.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_brand_status.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_brand_status.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_brand_status.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_r_product_status
    (status_code, display_name, description, sort_order, is_active)
VALUES
    ('DRAFT', 'Draft', 'Product is incomplete and not visible in active catalog flows.', 1, TRUE),
    ('ACTIVE', 'Active', 'Product is visible and available in active catalog flows.', 2, TRUE),
    ('INACTIVE', 'Inactive', 'Product is retained but hidden from active catalog flows.', 3, TRUE)
ON CONFLICT (status_code) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_r_product_status.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_r_product_status.description IS DISTINCT FROM EXCLUDED.description
   OR pp_r_product_status.sort_order IS DISTINCT FROM EXCLUDED.sort_order
   OR pp_r_product_status.is_active IS DISTINCT FROM EXCLUDED.is_active;
