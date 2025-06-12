CREATE DATABASE  IF NOT EXISTS `eut_warehouse` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `eut_warehouse`;
-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: 180.176.105.244    Database: eut_warehouse
-- ------------------------------------------------------
-- Server version	8.0.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cmdb_bridge`
--

DROP TABLE IF EXISTS `cmdb_bridge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cmdb_bridge` (
  `asset_tag` varchar(45) DEFAULT NULL,
  `u_type_ref` varchar(145) DEFAULT NULL,
  `name` varchar(45) DEFAULT NULL,
  `assigned_to` varchar(245) DEFAULT NULL,
  `serial_number` varchar(145) DEFAULT NULL,
  `u_status` varchar(45) DEFAULT NULL,
  `u_status_reason` varchar(45) DEFAULT NULL,
  `assignment_group` varchar(145) DEFAULT NULL,
  `manufacturer` varchar(150) DEFAULT NULL,
  `model_id` varchar(150) DEFAULT NULL,
  `u_third_party` varchar(45) DEFAULT NULL,
  `u_third_company` varchar(150) DEFAULT NULL,
  `dns_domain` varchar(45) DEFAULT NULL,
  `u_delivery` varchar(45) DEFAULT NULL,
  `used_for` varchar(45) DEFAULT NULL,
  `u_obsolescence_date_hw` date DEFAULT NULL,
  `u_obsolescence_date_sw` date DEFAULT NULL,
  `u_os_model_id` varchar(245) DEFAULT NULL,
  `sys_class_name` varchar(45) DEFAULT NULL,
  `sys_created_by` varchar(45) DEFAULT NULL,
  `company` varchar(45) DEFAULT NULL,
  `comments` longtext,
  `u_category` varchar(145) DEFAULT NULL,
  `managed_by` varchar(145) DEFAULT NULL,
  `support_group` varchar(145) DEFAULT NULL,
  `owned_by` varchar(45) DEFAULT NULL,
  `location` varchar(145) DEFAULT NULL,
  `u_created_date` datetime DEFAULT NULL,
  `sys_updated_on` datetime DEFAULT NULL,
  `sys_updated_by` varchar(145) DEFAULT NULL,
  `cmdb_update` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cmdb_bridge`
--

LOCK TABLES `cmdb_bridge` WRITE;
/*!40000 ALTER TABLE `cmdb_bridge` DISABLE KEYS */;
/*!40000 ALTER TABLE `cmdb_bridge` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-12 16:59:37
