--liquibase formatted sql
--changeset elvencode:015-remove-permission-scope splitStatements:false

-- Permissions are now plain role-derived authorities.
-- Organization boundaries are enforced by resource queries and service-level authorization.

CREATE OR REPLACE FUNCTION trg_pp_t_role_permission_grant_audit_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO pp_t_role_permission_grant_audit
            (role_code, permission_code, event_type, previous_active, new_active,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.role_code, NEW.permission_code, 'ASSIGNED', NULL, NEW.is_active,
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
        IF OLD.is_active IS DISTINCT FROM NEW.is_active THEN
            INSERT INTO pp_t_role_permission_grant_audit
                (role_code, permission_code, event_type, previous_active, new_active,
                 assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
                 database_user, source_code, change_reason, correlation_id)
            VALUES
                (NEW.role_code, NEW.permission_code,
                 CASE
                     WHEN NEW.is_active THEN 'ACTIVATED'
                     ELSE 'DEACTIVATED'
                 END,
                 OLD.is_active, NEW.is_active,
                 CASE
                     WHEN NOT NEW.is_active THEN NULL
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
                     WHEN NOT NEW.is_active THEN NULL
                     ELSE LEFT(COALESCE(
                         pp_setting('product_portal.rbac_assigned_reason'),
                         NEW.assigned_reason,
                         pp_setting('product_portal.rbac_audit_reason')
                     ), 255)
                 END,
                 CASE
                     WHEN NOT NEW.is_active
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
                     WHEN NOT NEW.is_active
                         THEN LEFT(COALESCE(
                             pp_setting('product_portal.rbac_revoked_reason'),
                             NEW.revoked_reason,
                             pp_setting('product_portal.rbac_audit_reason')
                         ), 255)
                     ELSE NULL
                 END,
                 CASE
                     WHEN NOT NEW.is_active
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
                     WHEN NOT NEW.is_active
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
        INSERT INTO pp_t_role_permission_grant_audit
            (role_code, permission_code, event_type, previous_active, new_active,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (OLD.role_code, OLD.permission_code, 'REVOKED', OLD.is_active, NULL,
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

UPDATE pp_t_role_permission_grant_audit
SET event_type = 'MIGRATED'
WHERE event_type = 'SCOPE_CHANGED';

ALTER TABLE pp_t_role_permission_grant_audit
    DROP CONSTRAINT IF EXISTS chk_pp_t_role_permission_grant_audit_event_type;

ALTER TABLE pp_t_role_permission_grant_audit
    ADD CONSTRAINT chk_pp_t_role_permission_grant_audit_event_type
        CHECK (event_type IN ('ASSIGNED', 'ACTIVATED', 'DEACTIVATED', 'REVOKED', 'MIGRATED'));

DROP INDEX IF EXISTS idx_pp_t_role_permission_grant_scope_code;
DROP INDEX IF EXISTS idx_pp_t_role_permission_grant_permission_scope_active;
DROP INDEX IF EXISTS idx_pp_t_role_permission_grant_audit_scope_time;

ALTER TABLE pp_t_role_permission_grant
    DROP CONSTRAINT IF EXISTS fk_pp_t_role_permission_grant_scope;

ALTER TABLE pp_t_role_permission_grant
    DROP CONSTRAINT IF EXISTS chk_pp_t_role_permission_grant_scope_code_not_blank;

ALTER TABLE pp_t_role_permission_grant
    DROP COLUMN IF EXISTS scope_code;

ALTER TABLE pp_t_role_permission_grant_audit
    DROP CONSTRAINT IF EXISTS chk_pp_t_role_perm_grant_aud_prev_scope_nb;

ALTER TABLE pp_t_role_permission_grant_audit
    DROP CONSTRAINT IF EXISTS chk_pp_t_role_permission_grant_audit_new_scope_code_not_blank;

ALTER TABLE pp_t_role_permission_grant_audit
    DROP COLUMN IF EXISTS previous_scope_code;

ALTER TABLE pp_t_role_permission_grant_audit
    DROP COLUMN IF EXISTS new_scope_code;

DROP TABLE IF EXISTS pp_r_permission_scope;
