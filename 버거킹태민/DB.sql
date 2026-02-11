-- MySQL dump 10.13  Distrib 8.0.19, for Win64 (x86_64)
--
-- Host: localhost    Database: db
-- ------------------------------------------------------
-- Server version	8.4.7

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
-- Table structure for table `tb_capture_log`
--

DROP TABLE IF EXISTS `tb_capture_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_capture_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` int NOT NULL,
  `label_id` int DEFAULT NULL,
  `load_level` int DEFAULT '0',
  `image_url` varchar(255) DEFAULT NULL,
  `gps_latitude` decimal(10,8) DEFAULT NULL,
  `gps_longitude` decimal(11,8) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `device_id` (`device_id`),
  KEY `label_id` (`label_id`),
  CONSTRAINT `tb_capture_log_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `tb_device` (`device_id`) ON DELETE CASCADE,
  CONSTRAINT `tb_capture_log_ibfk_2` FOREIGN KEY (`label_id`) REFERENCES `tb_label` (`label_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_capture_log`
--

LOCK TABLES `tb_capture_log` WRITE;
/*!40000 ALTER TABLE `tb_capture_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_capture_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_cleaning_log`
--

DROP TABLE IF EXISTS `tb_cleaning_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_cleaning_log` (
  `clean_id` bigint NOT NULL AUTO_INCREMENT,
  `device_id` int NOT NULL,
  `user_id` int NOT NULL,
  `cleaned_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`clean_id`),
  KEY `device_id` (`device_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `tb_cleaning_log_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `tb_device` (`device_id`) ON DELETE CASCADE,
  CONSTRAINT `tb_cleaning_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_cleaning_log`
--

LOCK TABLES `tb_cleaning_log` WRITE;
/*!40000 ALTER TABLE `tb_cleaning_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_cleaning_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_device`
--

DROP TABLE IF EXISTS `tb_device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_device` (
  `device_id` int NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `device_name` varchar(50) NOT NULL,
  `building` varchar(50) DEFAULT NULL,
  `floor` int DEFAULT NULL,
  `threshold` int NOT NULL DEFAULT '80',
  `current_load` int NOT NULL DEFAULT '0',
  `status` enum('ON','OFF','ERROR') NOT NULL DEFAULT 'OFF',
  `last_connected` datetime DEFAULT NULL,
  PRIMARY KEY (`device_id`),
  UNIQUE KEY `serial_number` (`serial_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_device`
--

LOCK TABLES `tb_device` WRITE;
/*!40000 ALTER TABLE `tb_device` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_device` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_feedback`
--

DROP TABLE IF EXISTS `tb_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_feedback` (
  `feedback_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `tb_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_feedback`
--

LOCK TABLES `tb_feedback` WRITE;
/*!40000 ALTER TABLE `tb_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_label`
--

DROP TABLE IF EXISTS `tb_label`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_label` (
  `label_id` int NOT NULL AUTO_INCREMENT,
  `label_name` varchar(20) NOT NULL COMMENT '상, 중, 하',
  `description` varchar(100) DEFAULT NULL COMMENT '라벨 설명',
  PRIMARY KEY (`label_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_label`
--

LOCK TABLES `tb_label` WRITE;
/*!40000 ALTER TABLE `tb_label` DISABLE KEYS */;
INSERT INTO `tb_label` VALUES (1,'상','쓰레기 가득 참 (High)'),(2,'중','절반 정도 참 (Medium)'),(3,'하','거의 비어 있음 (Low)');
/*!40000 ALTER TABLE `tb_label` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_notification`
--

DROP TABLE IF EXISTS `tb_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_notification` (
  `noti_id` bigint NOT NULL AUTO_INCREMENT,
  `target_user_id` int DEFAULT NULL,
  `device_id` int DEFAULT NULL,
  `title` varchar(100) NOT NULL,
  `message` text NOT NULL,
  `type` enum('THRESHOLD','NOTICE') NOT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`noti_id`),
  KEY `target_user_id` (`target_user_id`),
  KEY `device_id` (`device_id`),
  CONSTRAINT `tb_notification_ibfk_1` FOREIGN KEY (`target_user_id`) REFERENCES `tb_user` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `tb_notification_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `tb_device` (`device_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_notification`
--

LOCK TABLES `tb_notification` WRITE;
/*!40000 ALTER TABLE `tb_notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_user`
--

DROP TABLE IF EXISTS `tb_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(50) NOT NULL,
  `role` enum('ADMIN','CLEANER') NOT NULL DEFAULT 'CLEANER',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_user`
--

LOCK TABLES `tb_user` WRITE;
/*!40000 ALTER TABLE `tb_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `tb_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-11 23:34:18
