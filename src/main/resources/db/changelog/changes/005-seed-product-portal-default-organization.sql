--liquibase formatted sql
--changeset elvencode:005-seed-product-portal-default-organization context:reference

-- Production-safe default organization used by the current single-tenant bootstrap model.

INSERT INTO pp_m_organization
    (organization_id, organization_code, display_name, legal_name, description, is_active, created_by)
VALUES
    (1, 'DEFAULT', 'Default Organization', 'Product Portal',
     'Default organization for existing single-tenant product portal data.', TRUE, 'SYSTEM')
ON CONFLICT (organization_id) DO UPDATE SET
    organization_code = EXCLUDED.organization_code,
    display_name = EXCLUDED.display_name,
    legal_name = EXCLUDED.legal_name,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_organization.organization_code IS DISTINCT FROM EXCLUDED.organization_code
   OR pp_m_organization.display_name IS DISTINCT FROM EXCLUDED.display_name
   OR pp_m_organization.legal_name IS DISTINCT FROM EXCLUDED.legal_name
   OR pp_m_organization.description IS DISTINCT FROM EXCLUDED.description
   OR pp_m_organization.is_active IS DISTINCT FROM EXCLUDED.is_active;

SELECT setval(
    pg_get_serial_sequence('pp_m_organization', 'organization_id'),
    GREATEST((SELECT COALESCE(MAX(organization_id), 1) FROM pp_m_organization), 1),
    TRUE
);
