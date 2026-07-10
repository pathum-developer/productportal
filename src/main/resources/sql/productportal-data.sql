-- Seed data is ordered by foreign-key dependencies. Run productportal-schema.sql before this file.

INSERT IGNORE INTO pp_m_role
    (role_code, display_name, description, sort_order)
VALUES
    ('BUYER', 'Buyer', 'Customer account that can browse and purchase products.', 1),
    ('SELLER', 'Seller', 'Merchant account that can manage seller-owned catalog data.', 2),
    ('ADMIN', 'Admin', 'Administrative account with elevated product portal privileges.', 3);

INSERT IGNORE INTO pp_m_permission
    (permission_code, display_name, description, resource_code, action_code, sort_order)
VALUES
    ('PROFILE_READ', 'Read Profile', 'View own user profile details.', 'PROFILE', 'READ', 1),
    ('PROFILE_UPDATE', 'Update Profile', 'Update own user profile details.', 'PROFILE', 'UPDATE', 2),
    ('ADDRESS_MANAGE', 'Manage Addresses', 'Create, update, and remove own address records.', 'ADDRESS', 'MANAGE', 3),
    ('CATEGORY_READ', 'Read Categories', 'View active catalog categories.', 'CATEGORY', 'READ', 4),
    ('CATEGORY_CREATE', 'Create Categories', 'Create catalog categories.', 'CATEGORY', 'CREATE', 5),
    ('CATEGORY_UPDATE', 'Update Categories', 'Update catalog categories.', 'CATEGORY', 'UPDATE', 6),
    ('CATEGORY_DELETE', 'Delete Categories', 'Remove catalog categories.', 'CATEGORY', 'DELETE', 7),
    ('BRAND_READ', 'Read Brands', 'View active product brands.', 'BRAND', 'READ', 8),
    ('BRAND_CREATE', 'Create Brands', 'Create product brands.', 'BRAND', 'CREATE', 9),
    ('BRAND_UPDATE', 'Update Brands', 'Update product brands.', 'BRAND', 'UPDATE', 10),
    ('BRAND_DELETE', 'Delete Brands', 'Remove product brands.', 'BRAND', 'DELETE', 11),
    ('PRODUCT_READ', 'Read Products', 'View product catalog data.', 'PRODUCT', 'READ', 12),
    ('PRODUCT_CREATE', 'Create Products', 'Create product catalog records.', 'PRODUCT', 'CREATE', 13),
    ('PRODUCT_UPDATE', 'Update Products', 'Update product catalog records.', 'PRODUCT', 'UPDATE', 14),
    ('PRODUCT_DELETE', 'Delete Products', 'Remove product catalog records.', 'PRODUCT', 'DELETE', 15),
    ('USER_READ', 'Read Users', 'View user account details.', 'USER', 'READ', 16),
    ('USER_CREATE', 'Create Users', 'Create user accounts.', 'USER', 'CREATE', 17),
    ('USER_UPDATE', 'Update Users', 'Update user accounts.', 'USER', 'UPDATE', 18),
    ('USER_DELETE', 'Delete Users', 'Remove user accounts.', 'USER', 'DELETE', 19),
    ('ROLE_READ', 'Read Roles', 'View role definitions.', 'ROLE', 'READ', 20),
    ('ROLE_ASSIGN', 'Assign Roles', 'Assign roles to users.', 'ROLE', 'ASSIGN', 21),
    ('ROLE_MANAGE', 'Manage Roles', 'Create, update, and deactivate roles.', 'ROLE', 'MANAGE', 22),
    ('PERMISSION_READ', 'Read Permissions', 'View permission definitions.', 'PERMISSION', 'READ', 23),
    ('PERMISSION_MANAGE', 'Manage Permissions', 'Create, update, and deactivate permissions.', 'PERMISSION', 'MANAGE', 24);

INSERT IGNORE INTO pp_r_permission_scope
    (scope_code, display_name, description, sort_order)
VALUES
    ('SELF', 'Self', 'Permission applies only to the current user account or profile.', 1),
    ('OWNED', 'Owned Resource', 'Permission applies only to resources owned by the current user.', 2),
    ('ORGANIZATION', 'Organization', 'Permission applies to resources inside the selected organization.', 3),
    ('GLOBAL', 'Global', 'Permission applies across all organizations in the platform.', 4);

INSERT IGNORE INTO pp_t_role_permission_grant
    (role_code, permission_code, scope_code)
VALUES
    ('BUYER', 'PROFILE_READ', 'SELF'),
    ('BUYER', 'PROFILE_UPDATE', 'SELF'),
    ('BUYER', 'ADDRESS_MANAGE', 'SELF'),
    ('BUYER', 'CATEGORY_READ', 'ORGANIZATION'),
    ('BUYER', 'BRAND_READ', 'ORGANIZATION'),
    ('BUYER', 'PRODUCT_READ', 'ORGANIZATION'),
    ('SELLER', 'PROFILE_READ', 'SELF'),
    ('SELLER', 'PROFILE_UPDATE', 'SELF'),
    ('SELLER', 'ADDRESS_MANAGE', 'SELF'),
    ('SELLER', 'CATEGORY_READ', 'ORGANIZATION'),
    ('SELLER', 'BRAND_READ', 'ORGANIZATION'),
    ('SELLER', 'PRODUCT_READ', 'ORGANIZATION'),
    ('SELLER', 'PRODUCT_CREATE', 'ORGANIZATION'),
    ('SELLER', 'PRODUCT_UPDATE', 'OWNED'),
    ('ADMIN', 'PROFILE_READ', 'SELF'),
    ('ADMIN', 'PROFILE_UPDATE', 'SELF'),
    ('ADMIN', 'ADDRESS_MANAGE', 'SELF'),
    ('ADMIN', 'CATEGORY_READ', 'ORGANIZATION'),
    ('ADMIN', 'CATEGORY_CREATE', 'ORGANIZATION'),
    ('ADMIN', 'CATEGORY_UPDATE', 'ORGANIZATION'),
    ('ADMIN', 'CATEGORY_DELETE', 'ORGANIZATION'),
    ('ADMIN', 'BRAND_READ', 'ORGANIZATION'),
    ('ADMIN', 'BRAND_CREATE', 'ORGANIZATION'),
    ('ADMIN', 'BRAND_UPDATE', 'ORGANIZATION'),
    ('ADMIN', 'BRAND_DELETE', 'ORGANIZATION'),
    ('ADMIN', 'PRODUCT_READ', 'ORGANIZATION'),
    ('ADMIN', 'PRODUCT_CREATE', 'ORGANIZATION'),
    ('ADMIN', 'PRODUCT_UPDATE', 'ORGANIZATION'),
    ('ADMIN', 'PRODUCT_DELETE', 'ORGANIZATION'),
    ('ADMIN', 'USER_READ', 'ORGANIZATION'),
    ('ADMIN', 'USER_CREATE', 'ORGANIZATION'),
    ('ADMIN', 'USER_UPDATE', 'ORGANIZATION'),
    ('ADMIN', 'USER_DELETE', 'ORGANIZATION'),
    ('ADMIN', 'ROLE_READ', 'ORGANIZATION'),
    ('ADMIN', 'ROLE_ASSIGN', 'ORGANIZATION'),
    ('ADMIN', 'ROLE_MANAGE', 'ORGANIZATION'),
    ('ADMIN', 'PERMISSION_READ', 'ORGANIZATION'),
    ('ADMIN', 'PERMISSION_MANAGE', 'ORGANIZATION');

INSERT IGNORE INTO pp_r_user_status
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'User can authenticate and use permitted product portal features.', 1),
    ('INACTIVE', 'Inactive', 'User account is retained but cannot authenticate.', 2),
    ('SUSPENDED', 'Suspended', 'User account is temporarily blocked due to policy or risk.', 3),
    ('DELETED', 'Deleted', 'User account is logically removed and retained only for audit history.', 4);

INSERT IGNORE INTO pp_r_membership_status
    (status_code, display_name, description, sort_order)
VALUES
    ('INVITED', 'Invited', 'User has been invited to the organization but has not joined yet.', 1),
    ('ACTIVE', 'Active', 'User is an active member of the organization.', 2),
    ('SUSPENDED', 'Suspended', 'User membership is temporarily blocked in the organization.', 3),
    ('LEFT', 'Left', 'User left the organization voluntarily.', 4),
    ('REMOVED', 'Removed', 'User was removed from the organization.', 5);

INSERT INTO pp_m_organization
    (organization_id, organization_code, display_name, legal_name, description, created_by)
VALUES
    (1, 'DEFAULT', 'Default Organization', 'Product Portal',
     'Default organization for existing single-tenant product portal data.', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    display_name = VALUES(display_name),
    legal_name = VALUES(legal_name),
    description = VALUES(description),
    updated_by = 'SYSTEM';

INSERT IGNORE INTO pp_r_category_status
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'Category is visible and available for product assignment.', 1),
    ('INACTIVE', 'Inactive', 'Category is retained but hidden from active catalog flows.', 2);

INSERT IGNORE INTO pp_r_brand_status
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'Brand is visible and available for product assignment.', 1),
    ('INACTIVE', 'Inactive', 'Brand is retained but hidden from active catalog flows.', 2);

INSERT IGNORE INTO pp_r_product_status
    (status_code, display_name, description, sort_order)
VALUES
    ('DRAFT', 'Draft', 'Product is incomplete and not visible in active catalog flows.', 1),
    ('ACTIVE', 'Active', 'Product is visible and available in active catalog flows.', 2),
    ('INACTIVE', 'Inactive', 'Product is retained but hidden from active catalog flows.', 3);

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
ON DUPLICATE KEY UPDATE
    username = VALUES(username),
    full_name = VALUES(full_name),
    phone_number = VALUES(phone_number),
    status = VALUES(status),
    primary_organization_id = VALUES(primary_organization_id),
    updated_by = 'SYSTEM';

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
ON DUPLICATE KEY UPDATE
    membership_status = VALUES(membership_status),
    is_primary = VALUES(is_primary),
    joined_at = VALUES(joined_at),
    updated_by = 'SYSTEM';

INSERT IGNORE INTO pp_t_user_role_assignment
    (user_id, organization_id, role_code)
VALUES
    (5001, 1, 'BUYER'),
    (5002, 1, 'BUYER'),
    (5003, 1, 'SELLER'),
    (5004, 1, 'SELLER'),
    (5005, 1, 'ADMIN'),
    (5006, 1, 'BUYER'),
    (5007, 1, 'SELLER'),
    (5008, 1, 'BUYER');

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
ON DUPLICATE KEY UPDATE
    recipient_name = VALUES(recipient_name),
    phone_number = VALUES(phone_number),
    address_line_1 = VALUES(address_line_1),
    address_line_2 = VALUES(address_line_2),
    city = VALUES(city),
    district = VALUES(district),
    province = VALUES(province),
    postal_code = VALUES(postal_code),
    country = VALUES(country),
    is_default = VALUES(is_default),
    updated_by = 'SYSTEM';

INSERT INTO pp_m_category
    (category_id, parent_category_id, name, slug, status_code, sort_order, created_by)
VALUES
    (1001, NULL, 'Electronics', 'electronics', 'ACTIVE', 1, 'SYSTEM'),
    (1002, NULL, 'Home and Living', 'home-and-living', 'ACTIVE', 2, 'SYSTEM'),
    (1003, NULL, 'Fashion', 'fashion', 'ACTIVE', 3, 'SYSTEM'),
    (1004, NULL, 'Sports and Outdoors', 'sports-and-outdoors', 'ACTIVE', 4, 'SYSTEM'),
    (1005, NULL, 'Health and Beauty', 'health-and-beauty', 'ACTIVE', 5, 'SYSTEM')
ON DUPLICATE KEY UPDATE
    parent_category_id = VALUES(parent_category_id),
    name = VALUES(name),
    status_code = VALUES(status_code),
    sort_order = VALUES(sort_order),
    updated_by = 'SYSTEM';

INSERT INTO pp_m_category
    (category_id, parent_category_id, name, slug, status_code, sort_order, created_by)
VALUES
    (1006, 1001, 'Smartphones', 'smartphones', 'ACTIVE', 1, 'SYSTEM'),
    (1007, 1001, 'Laptops', 'laptops', 'ACTIVE', 2, 'SYSTEM'),
    (1008, 1001, 'Audio Devices', 'audio-devices', 'ACTIVE', 3, 'SYSTEM'),
    (1009, 1002, 'Kitchen Appliances', 'kitchen-appliances', 'ACTIVE', 1, 'SYSTEM'),
    (1010, 1002, 'Furniture', 'furniture', 'ACTIVE', 2, 'SYSTEM'),
    (1011, 1003, 'Mens Clothing', 'mens-clothing', 'ACTIVE', 1, 'SYSTEM'),
    (1012, 1003, 'Womens Clothing', 'womens-clothing', 'ACTIVE', 2, 'SYSTEM'),
    (1013, 1004, 'Fitness Equipment', 'fitness-equipment', 'ACTIVE', 1, 'SYSTEM'),
    (1014, 1004, 'Camping Gear', 'camping-gear', 'ACTIVE', 2, 'SYSTEM'),
    (1015, 1005, 'Skin Care', 'skin-care', 'INACTIVE', 1, 'SYSTEM')
ON DUPLICATE KEY UPDATE
    parent_category_id = VALUES(parent_category_id),
    name = VALUES(name),
    status_code = VALUES(status_code),
    sort_order = VALUES(sort_order),
    updated_by = 'SYSTEM';

INSERT INTO pp_m_brand
    (brand_id, name, slug, description, logo_url, status_code, created_by)
VALUES
    (2001, 'Apple', 'apple', 'Consumer electronics and computing devices.', 'https://cdn.productportal.local/brands/apple.png', 'ACTIVE', 'SYSTEM'),
    (2002, 'Samsung', 'samsung', 'Consumer electronics, mobile devices, and appliances.', 'https://cdn.productportal.local/brands/samsung.png', 'ACTIVE', 'SYSTEM'),
    (2003, 'Dell', 'dell', 'Business and personal computing devices.', 'https://cdn.productportal.local/brands/dell.png', 'ACTIVE', 'SYSTEM'),
    (2004, 'Sony', 'sony', 'Audio, entertainment, and electronics products.', 'https://cdn.productportal.local/brands/sony.png', 'ACTIVE', 'SYSTEM'),
    (2005, 'LG', 'lg', 'Home appliances and consumer electronics.', 'https://cdn.productportal.local/brands/lg.png', 'ACTIVE', 'SYSTEM'),
    (2006, 'Nike', 'nike', 'Sportswear, footwear, and fitness products.', 'https://cdn.productportal.local/brands/nike.png', 'ACTIVE', 'SYSTEM'),
    (2007, 'Adidas', 'adidas', 'Sportswear, footwear, and outdoor products.', 'https://cdn.productportal.local/brands/adidas.png', 'ACTIVE', 'SYSTEM'),
    (2008, 'IKEA', 'ikea', 'Furniture and home living products.', 'https://cdn.productportal.local/brands/ikea.png', 'ACTIVE', 'SYSTEM'),
    (2009, 'Philips', 'philips', 'Health, beauty, and home appliance products.', 'https://cdn.productportal.local/brands/philips.png', 'ACTIVE', 'SYSTEM'),
    (2010, 'Panasonic', 'panasonic', 'Appliances and consumer electronics.', 'https://cdn.productportal.local/brands/panasonic.png', 'ACTIVE', 'SYSTEM'),
    (2011, 'The North Face', 'the-north-face', 'Outdoor apparel and camping equipment.', 'https://cdn.productportal.local/brands/the-north-face.png', 'ACTIVE', 'SYSTEM'),
    (2012, 'Logitech', 'logitech', 'Computer accessories and audio peripherals.', 'https://cdn.productportal.local/brands/logitech.png', 'ACTIVE', 'SYSTEM'),
    (2013, 'Lenovo', 'lenovo', 'Computing devices and accessories.', 'https://cdn.productportal.local/brands/lenovo.png', 'ACTIVE', 'SYSTEM'),
    (2014, 'Revlon', 'revlon', 'Beauty and personal care products.', 'https://cdn.productportal.local/brands/revlon.png', 'INACTIVE', 'SYSTEM'),
    (2015, 'Under Armour', 'under-armour', 'Sportswear and performance products.', 'https://cdn.productportal.local/brands/under-armour.png', 'ACTIVE', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description),
    logo_url = VALUES(logo_url),
    status_code = VALUES(status_code),
    updated_by = 'SYSTEM';

INSERT INTO pp_m_product
    (product_id, organization_id, owner_user_id, category_id, brand_id, name, slug, description, model_number, sku_code, status_code, created_by)
VALUES
    (3001, 1, 5003, 1006, 2001, 'iPhone 16 Pro 256GB', 'iphone-16-pro-256gb', 'Premium smartphone with 256GB storage.', 'A3293', 'SKU-IPH16P-256', 'ACTIVE', 'SYSTEM'),
    (3002, 1, 5003, 1006, 2002, 'Galaxy S25 Ultra 512GB', 'galaxy-s25-ultra-512gb', 'Flagship Android smartphone with 512GB storage.', 'SM-S938B', 'SKU-GS25U-512', 'ACTIVE', 'SYSTEM'),
    (3003, 1, 5003, 1007, 2003, 'Dell XPS 14 Laptop', 'dell-xps-14-laptop', 'Compact performance laptop for professionals.', 'XPS9440', 'SKU-DELL-XPS14', 'ACTIVE', 'SYSTEM'),
    (3004, 1, 5003, 1007, 2013, 'Lenovo ThinkPad T14', 'lenovo-thinkpad-t14', 'Business laptop with enterprise manageability.', 'T14-G5', 'SKU-LNV-T14G5', 'ACTIVE', 'SYSTEM'),
    (3005, 1, 5003, 1008, 2004, 'Sony WH-1000XM5 Headphones', 'sony-wh-1000xm5-headphones', 'Wireless noise cancelling headphones.', 'WH1000XM5', 'SKU-SONY-XM5', 'ACTIVE', 'SYSTEM'),
    (3006, 1, 5003, 1008, 2012, 'Logitech Zone Vibe Wireless', 'logitech-zone-vibe-wireless', 'Wireless headset for calls and media.', 'ZONE-VIBE', 'SKU-LOGI-ZVIBE', 'DRAFT', 'SYSTEM'),
    (3007, 1, 5003, 1009, 2005, 'LG 28L Convection Microwave', 'lg-28l-convection-microwave', 'Convection microwave for everyday cooking.', 'MC2886BRUM', 'SKU-LG-MW28', 'ACTIVE', 'SYSTEM'),
    (3008, 1, 5003, 1009, 2010, 'Panasonic Blender 1.5L', 'panasonic-blender-15l', 'Kitchen blender with durable stainless blades.', 'MX-EX1551', 'SKU-PANA-BL15', 'ACTIVE', 'SYSTEM'),
    (3009, 1, 5004, 1010, 2008, 'IKEA Work Desk Oak Finish', 'ikea-work-desk-oak-finish', 'Minimal home office desk with oak finish.', 'MICKE-OAK', 'SKU-IKEA-DESK01', 'ACTIVE', 'SYSTEM'),
    (3010, 1, 5004, 1011, 2006, 'Nike Dri-FIT Training Tee', 'nike-dri-fit-training-tee', 'Mens moisture-wicking training t-shirt.', 'NDF-M-T01', 'SKU-NIKE-TEE01', 'ACTIVE', 'SYSTEM'),
    (3011, 1, 5004, 1012, 2007, 'Adidas Essentials Hoodie', 'adidas-essentials-hoodie', 'Womens casual fleece hoodie.', 'ADI-W-H01', 'SKU-ADI-HOOD01', 'ACTIVE', 'SYSTEM'),
    (3012, 1, 5004, 1013, 2015, 'Under Armour Training Gloves', 'under-armour-training-gloves', 'Protective gloves for strength training.', 'UA-TG-01', 'SKU-UA-GLOVE01', 'ACTIVE', 'SYSTEM'),
    (3013, 1, 5004, 1013, 2006, 'Nike Resistance Band Set', 'nike-resistance-band-set', 'Resistance bands for home workouts.', 'NRB-SET', 'SKU-NIKE-BAND01', 'DRAFT', 'SYSTEM'),
    (3014, 1, 5004, 1014, 2011, 'The North Face Trail Tent 2P', 'the-north-face-trail-tent-2p', 'Two-person tent for lightweight camping.', 'TNF-TENT-2P', 'SKU-TNF-TENT2P', 'ACTIVE', 'SYSTEM'),
    (3015, 1, 5004, 1015, 2014, 'Revlon Hydrating Face Serum', 'revlon-hydrating-face-serum', 'Hydrating serum for daily skin care routines.', 'RV-SERUM-HY', 'SKU-REV-SER01', 'INACTIVE', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    organization_id = VALUES(organization_id),
    owner_user_id = VALUES(owner_user_id),
    category_id = VALUES(category_id),
    brand_id = VALUES(brand_id),
    name = VALUES(name),
    description = VALUES(description),
    model_number = VALUES(model_number),
    sku_code = VALUES(sku_code),
    status_code = VALUES(status_code),
    updated_by = 'SYSTEM';

