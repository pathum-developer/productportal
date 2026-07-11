-- MySQL dump 10.13  Distrib 9.7.0, for Linux (x86_64)
--
-- Host: localhost    Database: productportal
-- ------------------------------------------------------
-- Server version	9.7.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `pp_a_login_attempt`
--

LOCK TABLES `pp_a_login_attempt` WRITE;
/*!40000 ALTER TABLE `pp_a_login_attempt` DISABLE KEYS */;
INSERT INTO `pp_a_login_attempt` VALUES (1,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 02:52:16.305272','2026-07-11 02:52:16.392321','SYSTEM'),(2,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 04:30:12.452383','2026-07-11 04:30:13.408487','SYSTEM'),(3,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 04:56:25.770262','2026-07-11 04:56:25.980161','SYSTEM'),(4,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 05:54:27.446097','2026-07-11 05:54:27.526472','SYSTEM'),(5,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 18:28:20.220452','2026-07-11 18:28:20.259909','SYSTEM'),(6,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 22:36:50.161420','2026-07-11 22:36:50.244680','SYSTEM'),(7,'naruto',5009,'SUCCESS','0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',NULL,'2026-07-11 22:56:10.812228','2026-07-11 22:56:10.851043','SYSTEM');
/*!40000 ALTER TABLE `pp_a_login_attempt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_brand`
--

LOCK TABLES `pp_m_brand` WRITE;
/*!40000 ALTER TABLE `pp_m_brand` DISABLE KEYS */;
INSERT INTO `pp_m_brand` VALUES (2001,'Apple','apple','Consumer electronics and computing devices.','https://cdn.productportal.local/brands/apple.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2002,'Samsung','samsung','Consumer electronics, mobile devices, and appliances.','https://cdn.productportal.local/brands/samsung.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2003,'Dell','dell','Business and personal computing devices.','https://cdn.productportal.local/brands/dell.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2004,'Sony','sony','Audio, entertainment, and electronics products.','https://cdn.productportal.local/brands/sony.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2005,'LG','lg','Home appliances and consumer electronics.','https://cdn.productportal.local/brands/lg.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2006,'Nike','nike','Sportswear, footwear, and fitness products.','https://cdn.productportal.local/brands/nike.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2007,'Adidas','adidas','Sportswear, footwear, and outdoor products.','https://cdn.productportal.local/brands/adidas.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2008,'IKEA','ikea','Furniture and home living products.','https://cdn.productportal.local/brands/ikea.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2009,'Philips','philips','Health, beauty, and home appliance products.','https://cdn.productportal.local/brands/philips.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2010,'Panasonic','panasonic','Appliances and consumer electronics.','https://cdn.productportal.local/brands/panasonic.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2011,'The North Face','the-north-face','Outdoor apparel and camping equipment.','https://cdn.productportal.local/brands/the-north-face.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2012,'Logitech','logitech','Computer accessories and audio peripherals.','https://cdn.productportal.local/brands/logitech.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2013,'Lenovo','lenovo','Computing devices and accessories.','https://cdn.productportal.local/brands/lenovo.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2014,'Revlon','revlon','Beauty and personal care products.','https://cdn.productportal.local/brands/revlon.png','INACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL),(2015,'Under Armour','under-armour','Sportswear and performance products.','https://cdn.productportal.local/brands/under-armour.png','ACTIVE',0,'2026-06-21 22:52:54.847921','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_brand` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_category`
--

LOCK TABLES `pp_m_category` WRITE;
/*!40000 ALTER TABLE `pp_m_category` DISABLE KEYS */;
INSERT INTO `pp_m_category` VALUES (1001,NULL,'Electronics','electronics','ACTIVE',1,0,'2026-06-21 22:52:54.477158','SYSTEM',NULL,NULL),(1002,NULL,'Home and Living','home-and-living','ACTIVE',2,0,'2026-06-21 22:52:54.477158','SYSTEM',NULL,NULL),(1003,NULL,'Fashion','fashion','ACTIVE',3,0,'2026-06-21 22:52:54.477158','SYSTEM',NULL,NULL),(1004,NULL,'Sports and Outdoors','sports-and-outdoors','ACTIVE',4,0,'2026-06-21 22:52:54.477158','SYSTEM',NULL,NULL),(1005,NULL,'Health and Beauty','health-and-beauty','ACTIVE',5,0,'2026-06-21 22:52:54.477158','SYSTEM',NULL,NULL),(1006,1001,'Smartphones','smartphones','ACTIVE',1,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1007,1001,'Laptops','laptops','ACTIVE',2,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1008,1001,'Audio Devices','audio-devices','ACTIVE',3,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1009,1002,'Kitchen Appliances','kitchen-appliances','ACTIVE',1,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1010,1002,'Furniture','furniture','ACTIVE',2,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1011,1003,'Mens Clothing','mens-clothing','ACTIVE',1,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1012,1003,'Womens Clothing','womens-clothing','ACTIVE',2,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1013,1004,'Fitness Equipment','fitness-equipment','ACTIVE',1,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1014,1004,'Camping Gear','camping-gear','ACTIVE',2,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL),(1015,1005,'Skin Care','skin-care','INACTIVE',1,0,'2026-06-21 22:52:54.803806','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_organization`
--

LOCK TABLES `pp_m_organization` WRITE;
/*!40000 ALTER TABLE `pp_m_organization` DISABLE KEYS */;
INSERT INTO `pp_m_organization` VALUES (1,'DEFAULT','Default Organization','Product Portal','Default organization for existing single-tenant product portal data.',1,0,'2026-07-09 15:21:08.692611','SYSTEM',NULL,'SYSTEM');
/*!40000 ALTER TABLE `pp_m_organization` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_permission`
--

LOCK TABLES `pp_m_permission` WRITE;
/*!40000 ALTER TABLE `pp_m_permission` DISABLE KEYS */;
INSERT INTO `pp_m_permission` VALUES ('ADDRESS_MANAGE','Manage Addresses','Create, update, and remove own address records.','ADDRESS','MANAGE',3,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('BRAND_CREATE','Create Brands','Create product brands.','BRAND','CREATE',9,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('BRAND_DELETE','Delete Brands','Remove product brands.','BRAND','DELETE',11,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('BRAND_READ','Read Brands','View active product brands.','BRAND','READ',8,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('BRAND_UPDATE','Update Brands','Update product brands.','BRAND','UPDATE',10,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('CATEGORY_CREATE','Create Categories','Create catalog categories.','CATEGORY','CREATE',5,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('CATEGORY_DELETE','Delete Categories','Remove catalog categories.','CATEGORY','DELETE',7,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('CATEGORY_READ','Read Categories','View active catalog categories.','CATEGORY','READ',4,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('CATEGORY_UPDATE','Update Categories','Update catalog categories.','CATEGORY','UPDATE',6,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PERMISSION_MANAGE','Manage Permissions','Create, update, and deactivate permissions.','PERMISSION','MANAGE',24,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PERMISSION_READ','Read Permissions','View permission definitions.','PERMISSION','READ',23,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PRODUCT_CREATE','Create Products','Create product catalog records.','PRODUCT','CREATE',13,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PRODUCT_DELETE','Delete Products','Remove product catalog records.','PRODUCT','DELETE',15,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PRODUCT_READ','Read Products','View product catalog data.','PRODUCT','READ',12,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PRODUCT_UPDATE','Update Products','Update product catalog records.','PRODUCT','UPDATE',14,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PROFILE_READ','Read Profile','View own user profile details.','PROFILE','READ',1,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('PROFILE_UPDATE','Update Profile','Update own user profile details.','PROFILE','UPDATE',2,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('ROLE_ASSIGN','Assign Roles','Assign roles to users.','ROLE','ASSIGN',21,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('ROLE_MANAGE','Manage Roles','Create, update, and deactivate roles.','ROLE','MANAGE',22,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('ROLE_READ','Read Roles','View role definitions.','ROLE','READ',20,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('USER_CREATE','Create Users','Create user accounts.','USER','CREATE',17,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('USER_DELETE','Delete Users','Remove user accounts.','USER','DELETE',19,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('USER_READ','Read Users','View user account details.','USER','READ',16,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL),('USER_UPDATE','Update Users','Update user accounts.','USER','UPDATE',18,1,'2026-07-09 14:03:26.275952','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_product`
--

LOCK TABLES `pp_m_product` WRITE;
/*!40000 ALTER TABLE `pp_m_product` DISABLE KEYS */;
INSERT INTO `pp_m_product` VALUES (3001,1,5003,1006,2001,'iPhone 16 Pro 256GB','iphone-16-pro-256gb','Premium smartphone with 256GB storage.','A3293','SKU-IPH16P-256','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3002,1,5003,1006,2002,'Galaxy S25 Ultra 512GB','galaxy-s25-ultra-512gb','Flagship Android smartphone with 512GB storage.','SM-S938B','SKU-GS25U-512','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3003,1,5003,1007,2003,'Dell XPS 14 Laptop','dell-xps-14-laptop','Compact performance laptop for professionals.','XPS9440','SKU-DELL-XPS14','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3004,1,5003,1007,2013,'Lenovo ThinkPad T14','lenovo-thinkpad-t14','Business laptop with enterprise manageability.','T14-G5','SKU-LNV-T14G5','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3005,1,5003,1008,2004,'Sony WH-1000XM5 Headphones','sony-wh-1000xm5-headphones','Wireless noise cancelling headphones.','WH1000XM5','SKU-SONY-XM5','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3006,1,5003,1008,2012,'Logitech Zone Vibe Wireless','logitech-zone-vibe-wireless','Wireless headset for calls and media.','ZONE-VIBE','SKU-LOGI-ZVIBE','DRAFT',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3007,1,5003,1009,2005,'LG 28L Convection Microwave','lg-28l-convection-microwave','Convection microwave for everyday cooking.','MC2886BRUM','SKU-LG-MW28','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3008,1,5003,1009,2010,'Panasonic Blender 1.5L','panasonic-blender-15l','Kitchen blender with durable stainless blades.','MX-EX1551','SKU-PANA-BL15','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3009,1,5004,1010,2008,'IKEA Work Desk Oak Finish','ikea-work-desk-oak-finish','Minimal home office desk with oak finish.','MICKE-OAK','SKU-IKEA-DESK01','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3010,1,5004,1011,2006,'Nike Dri-FIT Training Tee','nike-dri-fit-training-tee','Mens moisture-wicking training t-shirt.','NDF-M-T01','SKU-NIKE-TEE01','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3011,1,5004,1012,2007,'Adidas Essentials Hoodie','adidas-essentials-hoodie','Womens casual fleece hoodie.','ADI-W-H01','SKU-ADI-HOOD01','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3012,1,5004,1013,2015,'Under Armour Training Gloves','under-armour-training-gloves','Protective gloves for strength training.','UA-TG-01','SKU-UA-GLOVE01','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3013,1,5004,1013,2006,'Nike Resistance Band Set','nike-resistance-band-set','Resistance bands for home workouts.','NRB-SET','SKU-NIKE-BAND01','DRAFT',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3014,1,5004,1014,2011,'The North Face Trail Tent 2P','the-north-face-trail-tent-2p','Two-person tent for lightweight camping.','TNF-TENT-2P','SKU-TNF-TENT2P','ACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL),(3015,1,5004,1015,2014,'Revlon Hydrating Face Serum','revlon-hydrating-face-serum','Hydrating serum for daily skin care routines.','RV-SERUM-HY','SKU-REV-SER01','INACTIVE',0,'2026-06-21 22:52:55.201566','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_role`
--

LOCK TABLES `pp_m_role` WRITE;
/*!40000 ALTER TABLE `pp_m_role` DISABLE KEYS */;
INSERT INTO `pp_m_role` VALUES ('ADMIN','Admin','Administrative account with elevated product portal privileges.',3,1,'2026-06-23 08:46:02.162852','SYSTEM',NULL,NULL),('BUYER','Buyer','Customer account that can browse and purchase products.',1,1,'2026-06-23 08:46:02.162852','SYSTEM',NULL,NULL),('SELLER','Seller','Merchant account that can manage seller-owned catalog data.',2,1,'2026-06-23 08:46:02.162852','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_user`
--

LOCK TABLES `pp_m_user` WRITE;
/*!40000 ALTER TABLE `pp_m_user` DISABLE KEYS */;
INSERT INTO `pp_m_user` VALUES (5001,'amal.perera','Amal Perera','amal.perera@example.com','+94771110001','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5002,'nimali.silva','Nimali Silva','nimali.silva@example.com','+94771110002','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5003,'dinesh.fernando','Dinesh Fernando','dinesh.fernando@example.com','+94771110003','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5004,'kavindi.jayasinghe','Kavindi Jayasinghe','kavindi.jayasinghe@example.com','+94771110004','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5005,'ruwan.wijesinghe','Ruwan Wijesinghe','ruwan.wijesinghe@example.com','+94771110005','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5006,'tharushi.gunawardena','Tharushi Gunawardena','tharushi.gunawardena@example.com','+94771110006','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5007,'kasun.bandara','Kasun Bandara','kasun.bandara@example.com','+94771110007','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','SUSPENDED',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5008,'anjali.rathnayake','Anjali Rathnayake','anjali.rathnayake@example.com','+94771110008','$2a$10$yRBq307PNlU2EZPcG3B7Gev8XQ6zCjPktI.9H720f4QiRA.yu53o2','2026-07-11 22:53:39.933246','DELETED',1,0,'2026-06-23 08:46:02.815485','SYSTEM',NULL,NULL),(5009,'naruto','usumaki naruto','naruto@example.com','+940774327036','$2a$10$5m0qTRhIsTTqTo4yvn87Vel3FR4lU2hlEwG7q7W3ni4d4KqGBqEfS','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-06-23 10:55:25.349254','Anonymous User',NULL,NULL),(5010,'atiya.perera','atiya perera','atiya@example.com','+940764327036','$2a$10$od3djpWhwna9yAxDrgvhuOjLyNBstkcwpPGZOPavOAtcQw6w6Y/2y','2026-07-11 22:53:39.933246','ACTIVE',1,0,'2026-07-08 18:09:28.737891','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_m_user_address`
--

LOCK TABLES `pp_m_user_address` WRITE;
/*!40000 ALTER TABLE `pp_m_user_address` DISABLE KEYS */;
INSERT INTO `pp_m_user_address` VALUES (6001,5001,'Amal Perera','+94771110001','No 12, Lake Road','Apartment 2A','Colombo','Colombo','Western','00300','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6002,5002,'Nimali Silva','+94771110002','No 45, Temple Lane',NULL,'Kandy','Kandy','Central','20000','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6003,5003,'Dinesh Fernando','+94771110003','Warehouse 7, Industrial Zone','Phase 1','Katunayake','Gampaha','Western','11450','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6004,5004,'Kavindi Jayasinghe','+94771110004','No 88, Main Street','Shop 3','Galle','Galle','Southern','80000','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6005,5005,'Ruwan Wijesinghe','+94771110005','Admin Office, Product Portal HQ','Level 5','Colombo','Colombo','Western','00100','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6006,5006,'Tharushi Gunawardena','+94771110006','No 21, Hill View Road',NULL,'Nuwara Eliya','Nuwara Eliya','Central','22200','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6007,5007,'Kasun Bandara','+94771110007','No 14, Market Road','Unit B','Kurunegala','Kurunegala','North Western','60000','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6008,5008,'Anjali Rathnayake','+94771110008','No 9, Beach Road',NULL,'Matara','Matara','Southern','81000','Sri Lanka',1,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6009,5001,'Amal Perera','+94771110001','No 75, Station Road',NULL,'Moratuwa','Colombo','Western','10400','Sri Lanka',0,0,'2026-06-23 08:46:02.930307','SYSTEM',NULL,NULL),(6010,5009,'Boruto','0774698126','no 789','123 road','colombo','colombo','southern','80000','string',0,0,'2026-07-03 18:49:04.880217','Anonymous User',NULL,NULL),(6011,5009,'kawaki','0774892626','addressLine1','addressLine2','city','district','province','75000','Japan',0,0,'2026-07-03 19:26:26.463016','naruto',NULL,NULL),(6012,5009,'sarada','0774892626','addressLine1','addressLine2','city','district','province','75000','Japan',1,0,'2026-07-03 19:45:36.636283','naruto',NULL,NULL);
/*!40000 ALTER TABLE `pp_m_user_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_brand_status`
--

LOCK TABLES `pp_r_brand_status` WRITE;
/*!40000 ALTER TABLE `pp_r_brand_status` DISABLE KEYS */;
INSERT INTO `pp_r_brand_status` VALUES ('ACTIVE','Active','Brand is visible and available for product assignment.',1,1,'2026-06-21 22:52:52.587781','SYSTEM',NULL,NULL),('INACTIVE','Inactive','Brand is retained but hidden from active catalog flows.',2,1,'2026-06-21 22:52:52.587781','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_brand_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_category_status`
--

LOCK TABLES `pp_r_category_status` WRITE;
/*!40000 ALTER TABLE `pp_r_category_status` DISABLE KEYS */;
INSERT INTO `pp_r_category_status` VALUES ('ACTIVE','Active','Category is visible and available for product assignment.',1,1,'2026-06-21 22:52:51.729419','SYSTEM',NULL,NULL),('INACTIVE','Inactive','Category is retained but hidden from active catalog flows.',2,1,'2026-06-21 22:52:51.729419','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_category_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_membership_status`
--

LOCK TABLES `pp_r_membership_status` WRITE;
/*!40000 ALTER TABLE `pp_r_membership_status` DISABLE KEYS */;
INSERT INTO `pp_r_membership_status` VALUES ('ACTIVE','Active','User is an active member of the organization.',2,1,'2026-07-09 16:55:11.150316','SYSTEM',NULL,NULL),('INVITED','Invited','User has been invited to the organization but has not joined yet.',1,1,'2026-07-09 16:55:11.150316','SYSTEM',NULL,NULL),('LEFT','Left','User left the organization voluntarily.',4,1,'2026-07-09 16:55:11.150316','SYSTEM',NULL,NULL),('REMOVED','Removed','User was removed from the organization.',5,1,'2026-07-09 16:55:11.150316','SYSTEM',NULL,NULL),('SUSPENDED','Suspended','User membership is temporarily blocked in the organization.',3,1,'2026-07-09 16:55:11.150316','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_membership_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_permission_scope`
--

LOCK TABLES `pp_r_permission_scope` WRITE;
/*!40000 ALTER TABLE `pp_r_permission_scope` DISABLE KEYS */;
INSERT INTO `pp_r_permission_scope` VALUES ('GLOBAL','Global','Permission applies across all organizations in the platform.',4,1,'2026-07-09 16:00:06.215106','SYSTEM',NULL,NULL),('ORGANIZATION','Organization','Permission applies to resources inside the selected organization.',3,1,'2026-07-09 16:00:06.215106','SYSTEM',NULL,NULL),('OWNED','Owned Resource','Permission applies only to resources owned by the current user.',2,1,'2026-07-09 16:00:06.215106','SYSTEM',NULL,NULL),('SELF','Self','Permission applies only to the current user account or profile.',1,1,'2026-07-09 16:00:06.215106','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_permission_scope` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_product_status`
--

LOCK TABLES `pp_r_product_status` WRITE;
/*!40000 ALTER TABLE `pp_r_product_status` DISABLE KEYS */;
INSERT INTO `pp_r_product_status` VALUES ('ACTIVE','Active','Product is visible and available in active catalog flows.',2,1,'2026-06-21 22:52:53.026319','SYSTEM',NULL,NULL),('DRAFT','Draft','Product is incomplete and not visible in active catalog flows.',1,1,'2026-06-21 22:52:53.026319','SYSTEM',NULL,NULL),('INACTIVE','Inactive','Product is retained but hidden from active catalog flows.',3,1,'2026-06-21 22:52:53.026319','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_product_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_r_user_status`
--

LOCK TABLES `pp_r_user_status` WRITE;
/*!40000 ALTER TABLE `pp_r_user_status` DISABLE KEYS */;
INSERT INTO `pp_r_user_status` VALUES ('ACTIVE','Active','User can authenticate and use permitted product portal features.',1,1,'2026-06-23 08:46:02.409495','SYSTEM',NULL,NULL),('DELETED','Deleted','User account is logically removed and retained only for audit history.',4,1,'2026-06-23 08:46:02.409495','SYSTEM',NULL,NULL),('INACTIVE','Inactive','User account is retained but cannot authenticate.',2,1,'2026-06-23 08:46:02.409495','SYSTEM',NULL,NULL),('SUSPENDED','Suspended','User account is temporarily blocked due to policy or risk.',3,1,'2026-06-23 08:46:02.409495','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_r_user_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_auth_session`
--

LOCK TABLES `pp_t_auth_session` WRITE;
/*!40000 ALTER TABLE `pp_t_auth_session` DISABLE KEYS */;
INSERT INTO `pp_t_auth_session` VALUES ('9c640669-95b8-4777-bc63-5a3cb7569a1e',5009,'b6a01e712a306c1f34d8904af8f14ffc4cc2f12bf75e4bc803bcfdfbdefa6958','2026-07-11 22:56:10.892112','2026-08-10 22:56:10.892112','2026-07-11 22:56:10.892112',NULL,NULL,'0:0:0:0:0:0:0:1','PostmanRuntime/7.54.0',0,'2026-07-11 22:56:10.900609','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_t_auth_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_login_throttle_state`
--

LOCK TABLES `pp_t_login_throttle_state` WRITE;
/*!40000 ALTER TABLE `pp_t_login_throttle_state` DISABLE KEYS */;
/*!40000 ALTER TABLE `pp_t_login_throttle_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_role_permission_grant`
--

LOCK TABLES `pp_t_role_permission_grant` WRITE;
/*!40000 ALTER TABLE `pp_t_role_permission_grant` DISABLE KEYS */;
INSERT INTO `pp_t_role_permission_grant` VALUES ('ADMIN','ADDRESS_MANAGE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','BRAND_CREATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','BRAND_DELETE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','BRAND_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','BRAND_UPDATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','CATEGORY_CREATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','CATEGORY_DELETE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','CATEGORY_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','CATEGORY_UPDATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PERMISSION_MANAGE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PERMISSION_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PRODUCT_CREATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PRODUCT_DELETE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PRODUCT_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PRODUCT_UPDATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PROFILE_READ','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','PROFILE_UPDATE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','ROLE_ASSIGN','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','ROLE_MANAGE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','ROLE_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','USER_CREATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','USER_DELETE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','USER_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('ADMIN','USER_UPDATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','ADDRESS_MANAGE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','BRAND_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','CATEGORY_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','PRODUCT_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','PROFILE_READ','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('BUYER','PROFILE_UPDATE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','ADDRESS_MANAGE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','BRAND_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','CATEGORY_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','PRODUCT_CREATE','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','PRODUCT_READ','ORGANIZATION',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','PRODUCT_UPDATE','OWNED',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','PROFILE_READ','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL),('SELLER','PROFILE_UPDATE','SELF',1,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_t_role_permission_grant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_role_permission_grant_audit`
--

LOCK TABLES `pp_t_role_permission_grant_audit` WRITE;
/*!40000 ALTER TABLE `pp_t_role_permission_grant_audit` DISABLE KEYS */;
INSERT INTO `pp_t_role_permission_grant_audit` VALUES (1,'ADMIN','ADDRESS_MANAGE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(2,'ADMIN','BRAND_CREATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(3,'ADMIN','BRAND_DELETE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(4,'ADMIN','BRAND_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(5,'ADMIN','BRAND_UPDATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(6,'ADMIN','CATEGORY_CREATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(7,'ADMIN','CATEGORY_DELETE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(8,'ADMIN','CATEGORY_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(9,'ADMIN','CATEGORY_UPDATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(10,'ADMIN','PERMISSION_MANAGE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(11,'ADMIN','PERMISSION_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(12,'ADMIN','PRODUCT_CREATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(13,'ADMIN','PRODUCT_DELETE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(14,'ADMIN','PRODUCT_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(15,'ADMIN','PRODUCT_UPDATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(16,'ADMIN','PROFILE_READ','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(17,'ADMIN','PROFILE_UPDATE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(18,'ADMIN','ROLE_ASSIGN','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(19,'ADMIN','ROLE_MANAGE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(20,'ADMIN','ROLE_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(21,'ADMIN','USER_CREATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(22,'ADMIN','USER_DELETE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(23,'ADMIN','USER_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(24,'ADMIN','USER_UPDATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(25,'BUYER','ADDRESS_MANAGE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(26,'BUYER','BRAND_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(27,'BUYER','CATEGORY_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(28,'BUYER','PRODUCT_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(29,'BUYER','PROFILE_READ','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(30,'BUYER','PROFILE_UPDATE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(31,'SELLER','ADDRESS_MANAGE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(32,'SELLER','BRAND_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(33,'SELLER','CATEGORY_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(34,'SELLER','PRODUCT_CREATE','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(35,'SELLER','PRODUCT_READ','MIGRATED',NULL,1,NULL,'ORGANIZATION','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(36,'SELLER','PRODUCT_UPDATE','MIGRATED',NULL,1,NULL,'OWNED','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(37,'SELLER','PROFILE_READ','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL),(38,'SELLER','PROFILE_UPDATE','MIGRATED',NULL,1,NULL,'SELF','SYSTEM','Baseline RBAC role-permission assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.289774','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC role-permission assignment backfill.',NULL);
/*!40000 ALTER TABLE `pp_t_role_permission_grant_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_user_organization_membership`
--

LOCK TABLES `pp_t_user_organization_membership` WRITE;
/*!40000 ALTER TABLE `pp_t_user_organization_membership` DISABLE KEYS */;
INSERT INTO `pp_t_user_organization_membership` VALUES (5001,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5002,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5003,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5004,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5005,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5006,1,'ACTIVE',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5007,1,'SUSPENDED',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5008,1,'REMOVED',1,'2026-06-23 08:46:02.815485',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5009,1,'ACTIVE',1,'2026-06-23 10:55:25.349254',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL),(5010,1,'ACTIVE',1,'2026-07-08 18:09:28.737891',NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_t_user_organization_membership` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_user_organization_membership_audit`
--

LOCK TABLES `pp_t_user_organization_membership_audit` WRITE;
/*!40000 ALTER TABLE `pp_t_user_organization_membership_audit` DISABLE KEYS */;
INSERT INTO `pp_t_user_organization_membership_audit` VALUES (1,5001,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(2,5002,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(3,5003,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(4,5004,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(5,5005,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(6,5006,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(7,5007,1,'MIGRATED',NULL,'SUSPENDED',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(8,5008,1,'MIGRATED',NULL,'REMOVED',NULL,1,NULL,'2026-06-23 08:46:02.815485',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(9,5009,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-06-23 10:55:25.349254',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL),(10,5010,1,'MIGRATED',NULL,'ACTIVE',NULL,1,NULL,'2026-07-08 18:09:28.737891',NULL,NULL,NULL,NULL,'2026-07-09 16:59:46.344322','SYSTEM','root@localhost','DATABASE_TRIGGER','Migrated from existing organization-scoped role assignments.',NULL);
/*!40000 ALTER TABLE `pp_t_user_organization_membership_audit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_user_role_assignment`
--

LOCK TABLES `pp_t_user_role_assignment` WRITE;
/*!40000 ALTER TABLE `pp_t_user_role_assignment` DISABLE KEYS */;
INSERT INTO `pp_t_user_role_assignment` VALUES (5001,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5002,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5003,1,'SELLER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5004,1,'SELLER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5005,1,'ADMIN',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5006,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5007,1,'SELLER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5008,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5009,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL),(5010,1,'BUYER',1,NULL,NULL,'SYSTEM',NULL,NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM',NULL,NULL);
/*!40000 ALTER TABLE `pp_t_user_role_assignment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping data for table `pp_t_user_role_assignment_audit`
--

LOCK TABLES `pp_t_user_role_assignment_audit` WRITE;
/*!40000 ALTER TABLE `pp_t_user_role_assignment_audit` DISABLE KEYS */;
INSERT INTO `pp_t_user_role_assignment_audit` VALUES (1,5001,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(2,5002,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(3,5003,1,'SELLER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(4,5004,1,'SELLER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(5,5005,1,'ADMIN','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(6,5006,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(7,5007,1,'SELLER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(8,5008,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(9,5009,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL),(10,5010,1,'BUYER','MIGRATED',NULL,1,NULL,NULL,NULL,NULL,'SYSTEM','Baseline RBAC user-role assignment backfill.',NULL,NULL,'2026-07-09 14:03:26.300312','SYSTEM','MIGRATION','MIGRATION','Baseline RBAC user-role assignment backfill.',NULL);
/*!40000 ALTER TABLE `pp_t_user_role_assignment_audit` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-11 23:06:25
