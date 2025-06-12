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
-- Table structure for table `menuaccess`
--

DROP TABLE IF EXISTS `menuaccess`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuaccess` (
  `id` int NOT NULL AUTO_INCREMENT,
  `etiqueta` varchar(150) NOT NULL,
  `href` varchar(45) NOT NULL,
  `area` varchar(45) NOT NULL,
  `level` int NOT NULL,
  `subMenus` longtext,
  `estatus` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menuaccess`
--

LOCK TABLES `menuaccess` WRITE;
/*!40000 ALTER TABLE `menuaccess` DISABLE KEYS */;
INSERT INTO `menuaccess` VALUES (1,'EUT Inventario','./index.html','General',3,NULL,1),(2,'Orden de Entrada','apps/odc.html','Almancen',1,NULL,1),(3,'Inventario','apps/inv.html','General',3,NULL,1),(4,'ADF Inventario','apps/adf_inv.html','Almancen',3,NULL,1),(5,'Asignar Activo','apps/asig240529.html','CAU',3,NULL,1),(6,'CMDB','apps/cmdbFile.html','CMDB',3,NULL,1),(7,'Catalogo Equipos','apps/prodc.html','Almancen',1,NULL,1),(8,'Catalodo de Provedores','apps/provd.html','Almancen',2,NULL,0);
/*!40000 ALTER TABLE `menuaccess` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-12 17:00:11
