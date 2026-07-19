--liquibase formatted sql
--changeset elvencode:006-seed-product-portal-demo-users context:demo

-- Demo-only users, memberships, role assignments, and addresses.
-- Do not include the demo context in production deployments.

INSERT INTO pp_m_user
    (user_id, username, full_name, email, phone_number, password_hash, status, primary_organization_id, created_by)
VALUES
    (5001, 'amal.perera', 'Amal Perera', 'amal.perera@example.com', '+94771110001',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ACTIVE', 1, 'SYSTEM'),
    (5002, 'nimali.silva', 'Nimali Silva', 'nimali.silva@example.com', '+94771110002',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ACTIVE', 1, 'SYSTEM'),
    (5003, 'dinesh.fernando', 'Dinesh Fernando', 'dinesh.fernando@example.com', '+94771110003',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ACTIVE', 1, 'SYSTEM'),
    (5004, 'kavindi.jayasinghe', 'Kavindi Jayasinghe', 'kavindi.jayasinghe@example.com', '+94771110004',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ACTIVE', 1, 'SYSTEM'),
    (5005, 'ruwan.wijesinghe', 'Ruwan Wijesinghe', 'ruwan.wijesinghe@example.com', '+94771110005',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ACTIVE', 1, 'SYSTEM'),
    (5006, 'tharushi.gunawardena', 'Tharushi Gunawardena', 'tharushi.gunawardena@example.com', '+94771110006',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'INACTIVE', 1, 'SYSTEM'),
    (5007, 'kasun.bandara', 'Kasun Bandara', 'kasun.bandara@example.com', '+94771110007',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'SUSPENDED', 1, 'SYSTEM'),
    (5008, 'anjali.rathnayake', 'Anjali Rathnayake', 'anjali.rathnayake@example.com', '+94771110008',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'DELETED', 1, 'SYSTEM')
ON CONFLICT (user_id) DO UPDATE SET
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    phone_number = EXCLUDED.phone_number,
    status = EXCLUDED.status,
    primary_organization_id = EXCLUDED.primary_organization_id,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_user.username IS DISTINCT FROM EXCLUDED.username
   OR pp_m_user.full_name IS DISTINCT FROM EXCLUDED.full_name
   OR pp_m_user.email IS DISTINCT FROM EXCLUDED.email
   OR pp_m_user.phone_number IS DISTINCT FROM EXCLUDED.phone_number
   OR pp_m_user.status IS DISTINCT FROM EXCLUDED.status
   OR pp_m_user.primary_organization_id IS DISTINCT FROM EXCLUDED.primary_organization_id;

INSERT INTO pp_t_user_organization_membership
    (user_id, organization_id, membership_status, is_primary, joined_at, created_by)
VALUES
    (5001, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5002, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5003, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5004, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5005, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5006, 1, 'ACTIVE', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5007, 1, 'SUSPENDED', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM'),
    (5008, 1, 'REMOVED', TRUE, CURRENT_TIMESTAMP(6), 'SYSTEM')
ON CONFLICT (user_id, organization_id) DO UPDATE SET
    membership_status = EXCLUDED.membership_status,
    is_primary = EXCLUDED.is_primary,
    joined_at = COALESCE(pp_t_user_organization_membership.joined_at, EXCLUDED.joined_at),
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_t_user_organization_membership.membership_status IS DISTINCT FROM EXCLUDED.membership_status
   OR pp_t_user_organization_membership.is_primary IS DISTINCT FROM EXCLUDED.is_primary
   OR pp_t_user_organization_membership.joined_at IS NULL;

INSERT INTO pp_t_user_role_assignment
    (user_id, organization_id, role_code, is_active)
VALUES
    (5001, 1, 'BUYER', TRUE),
    (5002, 1, 'BUYER', TRUE),
    (5003, 1, 'SELLER', TRUE),
    (5004, 1, 'SELLER', TRUE),
    (5005, 1, 'ADMIN', TRUE),
    (5006, 1, 'BUYER', TRUE),
    (5007, 1, 'SELLER', TRUE),
    (5008, 1, 'BUYER', TRUE)
ON CONFLICT (user_id, organization_id, role_code) DO UPDATE SET
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_t_user_role_assignment.is_active IS DISTINCT FROM EXCLUDED.is_active;

INSERT INTO pp_m_user_address
    (address_id, user_id, recipient_name, phone_number, address_line_1, address_line_2, city, district,
     province, postal_code, country, is_default, created_by)
VALUES
    (6001, 5001, 'Amal Perera', '+94771110001', 'No 12, Lake Road', 'Apartment 2A', 'Colombo',
     'Colombo', 'Western', '00300', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6002, 5002, 'Nimali Silva', '+94771110002', 'No 45, Temple Lane', NULL, 'Kandy',
     'Kandy', 'Central', '20000', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6003, 5003, 'Dinesh Fernando', '+94771110003', 'Warehouse 7, Industrial Zone', 'Phase 1', 'Katunayake',
     'Gampaha', 'Western', '11450', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6004, 5004, 'Kavindi Jayasinghe', '+94771110004', 'No 88, Main Street', 'Shop 3', 'Galle',
     'Galle', 'Southern', '80000', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6005, 5005, 'Ruwan Wijesinghe', '+94771110005', 'Admin Office, Product Portal HQ', 'Level 5', 'Colombo',
     'Colombo', 'Western', '00100', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6006, 5006, 'Tharushi Gunawardena', '+94771110006', 'No 21, Hill View Road', NULL, 'Nuwara Eliya',
     'Nuwara Eliya', 'Central', '22200', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6007, 5007, 'Kasun Bandara', '+94771110007', 'No 14, Market Road', 'Unit B', 'Kurunegala',
     'Kurunegala', 'North Western', '60000', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6008, 5008, 'Anjali Rathnayake', '+94771110008', 'No 9, Beach Road', NULL, 'Matara',
     'Matara', 'Southern', '81000', 'Sri Lanka', TRUE, 'SYSTEM'),
    (6009, 5001, 'Amal Perera', '+94771110001', 'No 75, Station Road', NULL, 'Moratuwa',
     'Colombo', 'Western', '10400', 'Sri Lanka', FALSE, 'SYSTEM')
ON CONFLICT (address_id) DO UPDATE SET
    user_id = EXCLUDED.user_id,
    recipient_name = EXCLUDED.recipient_name,
    phone_number = EXCLUDED.phone_number,
    address_line_1 = EXCLUDED.address_line_1,
    address_line_2 = EXCLUDED.address_line_2,
    city = EXCLUDED.city,
    district = EXCLUDED.district,
    province = EXCLUDED.province,
    postal_code = EXCLUDED.postal_code,
    country = EXCLUDED.country,
    is_default = EXCLUDED.is_default,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_user_address.user_id IS DISTINCT FROM EXCLUDED.user_id
   OR pp_m_user_address.recipient_name IS DISTINCT FROM EXCLUDED.recipient_name
   OR pp_m_user_address.phone_number IS DISTINCT FROM EXCLUDED.phone_number
   OR pp_m_user_address.address_line_1 IS DISTINCT FROM EXCLUDED.address_line_1
   OR pp_m_user_address.address_line_2 IS DISTINCT FROM EXCLUDED.address_line_2
   OR pp_m_user_address.city IS DISTINCT FROM EXCLUDED.city
   OR pp_m_user_address.district IS DISTINCT FROM EXCLUDED.district
   OR pp_m_user_address.province IS DISTINCT FROM EXCLUDED.province
   OR pp_m_user_address.postal_code IS DISTINCT FROM EXCLUDED.postal_code
   OR pp_m_user_address.country IS DISTINCT FROM EXCLUDED.country
   OR pp_m_user_address.is_default IS DISTINCT FROM EXCLUDED.is_default;

SELECT setval(
    pg_get_serial_sequence('pp_m_user', 'user_id'),
    GREATEST((SELECT COALESCE(MAX(user_id), 1) FROM pp_m_user), 1),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('pp_m_user_address', 'address_id'),
    GREATEST((SELECT COALESCE(MAX(address_id), 1) FROM pp_m_user_address), 1),
    TRUE
);
