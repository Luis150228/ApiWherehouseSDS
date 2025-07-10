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
-- Table structure for table `almacen_catalogoequipos`
--

DROP TABLE IF EXISTS `almacen_catalogoequipos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_catalogoequipos` (
  `idequipo` int NOT NULL AUTO_INCREMENT,
  `npvr` int DEFAULT NULL,
  `grupo` varchar(45) DEFAULT NULL,
  `tipo_equipo` varchar(250) DEFAULT NULL,
  `marca` varchar(150) DEFAULT NULL,
  `modelo` varchar(150) DEFAULT NULL,
  `cod_barras` varchar(45) DEFAULT NULL,
  `descripcion` text,
  `imagen` varchar(500) DEFAULT NULL,
  `estatus` int DEFAULT '1',
  `usr_registro` varchar(45) DEFAULT NULL,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modifica` varchar(45) DEFAULT NULL,
  `f_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`idequipo`)
) ENGINE=InnoDB AUTO_INCREMENT=295 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `almacen_empresas`
--

DROP TABLE IF EXISTS `almacen_empresas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_empresas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `empresa` varchar(150) DEFAULT NULL,
  `estatus` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `almacen_invasignado`
--

DROP TABLE IF EXISTS `almacen_invasignado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_invasignado` (
  `idinventario` int NOT NULL AUTO_INCREMENT,
  `num_etiqueta` varchar(45) DEFAULT NULL,
  `entrada_Type` varchar(45) NOT NULL DEFAULT 'nuevo',
  `num_ci` varchar(45) DEFAULT NULL,
  `edo_ci` varchar(45) DEFAULT NULL,
  `noe` int NOT NULL,
  `idequipo` int NOT NULL,
  `serie` varchar(150) DEFAULT NULL,
  `stock` int DEFAULT '1',
  `usr_resguardo` varchar(7) DEFAULT NULL,
  `almacen` varchar(150) DEFAULT NULL,
  `tipo_almacen` varchar(45) DEFAULT 'Fisico',
  `empresa` varchar(145) DEFAULT NULL,
  `ubica_rack` varchar(150) DEFAULT NULL,
  `servicenow` varchar(245) DEFAULT NULL,
  `adf` varchar(45) DEFAULT NULL,
  `hostname` tinytext,
  `observacion` longtext,
  `num_asignacion` varchar(150) DEFAULT NULL,
  `usr_asignado` varchar(7) DEFAULT NULL,
  `name_asignado` varchar(255) DEFAULT NULL,
  `nota_asignado` longtext,
  `user_recibe` varchar(45) DEFAULT NULL,
  `f_recepcion` datetime DEFAULT NULL,
  `f_asignacion` datetime DEFAULT NULL,
  `usr_modifica` varchar(45) DEFAULT NULL,
  `f_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `usr_registro` varchar(7) DEFAULT NULL,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idinventario`)
) ENGINE=InnoDB AUTO_INCREMENT=75235 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `almacen_invbridge`
--

DROP TABLE IF EXISTS `almacen_invbridge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_invbridge` (
  `idinventario` int NOT NULL AUTO_INCREMENT,
  `noe` int NOT NULL,
  `idequipo` int NOT NULL,
  `etiqueta` varchar(145) DEFAULT NULL,
  `serie` varchar(150) DEFAULT NULL,
  `usr_origen` varchar(7) DEFAULT NULL,
  `almacen_origen` varchar(250) DEFAULT NULL,
  `usr_resguardo` varchar(7) DEFAULT NULL,
  `almacen` varchar(250) DEFAULT NULL,
  `tipo_almacen` varchar(45) DEFAULT 'Fisico',
  `empresa` int DEFAULT NULL,
  `num_asignacion` varchar(150) DEFAULT NULL,
  `adf` varchar(45) DEFAULT NULL,
  `estatus` int DEFAULT '1',
  `comentarios` longtext,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idinventario`)
) ENGINE=InnoDB AUTO_INCREMENT=83844 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `almacen_inventario`
--

DROP TABLE IF EXISTS `almacen_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_inventario` (
  `idinventario` int NOT NULL AUTO_INCREMENT,
  `num_etiqueta` varchar(45) DEFAULT NULL,
  `entrada_Type` varchar(45) NOT NULL DEFAULT 'nuevo',
  `num_ci` varchar(45) DEFAULT NULL,
  `edo_ci` varchar(45) DEFAULT NULL,
  `noe` int NOT NULL,
  `idequipo` int NOT NULL,
  `serie` varchar(150) DEFAULT NULL,
  `stock` int DEFAULT '1',
  `usr_resguardo` varchar(7) DEFAULT NULL,
  `almacen` varchar(150) DEFAULT NULL,
  `tipo_almacen` varchar(45) DEFAULT 'Fisico',
  `empresa` varchar(145) DEFAULT NULL,
  `ubica_rack` varchar(150) DEFAULT NULL,
  `servicenow` varchar(145) DEFAULT NULL,
  `adf` varchar(45) DEFAULT NULL,
  `hostname` tinytext,
  `observacion` longtext,
  `num_asignacion` varchar(150) DEFAULT NULL,
  `usr_asignado` varchar(7) DEFAULT NULL,
  `name_asignado` varchar(255) DEFAULT NULL,
  `nota_asignado` longtext,
  `user_recibe` varchar(45) DEFAULT NULL,
  `f_recepcion` datetime DEFAULT NULL,
  `f_asignacion` datetime DEFAULT NULL,
  `usr_modifica` varchar(45) DEFAULT NULL,
  `f_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `usr_registro` varchar(7) DEFAULT NULL,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idinventario`)
) ENGINE=InnoDB AUTO_INCREMENT=77736 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `almacen_ordenentrada`
--

DROP TABLE IF EXISTS `almacen_ordenentrada`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `almacen_ordenentrada` (
  `noe` int NOT NULL AUTO_INCREMENT,
  `num_pedido` varchar(150) DEFAULT NULL,
  `npvr` int DEFAULT NULL,
  `odc_marca` varchar(250) DEFAULT NULL,
  `stock_adquirido` int DEFAULT NULL,
  `f_entrada` datetime DEFAULT NULL,
  `almacen` varchar(150) DEFAULT NULL,
  `motivo` varchar(150) DEFAULT NULL,
  `documentacion` text,
  `observaciones` text,
  `usr_registro` varchar(45) DEFAULT NULL,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modifica` varchar(45) DEFAULT NULL,
  `f_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`noe`)
) ENGINE=InnoDB AUTO_INCREMENT=192 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cmdb`
--

DROP TABLE IF EXISTS `cmdb`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cmdb` (
  `asset_tag` varchar(45) NOT NULL,
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
  `cmdb_update` datetime DEFAULT NULL,
  PRIMARY KEY (`asset_tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `eut_users`
--

DROP TABLE IF EXISTS `eut_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eut_users` (
  `num_user` int NOT NULL AUTO_INCREMENT,
  `user` varchar(10) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `ubicacion` varchar(150) DEFAULT NULL,
  `tipo_almacen` varchar(45) DEFAULT NULL,
  `nivel` int NOT NULL DEFAULT '4',
  `ctrl_acceso` mediumtext NOT NULL,
  `puesto` varchar(150) NOT NULL,
  `password` mediumtext NOT NULL,
  `estatus` int NOT NULL DEFAULT '1',
  `logg` int DEFAULT NULL,
  `token` longtext,
  `last_login` datetime DEFAULT NULL,
  `creado` datetime DEFAULT NULL,
  `usr_update` varchar(10) DEFAULT NULL,
  `update` datetime DEFAULT NULL,
  PRIMARY KEY (`num_user`)
) ENGINE=InnoDB AUTO_INCREMENT=1099 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

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
-- Table structure for table `x_entradas`
--

DROP TABLE IF EXISTS `x_entradas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `x_entradas` (
  `id_entrada` int NOT NULL AUTO_INCREMENT,
  `noc` int DEFAULT NULL,
  `npvr` int DEFAULT NULL,
  `f_entrada` datetime DEFAULT NULL,
  `id_equipos` int NOT NULL,
  `cantidad` int NOT NULL,
  `almacen` varchar(150) DEFAULT NULL,
  `ubica_rack` varchar(150) DEFAULT NULL,
  `motivo` varchar(150) DEFAULT NULL,
  `documentacion` text,
  `observaciones` text,
  `usr_registro` varchar(45) DEFAULT NULL,
  `f_registro` datetime DEFAULT CURRENT_TIMESTAMP,
  `usr_modifica` varchar(45) DEFAULT NULL,
  `f_modifica` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_entrada`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'eut_warehouse'
--
/*!50003 DROP FUNCTION IF EXISTS `eut_hour` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `eut_hour`() RETURNS datetime
    DETERMINISTIC
BEGIN

DECLARE tiempo DATETIME;

SET tiempo = (SELECT DATE_SUB(NOW(), INTERVAL 6 hour));

RETURN tiempo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_actualUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `fn_actualUser`(var_token longtext) RETURNS varchar(50) CHARSET utf8mb3
    DETERMINISTIC
BEGIN

DECLARE let_numUsr INT;
DECLARE let_user VARCHAR(50);

SET let_numUsr = (SELECT tokenValidate(var_token));
SET let_user = (SELECT CONCAT(`user`,'_', `nivel` ,'_', `puesto`) FROM eut_users where num_user = let_numUsr);

RETURN let_user;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_userLevel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `fn_userLevel`(var_actualUser VARCHAR(50)) RETURNS int
    DETERMINISTIC
BEGIN

DECLARE let_level INT;

SET let_level = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(var_actualUser, '_', 2), '_', -1));

RETURN let_level;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_userPuesto` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `fn_userPuesto`(var_actualUser VARCHAR(50)) RETURNS varchar(10) CHARSET utf8mb3
    DETERMINISTIC
BEGIN

DECLARE let_puesto varchar(10);

SET let_puesto = (SELECT SUBSTRING_INDEX(var_actualUser, '_', -1));

RETURN let_puesto;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_userUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `fn_userUser`(var_actualUser VARCHAR(50)) RETURNS varchar(10) CHARSET utf8mb3
    DETERMINISTIC
BEGIN

DECLARE let_user varchar(10);

SET let_user = (SELECT SUBSTRING_INDEX(var_actualUser, '_', 1));

RETURN let_user;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `tokenValidate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` FUNCTION `tokenValidate`(var_token LONGTEXT) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE tk LONGTEXT;
DECLARE id INT;

SET tk = (SELECT trim(substring_index(var_token, ' ', -1)));
SET id = (SELECT num_user FROM eut_users WHERE token = tk AND (estatus = 1 AND puesto = 'Admin') LIMIT 1);

RETURN id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_catEquipo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_catEquipo`(var_idequipo INT)
BEGIN

SELECT grupo, tipo_equipo, marca, modelo, cod_barras, descripcion, imagen, estatus, usr_registro, f_registro, usr_modifica, f_modifica FROM almacen_catalogoequipos WHERE idequipo = var_idequipo;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_catEquipoCreate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_catEquipoCreate`(var_grupo VARCHAR(11), var_tipo_equipo VARCHAR(250), var_marca VARCHAR(125), var_description TINYTEXT, var_modelo VARCHAR(250), var_imagen LONGTEXT, var_token LONGTEXT)
BEGIN

DECLARE let_numuser VARCHAR(50);
DECLARE let_user VARCHAR(10);
DECLARE let_userLevel INT;
DECLARE let_userPuesto VARCHAR(10);
DECLARE let_dateCreate DATETIME;

SET let_numuser = (SELECT fn_actualUser(var_token));
SET let_user = (SELECT fn_userUser(let_numuser));
SET let_userLevel = (SELECT fn_userLevel(let_numuser));
SET let_userPuesto = (SELECT fn_userPuesto(let_numuser));
SET let_dateCreate = (SELECT eut_hour());

IF var_grupo = 'EAF' OR var_grupo = 'Accesorio' THEN
	IF let_userLevel <= 1 AND let_userPuesto = 'Admin' THEN
		INSERT INTO `almacen_catalogoequipos` (`grupo`, `npvr`, `tipo_equipo`, `marca`, `descripcion`, `modelo`, `imagen`, `usr_registro`, `f_registro`) VALUES (var_grupo, 7, var_tipo_equipo, var_marca, var_description, var_modelo, var_imagen, let_user, let_dateCreate);
		SELECT `grupo`, `tipo_equipo`, `marca`, `descripcion`, `imagen`, `estatus`, `usr_registro`, `f_registro`, '201' as 'code', 'Equipo creado correctamente' as 'response' FROM `almacen_catalogoequipos` WHERE usr_registro = let_user AND `f_registro` = let_dateCreate ORDER BY idequipo DESC limit 1; 

	ELSE
		SELECT '401' as 'code', 'No tiene permiso para acceder al recurso' AS 'response';
	END IF;
ELSE
	SELECT '400' as 'code', 'Tipo de equipo Desconocido' AS 'response';

-- END IF;
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_catEquipos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_catEquipos`()
BEGIN

SELECT idequipo, grupo, tipo_equipo, marca, modelo, descripcion, imagen, estatus, usr_registro, f_registro, usr_modifica, f_modifica FROM almacen_catalogoequipos;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_catEquiposList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_catEquiposList`()
BEGIN

SELECT idequipo, grupo, tipo_equipo, marca, modelo, descripcion, imagen, estatus, usr_registro, f_registro, usr_modifica, f_modifica FROM almacen_catalogoequipos;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_catEquipoUpdate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_catEquipoUpdate`(var_idequipo INT, var_grupo VARCHAR(11), var_tipo_equipo VARCHAR(250), var_marca VARCHAR(125), var_description TINYTEXT, var_modelo VARCHAR(250), var_cb VARCHAR(250), var_imagen LONGTEXT, var_estatus VARCHAR(11), var_token LONGTEXT)
BEGIN

DECLARE let_numuser VARCHAR(50);
DECLARE let_user VARCHAR(10);
DECLARE let_userLevel INT;
DECLARE let_userPuesto VARCHAR(10);
DECLARE let_estatus INT;
DECLARE let_dateCreate DATETIME;

IF var_estatus = 'activo' THEN
	SET let_estatus = 1;
ELSE
	SET let_estatus = 0;
END IF;

SET let_numuser = (SELECT fn_actualUser(var_token));
SET let_user = (SELECT fn_userUser(let_numuser));
SET let_userLevel = (SELECT fn_userLevel(let_numuser));
SET let_userPuesto = (SELECT fn_userPuesto(let_numuser));
SET let_dateCreate = (SELECT eut_hour());

IF var_grupo = 'EAF' OR var_grupo = 'Accesorio' THEN
	IF let_userLevel <= 1 AND let_userPuesto = 'Admin' THEN
		UPDATE `almacen_catalogoequipos` SET `grupo` = var_grupo, `tipo_equipo` = var_tipo_equipo, `marca` = var_marca, `descripcion` = var_description, `modelo` = var_modelo, `cod_barras` = var_cb, `imagen` = var_imagen, `estatus` = let_estatus, `usr_modifica` = let_user, `f_modifica` = let_dateCreate WHERE (`idequipo` = var_idequipo);

		SELECT `grupo`, `tipo_equipo`, `marca`, `descripcion`, `imagen`, IF(`estatus` = 1, "Activo", "Inactivo") as 'estatus', `usr_registro`, `f_modifica`, `f_modifica`, '200' as 'code', 'Equipo modificado correctamente' as 'response' FROM `almacen_catalogoequipos` WHERE usr_modifica = let_user AND `idequipo` = var_idequipo limit 1; 

	ELSE
		SELECT '401' as 'code', 'No tiene permiso para acceder al recurso' AS 'response';
	END IF;
ELSE
	SELECT '400' as 'code', 'Tipo de equipo Desconocido' AS 'response';

-- END IF;
END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_userLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_userLogin`(var_user VARCHAR(20))
BEGIN

SELECT num_user, `user`, nombre, password, estatus FROM eut_users WHERE estatus = 1 AND `user` = var_user limit 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_usersCreate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_usersCreate`(var_user varchar(10), var_nombre varchar(250), var_ubicacion varchar(150), var_tipo_almacen varchar(45), var_nivel int, var_ctrl_acceso mediumtext, var_puesto varchar(150), var_password mediumtext, var_estatus int)
BEGIN
DECLARE let_create DATETIME;

SET let_create = (now());

INSERT INTO `eut_users` (`user`, `nombre`, `ubicacion`, `tipo_almacen`, `nivel`, `puesto`, `password`, `estatus`, `creado`) VALUES 
(var_user, var_nombre, var_ubicacion, var_tipo_almacen, var_nivel, var_puesto, SHA2(var_password,256), var_estatus, let_create);

SELECT `user`, `nombre`, `ubicacion`, `tipo_almacen`, `nivel`, `puesto`, `estatus`, `creado` FROM `eut_users` WHERE `creado` = let_create order by num_user desc LIMIT 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_userSetToken` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_userSetToken`(var_num_user INT, var_token longtext)
BEGIN
UPDATE `eut_users` SET `token` = var_token, `last_login` = eut_hour() WHERE (`num_user` = var_num_user);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_usersList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_usersList`()
BEGIN

SELECT `user`, nombre, ubicacion, tipo_almacen, nivel, puesto, estatus, logg, token FROM eut_warehouse.eut_users limit 6;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `stp_usersUpdate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `stp_usersUpdate`(var_numUser int, var_newName VARCHAR(250), var_password MEDIUMTEXT, var_almacen VARCHAR(250), var_estatus INT)
BEGIN

DECLARE nameUser VARCHAR(250);
DECLARE userUpdate VARCHAR(10);
DECLARE let_password VARCHAR(250);
DECLARE let_almacen VARCHAR(250);
DECLARE let_estatus VARCHAR(250);
DECLARE let_token LONGTEXT;

SET userUpdate = (SELECT `user` FROM eut_users where num_user = var_numUser);
SET nameUser = (upper(var_newName));
IF var_password = '' or NULL THEN
    SET let_password = (SELECT `password` FROM eut_users where num_user = var_numUser);
	SET let_token = (SELECT `token` FROM eut_users where num_user = var_numUser);
ELSE
	SET let_password = SHA2(var_password,256);
    SET let_token = null;
END IF;

IF var_almacen = '' or NULL THEN
    SET let_almacen = (SELECT `ubicacion` FROM eut_users where num_user = var_numUser);
ELSE
	SET let_almacen = var_almacen;
END IF;

UPDATE `eut_users` SET `nombre` = nameUser, `password` = let_password, `token` = let_token, `ubicacion` = let_almacen, `estatus` = var_estatus, `usr_update` = userUpdate, `update` = eut_hour() WHERE (`num_user` = var_numUser);

SELECT num_user, `user`, nombre, ubicacion, tipo_almacen, nivel FROM eut_users;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `userGetInfo` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ALLOW_INVALID_DATES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`lrangel`@`%` PROCEDURE `userGetInfo`(var_numUser INT)
BEGIN

SELECT user, nombre, ubicacion, tipo_almacen, nivel, puesto, estatus, logg, last_login, creado FROM eut_users WHERE num_user = var_numUser AND estatus = 1 limit 1;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-07-10 13:34:06
