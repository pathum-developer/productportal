--liquibase formatted sql
--changeset elvencode:009-remove-product-user-ownership

-- Products are tenant-owned. A user may create or update a product, but is not its owner.
-- This is a contract migration: deploy application code that no longer reads owner_user_id
-- before applying it in a rolling environment.

ALTER TABLE pp_m_product
    ALTER COLUMN organization_id DROP DEFAULT;

ALTER TABLE pp_m_product
    DROP CONSTRAINT IF EXISTS fk_pp_m_product_owner_user;

DROP INDEX IF EXISTS idx_pp_m_product_owner_user_id;
DROP INDEX IF EXISTS idx_pp_m_product_org_owner_status;

ALTER TABLE pp_m_product
    DROP COLUMN IF EXISTS owner_user_id;

-- Product operations are organization-scoped now that no product-level user ownership exists.
UPDATE pp_t_role_permission_grant AS role_permission_grant
SET scope_code = 'ORGANIZATION',
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
FROM pp_m_permission AS permission_definition
WHERE role_permission_grant.permission_code = permission_definition.permission_code
  AND permission_definition.resource_code = 'PRODUCT'
  AND role_permission_grant.scope_code = 'OWNED';
