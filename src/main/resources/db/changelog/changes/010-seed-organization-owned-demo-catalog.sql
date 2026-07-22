--liquibase formatted sql
--changeset elvencode:010-seed-organization-owned-demo-catalog context:demo

-- Replacement for the legacy 007 demo seed. It intentionally contains no user-product ownership.

INSERT INTO pp_m_category
    (category_id, parent_category_id, name, slug, status_code, sort_order, created_by)
VALUES
    (1001, NULL, 'Electronics', 'electronics', 'ACTIVE', 1, 'SYSTEM'),
    (1002, NULL, 'Home and Living', 'home-and-living', 'ACTIVE', 2, 'SYSTEM'),
    (1003, NULL, 'Fashion', 'fashion', 'ACTIVE', 3, 'SYSTEM'),
    (1004, NULL, 'Sports and Outdoors', 'sports-and-outdoors', 'ACTIVE', 4, 'SYSTEM'),
    (1005, NULL, 'Health and Beauty', 'health-and-beauty', 'ACTIVE', 5, 'SYSTEM')
ON CONFLICT (category_id) DO UPDATE SET
    parent_category_id = EXCLUDED.parent_category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    status_code = EXCLUDED.status_code,
    sort_order = EXCLUDED.sort_order,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_category.parent_category_id IS DISTINCT FROM EXCLUDED.parent_category_id
   OR pp_m_category.name IS DISTINCT FROM EXCLUDED.name
   OR pp_m_category.slug IS DISTINCT FROM EXCLUDED.slug
   OR pp_m_category.status_code IS DISTINCT FROM EXCLUDED.status_code
   OR pp_m_category.sort_order IS DISTINCT FROM EXCLUDED.sort_order;

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
ON CONFLICT (category_id) DO UPDATE SET
    parent_category_id = EXCLUDED.parent_category_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    status_code = EXCLUDED.status_code,
    sort_order = EXCLUDED.sort_order,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_category.parent_category_id IS DISTINCT FROM EXCLUDED.parent_category_id
   OR pp_m_category.name IS DISTINCT FROM EXCLUDED.name
   OR pp_m_category.slug IS DISTINCT FROM EXCLUDED.slug
   OR pp_m_category.status_code IS DISTINCT FROM EXCLUDED.status_code
   OR pp_m_category.sort_order IS DISTINCT FROM EXCLUDED.sort_order;

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
ON CONFLICT (brand_id) DO UPDATE SET
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    logo_url = EXCLUDED.logo_url,
    status_code = EXCLUDED.status_code,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_brand.name IS DISTINCT FROM EXCLUDED.name
   OR pp_m_brand.slug IS DISTINCT FROM EXCLUDED.slug
   OR pp_m_brand.description IS DISTINCT FROM EXCLUDED.description
   OR pp_m_brand.logo_url IS DISTINCT FROM EXCLUDED.logo_url
   OR pp_m_brand.status_code IS DISTINCT FROM EXCLUDED.status_code;

INSERT INTO pp_m_product
    (product_id, organization_id, category_id, brand_id, name, slug, description, model_number, sku_code, status_code, created_by)
VALUES
    (3001, 1, 1006, 2001, 'iPhone 16 Pro 256GB', 'iphone-16-pro-256gb', 'Premium smartphone with 256GB storage.', 'A3293', 'SKU-IPH16P-256', 'ACTIVE', 'SYSTEM'),
    (3002, 1, 1006, 2002, 'Galaxy S25 Ultra 512GB', 'galaxy-s25-ultra-512gb', 'Flagship Android smartphone with 512GB storage.', 'SM-S938B', 'SKU-GS25U-512', 'ACTIVE', 'SYSTEM'),
    (3003, 1, 1007, 2003, 'Dell XPS 14 Laptop', 'dell-xps-14-laptop', 'Compact performance laptop for professionals.', 'XPS9440', 'SKU-DELL-XPS14', 'ACTIVE', 'SYSTEM'),
    (3004, 1, 1007, 2013, 'Lenovo ThinkPad T14', 'lenovo-thinkpad-t14', 'Business laptop with enterprise manageability.', 'T14-G5', 'SKU-LNV-T14G5', 'ACTIVE', 'SYSTEM'),
    (3005, 1, 1008, 2004, 'Sony WH-1000XM5 Headphones', 'sony-wh-1000xm5-headphones', 'Wireless noise cancelling headphones.', 'WH1000XM5', 'SKU-SONY-XM5', 'ACTIVE', 'SYSTEM'),
    (3006, 1, 1008, 2012, 'Logitech Zone Vibe Wireless', 'logitech-zone-vibe-wireless', 'Wireless headset for calls and media.', 'ZONE-VIBE', 'SKU-LOGI-ZVIBE', 'DRAFT', 'SYSTEM'),
    (3007, 1, 1009, 2005, 'LG 28L Convection Microwave', 'lg-28l-convection-microwave', 'Convection microwave for everyday cooking.', 'MC2886BRUM', 'SKU-LG-MW28', 'ACTIVE', 'SYSTEM'),
    (3008, 1, 1009, 2010, 'Panasonic Blender 1.5L', 'panasonic-blender-15l', 'Kitchen blender with durable stainless blades.', 'MX-EX1551', 'SKU-PANA-BL15', 'ACTIVE', 'SYSTEM'),
    (3009, 1, 1010, 2008, 'IKEA Work Desk Oak Finish', 'ikea-work-desk-oak-finish', 'Minimal home office desk with oak finish.', 'MICKE-OAK', 'SKU-IKEA-DESK01', 'ACTIVE', 'SYSTEM'),
    (3010, 1, 1011, 2006, 'Nike Dri-FIT Training Tee', 'nike-dri-fit-training-tee', 'Mens moisture-wicking training t-shirt.', 'NDF-M-T01', 'SKU-NIKE-TEE01', 'ACTIVE', 'SYSTEM'),
    (3011, 1, 1012, 2007, 'Adidas Essentials Hoodie', 'adidas-essentials-hoodie', 'Womens casual fleece hoodie.', 'ADI-W-H01', 'SKU-ADI-HOOD01', 'ACTIVE', 'SYSTEM'),
    (3012, 1, 1013, 2015, 'Under Armour Training Gloves', 'under-armour-training-gloves', 'Protective gloves for strength training.', 'UA-TG-01', 'SKU-UA-GLOVE01', 'ACTIVE', 'SYSTEM'),
    (3013, 1, 1013, 2006, 'Nike Resistance Band Set', 'nike-resistance-band-set', 'Resistance bands for home workouts.', 'NRB-SET', 'SKU-NIKE-BAND01', 'DRAFT', 'SYSTEM'),
    (3014, 1, 1014, 2011, 'The North Face Trail Tent 2P', 'the-north-face-trail-tent-2p', 'Two-person tent for lightweight camping.', 'TNF-TENT-2P', 'SKU-TNF-TENT2P', 'ACTIVE', 'SYSTEM'),
    (3015, 1, 1015, 2014, 'Revlon Hydrating Face Serum', 'revlon-hydrating-face-serum', 'Hydrating serum for daily skin care routines.', 'RV-SERUM-HY', 'SKU-REV-SER01', 'INACTIVE', 'SYSTEM')
ON CONFLICT (product_id) DO UPDATE SET
    organization_id = EXCLUDED.organization_id,
    category_id = EXCLUDED.category_id,
    brand_id = EXCLUDED.brand_id,
    name = EXCLUDED.name,
    slug = EXCLUDED.slug,
    description = EXCLUDED.description,
    model_number = EXCLUDED.model_number,
    sku_code = EXCLUDED.sku_code,
    status_code = EXCLUDED.status_code,
    updated_at = CURRENT_TIMESTAMP(6),
    updated_by = 'SYSTEM'
WHERE pp_m_product.organization_id IS DISTINCT FROM EXCLUDED.organization_id
   OR pp_m_product.category_id IS DISTINCT FROM EXCLUDED.category_id
   OR pp_m_product.brand_id IS DISTINCT FROM EXCLUDED.brand_id
   OR pp_m_product.name IS DISTINCT FROM EXCLUDED.name
   OR pp_m_product.slug IS DISTINCT FROM EXCLUDED.slug
   OR pp_m_product.description IS DISTINCT FROM EXCLUDED.description
   OR pp_m_product.model_number IS DISTINCT FROM EXCLUDED.model_number
   OR pp_m_product.sku_code IS DISTINCT FROM EXCLUDED.sku_code
   OR pp_m_product.status_code IS DISTINCT FROM EXCLUDED.status_code;

SELECT setval(
    pg_get_serial_sequence('pp_m_category', 'category_id'),
    GREATEST((SELECT COALESCE(MAX(category_id), 1) FROM pp_m_category), 1),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('pp_m_brand', 'brand_id'),
    GREATEST((SELECT COALESCE(MAX(brand_id), 1) FROM pp_m_brand), 1),
    TRUE
);

SELECT setval(
    pg_get_serial_sequence('pp_m_product', 'product_id'),
    GREATEST((SELECT COALESCE(MAX(product_id), 1) FROM pp_m_product), 1),
    TRUE
);
