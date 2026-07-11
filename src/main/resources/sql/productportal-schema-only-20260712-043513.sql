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
-- Current Database: `productportal`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `productportal` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `productportal`;

--
-- Table structure for table `pp_a_login_attempt`
--

DROP TABLE IF EXISTS `pp_a_login_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_a_login_attempt` (
  `login_attempt_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `outcome` varchar(40) NOT NULL,
  `client_ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(512) DEFAULT NULL,
  `locked_until` timestamp(6) NULL DEFAULT NULL,
  `occurred_at` timestamp(6) NOT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  PRIMARY KEY (`login_attempt_id`),
  KEY `idx_pp_a_login_attempt_username_time` (`username`,`occurred_at`),
  KEY `idx_pp_a_login_attempt_client_ip_time` (`client_ip`,`occurred_at`),
  KEY `idx_pp_a_login_attempt_outcome_time` (`outcome`,`occurred_at`),
  KEY `idx_pp_a_login_attempt_user_id_time` (`user_id`,`occurred_at`),
  CONSTRAINT `fk_pp_a_login_attempt_user` FOREIGN KEY (`user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `chk_pp_a_login_attempt_client_ip_not_blank` CHECK (((`client_ip` is null) or (trim(`client_ip`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_a_login_attempt_created_by_not_blank` CHECK ((trim(`created_by`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_a_login_attempt_outcome` CHECK ((`outcome` in (_utf8mb4'SUCCESS',_utf8mb4'BAD_CREDENTIALS',_utf8mb4'ACCOUNT_DISABLED',_utf8mb4'NO_ACTIVE_ROLE_ASSIGNMENT',_utf8mb4'USERNAME_LOCKED',_utf8mb4'IP_THROTTLED'))),
  CONSTRAINT `chk_pp_a_login_attempt_user_agent_not_blank` CHECK (((`user_agent` is null) or (trim(`user_agent`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_a_login_attempt_username_not_blank` CHECK ((trim(`username`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_brand`
--

DROP TABLE IF EXISTS `pp_m_brand`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_brand` (
  `brand_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `slug` varchar(180) NOT NULL,
  `description` text,
  `logo_url` varchar(500) DEFAULT NULL,
  `status_code` varchar(30) NOT NULL DEFAULT 'ACTIVE',
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`brand_id`),
  UNIQUE KEY `uk_pp_m_brands_name` (`name`),
  UNIQUE KEY `uk_pp_m_brands_slug` (`slug`),
  KEY `idx_pp_m_brands_status` (`status_code`),
  CONSTRAINT `fk_pp_m_brand_status` FOREIGN KEY (`status_code`) REFERENCES `pp_r_brand_status` (`status_code`),
  CONSTRAINT `chk_pp_m_brands_name_not_blank` CHECK ((trim(`name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_m_brands_slug_not_blank` CHECK ((trim(`slug`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=2016 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_category`
--

DROP TABLE IF EXISTS `pp_m_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_category` (
  `category_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `parent_category_id` bigint unsigned DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(180) NOT NULL,
  `status_code` varchar(30) NOT NULL DEFAULT 'ACTIVE',
  `sort_order` smallint unsigned NOT NULL DEFAULT '0',
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uk_pp_m_categories_slug` (`slug`),
  KEY `idx_pp_m_categories_parent_id` (`parent_category_id`),
  KEY `idx_pp_m_categories_status` (`status_code`),
  KEY `idx_pp_m_categories_parent_status` (`parent_category_id`,`status_code`),
  CONSTRAINT `fk_pp_m_category_parent` FOREIGN KEY (`parent_category_id`) REFERENCES `pp_m_category` (`category_id`),
  CONSTRAINT `fk_pp_m_category_status` FOREIGN KEY (`status_code`) REFERENCES `pp_r_category_status` (`status_code`),
  CONSTRAINT `chk_pp_m_categories_name_not_blank` CHECK ((trim(`name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_m_categories_slug_not_blank` CHECK ((trim(`slug`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=1016 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_organization`
--

DROP TABLE IF EXISTS `pp_m_organization`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_organization` (
  `organization_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `organization_code` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `legal_name` varchar(200) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`organization_id`),
  UNIQUE KEY `uk_pp_org_organizations_code` (`organization_code`),
  UNIQUE KEY `uk_pp_org_organizations_display_name` (`display_name`),
  KEY `idx_pp_org_organizations_active` (`is_active`),
  CONSTRAINT `chk_pp_org_organizations_code_not_blank` CHECK ((trim(`organization_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_organizations_display_name_not_blank` CHECK ((trim(`display_name`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_organizations_legal_name_not_blank` CHECK (((`legal_name` is null) or (trim(`legal_name`) <> _latin1'')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_permission`
--

DROP TABLE IF EXISTS `pp_m_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_permission` (
  `permission_code` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `resource_code` varchar(60) NOT NULL,
  `action_code` varchar(60) NOT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`permission_code`),
  UNIQUE KEY `uk_pp_usm_permissions_display_name` (`display_name`),
  UNIQUE KEY `uk_pp_usm_permissions_resource_action` (`resource_code`,`action_code`),
  KEY `idx_pp_usm_permissions_active` (`is_active`),
  CONSTRAINT `chk_pp_usm_permissions_action_code_not_blank` CHECK ((trim(`action_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permissions_code_not_blank` CHECK ((trim(`permission_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permissions_display_name_not_blank` CHECK ((trim(`display_name`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permissions_resource_code_not_blank` CHECK ((trim(`resource_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permissions_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_product`
--

DROP TABLE IF EXISTS `pp_m_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_product` (
  `product_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `organization_id` bigint unsigned NOT NULL DEFAULT '1',
  `owner_user_id` bigint unsigned DEFAULT NULL,
  `category_id` bigint unsigned NOT NULL,
  `brand_id` bigint unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `description` text,
  `model_number` varchar(100) DEFAULT NULL,
  `sku_code` varchar(100) DEFAULT NULL,
  `status_code` varchar(30) NOT NULL DEFAULT 'DRAFT',
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL,
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uk_pp_m_products_org_slug` (`organization_id`,`slug`),
  UNIQUE KEY `uk_pp_m_products_org_sku_code` (`organization_id`,`sku_code`),
  KEY `idx_pp_m_products_category_id` (`category_id`),
  KEY `idx_pp_m_products_brand_id` (`brand_id`),
  KEY `idx_pp_m_products_status` (`status_code`),
  KEY `idx_pp_m_products_category_status` (`category_id`,`status_code`),
  KEY `idx_pp_m_products_brand_status` (`brand_id`,`status_code`),
  KEY `idx_pp_m_products_organization_id` (`organization_id`),
  KEY `idx_pp_m_products_org_status` (`organization_id`,`status_code`),
  KEY `idx_pp_m_products_org_category_status` (`organization_id`,`category_id`,`status_code`),
  KEY `idx_pp_m_products_owner_user_id` (`owner_user_id`),
  KEY `idx_pp_m_products_org_owner_status` (`organization_id`,`owner_user_id`,`status_code`),
  CONSTRAINT `fk_pp_m_product_brand` FOREIGN KEY (`brand_id`) REFERENCES `pp_m_brand` (`brand_id`),
  CONSTRAINT `fk_pp_m_product_category` FOREIGN KEY (`category_id`) REFERENCES `pp_m_category` (`category_id`),
  CONSTRAINT `fk_pp_m_product_organization` FOREIGN KEY (`organization_id`) REFERENCES `pp_m_organization` (`organization_id`),
  CONSTRAINT `fk_pp_m_product_owner_user` FOREIGN KEY (`owner_user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pp_m_product_status` FOREIGN KEY (`status_code`) REFERENCES `pp_r_product_status` (`status_code`),
  CONSTRAINT `chk_pp_m_products_name_not_blank` CHECK ((trim(`name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_m_products_slug_not_blank` CHECK ((trim(`slug`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=3016 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_role`
--

DROP TABLE IF EXISTS `pp_m_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_role` (
  `role_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`role_code`),
  UNIQUE KEY `uk_pp_usm_roles_display_name` (`display_name`),
  CONSTRAINT `chk_pp_usm_roles_code_not_blank` CHECK ((trim(`role_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_roles_display_name_not_blank` CHECK ((trim(`display_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_roles_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_user`
--

DROP TABLE IF EXISTS `pp_m_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_user` (
  `user_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `phone_number` varchar(30) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `credentials_changed_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE',
  `primary_organization_id` bigint unsigned DEFAULT NULL,
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_pp_usm_users_username` (`username`),
  UNIQUE KEY `uk_pp_usm_users_email` (`email`),
  UNIQUE KEY `uk_pp_usm_users_phone_number` (`phone_number`),
  KEY `idx_pp_usm_users_status` (`status`),
  KEY `idx_pp_usm_users_primary_organization_id` (`primary_organization_id`),
  CONSTRAINT `fk_pp_m_user_primary_organization` FOREIGN KEY (`primary_organization_id`) REFERENCES `pp_m_organization` (`organization_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pp_m_user_status` FOREIGN KEY (`status`) REFERENCES `pp_r_user_status` (`status_code`),
  CONSTRAINT `chk_pp_usm_users_email_not_blank` CHECK ((trim(`email`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_users_full_name_not_blank` CHECK ((trim(`full_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_users_password_hash_not_blank` CHECK ((trim(`password_hash`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_users_phone_number_not_blank` CHECK (((`phone_number` is null) or (trim(`phone_number`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_users_username_not_blank` CHECK ((trim(`username`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=5011 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_m_user_address`
--

DROP TABLE IF EXISTS `pp_m_user_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_m_user_address` (
  `address_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `recipient_name` varchar(150) NOT NULL,
  `phone_number` varchar(30) NOT NULL,
  `address_line_1` varchar(255) NOT NULL,
  `address_line_2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `district` varchar(100) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `country` varchar(100) NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`address_id`),
  KEY `idx_pp_usm_addresses_user_id` (`user_id`),
  KEY `idx_pp_usm_addresses_user_default` (`user_id`,`is_default`),
  KEY `idx_pp_usm_addresses_city` (`city`),
  KEY `idx_pp_usm_addresses_postal_code` (`postal_code`),
  CONSTRAINT `fk_pp_m_user_address_user` FOREIGN KEY (`user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_pp_usm_addresses_address_line_1_not_blank` CHECK ((trim(`address_line_1`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_addresses_address_line_2_not_blank` CHECK (((`address_line_2` is null) or (trim(`address_line_2`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_addresses_city_not_blank` CHECK ((trim(`city`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_addresses_country_not_blank` CHECK ((trim(`country`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_addresses_district_not_blank` CHECK (((`district` is null) or (trim(`district`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_addresses_phone_number_not_blank` CHECK ((trim(`phone_number`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_addresses_postal_code_not_blank` CHECK (((`postal_code` is null) or (trim(`postal_code`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_addresses_province_not_blank` CHECK (((`province` is null) or (trim(`province`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_addresses_recipient_name_not_blank` CHECK ((trim(`recipient_name`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=6013 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_brand_status`
--

DROP TABLE IF EXISTS `pp_r_brand_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_brand_status` (
  `status_code` varchar(30) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`status_code`),
  UNIQUE KEY `uk_pp_r_brand_statuses_display_name` (`display_name`),
  CONSTRAINT `chk_pp_r_brand_statuses_code_not_blank` CHECK ((trim(`status_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_brand_statuses_display_name_not_blank` CHECK ((trim(`display_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_brand_statuses_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_category_status`
--

DROP TABLE IF EXISTS `pp_r_category_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_category_status` (
  `status_code` varchar(30) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`status_code`),
  UNIQUE KEY `uk_pp_r_category_statuses_display_name` (`display_name`),
  CONSTRAINT `chk_pp_r_category_statuses_code_not_blank` CHECK ((trim(`status_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_category_statuses_display_name_not_blank` CHECK ((trim(`display_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_category_statuses_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_membership_status`
--

DROP TABLE IF EXISTS `pp_r_membership_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_membership_status` (
  `status_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`status_code`),
  UNIQUE KEY `uk_pp_org_membership_statuses_display_name` (`display_name`),
  CONSTRAINT `chk_pp_org_membership_statuses_code_not_blank` CHECK ((trim(`status_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_membership_statuses_display_name_not_blank` CHECK ((trim(`display_name`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_membership_statuses_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_permission_scope`
--

DROP TABLE IF EXISTS `pp_r_permission_scope`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_permission_scope` (
  `scope_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`scope_code`),
  UNIQUE KEY `uk_pp_usm_permission_scopes_display_name` (`display_name`),
  KEY `idx_pp_usm_permission_scopes_active` (`is_active`),
  CONSTRAINT `chk_pp_usm_permission_scopes_code_not_blank` CHECK ((trim(`scope_code`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permission_scopes_display_name_not_blank` CHECK ((trim(`display_name`) <> _latin1'')),
  CONSTRAINT `chk_pp_usm_permission_scopes_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_product_status`
--

DROP TABLE IF EXISTS `pp_r_product_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_product_status` (
  `status_code` varchar(30) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`status_code`),
  UNIQUE KEY `uk_pp_r_product_statuses_display_name` (`display_name`),
  CONSTRAINT `chk_pp_r_product_statuses_code_not_blank` CHECK ((trim(`status_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_product_statuses_display_name_not_blank` CHECK ((trim(`display_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_r_product_statuses_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_r_user_status`
--

DROP TABLE IF EXISTS `pp_r_user_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_r_user_status` (
  `status_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` smallint unsigned NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`status_code`),
  UNIQUE KEY `uk_pp_usr_user_statuses_display_name` (`display_name`),
  CONSTRAINT `chk_pp_usr_user_statuses_code_not_blank` CHECK ((trim(`status_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usr_user_statuses_display_name_not_blank` CHECK ((trim(`display_name`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usr_user_statuses_sort_order_positive` CHECK ((`sort_order` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_t_auth_session`
--

DROP TABLE IF EXISTS `pp_t_auth_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_auth_session` (
  `auth_session_id` char(36) NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `refresh_token_hash` char(64) NOT NULL,
  `issued_at` timestamp(6) NOT NULL,
  `refresh_expires_at` timestamp(6) NOT NULL,
  `last_used_at` timestamp(6) NOT NULL,
  `revoked_at` timestamp(6) NULL DEFAULT NULL,
  `revocation_reason` varchar(60) DEFAULT NULL,
  `client_ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(512) DEFAULT NULL,
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`auth_session_id`),
  KEY `idx_pp_t_auth_session_user_active` (`user_id`,`revoked_at`,`refresh_expires_at`),
  KEY `idx_pp_t_auth_session_refresh_expires_at` (`refresh_expires_at`),
  CONSTRAINT `fk_pp_t_auth_session_user` FOREIGN KEY (`user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_pp_t_auth_session_client_ip_not_blank` CHECK (((`client_ip` is null) or (trim(`client_ip`) <> _latin1''))),
  CONSTRAINT `chk_pp_t_auth_session_created_by_not_blank` CHECK ((trim(`created_by`) <> _latin1'')),
  CONSTRAINT `chk_pp_t_auth_session_last_used_window` CHECK ((`last_used_at` >= `issued_at`)),
  CONSTRAINT `chk_pp_t_auth_session_refresh_token_hash_not_blank` CHECK ((trim(`refresh_token_hash`) <> _latin1'')),
  CONSTRAINT `chk_pp_t_auth_session_refresh_window` CHECK ((`refresh_expires_at` > `issued_at`)),
  CONSTRAINT `chk_pp_t_auth_session_revocation_reason` CHECK (((`revocation_reason` is null) or (`revocation_reason` in (_latin1'LOGOUT',_latin1'REFRESH_TOKEN_REUSE_DETECTED',_latin1'PASSWORD_CHANGED',_latin1'SESSION_LIMIT_EXCEEDED',_latin1'ADMIN_REVOKED')))),
  CONSTRAINT `chk_pp_t_auth_session_user_agent_not_blank` CHECK (((`user_agent` is null) or (trim(`user_agent`) <> _latin1'')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_t_login_throttle_state`
--

DROP TABLE IF EXISTS `pp_t_login_throttle_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_login_throttle_state` (
  `throttle_state_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `scope` varchar(30) NOT NULL,
  `identifier_value` varchar(255) NOT NULL,
  `failed_attempt_count` int NOT NULL DEFAULT '0',
  `window_started_at` timestamp(6) NULL DEFAULT NULL,
  `last_failed_at` timestamp(6) NULL DEFAULT NULL,
  `locked_until` timestamp(6) NULL DEFAULT NULL,
  `last_successful_at` timestamp(6) NULL DEFAULT NULL,
  `version` bigint unsigned NOT NULL DEFAULT '0',
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`throttle_state_id`),
  UNIQUE KEY `uk_pp_t_login_throttle_state_scope_identifier` (`scope`,`identifier_value`),
  KEY `idx_pp_t_login_throttle_state_scope_locked_until` (`scope`,`locked_until`),
  KEY `idx_pp_t_login_throttle_state_identifier` (`identifier_value`),
  CONSTRAINT `chk_pp_t_login_throttle_state_created_by_not_blank` CHECK ((trim(`created_by`) <> _latin1'')),
  CONSTRAINT `chk_pp_t_login_throttle_state_failed_attempt_count` CHECK ((`failed_attempt_count` >= 0)),
  CONSTRAINT `chk_pp_t_login_throttle_state_identifier_not_blank` CHECK ((trim(`identifier_value`) <> _latin1'')),
  CONSTRAINT `chk_pp_t_login_throttle_state_scope` CHECK ((`scope` in (_latin1'USERNAME',_latin1'IP_ADDRESS')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_t_role_permission_grant`
--

DROP TABLE IF EXISTS `pp_t_role_permission_grant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_role_permission_grant` (
  `role_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission_code` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `scope_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ORGANIZATION',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `assigned_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `assigned_reason` varchar(255) DEFAULT NULL,
  `revoked_by` varchar(100) DEFAULT NULL,
  `revoked_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`role_code`,`permission_code`),
  KEY `idx_pp_usm_role_permissions_permission_code` (`permission_code`),
  KEY `idx_pp_usm_role_permissions_role_active` (`role_code`,`is_active`),
  KEY `idx_pp_usm_role_permissions_permission_active` (`permission_code`,`is_active`),
  KEY `idx_pp_usm_role_permissions_assigned_by` (`assigned_by`),
  KEY `idx_pp_usm_role_permissions_revoked_by` (`revoked_by`),
  KEY `idx_pp_usm_role_permissions_scope_code` (`scope_code`),
  KEY `idx_pp_usm_role_permissions_permission_scope_active` (`permission_code`,`scope_code`,`is_active`),
  CONSTRAINT `fk_pp_t_role_permission_grant_permission` FOREIGN KEY (`permission_code`) REFERENCES `pp_m_permission` (`permission_code`),
  CONSTRAINT `fk_pp_t_role_permission_grant_role` FOREIGN KEY (`role_code`) REFERENCES `pp_m_role` (`role_code`),
  CONSTRAINT `fk_pp_t_role_permission_grant_scope` FOREIGN KEY (`scope_code`) REFERENCES `pp_r_permission_scope` (`scope_code`),
  CONSTRAINT `chk_pp_usm_role_permissions_assigned_by_not_blank` CHECK ((trim(`assigned_by`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permissions_assigned_reason_not_blank` CHECK (((`assigned_reason` is null) or (trim(`assigned_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permissions_permission_code_not_blank` CHECK ((trim(`permission_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permissions_revoked_by_not_blank` CHECK (((`revoked_by` is null) or (trim(`revoked_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permissions_revoked_reason_not_blank` CHECK (((`revoked_reason` is null) or (trim(`revoked_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permissions_role_code_not_blank` CHECK ((trim(`role_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permissions_scope_code_not_blank` CHECK ((trim(`scope_code`) <> _utf8mb4''))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_role_permission_grant_ai` AFTER INSERT ON `pp_t_role_permission_grant` FOR EACH ROW BEGIN
    INSERT INTO pp_t_role_permission_grant_audit
        (role_code, permission_code, event_type, previous_active, new_active,
         previous_scope_code, new_scope_code,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.role_code, NEW.permission_code, 'ASSIGNED', NULL, NEW.is_active,
         NULL, NEW.scope_code,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255),
         NULL,
         NULL,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_role_permission_grant_au` AFTER UPDATE ON `pp_t_role_permission_grant` FOR EACH ROW BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.scope_code <=> NEW.scope_code) THEN
        INSERT INTO pp_t_role_permission_grant_audit
            (role_code, permission_code, event_type, previous_active, new_active,
             previous_scope_code, new_scope_code,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.role_code, NEW.permission_code,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NEW.is_active THEN 'ACTIVATED'
                 WHEN NOT (OLD.is_active <=> NEW.is_active) THEN 'DEACTIVATED'
                 ELSE 'SCOPE_CHANGED'
             END,
             OLD.is_active, NEW.is_active,
             OLD.scope_code, NEW.scope_code,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_revoked_reason, NEW.revoked_reason, @rbac_audit_reason), 255)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.assigned_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, NEW.revoked_reason), 255)
                 ELSE LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255)
             END,
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_role_permission_grant_ad` AFTER DELETE ON `pp_t_role_permission_grant` FOR EACH ROW BEGIN
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
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_revoked_reason, OLD.revoked_reason, @rbac_audit_reason), 255),
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, OLD.revoked_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pp_t_role_permission_grant_audit`
--

DROP TABLE IF EXISTS `pp_t_role_permission_grant_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_role_permission_grant_audit` (
  `audit_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `permission_code` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `event_type` varchar(30) NOT NULL,
  `previous_active` tinyint(1) DEFAULT NULL,
  `new_active` tinyint(1) DEFAULT NULL,
  `previous_scope_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `new_scope_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `assigned_by` varchar(100) DEFAULT NULL,
  `assigned_reason` varchar(255) DEFAULT NULL,
  `revoked_by` varchar(100) DEFAULT NULL,
  `revoked_reason` varchar(255) DEFAULT NULL,
  `changed_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `changed_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `database_user` varchar(100) NOT NULL DEFAULT 'UNKNOWN',
  `source_code` varchar(30) NOT NULL DEFAULT 'DATABASE_TRIGGER',
  `change_reason` varchar(255) DEFAULT NULL,
  `correlation_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_pp_usm_role_permission_audits_role_time` (`role_code`,`changed_at`),
  KEY `idx_pp_usm_role_permission_audits_permission_time` (`permission_code`,`changed_at`),
  KEY `idx_pp_usm_role_permission_audits_event_time` (`event_type`,`changed_at`),
  KEY `idx_pp_usm_role_permission_audits_correlation_id` (`correlation_id`),
  KEY `idx_pp_usm_role_permission_audits_assigned_by` (`assigned_by`),
  KEY `idx_pp_usm_role_permission_audits_revoked_by` (`revoked_by`),
  KEY `idx_pp_usm_role_permission_audits_scope_time` (`new_scope_code`,`changed_at`),
  CONSTRAINT `chk_pp_usm_role_permission_audits_assigned_by_not_blank` CHECK (((`assigned_by` is null) or (trim(`assigned_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_assigned_reason_not_blank` CHECK (((`assigned_reason` is null) or (trim(`assigned_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_changed_by_not_blank` CHECK ((trim(`changed_by`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permission_audits_database_user_not_blank` CHECK ((trim(`database_user`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permission_audits_event_type` CHECK ((`event_type` in (_latin1'ASSIGNED',_latin1'ACTIVATED',_latin1'DEACTIVATED',_latin1'SCOPE_CHANGED',_latin1'REVOKED',_latin1'MIGRATED'))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_new_scope_code_not_blank` CHECK (((`new_scope_code` is null) or (trim(`new_scope_code`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_permission_code_not_blank` CHECK ((trim(`permission_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permission_audits_previous_scope_code_not_blank` CHECK (((`previous_scope_code` is null) or (trim(`previous_scope_code`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_revoked_by_not_blank` CHECK (((`revoked_by` is null) or (trim(`revoked_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_revoked_reason_not_blank` CHECK (((`revoked_reason` is null) or (trim(`revoked_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_role_permission_audits_role_code_not_blank` CHECK ((trim(`role_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_role_permission_audits_source_code_not_blank` CHECK ((trim(`source_code`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_t_user_organization_membership`
--

DROP TABLE IF EXISTS `pp_t_user_organization_membership`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_user_organization_membership` (
  `user_id` bigint unsigned NOT NULL,
  `organization_id` bigint unsigned NOT NULL,
  `membership_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE',
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `joined_at` timestamp(6) NULL DEFAULT NULL,
  `invited_by` varchar(100) DEFAULT NULL,
  `invited_at` timestamp(6) NULL DEFAULT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`user_id`,`organization_id`),
  KEY `idx_pp_org_user_memberships_status` (`membership_status`),
  KEY `idx_pp_org_user_memberships_org_status` (`organization_id`,`membership_status`),
  KEY `idx_pp_org_user_memberships_user_status` (`user_id`,`membership_status`),
  KEY `idx_pp_org_user_memberships_primary` (`user_id`,`is_primary`),
  KEY `idx_pp_org_user_memberships_invited_by` (`invited_by`),
  CONSTRAINT `fk_pp_t_user_organization_membership_organization` FOREIGN KEY (`organization_id`) REFERENCES `pp_m_organization` (`organization_id`),
  CONSTRAINT `fk_pp_t_user_organization_membership_status` FOREIGN KEY (`membership_status`) REFERENCES `pp_r_membership_status` (`status_code`),
  CONSTRAINT `fk_pp_t_user_organization_membership_user` FOREIGN KEY (`user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_pp_org_user_memberships_invited_by_not_blank` CHECK (((`invited_by` is null) or (trim(`invited_by`) <> _utf8mb4'')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_organization_membership_bi` BEFORE INSERT ON `pp_t_user_organization_membership` FOR EACH ROW BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_t_user_organization_membership existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_organization_membership_ai` AFTER INSERT ON `pp_t_user_organization_membership` FOR EACH ROW BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    END IF;

    INSERT INTO pp_t_user_organization_membership_audit
        (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
         previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
         new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
         source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.organization_id,
         LEFT(COALESCE(@org_membership_event_type,
              CASE
                  WHEN NEW.membership_status = 'INVITED' THEN 'INVITED'
                  WHEN NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                  WHEN NEW.membership_status = 'LEFT' THEN 'LEFT'
                  WHEN NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                  ELSE 'JOINED'
              END), 30),
         NULL, NEW.membership_status,
         NULL, NEW.is_primary,
         NULL, NEW.joined_at,
         NULL, NEW.invited_by,
         NULL, NEW.invited_at,
         LEFT(COALESCE(@rbac_audit_actor, NEW.created_by, NEW.invited_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_organization_membership_bu` BEFORE UPDATE ON `pp_t_user_organization_membership` FOR EACH ROW BEGIN
    IF NEW.is_primary
       AND EXISTS (
           SELECT 1
           FROM pp_t_user_organization_membership existing_membership
           WHERE existing_membership.user_id = NEW.user_id
             AND existing_membership.is_primary = TRUE
             AND NOT (existing_membership.user_id <=> OLD.user_id
                      AND existing_membership.organization_id <=> OLD.organization_id)
       ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a primary organization membership';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_organization_membership_au` AFTER UPDATE ON `pp_t_user_organization_membership` FOR EACH ROW BEGIN
    IF NEW.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NEW.organization_id,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND NOT (primary_organization_id <=> NEW.organization_id);
    ELSEIF OLD.is_primary
        AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NULL,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
        WHERE user_id = NEW.user_id
          AND primary_organization_id = OLD.organization_id;
    END IF;

    IF NOT (OLD.membership_status <=> NEW.membership_status)
        OR NOT (OLD.is_primary <=> NEW.is_primary)
        OR NOT (OLD.joined_at <=> NEW.joined_at)
        OR NOT (OLD.invited_by <=> NEW.invited_by)
        OR NOT (OLD.invited_at <=> NEW.invited_at) THEN
        INSERT INTO pp_t_user_organization_membership_audit
            (user_id, organization_id, event_type, previous_membership_status, new_membership_status,
             previous_primary, new_primary, previous_joined_at, new_joined_at, previous_invited_by,
             new_invited_by, previous_invited_at, new_invited_at, changed_by, database_user,
             source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id,
             CASE
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'ACTIVE' THEN 'ACTIVATED'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'SUSPENDED' THEN 'SUSPENDED'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'LEFT' THEN 'LEFT'
                 WHEN NOT (OLD.membership_status <=> NEW.membership_status)
                      AND NEW.membership_status = 'REMOVED' THEN 'REMOVED'
                 WHEN NOT (OLD.is_primary <=> NEW.is_primary) THEN 'PRIMARY_CHANGED'
                 ELSE 'DETAILS_CHANGED'
             END,
             OLD.membership_status, NEW.membership_status,
             OLD.is_primary, NEW.is_primary,
             OLD.joined_at, NEW.joined_at,
             OLD.invited_by, NEW.invited_by,
             OLD.invited_at, NEW.invited_at,
             LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100),
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             LEFT(@rbac_audit_reason, 255),
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_organization_membership_ad` AFTER DELETE ON `pp_t_user_organization_membership` FOR EACH ROW BEGIN
    IF OLD.is_primary
       AND COALESCE(@org_membership_skip_user_sync, FALSE) = FALSE THEN
        UPDATE pp_m_user
        SET primary_organization_id = NULL,
            updated_at = CURRENT_TIMESTAMP(6),
            updated_by = LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100)
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
         LEFT(COALESCE(@rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(@rbac_audit_reason, 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pp_t_user_organization_membership_audit`
--

DROP TABLE IF EXISTS `pp_t_user_organization_membership_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_user_organization_membership_audit` (
  `audit_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `organization_id` bigint unsigned NOT NULL,
  `event_type` varchar(30) NOT NULL,
  `previous_membership_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `new_membership_status` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `previous_primary` tinyint(1) DEFAULT NULL,
  `new_primary` tinyint(1) DEFAULT NULL,
  `previous_joined_at` timestamp(6) NULL DEFAULT NULL,
  `new_joined_at` timestamp(6) NULL DEFAULT NULL,
  `previous_invited_by` varchar(100) DEFAULT NULL,
  `new_invited_by` varchar(100) DEFAULT NULL,
  `previous_invited_at` timestamp(6) NULL DEFAULT NULL,
  `new_invited_at` timestamp(6) NULL DEFAULT NULL,
  `changed_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `changed_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `database_user` varchar(100) NOT NULL DEFAULT 'UNKNOWN',
  `source_code` varchar(30) NOT NULL DEFAULT 'DATABASE_TRIGGER',
  `change_reason` varchar(255) DEFAULT NULL,
  `correlation_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_pp_org_user_membership_audits_user_org_time` (`user_id`,`organization_id`,`changed_at`),
  KEY `idx_pp_org_user_membership_audits_org_time` (`organization_id`,`changed_at`),
  KEY `idx_pp_org_user_membership_audits_event_time` (`event_type`,`changed_at`),
  KEY `idx_pp_org_user_membership_audits_correlation_id` (`correlation_id`),
  KEY `idx_pp_org_user_membership_audits_changed_by` (`changed_by`),
  CONSTRAINT `chk_pp_org_user_membership_audits_changed_by_not_blank` CHECK ((trim(`changed_by`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_user_membership_audits_database_user_not_blank` CHECK ((trim(`database_user`) <> _latin1'')),
  CONSTRAINT `chk_pp_org_user_membership_audits_event_type` CHECK ((`event_type` in (_latin1'INVITED',_latin1'JOINED',_latin1'ACTIVATED',_latin1'SUSPENDED',_latin1'LEFT',_latin1'REMOVED',_latin1'PRIMARY_CHANGED',_latin1'DETAILS_CHANGED',_latin1'MIGRATED'))),
  CONSTRAINT `chk_pp_org_user_membership_audits_new_invited_by_not_blank` CHECK (((`new_invited_by` is null) or (trim(`new_invited_by`) <> _latin1''))),
  CONSTRAINT `chk_pp_org_user_membership_audits_new_status_not_blank` CHECK (((`new_membership_status` is null) or (trim(`new_membership_status`) <> _latin1''))),
  CONSTRAINT `chk_pp_org_user_membership_audits_previous_invited_by_not_blank` CHECK (((`previous_invited_by` is null) or (trim(`previous_invited_by`) <> _latin1''))),
  CONSTRAINT `chk_pp_org_user_membership_audits_previous_status_not_blank` CHECK (((`previous_membership_status` is null) or (trim(`previous_membership_status`) <> _latin1''))),
  CONSTRAINT `chk_pp_org_user_membership_audits_source_code_not_blank` CHECK ((trim(`source_code`) <> _latin1''))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pp_t_user_role_assignment`
--

DROP TABLE IF EXISTS `pp_t_user_role_assignment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_user_role_assignment` (
  `user_id` bigint unsigned NOT NULL,
  `organization_id` bigint unsigned NOT NULL DEFAULT '1',
  `role_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `valid_from` timestamp(6) NULL DEFAULT NULL,
  `valid_until` timestamp(6) NULL DEFAULT NULL,
  `assigned_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `assigned_reason` varchar(255) DEFAULT NULL,
  `revoked_by` varchar(100) DEFAULT NULL,
  `revoked_reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `updated_at` timestamp(6) NULL DEFAULT NULL,
  `updated_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`user_id`,`organization_id`,`role_code`),
  KEY `idx_pp_usm_user_roles_role_code` (`role_code`),
  KEY `idx_pp_usm_user_roles_role_active` (`role_code`,`is_active`),
  KEY `idx_pp_usm_user_roles_assigned_by` (`assigned_by`),
  KEY `idx_pp_usm_user_roles_revoked_by` (`revoked_by`),
  KEY `idx_pp_usm_user_roles_user_org_active_validity` (`user_id`,`organization_id`,`is_active`,`valid_from`,`valid_until`),
  KEY `idx_pp_usm_user_roles_org_role_active` (`organization_id`,`role_code`,`is_active`),
  CONSTRAINT `fk_pp_t_user_role_assignment_membership` FOREIGN KEY (`user_id`, `organization_id`) REFERENCES `pp_t_user_organization_membership` (`user_id`, `organization_id`),
  CONSTRAINT `fk_pp_t_user_role_assignment_organization` FOREIGN KEY (`organization_id`) REFERENCES `pp_m_organization` (`organization_id`),
  CONSTRAINT `fk_pp_t_user_role_assignment_role` FOREIGN KEY (`role_code`) REFERENCES `pp_m_role` (`role_code`),
  CONSTRAINT `fk_pp_t_user_role_assignment_user` FOREIGN KEY (`user_id`) REFERENCES `pp_m_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_pp_usm_user_roles_assigned_by_not_blank` CHECK ((trim(`assigned_by`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_user_roles_assigned_reason_not_blank` CHECK (((`assigned_reason` is null) or (trim(`assigned_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_roles_revoked_by_not_blank` CHECK (((`revoked_by` is null) or (trim(`revoked_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_roles_revoked_reason_not_blank` CHECK (((`revoked_reason` is null) or (trim(`revoked_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_roles_role_code_not_blank` CHECK ((trim(`role_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_user_roles_valid_window` CHECK (((`valid_until` is null) or (`valid_from` is null) or (`valid_until` > `valid_from`)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_role_assignment_ai` AFTER INSERT ON `pp_t_user_role_assignment` FOR EACH ROW BEGIN
    INSERT INTO pp_t_user_role_assignment_audit
        (user_id, organization_id, role_code, event_type, previous_active, new_active,
         previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
         assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
         database_user, source_code, change_reason, correlation_id)
    VALUES
        (NEW.user_id, NEW.organization_id, NEW.role_code, 'ASSIGNED', NULL, NEW.is_active,
         NULL, NULL, NEW.valid_from, NEW.valid_until,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255),
         NULL,
         NULL,
         LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_role_assignment_au` AFTER UPDATE ON `pp_t_user_role_assignment` FOR EACH ROW BEGIN
    IF NOT (OLD.is_active <=> NEW.is_active)
        OR NOT (OLD.valid_from <=> NEW.valid_from)
        OR NOT (OLD.valid_until <=> NEW.valid_until) THEN
        INSERT INTO pp_t_user_role_assignment_audit
            (user_id, organization_id, role_code, event_type, previous_active, new_active,
             previous_valid_from, previous_valid_until, new_valid_from, new_valid_until,
             assigned_by, assigned_reason, revoked_by, revoked_reason, changed_by,
             database_user, source_code, change_reason, correlation_id)
        VALUES
            (NEW.user_id, NEW.organization_id, NEW.role_code,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NEW.is_active THEN 'ACTIVATED'
                 WHEN NOT (OLD.is_active <=> NEW.is_active) THEN 'DEACTIVATED'
                 ELSE 'VALIDITY_CHANGED'
             END,
             OLD.is_active, NEW.is_active,
             OLD.valid_from, OLD.valid_until, NEW.valid_from, NEW.valid_until,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_by, NEW.assigned_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active THEN NULL
                 ELSE LEFT(COALESCE(@rbac_assigned_reason, NEW.assigned_reason, @rbac_audit_reason), 255)
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_reason, NEW.revoked_reason, @rbac_audit_reason), 255)
                 ELSE NULL
             END,
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_revoked_by, NEW.revoked_by, @rbac_audit_actor, NEW.updated_by, NEW.created_by, 'SYSTEM'), 100)
                 ELSE LEFT(COALESCE(@rbac_audit_actor, NEW.updated_by, NEW.assigned_by, NEW.created_by, 'SYSTEM'), 100)
             END,
             LEFT(CURRENT_USER(), 100),
             LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
             CASE
                 WHEN NOT (OLD.is_active <=> NEW.is_active) AND NOT NEW.is_active
                     THEN LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, NEW.revoked_reason), 255)
                 ELSE LEFT(COALESCE(@rbac_audit_reason, @rbac_assigned_reason, NEW.assigned_reason), 255)
             END,
             LEFT(@rbac_audit_correlation_id, 100));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pp_t_user_role_assignment_ad` AFTER DELETE ON `pp_t_user_role_assignment` FOR EACH ROW BEGIN
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
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(COALESCE(@rbac_revoked_reason, OLD.revoked_reason, @rbac_audit_reason), 255),
         LEFT(COALESCE(@rbac_revoked_by, OLD.revoked_by, @rbac_audit_actor, OLD.updated_by, OLD.created_by, 'SYSTEM'), 100),
         LEFT(CURRENT_USER(), 100),
         LEFT(COALESCE(@rbac_audit_source, 'DATABASE_TRIGGER'), 30),
         LEFT(COALESCE(@rbac_audit_reason, @rbac_revoked_reason, OLD.revoked_reason), 255),
         LEFT(@rbac_audit_correlation_id, 100));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `pp_t_user_role_assignment_audit`
--

DROP TABLE IF EXISTS `pp_t_user_role_assignment_audit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pp_t_user_role_assignment_audit` (
  `audit_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `organization_id` bigint unsigned NOT NULL DEFAULT '1',
  `role_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `event_type` varchar(30) NOT NULL,
  `previous_active` tinyint(1) DEFAULT NULL,
  `new_active` tinyint(1) DEFAULT NULL,
  `previous_valid_from` timestamp(6) NULL DEFAULT NULL,
  `previous_valid_until` timestamp(6) NULL DEFAULT NULL,
  `new_valid_from` timestamp(6) NULL DEFAULT NULL,
  `new_valid_until` timestamp(6) NULL DEFAULT NULL,
  `assigned_by` varchar(100) DEFAULT NULL,
  `assigned_reason` varchar(255) DEFAULT NULL,
  `revoked_by` varchar(100) DEFAULT NULL,
  `revoked_reason` varchar(255) DEFAULT NULL,
  `changed_at` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `changed_by` varchar(100) NOT NULL DEFAULT 'SYSTEM',
  `database_user` varchar(100) NOT NULL DEFAULT 'UNKNOWN',
  `source_code` varchar(30) NOT NULL DEFAULT 'DATABASE_TRIGGER',
  `change_reason` varchar(255) DEFAULT NULL,
  `correlation_id` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`audit_id`),
  KEY `idx_pp_usm_user_role_audits_role_time` (`role_code`,`changed_at`),
  KEY `idx_pp_usm_user_role_audits_event_time` (`event_type`,`changed_at`),
  KEY `idx_pp_usm_user_role_audits_correlation_id` (`correlation_id`),
  KEY `idx_pp_usm_user_role_audits_assigned_by` (`assigned_by`),
  KEY `idx_pp_usm_user_role_audits_revoked_by` (`revoked_by`),
  KEY `idx_pp_usm_user_role_audits_user_org_time` (`user_id`,`organization_id`,`changed_at`),
  KEY `idx_pp_usm_user_role_audits_org_time` (`organization_id`,`changed_at`),
  CONSTRAINT `chk_pp_usm_user_role_audits_assigned_by_not_blank` CHECK (((`assigned_by` is null) or (trim(`assigned_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_role_audits_assigned_reason_not_blank` CHECK (((`assigned_reason` is null) or (trim(`assigned_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_role_audits_changed_by_not_blank` CHECK ((trim(`changed_by`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_user_role_audits_database_user_not_blank` CHECK ((trim(`database_user`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_user_role_audits_event_type` CHECK ((`event_type` in (_utf8mb4'ASSIGNED',_utf8mb4'ACTIVATED',_utf8mb4'DEACTIVATED',_utf8mb4'VALIDITY_CHANGED',_utf8mb4'REVOKED',_utf8mb4'MIGRATED'))),
  CONSTRAINT `chk_pp_usm_user_role_audits_new_valid_window` CHECK (((`new_valid_until` is null) or (`new_valid_from` is null) or (`new_valid_until` > `new_valid_from`))),
  CONSTRAINT `chk_pp_usm_user_role_audits_previous_valid_window` CHECK (((`previous_valid_until` is null) or (`previous_valid_from` is null) or (`previous_valid_until` > `previous_valid_from`))),
  CONSTRAINT `chk_pp_usm_user_role_audits_revoked_by_not_blank` CHECK (((`revoked_by` is null) or (trim(`revoked_by`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_role_audits_revoked_reason_not_blank` CHECK (((`revoked_reason` is null) or (trim(`revoked_reason`) <> _utf8mb4''))),
  CONSTRAINT `chk_pp_usm_user_role_audits_role_code_not_blank` CHECK ((trim(`role_code`) <> _utf8mb4'')),
  CONSTRAINT `chk_pp_usm_user_role_audits_source_code_not_blank` CHECK ((trim(`source_code`) <> _utf8mb4''))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'productportal'
--

--
-- Dumping routines for database 'productportal'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-11 23:05:13
