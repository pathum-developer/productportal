--liquibase formatted sql
--changeset elvencode:013-remove-organization-from-user-role-assignment splitStatements:false

-- A user now belongs to exactly one organization, so role assignments are scoped by the user's organization.
-- The audit table keeps organization_id as historical context and derives it from pp_m_user.

ALTER TABLE pp_t_user_role_assignment
    DROP CONSTRAINT IF EXISTS fk_pp_t_user_role_assignment_user_organization;

ALTER TABLE pp_t_user_role_assignment
    DROP CONSTRAINT IF EXISTS fk_pp_t_user_role_assignment_organization;

ALTER TABLE pp_t_user_role_assignment
    DROP CONSTRAINT IF EXISTS pk_pp_t_user_role_assignment;

DROP INDEX IF EXISTS idx_pp_t_user_role_assignment_user_org_active_validity;
DROP INDEX IF EXISTS idx_pp_t_user_role_assignment_org_role_active;

ALTER TABLE pp_t_user_role_assignment
    DROP COLUMN IF EXISTS organization_id;

ALTER TABLE pp_t_user_role_assignment
    ADD CONSTRAINT pk_pp_t_user_role_assignment PRIMARY KEY (user_id, role_code);

CREATE INDEX IF NOT EXISTS idx_pp_t_user_role_assignment_user_active_validity
    ON pp_t_user_role_assignment (user_id, is_active, valid_from, valid_until);

ALTER TABLE pp_t_user_role_assignment_audit
    ALTER COLUMN organization_id DROP NOT NULL;

CREATE OR REPLACE FUNCTION trg_pp_t_user_role_assignment_audit_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    audit_user_id BIGINT;
    audit_organization_id BIGINT;
BEGIN
    IF TG_OP = 'DELETE' THEN
        audit_user_id := OLD.user_id;
    ELSE
        audit_user_id := NEW.user_id;
    END IF;

    SELECT portal_user.organization_id
    INTO audit_organization_id
    FROM pp_m_user AS portal_user
    WHERE portal_user.user_id = audit_user_id;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO pp_t_user_role_assignment_audit
            (user_id, organization_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, audit_organization_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
             NULL, NULL, NEW.valid_from, NEW.valid_until,
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_assigned_by'),
                 NEW.assigned_by,
                 pp_setting('product_portal.rbac_audit_actor'),
                 NEW.created_by,
                 'SYSTEM'
             ), 100),
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_assigned_reason'),
                 NEW.assigned_reason,
                 pp_setting('product_portal.rbac_audit_reason')
             ), 255),
             NULL,
             NULL,
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_assigned_by'),
                 NEW.assigned_by,
                 pp_setting('product_portal.rbac_audit_actor'),
                 NEW.created_by,
                 'SYSTEM'
             ), 100),
             LEFT(CURRENT_USER::TEXT, 100),
             LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_audit_reason'),
                 pp_setting('product_portal.rbac_assigned_reason'),
                 NEW.assigned_reason
             ), 255),
             LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));

        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.is_active IS DISTINCT FROM NEW.is_active
           OR OLD.valid_from IS DISTINCT FROM NEW.valid_from
           OR OLD.valid_until IS DISTINCT FROM NEW.valid_until THEN
            INSERT INTO pp_t_user_role_assignment_audit
                (user_id, organization_id, role_code, event_type, previous_active, new_active,
                 previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
                 assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
                 database_user, source_code, change_reason, correlation_id)
            VALUES
                (NEW.user_id, audit_organization_id, NEW.role_code,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NEW.is_active THEN 'ACTIVATED'
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active THEN 'DEACTIVATED'
                     ELSE 'VALIDITY_CHANGED'
                 END,
                 OLD.is_active, NEW.is_active,
                 OLD.valid_from, OLD.valid_until, NEW.valid_from, NEW.valid_until,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active THEN NULL
                     ELSE LEFT(COALESCE(
                         pp_setting('product_portal.rbac_assigned_by'),
                         NEW.assigned_by,
                         pp_setting('product_portal.rbac_audit_actor'),
                         NEW.updated_by,
                         NEW.created_by,
                         'SYSTEM'
                     ), 100)
                 END,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active THEN NULL
                     ELSE LEFT(COALESCE(
                         pp_setting('product_portal.rbac_assigned_reason'),
                         NEW.assigned_reason,
                         pp_setting('product_portal.rbac_audit_reason')
                     ), 255)
                 END,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active
                         THEN LEFT(COALESCE(
                             pp_setting('product_portal.rbac_revoked_by'),
                             NEW.revoked_by,
                             pp_setting('product_portal.rbac_audit_actor'),
                             NEW.updated_by,
                             NEW.created_by,
                             'SYSTEM'
                         ), 100)
                     ELSE NULL
                 END,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active
                         THEN LEFT(COALESCE(
                             pp_setting('product_portal.rbac_revoked_reason'),
                             NEW.revoked_reason,
                             pp_setting('product_portal.rbac_audit_reason')
                         ), 255)
                     ELSE NULL
                 END,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active
                         THEN LEFT(COALESCE(
                             pp_setting('product_portal.rbac_revoked_by'),
                             NEW.revoked_by,
                             pp_setting('product_portal.rbac_audit_actor'),
                             NEW.updated_by,
                             NEW.created_by,
                             'SYSTEM'
                         ), 100)
                     ELSE LEFT(COALESCE(
                         pp_setting('product_portal.rbac_audit_actor'),
                         NEW.updated_by,
                         NEW.assigned_by,
                         NEW.created_by,
                         'SYSTEM'
                     ), 100)
                 END,
                 LEFT(CURRENT_USER::TEXT, 100),
                 LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NOT NEW.is_active
                         THEN LEFT(COALESCE(
                             pp_setting('product_portal.rbac_audit_reason'),
                             pp_setting('product_portal.rbac_revoked_reason'),
                             NEW.revoked_reason
                         ), 255)
                     ELSE LEFT(COALESCE(
                         pp_setting('product_portal.rbac_audit_reason'),
                         pp_setting('product_portal.rbac_assigned_reason'),
                         NEW.assigned_reason
                     ), 255)
                 END,
                 LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));
        END IF;

        RETURN NEW;
    ELSE
        INSERT INTO pp_t_user_role_assignment_audit
            (user_id, organization_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (OLD.user_id, audit_organization_id, OLD.role_code, 'REVOKED', OLD.is_active, NULL,
             OLD.valid_from, OLD.valid_until, NULL, NULL,
             OLD.assigned_by,
             OLD.assigned_reason,
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_revoked_by'),
                 OLD.revoked_by,
                 pp_setting('product_portal.rbac_audit_actor'),
                 OLD.updated_by,
                 OLD.created_by,
                 'SYSTEM'
             ), 100),
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_revoked_reason'),
                 OLD.revoked_reason,
                 pp_setting('product_portal.rbac_audit_reason')
             ), 255),
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_revoked_by'),
                 OLD.revoked_by,
                 pp_setting('product_portal.rbac_audit_actor'),
                 OLD.updated_by,
                 OLD.created_by,
                 'SYSTEM'
             ), 100),
             LEFT(CURRENT_USER::TEXT, 100),
             LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_audit_reason'),
                 pp_setting('product_portal.rbac_revoked_reason'),
                 OLD.revoked_reason
             ), 255),
             LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));

        RETURN OLD;
    END IF;
END;
$$;
