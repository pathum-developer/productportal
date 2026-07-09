-- Seed data is ordered by foreign-key dependencies. Run productportal-schema.sql before this file.

INSERT IGNORE INTO pp_usm_roles
    (role_code, display_name, description, sort_order)
VALUES
    ('BUYER', 'Buyer', 'Customer account that can browse and purchase products.', 1),
    ('SELLER', 'Seller', 'Merchant account that can manage seller-owned catalog data.', 2),
    ('ADMIN', 'Admin', 'Administrative account with elevated product portal privileges.', 3);

INSERT IGNORE INTO pp_usr_user_statuses
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'User can authenticate and use permitted product portal features.', 1),
    ('INACTIVE', 'Inactive', 'User account is retained but cannot authenticate.', 2),
    ('SUSPENDED', 'Suspended', 'User account is temporarily blocked due to policy or risk.', 3),
    ('DELETED', 'Deleted', 'User account is logically removed and retained only for audit history.', 4);

INSERT IGNORE INTO pp_r_category_statuses
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'Category is visible and available for product assignment.', 1),
    ('INACTIVE', 'Inactive', 'Category is retained but hidden from active catalog flows.', 2);

INSERT IGNORE INTO pp_r_brand_statuses
    (status_code, display_name, description, sort_order)
VALUES
    ('ACTIVE', 'Active', 'Brand is visible and available for product assignment.', 1),
    ('INACTIVE', 'Inactive', 'Brand is retained but hidden from active catalog flows.', 2);

INSERT IGNORE INTO pp_r_product_statuses
    (status_code, display_name, description, sort_order)
VALUES
    ('DRAFT', 'Draft', 'Product is incomplete and not visible in active catalog flows.', 1),
    ('ACTIVE', 'Active', 'Product is visible and available in active catalog flows.', 2),
    ('INACTIVE', 'Inactive', 'Product is retained but hidden from active catalog flows.', 3);

INSERT INTO pp_usm_users
    (user_id, username, full_name, email, phone_number, password_hash, role_code, status, created_by)
VALUES
    (5001, 'amal.perera', 'Amal Perera', 'amal.perera@example.com', '+94771110001',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'BUYER', 'ACTIVE', 'SYSTEM'),
    (5002, 'nimali.silva', 'Nimali Silva', 'nimali.silva@example.com', '+94771110002',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'BUYER', 'ACTIVE', 'SYSTEM'),
    (5003, 'dinesh.fernando', 'Dinesh Fernando', 'dinesh.fernando@example.com', '+94771110003',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'SELLER', 'ACTIVE', 'SYSTEM'),
    (5004, 'kavindi.jayasinghe', 'Kavindi Jayasinghe', 'kavindi.jayasinghe@example.com', '+94771110004',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'SELLER', 'ACTIVE', 'SYSTEM'),
    (5005, 'ruwan.wijesinghe', 'Ruwan Wijesinghe', 'ruwan.wijesinghe@example.com', '+94771110005',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'ADMIN', 'ACTIVE', 'SYSTEM'),
    (5006, 'tharushi.gunawardena', 'Tharushi Gunawardena', 'tharushi.gunawardena@example.com', '+94771110006',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'BUYER', 'INACTIVE', 'SYSTEM'),
    (5007, 'kasun.bandara', 'Kasun Bandara', 'kasun.bandara@example.com', '+94771110007',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'SELLER', 'SUSPENDED', 'SYSTEM'),
    (5008, 'anjali.rathnayake', 'Anjali Rathnayake', 'anjali.rathnayake@example.com', '+94771110008',
     '$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2', 'BUYER', 'DELETED', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    username = VALUES(username),
    full_name = VALUES(full_name),
    phone_number = VALUES(phone_number),
    role_code = VALUES(role_code),
    status = VALUES(status),
    updated_by = 'SYSTEM';

INSERT INTO pp_usm_addresses
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

INSERT INTO pp_m_categories
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

INSERT INTO pp_m_categories
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

INSERT INTO pp_m_brands
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

INSERT INTO pp_m_products
    (product_id, category_id, brand_id, name, slug, description, model_number, sku_code, status_code, created_by)
VALUES
    (3001, 1006, 2001, 'iPhone 16 Pro 256GB', 'iphone-16-pro-256gb', 'Premium smartphone with 256GB storage.', 'A3293', 'SKU-IPH16P-256', 'ACTIVE', 'SYSTEM'),
    (3002, 1006, 2002, 'Galaxy S25 Ultra 512GB', 'galaxy-s25-ultra-512gb', 'Flagship Android smartphone with 512GB storage.', 'SM-S938B', 'SKU-GS25U-512', 'ACTIVE', 'SYSTEM'),
    (3003, 1007, 2003, 'Dell XPS 14 Laptop', 'dell-xps-14-laptop', 'Compact performance laptop for professionals.', 'XPS9440', 'SKU-DELL-XPS14', 'ACTIVE', 'SYSTEM'),
    (3004, 1007, 2013, 'Lenovo ThinkPad T14', 'lenovo-thinkpad-t14', 'Business laptop with enterprise manageability.', 'T14-G5', 'SKU-LNV-T14G5', 'ACTIVE', 'SYSTEM'),
    (3005, 1008, 2004, 'Sony WH-1000XM5 Headphones', 'sony-wh-1000xm5-headphones', 'Wireless noise cancelling headphones.', 'WH1000XM5', 'SKU-SONY-XM5', 'ACTIVE', 'SYSTEM'),
    (3006, 1008, 2012, 'Logitech Zone Vibe Wireless', 'logitech-zone-vibe-wireless', 'Wireless headset for calls and media.', 'ZONE-VIBE', 'SKU-LOGI-ZVIBE', 'DRAFT', 'SYSTEM'),
    (3007, 1009, 2005, 'LG 28L Convection Microwave', 'lg-28l-convection-microwave', 'Convection microwave for everyday cooking.', 'MC2886BRUM', 'SKU-LG-MW28', 'ACTIVE', 'SYSTEM'),
    (3008, 1009, 2010, 'Panasonic Blender 1.5L', 'panasonic-blender-15l', 'Kitchen blender with durable stainless blades.', 'MX-EX1551', 'SKU-PANA-BL15', 'ACTIVE', 'SYSTEM'),
    (3009, 1010, 2008, 'IKEA Work Desk Oak Finish', 'ikea-work-desk-oak-finish', 'Minimal home office desk with oak finish.', 'MICKE-OAK', 'SKU-IKEA-DESK01', 'ACTIVE', 'SYSTEM'),
    (3010, 1011, 2006, 'Nike Dri-FIT Training Tee', 'nike-dri-fit-training-tee', 'Mens moisture-wicking training t-shirt.', 'NDF-M-T01', 'SKU-NIKE-TEE01', 'ACTIVE', 'SYSTEM'),
    (3011, 1012, 2007, 'Adidas Essentials Hoodie', 'adidas-essentials-hoodie', 'Womens casual fleece hoodie.', 'ADI-W-H01', 'SKU-ADI-HOOD01', 'ACTIVE', 'SYSTEM'),
    (3012, 1013, 2015, 'Under Armour Training Gloves', 'under-armour-training-gloves', 'Protective gloves for strength training.', 'UA-TG-01', 'SKU-UA-GLOVE01', 'ACTIVE', 'SYSTEM'),
    (3013, 1013, 2006, 'Nike Resistance Band Set', 'nike-resistance-band-set', 'Resistance bands for home workouts.', 'NRB-SET', 'SKU-NIKE-BAND01', 'DRAFT', 'SYSTEM'),
    (3014, 1014, 2011, 'The North Face Trail Tent 2P', 'the-north-face-trail-tent-2p', 'Two-person tent for lightweight camping.', 'TNF-TENT-2P', 'SKU-TNF-TENT2P', 'ACTIVE', 'SYSTEM'),
    (3015, 1015, 2014, 'Revlon Hydrating Face Serum', 'revlon-hydrating-face-serum', 'Hydrating serum for daily skin care routines.', 'RV-SERUM-HY', 'SKU-REV-SER01', 'INACTIVE', 'SYSTEM')
ON DUPLICATE KEY UPDATE
    category_id = VALUES(category_id),
    brand_id = VALUES(brand_id),
    name = VALUES(name),
    description = VALUES(description),
    model_number = VALUES(model_number),
    sku_code = VALUES(sku_code),
    status_code = VALUES(status_code),
    updated_by = 'SYSTEM';

