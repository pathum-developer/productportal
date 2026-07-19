--liquibase formatted sql
--changeset elvencode:002-create-product-portal-audit-triggers splitStatements:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT CASE WHEN COUNT(*) = 0 THEN 0 WHEN COUNT(*) = 9 THEN 1 ELSE 1 / (COUNT(*) - COUNT(*)) END FROM pg_catalog.pg_trigger t JOIN pg_catalog.pg_class c ON c.oid = t.tgrelid JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = current_schema() AND NOT t.tgisinternal AND t.tgname IN ('trg_pp_t_user_organization_membership_ai','trg_pp_t_user_organization_membership_au','trg_pp_t_user_organization_membership_ad','trg_pp_t_user_role_assignment_ai','trg_pp_t_user_role_assignment_au','trg_pp_t_user_role_assignment_ad','trg_pp_t_role_permission_grant_ai','trg_pp_t_role_permission_grant_au','trg_pp_t_role_permission_grant_ad')
--comment: Runs only when Product Portal audit triggers are absent. Complete existing trigger sets are marked as already ran.

-- PostgreSQL audit and synchronization triggers for Product Portal.
-- Custom audit context can be supplied per transaction with SET LOCAL product_portal.<key> = '<value>'.

CREATE OR REPLACE FUNCTION pp_setting(setting_name TEXT)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN NULLIF(current_setting(setting_name, TRUE), '');
END;
$$;

CREATE OR REPLACE FUNCTION pp_setting_bool(setting_name TEXT, default_value BOOLEAN)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    setting_value TEXT := pp_setting(setting_name);
BEGIN
    IF setting_value IS NULL THEN
        RETURN default_value;
    END IF;

    CASE lower(setting_value)
        WHEN 'true' THEN RETURN TRUE;
        WHEN 't' THEN RETURN TRUE;
        WHEN '1' THEN RETURN TRUE;
        WHEN 'on' THEN RETURN TRUE;
        WHEN 'yes' THEN RETURN TRUE;
        WHEN 'false' THEN RETURN FALSE;
        WHEN 'f' THEN RETURN FALSE;
        WHEN '0' THEN RETURN FALSE;
        WHEN 'off' THEN RETURN FALSE;
        WHEN 'no' THEN RETURN FALSE;
        ELSE RETURN default_value;
    END CASE;
END;
$$;

CREATE OR REPLACE FUNCTION trg_pp_t_user_organization_membership_audit_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.is_primary
           AND NOT pp_setting_bool('product_portal.org_membership_skip_user_sync', FALSE) THEN
            UPDATE pp_m_user
            SET primary_organization_id = NEW.organization_id,
                updated_at = CURRENT_TIMESTAMP(6),
                updated_by = LEFT(COALESCE(
                    pp_setting('product_portal.rbac_audit_actor'),
                    NEW.created_by,
                    'SYSTEM'
                ), 100)
            WHERE user_id = NEW.user_id
              AND primary_organization_id IS DISTINCT FROM NEW.organization_id;
        END IF;

        INSERT INTO pp_t_user_organization_membership_audit
            (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
             previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
             new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
             source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id,
             LEFT(COALESCE(
                  pp_setting('product_portal.org_membership_event_type'),
                  CASE
                      WHEN NEW.membership_status = 'INVITED' THEN 'INVITED'
                      WHEN NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                      WHEN NEW.membership_status = 'LEFT' THEN 'LEFT'
                      WHEN NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                      ELSE 'JOINED'
                  END
              ), 30),
             NULL, NEW.membership_status,
             NULL, NEW.is_primary,
             NULL, NEW.joined_at,
             NULL, NEW.invited_by,
             NULL, NEW.invited_at,
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_audit_actor'),
                 NEW.created_by,
                 NEW.invited_by,
                 'SYSTEM'
             ), 100),
             LEFT(CURRENT_USER::TEXT, 100),
             LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
             LEFT(pp_setting('product_portal.rbac_audit_reason'), 255),
             LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));

        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.is_primary
           AND NOT pp_setting_bool('product_portal.org_membership_skip_user_sync', FALSE) THEN
            UPDATE pp_m_user
            SET primary_organization_id = NEW.organization_id,
                updated_at = CURRENT_TIMESTAMP(6),
                updated_by = LEFT(COALESCE(
                    pp_setting('product_portal.rbac_audit_actor'),
                    NEW.updated_by,
                    NEW.created_by,
                    'SYSTEM'
                ), 100)
            WHERE user_id = NEW.user_id
              AND primary_organization_id IS DISTINCT FROM NEW.organization_id;
        ELSIF OLD.is_primary
              AND NOT pp_setting_bool('product_portal.org_membership_skip_user_sync', FALSE) THEN
            UPDATE pp_m_user
            SET primary_organization_id = NULL,
                updated_at = CURRENT_TIMESTAMP(6),
                updated_by = LEFT(COALESCE(
                    pp_setting('product_portal.rbac_audit_actor'),
                    NEW.updated_by,
                    NEW.created_by,
                    'SYSTEM'
                ), 100)
            WHERE user_id = NEW.user_id
              AND primary_organization_id = OLD.organization_id;
        END IF;

        IF OLD.membership_status IS DISTINCT FROM NEW.membership_status
           OR OLD.is_primary IS DISTINCT FROM NEW.is_primary
           OR OLD.joined_at IS DISTINCT FROM NEW.joined_at
           OR OLD.invited_by IS DISTINCT FROM NEW.invited_by
           OR OLD.invited_at IS DISTINCT FROM NEW.invited_at THEN
            INSERT INTO pp_t_user_organization_membership_audit
                (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
                 previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
                 new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
                 source_code, change_reason, correlation_id)
            VALUES
                (NEW.user_id, NEW.organization_id,
                 CASE
                     WHEN OLD.membership_status IS DISTINCT FROM NEW.membership_status
                          AND NEW.membership_status = 'ACTIVE' THEN 'ACTIVATED'
                     WHEN OLD.membership_status IS DISTINCT FROM NEW.membership_status
                          AND NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                     WHEN OLD.membership_status IS DISTINCT FROM NEW.membership_status
                          AND NEW.membership_status = 'LEFT' THEN 'LEFT'
                     WHEN OLD.membership_status IS DISTINCT FROM NEW.membership_status
                          AND NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                     WHEN OLD.is_primary IS DISTINCT FROM NEW.is_primary THEN 'PRIMARY_CHANGED'
                     ELSE 'DETAILS_CHANGED'
                 END,
                 OLD.membership_status, NEW.membership_status,
                 OLD.is_primary, NEW.is_primary,
                 OLD.joined_at, NEW.joined_at,
                 OLD.invited_by, NEW.invited_by,
                 OLD.invited_at, NEW.invited_at,
                 LEFT(COALESCE(
                     pp_setting('product_portal.rbac_audit_actor'),
                     NEW.updated_by,
                     NEW.created_by,
                     'SYSTEM'
                 ), 100),
                 LEFT(CURRENT_USER::TEXT, 100),
                 LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
                 LEFT(pp_setting('product_portal.rbac_audit_reason'), 255),
                 LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));
        END IF;

        RETURN NEW;
    ELSE
        IF OLD.is_primary
           AND NOT pp_setting_bool('product_portal.org_membership_skip_user_sync', FALSE) THEN
            UPDATE pp_m_user
            SET primary_organization_id = NULL,
                updated_at = CURRENT_TIMESTAMP(6),
                updated_by = LEFT(COALESCE(
                    pp_setting('product_portal.rbac_audit_actor'),
                    OLD.updated_by,
                    OLD.created_by,
                    'SYSTEM'
                ), 100)
            WHERE user_id = OLD.user_id
              AND primary_organization_id = OLD.organization_id;
        END IF;

        INSERT INTO pp_t_user_organization_membership_audit
            (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
             previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
             new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
             source_code, change_reason, correlation_id)
        VALUES
            (OLD.user_id, OLD.organization_id, 'REMOVED',
             OLD.membership_status, NULL,
             OLD.is_primary, NULL,
             OLD.joined_at, NULL,
             OLD.invited_by, NULL,
             OLD.invited_at, NULL,
             LEFT(COALESCE(
                 pp_setting('product_portal.rbac_audit_actor'),
                 OLD.updated_by,
                 OLD.created_by,
                 'SYSTEM'
             ), 100),
             LEFT(CURRENT_USER::TEXT, 100),
             LEFT(COALESCE(pp_setting('product_portal.rbac_audit_source'), 'DATABASE_TRIGGER'), 30),
             LEFT(pp_setting('product_portal.rbac_audit_reason'), 255),
             LEFT(pp_setting('product_portal.rbac_audit_correlation_id'), 100));

        RETURN OLD;
    END IF;
END;
$$;

CREATE TRIGGER trg_pp_t_user_organization_membership_ai
AFTER INSERT ON pp_t_user_organization_membership
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_organization_membership_audit_fn();

CREATE TRIGGER trg_pp_t_user_organization_membership_au
AFTER UPDATE ON pp_t_user_organization_membership
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_organization_membership_audit_fn();

CREATE TRIGGER trg_pp_t_user_organization_membership_ad
AFTER DELETE ON pp_t_user_organization_membership
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_organization_membership_audit_fn();

CREATE OR REPLACE FUNCTION trg_pp_t_user_role_assignment_audit_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO pp_t_user_role_assignment_audit
            (user_id, organization_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
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
                (NEW.user_id, NEW.organization_id, NEW.role_code,
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
            (OLD.user_id, OLD.organization_id, OLD.role_code, 'REVOKED', OLD.is_active, NULL,
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

CREATE TRIGGER trg_pp_t_user_role_assignment_ai
AFTER INSERT ON pp_t_user_role_assignment
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_role_assignment_audit_fn();

CREATE TRIGGER trg_pp_t_user_role_assignment_au
AFTER UPDATE ON pp_t_user_role_assignment
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_role_assignment_audit_fn();

CREATE TRIGGER trg_pp_t_user_role_assignment_ad
AFTER DELETE ON pp_t_user_role_assignment
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_user_role_assignment_audit_fn();

CREATE OR REPLACE FUNCTION trg_pp_t_role_permission_grant_audit_fn()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO pp_t_role_permission_grant_audit
            (role_code, permission_code, event_type, previous_active, new_active,
             previous_scope_code, new_scope_code,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.role_code, NEW.permission_code, 'ASSIGNED', NULL, NEW.is_active,
             NULL, NEW.scope_code,
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
           OR OLD.scope_code IS DISTINCT FROM NEW.scope_code THEN
            INSERT INTO pp_t_role_permission_grant_audit
                (role_code, permission_code, event_type, previous_active, new_active,
                 previous_scope_code, new_scope_code,
                 assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
                 database_user, source_code, change_reason, correlation_id)
            VALUES
                (NEW.role_code, NEW.permission_code,
                 CASE
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active AND NEW.is_active THEN 'ACTIVATED'
                     WHEN OLD.is_active IS DISTINCT FROM NEW.is_active THEN 'DEACTIVATED'
                     ELSE 'SCOPE_CHANGED'
                 END,
                 OLD.is_active, NEW.is_active,
                 OLD.scope_code, NEW.scope_code,
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
        INSERT INTO pp_t_role_permission_grant_audit
            (role_code, permission_code, event_type, previous_active, new_active,
             previous_scope_code, new_scope_code,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (OLD.role_code, OLD.permission_code, 'REVOKED', OLD.is_active, NULL,
             OLD.scope_code, NULL,
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

CREATE TRIGGER trg_pp_t_role_permission_grant_ai
AFTER INSERT ON pp_t_role_permission_grant
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_role_permission_grant_audit_fn();

CREATE TRIGGER trg_pp_t_role_permission_grant_au
AFTER UPDATE ON pp_t_role_permission_grant
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_role_permission_grant_audit_fn();

CREATE TRIGGER trg_pp_t_role_permission_grant_ad
AFTER DELETE ON pp_t_role_permission_grant
FOR EACH ROW
EXECUTE FUNCTION trg_pp_t_role_permission_grant_audit_fn();
