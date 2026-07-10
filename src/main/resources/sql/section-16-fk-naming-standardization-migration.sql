-- Section 16 foreign-key naming standardization migration.
-- Renames foreign-key metadata after table names were standardized to pp_m / pp_r / pp_t.

ALTER TABLE pp_m_user
    DROP FOREIGN KEY fk_pp_usm_users_status,
    DROP FOREIGN KEY fk_pp_usm_users_primary_organization,
    ADD CONSTRAINT fk_pp_m_user_status
        FOREIGN KEY (status) REFERENCES pp_r_user_status (status_code),
    ADD CONSTRAINT fk_pp_m_user_primary_organization
        FOREIGN KEY (primary_organization_id) REFERENCES pp_m_organization (organization_id) ON DELETE SET NULL;

ALTER TABLE pp_t_user_organization_membership
    DROP FOREIGN KEY fk_pp_org_user_memberships_user,
    DROP FOREIGN KEY fk_pp_org_user_memberships_organization,
    DROP FOREIGN KEY fk_pp_org_user_memberships_status,
    ADD CONSTRAINT fk_pp_t_user_organization_membership_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_pp_t_user_organization_membership_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    ADD CONSTRAINT fk_pp_t_user_organization_membership_status
        FOREIGN KEY (membership_status) REFERENCES pp_r_membership_status (status_code);

ALTER TABLE pp_t_user_role_assignment
    DROP FOREIGN KEY fk_pp_usm_user_roles_user,
    DROP FOREIGN KEY fk_pp_usm_user_roles_organization,
    DROP FOREIGN KEY fk_pp_usm_user_roles_membership,
    DROP FOREIGN KEY fk_pp_usm_user_roles_role,
    ADD CONSTRAINT fk_pp_t_user_role_assignment_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_pp_t_user_role_assignment_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    ADD CONSTRAINT fk_pp_t_user_role_assignment_membership
        FOREIGN KEY (user_id, organization_id) REFERENCES pp_t_user_organization_membership (user_id, organization_id),
    ADD CONSTRAINT fk_pp_t_user_role_assignment_role
        FOREIGN KEY (role_code) REFERENCES pp_m_role (role_code);

ALTER TABLE pp_t_role_permission_grant
    DROP FOREIGN KEY fk_pp_usm_role_permissions_role,
    DROP FOREIGN KEY fk_pp_usm_role_permissions_permission,
    DROP FOREIGN KEY fk_pp_usm_role_permissions_scope,
    ADD CONSTRAINT fk_pp_t_role_permission_grant_role
        FOREIGN KEY (role_code) REFERENCES pp_m_role (role_code),
    ADD CONSTRAINT fk_pp_t_role_permission_grant_permission
        FOREIGN KEY (permission_code) REFERENCES pp_m_permission (permission_code),
    ADD CONSTRAINT fk_pp_t_role_permission_grant_scope
        FOREIGN KEY (scope_code) REFERENCES pp_r_permission_scope (scope_code);

ALTER TABLE pp_m_user_address
    DROP FOREIGN KEY fk_pp_usm_addresses_user,
    ADD CONSTRAINT fk_pp_m_user_address_user
        FOREIGN KEY (user_id) REFERENCES pp_m_user (user_id) ON DELETE CASCADE;

ALTER TABLE pp_m_category
    DROP FOREIGN KEY fk_pp_m_categories_parent,
    DROP FOREIGN KEY fk_pp_m_categories_status,
    ADD CONSTRAINT fk_pp_m_category_parent
        FOREIGN KEY (parent_category_id) REFERENCES pp_m_category (category_id),
    ADD CONSTRAINT fk_pp_m_category_status
        FOREIGN KEY (status_code) REFERENCES pp_r_category_status (status_code);

ALTER TABLE pp_m_brand
    DROP FOREIGN KEY fk_pp_m_brands_status,
    ADD CONSTRAINT fk_pp_m_brand_status
        FOREIGN KEY (status_code) REFERENCES pp_r_brand_status (status_code);

ALTER TABLE pp_m_product
    DROP FOREIGN KEY fk_pp_m_products_organization,
    DROP FOREIGN KEY fk_pp_m_products_owner_user,
    DROP FOREIGN KEY fk_pp_m_products_category,
    DROP FOREIGN KEY fk_pp_m_products_brand,
    DROP FOREIGN KEY fk_pp_m_products_status,
    ADD CONSTRAINT fk_pp_m_product_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id),
    ADD CONSTRAINT fk_pp_m_product_owner_user
        FOREIGN KEY (owner_user_id) REFERENCES pp_m_user (user_id) ON DELETE SET NULL,
    ADD CONSTRAINT fk_pp_m_product_category
        FOREIGN KEY (category_id) REFERENCES pp_m_category (category_id),
    ADD CONSTRAINT fk_pp_m_product_brand
        FOREIGN KEY (brand_id) REFERENCES pp_m_brand (brand_id),
    ADD CONSTRAINT fk_pp_m_product_status
        FOREIGN KEY (status_code) REFERENCES pp_r_product_status (status_code);
