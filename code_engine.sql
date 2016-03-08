# ************************************************************
# Sequel Pro SQL dump
# Version 4500
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.44-log)
# Database: codeengine
# Generation Time: 2016-03-08 16:02:11 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table artifact
# ------------------------------------------------------------

DROP TABLE IF EXISTS `artifact`;

CREATE TABLE `artifact` (
  `artifact_id` int(11) NOT NULL AUTO_INCREMENT,
  `artifact_type_id` int(11) NOT NULL,
  `build_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `artifact_message` longtext,
  `link_self` varchar(512) DEFAULT NULL,
  `link_edit` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`artifact_id`),
  UNIQUE KEY `artifact_id_uindex` (`artifact_id`),
  KEY `artifact_type_id_fk` (`artifact_type_id`),
  KEY `artifact_build_id_fk` (`build_id`),
  CONSTRAINT `artifact_build_id_fk` FOREIGN KEY (`build_id`) REFERENCES `build` (`build_id`),
  CONSTRAINT `artifact_type_id_fk` FOREIGN KEY (`artifact_type_id`) REFERENCES `artifact_type` (`artifact_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table artifact_location
# ------------------------------------------------------------

DROP TABLE IF EXISTS `artifact_location`;

CREATE TABLE `artifact_location` (
  `artifact_location_id` int(11) NOT NULL AUTO_INCREMENT,
  `artifact_id` int(11) NOT NULL,
  `container` varchar(255) NOT NULL,
  `file` varchar(255) NOT NULL,
  PRIMARY KEY (`artifact_location_id`),
  UNIQUE KEY `artifact_location_id_uindex` (`artifact_location_id`),
  KEY `artifact_location_artifact_id_fk` (`artifact_id`),
  CONSTRAINT `artifact_location_artifact_id_fk` FOREIGN KEY (`artifact_id`) REFERENCES `artifact` (`artifact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table artifact_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `artifact_type`;

CREATE TABLE `artifact_type` (
  `artifact_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `artifact_type` varchar(64) NOT NULL,
  `artifact_type_label` varchar(64) NOT NULL,
  PRIMARY KEY (`artifact_type_id`),
  UNIQUE KEY `artifact_type_id_uindex` (`artifact_type_id`),
  UNIQUE KEY `artifact_type_uindex` (`artifact_type`),
  UNIQUE KEY `artifact_type_label_uindex` (`artifact_type_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of artifact types.';

LOCK TABLES `artifact_type` WRITE;
/*!40000 ALTER TABLE `artifact_type` DISABLE KEYS */;

INSERT INTO `artifact_type` (`artifact_type_id`, `artifact_type`, `artifact_type_label`)
VALUES
	(1,'BUILD_LOG','Build log'),
	(2,'WORKSPACE','Workspace'),
	(3,'TEST_LOG','Test log'),
	(4,'DEPLOY_LOG','Deploy log');

/*!40000 ALTER TABLE `artifact_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table build
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build`;

CREATE TABLE `build` (
  `build_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `result_message` longtext,
  `result_type_id` int(11) NOT NULL,
  `build_trigger_id` int(11) NOT NULL,
  PRIMARY KEY (`build_id`),
  UNIQUE KEY `build_id_uindex` (`build_id`),
  KEY `build_project_id_fk` (`project_id`),
  KEY `build_result_type_id_fk` (`result_type_id`),
  KEY `build_build_trigger_build_trigger_id_fk` (`build_trigger_id`),
  CONSTRAINT `build_build_trigger_build_trigger_id_fk` FOREIGN KEY (`build_trigger_id`) REFERENCES `build_trigger` (`build_trigger_id`),
  CONSTRAINT `build_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `build_result_type_id_fk` FOREIGN KEY (`result_type_id`) REFERENCES `result_type` (`result_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table build_step
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_step`;

CREATE TABLE `build_step` (
  `build_step_id` int(11) NOT NULL AUTO_INCREMENT,
  `build_id` int(11) NOT NULL,
  `artifact_id` int(11) NOT NULL,
  `build_step_type_id` int(11) NOT NULL,
  `result_type_id` int(11) NOT NULL,
  `started` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `finished` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `build_step_message` longtext,
  PRIMARY KEY (`build_step_id`),
  UNIQUE KEY `build_step_id_uindex` (`build_step_id`),
  KEY `build_step_build_id_fk` (`build_id`),
  KEY `build_step_artifact_id_fk` (`artifact_id`),
  KEY `build_step_type_id_fk` (`build_step_type_id`),
  KEY `build_step_result_type_id_fk` (`result_type_id`),
  CONSTRAINT `build_step_artifact_id_fk` FOREIGN KEY (`artifact_id`) REFERENCES `artifact` (`artifact_id`),
  CONSTRAINT `build_step_build_id_fk` FOREIGN KEY (`build_id`) REFERENCES `build` (`build_id`),
  CONSTRAINT `build_step_result_type_id_fk` FOREIGN KEY (`result_type_id`) REFERENCES `result_type` (`result_type_id`),
  CONSTRAINT `build_step_type_id_fk` FOREIGN KEY (`build_step_type_id`) REFERENCES `build_step_type` (`build_step_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table build_step_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_step_type`;

CREATE TABLE `build_step_type` (
  `build_step_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `build_step_type` varchar(64) NOT NULL,
  `build_step_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`build_step_type_id`),
  UNIQUE KEY `build_step_type_id_uindex` (`build_step_type_id`),
  UNIQUE KEY `build_step_type_label_uindex` (`build_step_type_label`),
  UNIQUE KEY `build_step_type_uindex` (`build_step_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of build steps.';

LOCK TABLES `build_step_type` WRITE;
/*!40000 ALTER TABLE `build_step_type` DISABLE KEYS */;

INSERT INTO `build_step_type` (`build_step_type_id`, `build_step_type`, `build_step_type_label`)
VALUES
	(1,'BUILDING','Building'),
	(2,'TESTING','Testing'),
	(3,'DEPLOYING','Deploying');

/*!40000 ALTER TABLE `build_step_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table build_trigger
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_trigger`;

CREATE TABLE `build_trigger` (
  `build_trigger_id` int(11) NOT NULL AUTO_INCREMENT,
  `build_trigger_type_id` int(11) NOT NULL,
  `trigger_message` longtext,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `trigger_author` varchar(255) NOT NULL,
  `trigger_author_avatar_url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`build_trigger_id`),
  UNIQUE KEY `build_trigger_id_uindex` (`build_trigger_id`),
  KEY `build_trigger_type_id_fk` (`build_trigger_type_id`),
  CONSTRAINT `build_trigger_type_id_fk` FOREIGN KEY (`build_trigger_type_id`) REFERENCES `build_trigger_type` (`build_trigger_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a build trigger event.';



# Dump of table build_trigger_manual_git
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_trigger_manual_git`;

CREATE TABLE `build_trigger_manual_git` (
  `build_trigger_id` int(11) NOT NULL,
  `commit_sha` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`build_trigger_id`),
  UNIQUE KEY `build_trigger_id_uindex` (`build_trigger_id`),
  CONSTRAINT `build_trigger_manual_git_build_id_fk` FOREIGN KEY (`build_trigger_id`) REFERENCES `build_trigger` (`build_trigger_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a manual trigger of a Git-repo build.';



# Dump of table build_trigger_manual_svn
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_trigger_manual_svn`;

CREATE TABLE `build_trigger_manual_svn` (
  `build_trigger_id` int(11) NOT NULL,
  `branch` int(11) NOT NULL,
  PRIMARY KEY (`build_trigger_id`),
  UNIQUE KEY `build_trigger_manual_svn_build_trigger_id_uindex` (`build_trigger_id`),
  CONSTRAINT `build_trigger_manual_svn_build_trigger_id_fk` FOREIGN KEY (`build_trigger_id`) REFERENCES `build_trigger` (`build_trigger_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a manual trigger of a build of a SVN repo.';



# Dump of table build_trigger_pull_request
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_trigger_pull_request`;

CREATE TABLE `build_trigger_pull_request` (
  `build_trigger_id` int(11) NOT NULL AUTO_INCREMENT,
  `commit_sha` varchar(255) NOT NULL,
  `commit_url` varchar(255) DEFAULT NULL,
  `compare_url` varchar(255) DEFAULT NULL,
  `pull_request_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`build_trigger_id`),
  UNIQUE KEY `build_trigger_id_uindex` (`build_trigger_id`),
  CONSTRAINT `build_trigger_pull_request_id_fk` FOREIGN KEY (`build_trigger_id`) REFERENCES `build_trigger` (`build_trigger_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a PULL_REQUEST build trigger event.';



# Dump of table build_trigger_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `build_trigger_type`;

CREATE TABLE `build_trigger_type` (
  `build_trigger_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `build_trigger_type` varchar(255) NOT NULL,
  `build_trigger_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`build_trigger_type_id`),
  UNIQUE KEY `build_trigger_type_id_uindex` (`build_trigger_type_id`),
  UNIQUE KEY `build_trigger_type_uindex` (`build_trigger_type`),
  UNIQUE KEY `build_trigger_type_label_uindex` (`build_trigger_type_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of build trigger types, e.g. "MANUAL" or "PULL_REQUEST"';

LOCK TABLES `build_trigger_type` WRITE;
/*!40000 ALTER TABLE `build_trigger_type` DISABLE KEYS */;

INSERT INTO `build_trigger_type` (`build_trigger_type_id`, `build_trigger_type`, `build_trigger_type_label`)
VALUES
	(1,'PULL_REQUEST','Pull Request'),
	(2,'MANUAL_GIT','Manual trigger (Git)'),
	(3,'MANUAL_SVN','Manual trigger (SVN)');

/*!40000 ALTER TABLE `build_trigger_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table credential
# ------------------------------------------------------------

DROP TABLE IF EXISTS `credential`;

CREATE TABLE `credential` (
  `credential_id` int(11) NOT NULL AUTO_INCREMENT,
  `credential_type_id` int(11) NOT NULL,
  `credential_key` varchar(512) DEFAULT NULL,
  `credential_value` longtext,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `label` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`credential_id`),
  UNIQUE KEY `credential_id_uindex` (`credential_id`),
  KEY `credential_credential_type_credential_type_id_fk` (`credential_type_id`),
  CONSTRAINT `credential_credential_type_credential_type_id_fk` FOREIGN KEY (`credential_type_id`) REFERENCES `credential_type` (`credential_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models an access credential instance.';

LOCK TABLES `credential` WRITE;
/*!40000 ALTER TABLE `credential` DISABLE KEYS */;

INSERT INTO `credential` (`credential_id`, `credential_type_id`, `credential_key`, `credential_value`, `created`, `label`)
VALUES
	(1,1,'myusername','mypassword','2016-03-08 05:47:56','Neil\'s CF username/password'),
	(2,3,'AKIAIOSFODNN7EXAMPLE','wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY','2016-03-08 05:49:20','Neil\'s AWS access key pair'),
	(3,4,'github_rsa','ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDu3dTyj/jAXkvAwyNBwlc9tX/kZZ9w+oAfzggB7ZzER3AKC7NVMgwh1LRJ5QvQVQeQNwcVNjVidlrHd8BCcGto6+UowJWTmEqb23Ky+OxXiqSM7qCxc0Fs8cOBcN7IbZ6eNfqKrUA5JKR1vRL3KZH6ustedD14XDT2/mRMvOq7gcyQvQxaZitBEKILvasdfasdfnkWORUE6j8UzIvNZrRyUhZ6ti+do+lFwapYbZ4RpJsDGBGJEuQ13XuKKx0p1Zw1vLcLqN6wv4+1Gpi3/CABTypuFMOVfMCgkLlm4ujel0QCsa2NsMutNjBNNsAD7oCRzNDJF5EaBwjcLn9hPcYVYh bubba@github.com\n','2016-03-08 05:51:09','Neil\'s GitHub key'),
	(4,2,NULL,'6e0a8cb3e4dc64f72b2a0f0a0191de4cc242dca6','2016-03-08 05:53:32','Neil\'s OAuth2 token');

/*!40000 ALTER TABLE `credential` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table credential_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `credential_type`;

CREATE TABLE `credential_type` (
  `credential_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `credential_type` varchar(255) NOT NULL,
  `credential_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`credential_type_id`),
  UNIQUE KEY `credential_type_id_uindex` (`credential_type_id`),
  UNIQUE KEY `credential_type_uindex` (`credential_type`),
  UNIQUE KEY `credential_type_label_uindex` (`credential_type_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of credential types, e.g. "OAUTH2", "USERNAME_PASSWORD", etc.';

LOCK TABLES `credential_type` WRITE;
/*!40000 ALTER TABLE `credential_type` DISABLE KEYS */;

INSERT INTO `credential_type` (`credential_type_id`, `credential_type`, `credential_type_label`)
VALUES
	(1,'USERNAME_PASSWORD','Username & Password'),
	(2,'OAUTH2_TOKEN','OAuth2 Token'),
	(3,'AWS_ACCESS_KEY','AWS Access Key'),
	(4,'PKI','Public/Private Key');

/*!40000 ALTER TABLE `credential_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table deployment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `deployment`;

CREATE TABLE `deployment` (
  `deployment_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `build_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `browse_url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`deployment_id`),
  UNIQUE KEY `deployment_id_uindex` (`deployment_id`),
  KEY `deployment_project_id_fk` (`project_id`),
  KEY `deployment_build_id_fk` (`build_id`),
  CONSTRAINT `deployment_build_id_fk` FOREIGN KEY (`build_id`) REFERENCES `build` (`build_id`),
  CONSTRAINT `deployment_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table environment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `environment`;

CREATE TABLE `environment` (
  `environment_id` int(11) NOT NULL AUTO_INCREMENT,
  `environment_type_id` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `description` longtext,
  `url` varchar(512) NOT NULL,
  `owner_user_id` int(11) NOT NULL,
  `environment_credential_id` int(11) NOT NULL,
  PRIMARY KEY (`environment_id`),
  UNIQUE KEY `environment_environment_id_uindex` (`environment_id`),
  UNIQUE KEY `environment_label_uindex` (`label`),
  KEY `environment_type_id_fk` (`environment_type_id`),
  KEY `environment_owner_user_id_fk` (`owner_user_id`),
  KEY `environment_credential_id_fk` (`environment_credential_id`),
  CONSTRAINT `environment_credential_id_fk` FOREIGN KEY (`environment_credential_id`) REFERENCES `credential` (`credential_id`),
  CONSTRAINT `environment_owner_user_id_fk` FOREIGN KEY (`owner_user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `environment_type_id_fk` FOREIGN KEY (`environment_type_id`) REFERENCES `environment_type` (`environment_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a deployment target/environment instance, such as a CloudFoundry instance or an AWS instance.';

LOCK TABLES `environment` WRITE;
/*!40000 ALTER TABLE `environment` DISABLE KEYS */;

INSERT INTO `environment` (`environment_id`, `environment_type_id`, `label`, `description`, `url`, `owner_user_id`, `environment_credential_id`)
VALUES
	(1,1,'Neil\'s CloudFoundry env','wubble wubble','https://cloudfoundry1.example.com',1,1),
	(4,2,'Adam\'s AWS env','Harold the hedgehog','https://aws1.example.com',1,1);

/*!40000 ALTER TABLE `environment` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table environment_aws
# ------------------------------------------------------------

DROP TABLE IF EXISTS `environment_aws`;

CREATE TABLE `environment_aws` (
  `environment_id` int(11) NOT NULL,
  `aws_environment_name` varchar(255) NOT NULL,
  PRIMARY KEY (`environment_id`),
  UNIQUE KEY `environment_aws_environment_id_uindex` (`environment_id`),
  CONSTRAINT `aws_environment_id_fk` FOREIGN KEY (`environment_id`) REFERENCES `environment` (`environment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models an AWS deployment target/environment instance.';



# Dump of table environment_cloudfoundry
# ------------------------------------------------------------

DROP TABLE IF EXISTS `environment_cloudfoundry`;

CREATE TABLE `environment_cloudfoundry` (
  `environment_id` int(11) NOT NULL,
  `organization` varchar(255) NOT NULL,
  `space` varchar(255) NOT NULL,
  PRIMARY KEY (`environment_id`),
  UNIQUE KEY `environment_cloudfoundry_id_uindex` (`environment_id`),
  CONSTRAINT `cloudfoundry_environment_id_fk` FOREIGN KEY (`environment_id`) REFERENCES `environment` (`environment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a CloudFoundry deployment target/environment instance.';



# Dump of table environment_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `environment_type`;

CREATE TABLE `environment_type` (
  `environment_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `environment_type` varchar(64) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`environment_type_id`),
  UNIQUE KEY `environment_type_id_uindex` (`environment_type_id`),
  UNIQUE KEY `environment_type_uindex` (`environment_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `environment_type` WRITE;
/*!40000 ALTER TABLE `environment_type` DISABLE KEYS */;

INSERT INTO `environment_type` (`environment_type_id`, `environment_type`, `label`)
VALUES
	(1,'CLOUDFOUNDRY','CloudFoundry'),
	(2,'AWS','AWS'),
	(3,'AZURE','Microsoft Azure');

/*!40000 ALTER TABLE `environment_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table notification_target
# ------------------------------------------------------------

DROP TABLE IF EXISTS `notification_target`;

CREATE TABLE `notification_target` (
  `notification_target_id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_type_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `url` varchar(255) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `target_credential_id` int(11) NOT NULL,
  PRIMARY KEY (`notification_target_id`),
  UNIQUE KEY `notification_target_id_uindex` (`notification_target_id`),
  KEY `notification_target_type_id_fk` (`notification_type_id`),
  KEY `notification_target_project_id_fk` (`project_id`),
  KEY `notification_target_credential_id_fk` (`target_credential_id`),
  CONSTRAINT `notification_target_credential_id_fk` FOREIGN KEY (`target_credential_id`) REFERENCES `credential` (`credential_id`),
  CONSTRAINT `notification_target_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `notification_target_type_id_fk` FOREIGN KEY (`notification_type_id`) REFERENCES `notification_type` (`notification_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a notification target instance, e.g. a HipChat room, or GitHub pull request.';



# Dump of table notification_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `notification_type`;

CREATE TABLE `notification_type` (
  `notification_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `notification_type` varchar(64) NOT NULL,
  `notification_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`notification_type_id`),
  UNIQUE KEY `notification_type_id_uindex` (`notification_type_id`),
  UNIQUE KEY `notification_type_uindex` (`notification_type`),
  UNIQUE KEY `notification_type_label_uindex` (`notification_type_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of notification target types, e.g. "SLACK", "HIPCHAT", "GITHUB_PULL_REQUEST", etc.';

LOCK TABLES `notification_type` WRITE;
/*!40000 ALTER TABLE `notification_type` DISABLE KEYS */;

INSERT INTO `notification_type` (`notification_type_id`, `notification_type`, `notification_type_label`)
VALUES
	(1,'SLACK','Slack'),
	(2,'HIPCHAT','HipChat'),
	(3,'FLOWDOCK','Flowdock'),
	(4,'HTTP_POST','HTTP Post'),
	(5,'GITHUB_PULL_REQUEST','GitHub Pull Request');

/*!40000 ALTER TABLE `notification_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table post_deploy_action
# ------------------------------------------------------------

DROP TABLE IF EXISTS `post_deploy_action`;

CREATE TABLE `post_deploy_action` (
  `post_deploy_action_id` int(11) NOT NULL AUTO_INCREMENT,
  `post_deploy_action_type_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `metadata` varchar(255) DEFAULT NULL,
  `post_deploy_action_message` longtext,
  PRIMARY KEY (`post_deploy_action_id`),
  UNIQUE KEY `post_deploy_action_id_uindex` (`post_deploy_action_id`),
  KEY `post_deploy_action_type_id_fk` (`post_deploy_action_type_id`),
  KEY `post_deploy_action_project_id_fk` (`project_id`),
  CONSTRAINT `post_deploy_action_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `post_deploy_action_type_id_fk` FOREIGN KEY (`post_deploy_action_type_id`) REFERENCES `post_deploy_action_type` (`post_deploy_action_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='List of post-deploy-action instances.';



# Dump of table post_deploy_action_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `post_deploy_action_type`;

CREATE TABLE `post_deploy_action_type` (
  `post_deploy_action_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `post_deploy_action_type` varchar(64) NOT NULL,
  `post_deploy_action_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`post_deploy_action_type_id`),
  UNIQUE KEY `post_deploy_action_type_id_uindex` (`post_deploy_action_type_id`),
  UNIQUE KEY `post_deploy_action_type_label_uindex` (`post_deploy_action_type_label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of post-deploy-actions, e.g. "STORMRUNNER", "FORTIFY", etc.';



# Dump of table project
# ------------------------------------------------------------

DROP TABLE IF EXISTS `project`;

CREATE TABLE `project` (
  `project_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_name` varchar(255) NOT NULL,
  `description` longtext,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `repo_id` int(11) NOT NULL,
  `runtime_type_id` int(11) NOT NULL,
  `repo_credential_id` int(11) NOT NULL,
  PRIMARY KEY (`project_id`),
  UNIQUE KEY `project_id_uindex` (`project_id`),
  KEY `project_repo_id_fk` (`repo_id`),
  KEY `project_runtime_type_id_fk` (`runtime_type_id`),
  KEY `project_repo_credential_id_fk` (`repo_credential_id`),
  CONSTRAINT `project_repo_credential_id_fk` FOREIGN KEY (`repo_credential_id`) REFERENCES `credential` (`credential_id`),
  CONSTRAINT `project_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repo` (`repo_id`),
  CONSTRAINT `project_runtime_type_id_fk` FOREIGN KEY (`runtime_type_id`) REFERENCES `runtime_type` (`runtime_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a CodeEngine project.';

LOCK TABLES `project` WRITE;
/*!40000 ALTER TABLE `project` DISABLE KEYS */;

INSERT INTO `project` (`project_id`, `project_name`, `description`, `created`, `repo_id`, `runtime_type_id`, `repo_credential_id`)
VALUES
	(1,'neil-schema-2','It\'s a new project!','2016-03-08 06:24:26',1,5,4);

/*!40000 ALTER TABLE `project` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table project_environment
# ------------------------------------------------------------

DROP TABLE IF EXISTS `project_environment`;

CREATE TABLE `project_environment` (
  `project_id` int(11) NOT NULL,
  `environment_id` int(11) NOT NULL,
  PRIMARY KEY (`project_id`,`environment_id`),
  KEY `environment_id_fk` (`environment_id`),
  CONSTRAINT `environment_id_fk` FOREIGN KEY (`environment_id`) REFERENCES `environment` (`environment_id`),
  CONSTRAINT `project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Map of projects to deployment environments/targets.';

LOCK TABLES `project_environment` WRITE;
/*!40000 ALTER TABLE `project_environment` DISABLE KEYS */;

INSERT INTO `project_environment` (`project_id`, `environment_id`)
VALUES
	(1,4);

/*!40000 ALTER TABLE `project_environment` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table project_member
# ------------------------------------------------------------

DROP TABLE IF EXISTS `project_member`;

CREATE TABLE `project_member` (
  `project_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_owner` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`project_id`,`user_id`),
  KEY `project_member_user_id_fk` (`user_id`),
  CONSTRAINT `project_member_project_id_fk` FOREIGN KEY (`project_id`) REFERENCES `project` (`project_id`),
  CONSTRAINT `project_member_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Map of user project membership.';

LOCK TABLES `project_member` WRITE;
/*!40000 ALTER TABLE `project_member` DISABLE KEYS */;

INSERT INTO `project_member` (`project_id`, `user_id`, `is_owner`)
VALUES
	(1,1,1),
	(1,2,0),
	(1,3,1);

/*!40000 ALTER TABLE `project_member` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table repo
# ------------------------------------------------------------

DROP TABLE IF EXISTS `repo`;

CREATE TABLE `repo` (
  `repo_id` int(11) NOT NULL AUTO_INCREMENT,
  `repo_name` varchar(255) NOT NULL,
  `vcs_id` int(11) NOT NULL,
  PRIMARY KEY (`repo_id`),
  UNIQUE KEY `repo_id_uindex` (`repo_id`),
  KEY `repo_vcs_id_fk` (`vcs_id`),
  CONSTRAINT `repo_vcs_id_fk` FOREIGN KEY (`vcs_id`) REFERENCES `vcs` (`vcs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a generic VCS repo instance. This table is used in conjunction with a specific repo VCS type table, e.g. "repo_github" or "repo_svn".';

LOCK TABLES `repo` WRITE;
/*!40000 ALTER TABLE `repo` DISABLE KEYS */;

INSERT INTO `repo` (`repo_id`, `repo_name`, `vcs_id`)
VALUES
	(1,'neilotoole/schema2',1);

/*!40000 ALTER TABLE `repo` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table repo_github
# ------------------------------------------------------------

DROP TABLE IF EXISTS `repo_github`;

CREATE TABLE `repo_github` (
  `repo_id` int(11) NOT NULL,
  `github_repo_id` varchar(255) NOT NULL,
  `repo_user` varchar(255) NOT NULL,
  `branch` varchar(255) DEFAULT NULL,
  `http_url` varchar(255) DEFAULT NULL,
  `clone_url` varchar(255) DEFAULT NULL,
  `ssh_url` varchar(255) DEFAULT NULL,
  `webhook_id` varchar(255) DEFAULT NULL,
  `webhook_url` varchar(255) DEFAULT NULL,
  `latest_commit_sha` varchar(255) DEFAULT NULL,
  `webhook_credential_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`repo_id`),
  UNIQUE KEY `repo_github_repo_id_uindex` (`repo_id`),
  KEY `repo_github_webhook_credential_id_fk` (`webhook_credential_id`),
  CONSTRAINT `repo_github_webhook_credential_id_fk` FOREIGN KEY (`webhook_credential_id`) REFERENCES `credential` (`credential_id`),
  CONSTRAINT `repo_github_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repo` (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a reference to a GitHub repo. This table is used in conjunction with the generic "repo" table.';

LOCK TABLES `repo_github` WRITE;
/*!40000 ALTER TABLE `repo_github` DISABLE KEYS */;

INSERT INTO `repo_github` (`repo_id`, `github_repo_id`, `repo_user`, `branch`, `http_url`, `clone_url`, `ssh_url`, `webhook_id`, `webhook_url`, `latest_commit_sha`, `webhook_credential_id`)
VALUES
	(1,'234234234','neilotoole','master','https://github.com/neilotoole/schema2','https://github.com/neilotoole/schema2.git',NULL,'23234234','https://something','234234234',4);

/*!40000 ALTER TABLE `repo_github` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table repo_svn
# ------------------------------------------------------------

DROP TABLE IF EXISTS `repo_svn`;

CREATE TABLE `repo_svn` (
  `repo_id` int(11) NOT NULL,
  `branch` varchar(255) DEFAULT NULL,
  `http_url` varchar(512) DEFAULT NULL,
  UNIQUE KEY `repo_svn_repo_id_uindex` (`repo_id`),
  CONSTRAINT `repo_svn_repo_id_fk` FOREIGN KEY (`repo_id`) REFERENCES `repo` (`repo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Models a reference to a Subversion repo. This table is used in conjunction with the generic "repo" table.';



# Dump of table result_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `result_type`;

CREATE TABLE `result_type` (
  `result_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `result_type` varchar(16) NOT NULL,
  `result_type_label` varchar(16) NOT NULL,
  PRIMARY KEY (`result_type_id`),
  UNIQUE KEY `result_type_id_uindex` (`result_type_id`),
  UNIQUE KEY `result_type_label_uindex` (`result_type_label`),
  UNIQUE KEY `result_type_uindex` (`result_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of results: PENDING, SUCCESS, or FAILURE.';

LOCK TABLES `result_type` WRITE;
/*!40000 ALTER TABLE `result_type` DISABLE KEYS */;

INSERT INTO `result_type` (`result_type_id`, `result_type`, `result_type_label`)
VALUES
	(1,'PENDING','Pending'),
	(2,'SUCCESS','Success'),
	(3,'FAILURE','Failure');

/*!40000 ALTER TABLE `result_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table runtime_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `runtime_type`;

CREATE TABLE `runtime_type` (
  `runtime_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `runtime_type` varchar(64) NOT NULL,
  `runtime_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`runtime_type_id`),
  UNIQUE KEY `runtime_type_id_uindex` (`runtime_type_id`),
  UNIQUE KEY `runtime_type_label_uindex` (`runtime_type_label`),
  UNIQUE KEY `runtime_type_uindex` (`runtime_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `runtime_type` WRITE;
/*!40000 ALTER TABLE `runtime_type` DISABLE KEYS */;

INSERT INTO `runtime_type` (`runtime_type_id`, `runtime_type`, `runtime_type_label`)
VALUES
	(1,'JAVA','Java'),
	(2,'PHP','PHP'),
	(3,'DOTNET','.NET'),
	(4,'RUBY','Ruby'),
	(5,'GO','Go'),
	(6,'NODEJS','nodejs');

/*!40000 ALTER TABLE `runtime_type` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(128) DEFAULT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_id_uindex` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;

INSERT INTO `user` (`user_id`, `email`, `full_name`, `created`)
VALUES
	(1,'neilotoole@apache.org','Neil O\'Toole','2016-03-04 12:38:35'),
	(2,'phani.raj@hpe.com','Phani Raj','2016-03-04 12:38:48'),
	(3,'adam.sheldon@hpe.com','Adam Sheldon','2016-03-04 12:39:00');

/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table user_vcs_credential
# ------------------------------------------------------------

DROP TABLE IF EXISTS `user_vcs_credential`;

CREATE TABLE `user_vcs_credential` (
  `user_id` int(11) NOT NULL,
  `vcs_id` int(11) NOT NULL,
  `user_vcs_credential_id` int(11) NOT NULL,
  KEY `user_vcs_credential_user_id_fk` (`user_id`),
  KEY `user_vcs_credential_vcs_id_fk` (`vcs_id`),
  KEY `user_vcs_credential_credential_id_fk` (`user_vcs_credential_id`),
  CONSTRAINT `user_vcs_credential_credential_id_fk` FOREIGN KEY (`user_vcs_credential_id`) REFERENCES `credential` (`credential_id`),
  CONSTRAINT `user_vcs_credential_user_id_fk` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  CONSTRAINT `user_vcs_credential_vcs_id_fk` FOREIGN KEY (`vcs_id`) REFERENCES `vcs` (`vcs_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mapping of user credentials for a VCS instance.';



# Dump of table variable
# ------------------------------------------------------------

DROP TABLE IF EXISTS `variable`;

CREATE TABLE `variable` (
  `name` varchar(128) NOT NULL,
  `value` longblob,
  `description` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`name`),
  UNIQUE KEY `variable_name_uindex` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Holds miscellaneous key/value pairs, e.g. for version info, system metadata, etc.';

LOCK TABLES `variable` WRITE;
/*!40000 ALTER TABLE `variable` DISABLE KEYS */;

INSERT INTO `variable` (`name`, `value`, `description`)
VALUES
	('api_version',X'32','REST API version.'),
	('db_schema_version',X'302E302E33','Database schema version.'),
	('swagger_url',X'2F6170692F76322F737761676765722E796D6C','URL path of the API swagger document.');

/*!40000 ALTER TABLE `variable` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table vcs
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vcs`;

CREATE TABLE `vcs` (
  `vcs_id` int(11) NOT NULL AUTO_INCREMENT,
  `browse_url` varchar(512) DEFAULT NULL,
  `api_url` varchar(512) DEFAULT NULL,
  `label` varchar(255) NOT NULL,
  `vcs_type_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`vcs_id`),
  UNIQUE KEY `vcs_vcs_id_uindex` (`vcs_id`),
  UNIQUE KEY `vcs_label_uindex` (`label`),
  KEY `vcs_type_id_fk` (`vcs_type_id`),
  CONSTRAINT `vcs_type_id_fk` FOREIGN KEY (`vcs_type_id`) REFERENCES `vcs_type` (`vcs_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='List of VCS instances. For example, "GitHub.com", "Bitbucket.org", "HPE IT GitHub Enterprise", "HPE Software GitHub Enterprise", etc.';

LOCK TABLES `vcs` WRITE;
/*!40000 ALTER TABLE `vcs` DISABLE KEYS */;

INSERT INTO `vcs` (`vcs_id`, `browse_url`, `api_url`, `label`, `vcs_type_id`)
VALUES
	(1,'https://github.com','https://api.github.com','GitHub',1),
	(2,'https://github-enterprise.us-west.hpe.com','https://api.github-enterprise.us-west.hpe.com','HPE GitHub Enterprise',2);

/*!40000 ALTER TABLE `vcs` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table vcs_type
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vcs_type`;

CREATE TABLE `vcs_type` (
  `vcs_type_id` int(11) NOT NULL AUTO_INCREMENT,
  `vcs_type` varchar(64) NOT NULL,
  `vcs_type_label` varchar(255) NOT NULL,
  PRIMARY KEY (`vcs_type_id`),
  UNIQUE KEY `vcs_type_id_uindex` (`vcs_type_id`),
  UNIQUE KEY `vcs_type_label_uindex` (`vcs_type_label`),
  UNIQUE KEY `vcs_type_uindex` (`vcs_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Enumeration of Version Control System types. There is a canonical name, e.g. "github", "github_enterprise", "svn", and a display label, e.g. "GitHub", "GitHub Enterprise", "Subversion".';

LOCK TABLES `vcs_type` WRITE;
/*!40000 ALTER TABLE `vcs_type` DISABLE KEYS */;

INSERT INTO `vcs_type` (`vcs_type_id`, `vcs_type`, `vcs_type_label`)
VALUES
	(1,'GITHUB','GitHub.com'),
	(2,'GITHUB_ENTERPRISE','GitHub Enterprise'),
	(3,'BITBUCKET','Bitbucket'),
	(4,'SVN','Subversion');

/*!40000 ALTER TABLE `vcs_type` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
