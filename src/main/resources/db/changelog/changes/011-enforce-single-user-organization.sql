--liquibase formatted sql
--changeset elvencode:011-enforce-single-user-organization

-- Users now belong to exactly one organization.
-- Membership rows are retained as legacy history, but no active authorization path depends on them.

ALTER TABLE pp_t_user_role_assignment
    DROP CONSTRAINT IF EXISTS fk_pp_t_user_role_assignment_membership;

DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_ai ON pp_t_user_organization_membership;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_au ON pp_t_user_organization_membership;
DROP TRIGGER IF EXISTS trg_pp_t_user_organization_membership_ad ON pp_t_user_organization_membership;
DROP FUNCTION IF EXISTS trg_pp_t_user_organization_membership_audit_fn();

ALTER TABLE pp_m_user
    DROP CONSTRAINT IF EXISTS fk_pp_m_user_primary_organization;

ALTER TABLE pp_m_user
    RENAME COLUMN primary_organization_id TO organization_id;

DROP INDEX IF EXISTS idx_pp_m_user_primary_organization_id;

UPDATE pp_m_user AS portal_user
SET organization_id = COALESCE(
        portal_user.organization_id,
        (
            SELECT membership.organization_id
            FROM pp_t_user_organization_membership AS membership
            WHERE membership.user_id = portal_user.user_id
            ORDER BY membership.is_primary DESC,
                     CASE membership.membership_status
                         WHEN 'ACTIVE' THEN 1
                         WHEN 'INVITED' THEN 2
                         WHEN 'SUSPENDED' THEN 3
                         WHEN 'LEFT' THEN 4
                         WHEN 'REMOVED' THEN 5
                         ELSE 6
                     END,
                     membership.joined_at NULLS LAST,
                     membership.organization_id
            LIMIT 1
        ),
        (
            SELECT organization.organization_id
            FROM pp_m_organization AS organization
            WHERE organization.organization_code = 'DEFAULT'
            LIMIT 1
        ),
        (
            SELECT organization.organization_id
            FROM pp_m_organization AS organization
            ORDER BY organization.organization_id
            LIMIT 1
        )
    )
WHERE portal_user.organization_id IS NULL;

ALTER TABLE pp_m_user
    ALTER COLUMN organization_id SET NOT NULL;

ALTER TABLE pp_m_user
    ADD CONSTRAINT fk_pp_m_user_organization
        FOREIGN KEY (organization_id) REFERENCES pp_m_organization (organization_id);

CREATE INDEX IF NOT EXISTS idx_pp_m_user_organization_id ON pp_m_user (organization_id);

DELETE FROM pp_t_user_role_assignment AS role_assignment
USING pp_m_user AS portal_user
WHERE role_assignment.user_id = portal_user.user_id
  AND role_assignment.organization_id <> portal_user.organization_id;

ALTER TABLE pp_t_user_role_assignment
    ALTER COLUMN organization_id DROP DEFAULT;

ALTER TABLE pp_m_user
    ADD CONSTRAINT uk_pp_m_user_id_organization UNIQUE (user_id, organization_id);

ALTER TABLE pp_t_user_role_assignment
    ADD CONSTRAINT fk_pp_t_user_role_assignment_user_organization
        FOREIGN KEY (user_id, organization_id)
        REFERENCES pp_m_user (user_id, organization_id)
        ON DELETE CASCADE;

DELETE FROM pp_t_user_organization_membership AS membership
USING pp_m_user AS portal_user
WHERE membership.user_id = portal_user.user_id
  AND membership.organization_id <> portal_user.organization_id;

ALTER TABLE pp_t_user_organization_membership
    ADD CONSTRAINT uk_pp_t_user_organization_membership_user UNIQUE (user_id);

ALTER TABLE pp_t_user_organization_membership
    ADD CONSTRAINT fk_pp_t_user_organization_membership_user_organization
        FOREIGN KEY (user_id, organization_id)
        REFERENCES pp_m_user (user_id, organization_id)
        ON DELETE CASCADE;
