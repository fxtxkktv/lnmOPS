-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: lnmopsdb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `apimgr`
--

DROP TABLE IF EXISTS `apimgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `apimgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `api_name` varchar(255) NOT NULL,
  `api_desc` varchar(255) DEFAULT NULL,
  `api_version` varchar(255) NOT NULL,
  `api_options` varchar(255) DEFAULT NULL,
  `api_safe` varchar(255) NOT NULL,
  `api_script_path` varchar(255) DEFAULT NULL,
  `api_type` int(11) NOT NULL,
  `api_host` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `apscheduler_jobs`
--

DROP TABLE IF EXISTS `apscheduler_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `apscheduler_jobs` (
  `id` varchar(191) NOT NULL,
  `next_run_time` double DEFAULT NULL,
  `job_state` blob NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_apscheduler_jobs_next_run_time` (`next_run_time`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `apscheduler_logs`
--

DROP TABLE IF EXISTS `apscheduler_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `apscheduler_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `jobid` varchar(255) DEFAULT NULL,
  `jobtime` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `apimode` varchar(255) DEFAULT NULL,
  `hostlist` varchar(255) DEFAULT NULL,
  `runFuncAPI` varchar(255) DEFAULT NULL,
  `jid` varchar(255) NOT NULL,
  `full_ret` longtext NOT NULL,
  `run_status` int(11) DEFAULT '8318',
  PRIMARY KEY (`id`),
  KEY `index_jid` (`jobid`),
  KEY `index_id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2937608 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `faultrecords`
--

DROP TABLE IF EXISTS `faultrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faultrecords` (
  `ftrank` varchar(255) NOT NULL DEFAULT '',
  `fttype` varchar(255) DEFAULT NULL,
  `ftlevel` varchar(255) DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `stopdate` date DEFAULT NULL,
  `ftobject` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `fname` varchar(255) NOT NULL,
  `ftfile` longblob NOT NULL,
  PRIMARY KEY (`ftrank`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hardwaremgr`
--

DROP TABLE IF EXISTS `hardwaremgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hardwaremgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hdnumber` varchar(255) DEFAULT NULL,
  `hdname` varchar(255) DEFAULT NULL,
  `hdbrand` varchar(255) DEFAULT NULL,
  `roomid` int(11) DEFAULT NULL,
  `hddate` date DEFAULT NULL,
  `supplier` varchar(255) DEFAULT NULL,
  `comment` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hostmgr`
--

DROP TABLE IF EXISTS `hostmgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hostmgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hostname` varchar(255) DEFAULT NULL,
  `hostaddr` varchar(255) DEFAULT NULL,
  `systype` varchar(255) DEFAULT NULL,
  `selecthd` varchar(255) DEFAULT NULL,
  `hostdate` date DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `logrecord`
--

DROP TABLE IF EXISTS `logrecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logrecord` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `objtime` datetime DEFAULT NULL,
  `objname` varchar(255) DEFAULT NULL,
  `objact` varchar(255) DEFAULT NULL,
  `objtext` varchar(255) DEFAULT NULL,
  `objhost` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1030 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `minioninfo`
--

DROP TABLE IF EXISTS `minioninfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `minioninfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nodeid` varchar(255) DEFAULT NULL,
  `hostname` varchar(255) NOT NULL,
  `IP` varchar(255) DEFAULT NULL,
  `Mem` int(100) DEFAULT NULL,
  `CPU` varchar(255) DEFAULT NULL,
  `CPUS` int(100) DEFAULT NULL,
  `OS` varchar(255) DEFAULT NULL,
  `virtual` varchar(255) DEFAULT NULL,
  `status` int(2) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `nodeid` (`nodeid`)
) ENGINE=MyISAM AUTO_INCREMENT=46 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nodegrpmgr`
--

DROP TABLE IF EXISTS `nodegrpmgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodegrpmgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grpname` varchar(255) DEFAULT NULL,
  `grpdesc` varchar(255) DEFAULT NULL,
  `grpnodes` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roommgr`
--

DROP TABLE IF EXISTS `roommgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roommgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roomname` varchar(255) DEFAULT NULL,
  `roomaddr` varchar(255) DEFAULT NULL,
  `roomsize` int(255) DEFAULT '0',
  `startdate` date DEFAULT NULL,
  `comment` longtext,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `softwaremgr`
--

DROP TABLE IF EXISTS `softwaremgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `softwaremgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `softnumber` varchar(30) DEFAULT NULL,
  `softname` varchar(255) DEFAULT NULL,
  `softversion` varchar(255) DEFAULT NULL,
  `softdate` date DEFAULT NULL,
  `supplier` varchar(255) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `softfile` longblob NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=120 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sshmgr`
--

DROP TABLE IF EXISTS `sshmgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sshmgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hostdesc` varchar(255) DEFAULT NULL,
  `hostaddr` varchar(255) DEFAULT NULL,
  `sshport` int(11) DEFAULT '22',
  `sshuser` varchar(255) DEFAULT NULL,
  `sshpass` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `hostaddr` (`hostaddr`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysattr`
--

DROP TABLE IF EXISTS `sysattr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysattr` (
  `attr` varchar(64) NOT NULL DEFAULT '',
  `value` longtext,
  `status` int(2) DEFAULT '1',
  `servattr` varchar(24) DEFAULT 'sys' COMMENT '指定功能属性,默认系统属性',
  PRIMARY KEY (`attr`),
  UNIQUE KEY `attr` (`attr`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysinfo`
--

DROP TABLE IF EXISTS `sysinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysinfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `info` text,
  `tim` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=394276 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taskconf`
--

DROP TABLE IF EXISTS `taskconf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taskconf` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `taskname` varchar(255) DEFAULT NULL,
  `taskdesc` varchar(255) DEFAULT NULL,
  `timedesc` varchar(255) DEFAULT NULL,
  `api_type` int(11) DEFAULT NULL,
  `api_obj` varchar(255) DEFAULT NULL,
  `runobject` varchar(255) DEFAULT NULL,
  `status` int(2) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `taskgrpmgr`
--

DROP TABLE IF EXISTS `taskgrpmgr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taskgrpmgr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grpname` varchar(255) DEFAULT NULL,
  `grpdesc` varchar(255) DEFAULT NULL,
  `grptasks` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=33 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL DEFAULT '0',
  `passwd` varchar(50) NOT NULL DEFAULT '0',
  `policy` int(11) DEFAULT '0',
  `access` tinyint(4) DEFAULT '0',
  `adddate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `comment` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=51 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-10-12  9:23:37
-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: lnmopsdb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `user`
--
-- WHERE:  username='admin'

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin','p9PvYWRiJQA0Fw5fB1TjKw==',100033,1,'2018-09-26 01:00:06',1,'admin');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-10-12  9:23:37
-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: lnmopsdb
-- ------------------------------------------------------
-- Server version	5.1.73

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `sysattr`
--
-- WHERE:  servattr!='netiface'

LOCK TABLES `sysattr` WRITE;
/*!40000 ALTER TABLE `sysattr` DISABLE KEYS */;
INSERT INTO `sysattr` VALUES ('resData','{\"ResState\": \"False\", \"visitDay\": \"1\", \"ResInv\": \"90\", \"ResSaveDay\": \"30\"}',1,'sys'),('saltconf','{\"txport\": \"5506\", \"saltListen\": \"0.0.0.0\", \"autoAccept\": \"true\", \"smsport\": \"5505\", \"timeout\": \"3\"}',1,'saltstack');
/*!40000 ALTER TABLE `sysattr` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-10-12  9:23:37
