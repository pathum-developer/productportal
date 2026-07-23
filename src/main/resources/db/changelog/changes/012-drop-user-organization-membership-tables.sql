--liquibase formatted sql
--changeset elvencode:012-drop-user-organization-membership-tables

-- The single-organization user model no longer needs the legacy membership model.
DROP TABLE IF EXISTS pp_t_user_organization_membership_audit;
DROP TABLE IF EXISTS pp_t_user_organization_membership;
DROP TABLE IF EXISTS pp_r_membership_status;
