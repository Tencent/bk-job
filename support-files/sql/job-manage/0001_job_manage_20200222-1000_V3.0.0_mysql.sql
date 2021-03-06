SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS job_manage DEFAULT CHARACTER SET utf8mb4;
USE job_manage;

CREATE TABLE IF NOT EXISTS `script`
(
    `id`               VARCHAR(32)                    NOT NULL,
    `row_create_time`  DATETIME                       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  DATETIME                       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `name`             VARCHAR(512)                   NOT NULL,
    `app_id`           BIGINT(20) UNSIGNED            NOT NULL,
    `type`             TINYINT(4) UNSIGNED            NOT NULL DEFAULT '1',
    `is_public`        TINYINT(1) UNSIGNED          DEFAULT '0',
    `creator`          VARCHAR(128)        NOT NULL,
    `create_time`      BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
    `last_modify_user` VARCHAR(128)                 DEFAULT NULL,
    `last_modify_time` BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
    `category`         TINYINT(1) UNSIGNED          DEFAULT '1',
    `description`      VARCHAR(1024),
    `is_deleted`       TINYINT(1) UNSIGNED          DEFAULT '0',
    `tags`             VARCHAR(512)                 DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY (`app_id`),
    KEY (`app_id`, `name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `script_version`
(
    `id`               BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `row_create_time`   DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`   DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `script_id`        VARCHAR(32)                  DEFAULT NULL,
    `content`          LONGTEXT /*!99104 COMPRESSED */           NOT NULL,
    `creator`          VARCHAR(128)        NOT NULL,
    `create_time`      BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
    `last_modify_user` VARCHAR(128)                 DEFAULT NULL,
    `last_modify_time` BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
    `version`          VARCHAR(100)                 DEFAULT NULL,
    `is_deleted`       TINYINT(1) UNSIGNED          DEFAULT '0',
    `status`           TINYINT(1) UNSIGNED          DEFAULT '0',
    `version_desc`     VARCHAR(1024),
    PRIMARY KEY (`id`),
    KEY (`script_id`)
) ENGINE = InnoDB
  AUTO_INCREMENT=1000000
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS  `tag`
(
    `id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `app_id`           bigint(20) unsigned NOT NULL,
    `name`             varchar(512)        NOT NULL,
    `creator`          varchar(128)        NOT NULL,
    `last_modify_user` varchar(128)        NOT NULL,
    `is_deleted`       tinyint(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_app_id_name` (`app_id`, `name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_favorite_plan`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `app_id`          bigint(20) unsigned NOT NULL,
    `username`        varchar(128)        NOT NULL,
    `plan_id`         bigint(20) unsigned NOT NULL,
    `is_deleted`      tinyint(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_app_id_username_template_id` (`app_id`, `username`, `plan_id`) USING BTREE,
    KEY `idx_username` (`username`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_favorite_template`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `app_id`          bigint(20) unsigned NOT NULL,
    `username`        varchar(128)        NOT NULL,
    `template_id`     bigint(20) unsigned NOT NULL,
    `is_deleted`      tinyint(1) unsigned NOT NULL DEFAULT '0',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_app_id_username_template_id` (`app_id`, `username`, `template_id`) USING BTREE,
    KEY `idx_username` (`username`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`   datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`   datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `app_id`            bigint(20) unsigned NOT NULL,
    `template_id`       bigint(20) unsigned NOT NULL,
    `name`              varchar(512)        NOT NULL,
    `creator`           varchar(128)        NOT NULL,
    `type`              tinyint(1) unsigned NOT NULL DEFAULT '0',
    `is_deleted`        tinyint(1) unsigned NOT NULL DEFAULT '0',
    `create_time`       bigint(20) unsigned NOT NULL,
    `last_modify_user`  varchar(128)        NOT NULL,
    `last_modify_time`  bigint(20) unsigned NOT NULL DEFAULT '0',
    `first_step_id`     bigint(20) unsigned          DEFAULT NULL,
    `last_step_id`      bigint(20) unsigned          DEFAULT NULL,
    `version`           char(64)            NOT NULL,
    `is_latest_version` tinyint(1) unsigned NOT NULL DEFAULT '1',
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`) USING BTREE,
    KEY `idx_app_id` (`app_id`) USING BTREE,
    KEY `idx_creator` (`creator`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1000000
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_step`
(
    `id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `plan_id`          bigint(20) unsigned NOT NULL,
    `type`             tinyint(2) unsigned NOT NULL,
    `name`             varchar(512)        NOT NULL,
    `previous_step_id` bigint(20) unsigned NOT NULL,
    `next_step_id`     bigint(20) unsigned NOT NULL,
    `is_enable`        tinyint(1) unsigned NOT NULL,
    `is_deleted`       tinyint(1) unsigned NOT NULL DEFAULT '0',
    `script_step_id`   bigint(20) unsigned          DEFAULT NULL,
    `file_step_id`     bigint(20) unsigned          DEFAULT NULL,
    `approval_step_id` bigint(20) unsigned          DEFAULT NULL,
    `template_step_id` bigint(20) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_plan_id` (`plan_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_step_approval`
(
    `id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`  datetime                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `row_update_time`  datetime                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `step_id`          bigint(20) unsigned NOT NULL,
    `approval_type`    tinyint(2) unsigned NOT NULL DEFAULT '0',
    `approval_user`    varchar(255)        NOT NULL,
    `approval_message` varchar(2048)       NOT NULL,
    `notify_channel`   varchar(1024)       NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_step_file`
(
    `id`                        bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `row_create_time`           datetime                     DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`           datetime                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `step_id`                   bigint(20) UNSIGNED NOT NULL,
    `destination_file_location` varchar(512)        NOT NULL,
    `execute_account`           bigint(20) UNSIGNED NOT NULL,
    `destination_host_list`     longtext /*!99104 COMPRESSED */,
    `timeout`                   bigint(20) UNSIGNED NOT NULL DEFAULT '0',
    `origin_speed_limit`        bigint(20) UNSIGNED NULL     DEFAULT NULL,
    `target_speed_limit`        bigint(20) UNSIGNED NULL     DEFAULT NULL,
    `ignore_error`              tinyint(1) UNSIGNED NOT NULL,
    `duplicate_handler`         tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
	`not_exist_path_handler`	TINYINT(2) UNSIGNED DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `idx_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_step_file_list`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time` datetime                     DEFAULT CURRENT_TIMESTAMP,
    `row_update_time` datetime                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `step_id`         bigint(20) unsigned NOT NULL,
    `file_type`       tinyint(2) unsigned NOT NULL DEFAULT '0',
    `file_location`   varchar(512)        NOT NULL,
    `file_size`       bigint(20) unsigned          DEFAULT NULL,
    `file_hash`       char(64)                     DEFAULT NULL,
    `host`            longtext /*!99104 COMPRESSED */,
    `host_account`    bigint(20) unsigned          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_step_script`
(
    `id`                    bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`       datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`       datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `plan_id`               bigint(20) unsigned NOT NULL,
    `step_id`               bigint(20) unsigned NOT NULL,
    `script_type`           tinyint(2) unsigned NOT NULL,
    `script_id`             char(32)                     DEFAULT NULL,
    `script_version_id`     bigint(20) unsigned          DEFAULT NULL,
    `content`               longtext /*!99104 COMPRESSED */,
    `language`              tinyint(5) unsigned NOT NULL,
    `script_param`          varchar(512)                 DEFAULT NULL,
    `script_timeout`        bigint(20) unsigned NOT NULL,
    `execute_account`       bigint(20) unsigned NOT NULL,
    `destination_host_list` longtext /*!99104 COMPRESSED */,
    `is_secure_param`       tinyint(1) unsigned NOT NULL DEFAULT '0',
    `is_latest_version`     tinyint(1) unsigned NOT NULL DEFAULT '1',
    `ignore_error`          tinyint(1) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_step_id` (`step_id`) USING BTREE,
    KEY `idx_script_id` (`script_id`) USING BTREE,
    KEY `idx_template_id` (`plan_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_plan_variable`
(
    `id`                   bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`      datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`      datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `plan_id`              bigint(20) unsigned NOT NULL,
    `template_variable_id` bigint(20) unsigned NOT NULL,
    `name`                 varchar(255)        NOT NULL,
    `type`                 tinyint(2) unsigned NOT NULL,
    `default_value`        longtext,
    `description`          varchar(512)        NOT NULL,
    `is_changeable`        tinyint(1) unsigned NOT NULL,
    `is_required`          tinyint(1) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`plan_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template`
(
    `id`                bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`   datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`   datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `app_id`            bigint(20) unsigned NOT NULL,
    `name`              varchar(512)        NOT NULL,
    `description`       varchar(2048)                DEFAULT NULL,
    `creator`           varchar(128)        NOT NULL,
    `status`            tinyint(2) unsigned NOT NULL DEFAULT '0',
    `is_deleted`        tinyint(1) unsigned NOT NULL DEFAULT '0',
    `create_time`       bigint(20) unsigned NOT NULL,
    `last_modify_user`  varchar(128)        NOT NULL,
    `last_modify_time`  bigint(20) unsigned NOT NULL DEFAULT '0',
    `tags`              varchar(512)                 DEFAULT NULL,
    `first_step_id`     bigint(20) unsigned          DEFAULT NULL,
    `last_step_id`      bigint(20) unsigned          DEFAULT NULL,
    `version`           char(64)            NOT NULL,
    `is_latest_version` tinyint(1) unsigned NOT NULL DEFAULT '1',
    PRIMARY KEY (`id`),
    KEY `idx_name` (`name`) USING BTREE,
    KEY `idx_creator` (`creator`) USING BTREE,
    KEY `idx_app_id` (`app_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_step`
(
    `id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `template_id`      bigint(20) unsigned NOT NULL,
    `type`             tinyint(2) unsigned NOT NULL DEFAULT '0',
    `name`             varchar(512)        NOT NULL,
    `previous_step_id` bigint(20) unsigned NOT NULL DEFAULT '0',
    `next_step_id`     bigint(20) unsigned NOT NULL DEFAULT '0',
    `is_deleted`       tinyint(1) unsigned NOT NULL DEFAULT '0',
    `script_step_id`   bigint(20) unsigned          DEFAULT NULL,
    `file_step_id`     bigint(20) unsigned          DEFAULT NULL,
    `approval_step_id` bigint(20) unsigned          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_step_approval`
(
    `id`               bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`  datetime                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `row_update_time`  datetime                     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    `step_id`          bigint(20) unsigned NOT NULL,
    `approval_type`    tinyint(2) unsigned NOT NULL DEFAULT '0',
    `approval_user`    varchar(255)        NOT NULL,
    `approval_message` varchar(2048)       NOT NULL,
    `notify_channel`   varchar(1024)       NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_step_file`
(
    `id`                        bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    `row_create_time`           datetime                     DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`           datetime                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `step_id`                   bigint(20) UNSIGNED NOT NULL,
    `destination_file_location` varchar(512)        NOT NULL,
    `execute_account`           bigint(20) UNSIGNED NOT NULL,
    `destination_host_list`     longtext,
    `timeout`                   bigint(20) UNSIGNED NOT NULL DEFAULT '0',
    `origin_speed_limit`        bigint(20) UNSIGNED NULL     DEFAULT NULL,
    `target_speed_limit`        bigint(20) UNSIGNED NULL     DEFAULT NULL,
    `ignore_error`              tinyint(1) UNSIGNED NOT NULL,
    `duplicate_handler`         tinyint(2) UNSIGNED NOT NULL DEFAULT '1',
	`not_exist_path_handler`	TINYINT(2) UNSIGNED DEFAULT 1,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_step_file_list`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time` datetime                     DEFAULT CURRENT_TIMESTAMP,
    `row_update_time` datetime                     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `step_id`         bigint(20) unsigned NOT NULL,
    `file_type`       tinyint(2) unsigned NOT NULL DEFAULT '0',
    `file_location`   varchar(512)        NOT NULL,
    `file_size`       bigint(20) unsigned          DEFAULT NULL,
    `file_hash`       char(64)                     DEFAULT NULL,
    `host`            longtext,
    `host_account`    bigint(20) unsigned          DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_step_id` (`step_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_step_script`
(
    `id`                    bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time`       datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`       datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `template_id`           bigint(20) unsigned NOT NULL,
    `step_id`               bigint(20) unsigned NOT NULL,
    `script_type`           tinyint(2) unsigned NOT NULL DEFAULT '0',
    `script_id`             char(32)                     DEFAULT NULL,
    `script_version_id`     bigint(20) unsigned          DEFAULT NULL,
    `content`               longtext /*!99104 COMPRESSED */,
    `language`              tinyint(5) unsigned NOT NULL,
    `script_param`          varchar(512)                 DEFAULT NULL,
    `script_timeout`        bigint(20) unsigned NOT NULL,
    `execute_account`       bigint(20) unsigned NOT NULL,
    `destination_host_list` longtext /*!99104 COMPRESSED */,
    `is_secure_param`       tinyint(1) unsigned NOT NULL DEFAULT '0',
    `is_latest_version`     tinyint(1) unsigned NOT NULL DEFAULT '1',
    `ignore_error`          tinyint(1) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_step_id` (`step_id`) USING BTREE,
    KEY `idx_script_id` (`script_id`) USING BTREE,
    KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;

CREATE TABLE IF NOT EXISTS `task_template_variable`
(
    `id`              bigint(20) unsigned NOT NULL AUTO_INCREMENT,
    `row_create_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time` datetime            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `template_id`     bigint(20) unsigned NOT NULL,
    `name`            varchar(255)        NOT NULL,
    `type`            tinyint(2) unsigned NOT NULL,
    `default_value`   longtext,
    `description`     varchar(512)        NOT NULL,
    `is_changeable`   tinyint(1) unsigned NOT NULL,
    `is_required`     tinyint(1) unsigned NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_template_id` (`template_id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1000000
  DEFAULT CHARSET = utf8mb4;


 CREATE TABLE IF NOT EXISTS `host`
(  `host_id` bigint(20) unsigned NOT NULL,
  `row_create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `row_update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `app_id` bigint(20) unsigned NOT NULL,
  `ip` varchar(15) NOT NULL,
  `ip_desc` varchar(2000) DEFAULT NULL,
  `set_ids` varchar(2048) DEFAULT NULL,
  `module_ids` varchar(2048) DEFAULT NULL,
  `cloud_area_id` bigint(20) unsigned NOT NULL,
  `display_ip` varchar(1024) NOT NULL,
  `os` varchar(512) DEFAULT '',
  `module_type` varchar(2048) DEFAULT '1' COMMENT '???????????????????????????',
  `is_agent_alive` tinyint(4) unsigned DEFAULT '1',
  PRIMARY KEY (`host_id`),
  KEY `idx_app_ip_cloud_area_ip` (`app_id`,`ip`,`cloud_area_id`) USING BTREE,
  KEY `idx_ip_cloud_area_id` (`ip`,`cloud_area_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

  CREATE TABLE IF NOT EXISTS `application`
(
  `app_id` bigint(20) unsigned NOT NULL,
  `row_create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `row_update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `app_name` varchar(1024) DEFAULT NULL,
  `maintainers` varchar(8192) DEFAULT NULL,
  `bk_supplier_account` varchar(128) NOT NULL DEFAULT '0',
  `app_type` tinyint(4) NOT NULL DEFAULT '1',
  `sub_app_ids` text /*!99104 COMPRESSED */,
  `timezone` varchar(128) DEFAULT 'Asia/Shanghai',
  `bk_operate_dept_id` BIGINT(20) DEFAULT NULL,
  `language` VARCHAR(20) DEFAULT NULL,
  PRIMARY KEY (`app_id`),
  KEY `app_type` (`app_type`)
) ENGINE = INNODB
  DEFAULT CHARSET = utf8mb4;
  

CREATE TABLE IF NOT EXISTS `account` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `row_create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `row_update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `account` varchar(255) NOT NULL,
  `alias` varchar(255) DEFAULT NULL,
  `category` tinyint(4) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `app_id` bigint(20) NOT NULL,
  `grantee` longtext DEFAULT NULL,
  `remark` varchar(1024) DEFAULT NULL,
  `os` varchar(32) DEFAULT 'Linux',
  `password` varchar(255) DEFAULT NULL,
  `db_password` varchar(255) DEFAULT NULL,
  `db_port` int(5) DEFAULT NULL,
  `db_system_account_id` bigint(20) DEFAULT NULL,
  `creator` varchar(128) NOT NULL,
  `create_time`      BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
  `is_deleted`       TINYINT(1) UNSIGNED          DEFAULT '0',
  `last_modify_user` varchar(128) DEFAULT NULL,
  `last_modify_time` BIGINT(20) UNSIGNED            NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`app_id`,`category`,`alias`)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4;

-- ----------------------------
-- IP??????????????????begin
-- ----------------------------

-- ----------------------------
-- Table structure for action_scope
-- ----------------------------
CREATE TABLE IF NOT EXISTS `action_scope`  (
  `id` bigint(20) NOT NULL,
  `code` VARCHAR(128) COMMENT '?????????IP????????????Code',
  `name` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
  `description` text CHARACTER SET utf8mb4 NULL,
  `row_create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `row_update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  `creator` varchar(128) CHARACTER SET utf8mb4 NOT NULL,
  `last_modify_user` varchar(128) CHARACTER SET utf8mb4 NULL DEFAULT NULL,
  `create_time` bigint(20) UNSIGNED NULL DEFAULT NULL,
  `last_modify_time` bigint(20) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4;


-- ----------------------------
-- Records of action_scope
-- ----------------------------
REPLACE INTO `action_scope` VALUES (1, 'SCRIPT_EXECUTE', '????????????', '????????????', '2019-12-26 22:08:48', '2020-02-11 23:07:28', 'admin', 'admin', 1577369328, 1577369328);
REPLACE INTO `action_scope` VALUES (2, 'FILE_DISTRIBUTION', '????????????', '????????????', '2019-12-26 22:08:48', '2020-02-11 23:07:28', 'admin', 'admin', 1577369328, 1577369328);


-- ----------------------------
-- Table structure for white_ip_ip
-- ----------------------------
CREATE TABLE IF NOT EXISTS `white_ip_ip`  (
    `id`               bigint(20)  NOT NULL AUTO_INCREMENT,
    `record_id`        bigint(20)  NOT NULL,
    `ip`               varchar(16) CHARACTER SET utf8mb4  NOT NULL,
    `cloud_area_id`    bigint(20)  NOT NULL,
    `row_create_time`  datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `creator`          varchar(128) CHARACTER SET utf8mb4 NOT NULL,
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4 NULL     DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_record_id` (`record_id`) USING BTREE,
    INDEX `idx_ip` (`ip`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for white_ip_action_scope
-- ----------------------------
CREATE TABLE IF NOT EXISTS `white_ip_action_scope`
(
    `id`               bigint(20)                                             NOT NULL AUTO_INCREMENT,
    `record_id`        bigint(20)                                             NOT NULL COMMENT '?????????id',
    `action_scope_id`  bigint(20)                                             NOT NULL DEFAULT 1 COMMENT '????????????',
    `row_create_time`  datetime(0)                                            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime(0)                                            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `creator`          varchar(128) CHARACTER SET utf8mb4                     NOT NULL,
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                     NULL     DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED                                    NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                    NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_record_id` (`record_id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for white_ip_record
-- ----------------------------
CREATE TABLE IF NOT EXISTS `white_ip_record`
(
    `id`               bigint(20)                                             NOT NULL AUTO_INCREMENT,
    `remark`           text CHARACTER SET utf8mb4                             NOT NULL COMMENT '??????',
    `row_create_time`  datetime(0)                                            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime(0)                                            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `creator`          varchar(128) CHARACTER SET utf8mb4                     NOT NULL,
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                     NULL     DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED                                    NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                    NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- IP??????????????????end
-- ----------------------------

-- ----------------------------
-- ?????????????????????begin
-- ----------------------------


-- ----------------------------
-- Table structure for available_esb_channel
-- ----------------------------
CREATE TABLE IF NOT EXISTS `available_esb_channel`  (
  `type` varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '????????????',
  `enable` bit(1) NOT NULL DEFAULT b'1' COMMENT '????????????????????????????????????',
  `creator` varchar(255) CHARACTER SET utf8mb4 NULL DEFAULT NULL COMMENT '????????????????????????????????????',
  `last_modify_time` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '????????????',
  PRIMARY KEY (`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4;



-- ----------------------------
-- Table structure for esb_user_info
-- ----------------------------
CREATE TABLE IF NOT EXISTS  `esb_user_info`  (
  `id` bigint(20) NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 NOT NULL,
  `logo` TEXT NULL,
  `display_name` varchar(255) CHARACTER SET utf8mb4 NULL DEFAULT NULL,
  `row_update_time` timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  `last_modify_time` bigint(20) UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_username`(`username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4;



-- ----------------------------
-- Table structure for notify_black_user_info
-- ----------------------------
CREATE TABLE IF NOT EXISTS `notify_black_user_info`
(
    `id`               bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `username`         varchar(255) CHARACTER SET utf8mb4                            NOT NULL,
    `creator`          varchar(255) CHARACTER SET utf8mb4                            NULL DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_username` (`username`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for notify_config_status
-- ----------------------------
CREATE TABLE IF NOT EXISTS `notify_config_status`
(
    `app_id`           bigint(20)                                                    NOT NULL,
    `username`         varchar(255) CHARACTER SET utf8mb4                            NOT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL DEFAULT NULL,
    PRIMARY KEY (`app_id`, `username`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for notify_policy_role_target
-- ----------------------------
CREATE TABLE IF NOT EXISTS `notify_policy_role_target`  (
    `id`               bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `policy_id`        bigint(20)                                                    NOT NULL COMMENT '??????Id',
    `role`             varchar(255) CHARACTER SET utf8mb4                            NOT NULL COMMENT '???????????????RESOURCE_OWNER/EXECUTOR/APP_MANAGER/EXTRA_OBSERVER??????????????????????????????????????????????????????????????????????????????+CMDB???????????????',
    `enable`           bit(1)                                                        NOT NULL COMMENT '????????????',
    `extra_observers`  text CHARACTER SET utf8mb4                                    NULL COMMENT '???????????????',
    `creator`          varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `row_update_time`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                            NULL     DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for notify_role_target_channel
-- ----------------------------
CREATE TABLE IF NOT EXISTS `notify_role_target_channel`
(
    `id`               bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `role_target_id`   bigint(20)                                                    NOT NULL,
    `channel`          varchar(255) CHARACTER SET utf8mb4                            NOT NULL,
    `creator`          varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `row_create_time`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                            NULL     DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


-- ----------------------------
-- Table structure for notify_trigger_policy
-- ----------------------------
CREATE TABLE IF NOT EXISTS `notify_trigger_policy`
(
    `id`               bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `app_id`           bigint(20)                                                    NOT NULL,
    `resource_id`      varchar(255) CHARACTER SET utf8mb4                            NOT NULL COMMENT '?????????????????????/?????????id',
    `resource_type`    tinyint(4)                                                    NOT NULL COMMENT '?????????????????????',
    `trigger_user`     varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `trigger_type`     tinyint(4)                                                    NOT NULL COMMENT '?????????????????????/API/???????????????',
    `execute_status`   tinyint(4)                                                    NOT NULL COMMENT '??????????????????',
    `creator`          varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `row_create_time`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `row_update_time`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `create_time`      bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL     DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;

-- ----------------------------
-- ?????????????????????end
-- ----------------------------

-- ----------------------------
-- Table structure for global_setting
-- ----------------------------
CREATE TABLE IF NOT EXISTS `global_setting`
(
    `key`      varchar(255) CHARACTER SET utf8mb4 NOT NULL,
    `value` text CHARACTER SET utf8mb4 NULL,
    `decription` varchar(255) CHARACTER SET utf8mb4 NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb4;


CREATE TABLE IF NOT EXISTS `dangerous_rule`  (
    `id`               bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `expression`       varchar(255) CHARACTER SET utf8mb4                            NOT NULL COMMENT '?????????',
    `script_type`      TINYINT                                                            DEFAULT 1 COMMENT '????????????',
    `description`      text CHARACTER SET utf8mb4                                    NULL COMMENT '??????',
    `priority`         int(11)                                                       NULL DEFAULT NULL COMMENT '?????????',
    `creator`          varchar(128) CHARACTER SET utf8mb4                            NOT NULL,
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                            NULL DEFAULT NULL,
    `create_time`      bigint(20) UNSIGNED                                           NULL DEFAULT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


CREATE TABLE IF NOT EXISTS `index_greeting`
(
    `id`               bigint(20)                                             NOT NULL AUTO_INCREMENT,
    `start_seconds`    int(10)                                                NOT NULL COMMENT '??????????????????????????????',
    `end_seconds`      int(10)                                                NOT NULL COMMENT '??????????????????????????????',
    `content`          text CHARACTER SET utf8mb4                             NOT NULL COMMENT '???????????????${time}??????????????????',
	`content_en` 	   TEXT                                                   NULL COMMENT '???????????????',
    `priority`         int(10)                                                NOT NULL COMMENT '?????????',
    `active`           bit(1)                                                 NOT NULL COMMENT '????????????',
    `description`      TEXT COMMENT '??????',
    `creator`          varchar(128) CHARACTER SET utf8mb4                     NOT NULL COMMENT '?????????',
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4                     NULL DEFAULT NULL COMMENT '?????????',
    `create_time`      bigint(20) UNSIGNED                                    NULL DEFAULT NULL COMMENT '????????????',
    `last_modify_time` bigint(20) UNSIGNED                                    NULL DEFAULT NULL COMMENT '????????????',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (2, 82800, 86400, '?????????${time}????????????... ?????????????????????????????????', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (3, 0, 3600, '?????????${time}????????????... ?????????????????????????????????', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (4, 3600, 14400, '?????????${time}????????????????????????????????????????????????????????????????????????????????????...', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (6, 14400, 25200, '?????????${time}???????????????????????????????????????????????????????????????????????????~ ??????????????????', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (7, 25200, 42000, '?????????${time}???????????????????????????????????????????????????????????????????????????????????????????????????~', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (8, 42000, 45000, '?????????${time}????????????????????????????????????????????????????????????~', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (9, 45000, 50400, '?????????${time}???????????????????????????????????????????????????????????????????????????', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`,
                             `last_modify_user`, `create_time`, `last_modify_time`, `description`)
VALUES (10, 50400, 64800, '?????????${time}?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????', 2, b'1', 'admin', 'admin', 1, 1,
        NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (11, 64800, 70200, '?????????${time}????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????', 2, b'1', 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `index_greeting`(`id`, `start_seconds`, `end_seconds`, `content`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (12, 70200, 82800, '?????????${time}???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????~', 2, b'1', 'admin', 'admin', 1, 1, NULL);


CREATE TABLE IF NOT EXISTS `analysis_task`  (
    `id`                          bigint(20)                                                    NOT NULL AUTO_INCREMENT,
    `code`                        varchar(255) CHARACTER SET utf8mb4 NOT NULL COMMENT '????????????????????????????????????',
    `app_ids`                     text CHARACTER SET utf8mb4         NOT NULL COMMENT '?????????appId???null???????????????',
    `result_description_template` TEXT COMMENT '??????????????????????????????',
    `result_description_template_en` TEXT NULL COMMENT '?????????????????????????????????????????????',
    `result_item_template`        text CHARACTER SET utf8mb4         NOT NULL COMMENT '??????????????????????????????',
    `result_item_template_en` 	  TEXT NULL COMMENT '???????????????????????????????????????',
    `priority`                    int(10)                                                       NOT NULL COMMENT '?????????',
    `active`                      bit(1)                                                        NOT NULL COMMENT '????????????',
    `period_seconds`              bigint(20)                                                    NOT NULL COMMENT '????????????',
    `creator`                     varchar(128) CHARACTER SET utf8mb4        NOT NULL COMMENT '?????????',
    `last_modify_user`            varchar(128) CHARACTER SET utf8mb4        NULL DEFAULT NULL COMMENT '?????????',
    `create_time`                 bigint(20) UNSIGNED                                           NULL DEFAULT NULL COMMENT '????????????',
    `last_modify_time`            bigint(20) UNSIGNED                                           NULL DEFAULT NULL COMMENT '????????????',
    `description`                 TEXT COMMENT '??????????????????',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `idx_code` (`code`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


CREATE TABLE IF NOT EXISTS `analysis_task_instance`
(
    `id`               bigint(20)                                                  NOT NULL AUTO_INCREMENT,
    `app_id`           bigint(20)                                                  NOT NULL COMMENT '??????id',
    `task_id`          bigint(255)                                                 NOT NULL COMMENT '??????id',
    `status`           int(10)                                                     NOT NULL COMMENT '????????????',
    `result_data`      MEDIUMTEXT CHARACTER SET utf8mb4 NOT NULL COMMENT '?????????????????????????????????????????????',
    `priority`         int(10)                                                     NOT NULL COMMENT '?????????',
    `active`           bit(1)                                                      NOT NULL COMMENT '????????????',
    `creator`          varchar(128) CHARACTER SET utf8mb4      NOT NULL COMMENT '?????????',
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4      NULL DEFAULT NULL COMMENT '?????????',
    `create_time`      bigint(20) UNSIGNED                                         NULL DEFAULT NULL COMMENT '????????????',
    `last_modify_time` bigint(20) UNSIGNED                                         NULL DEFAULT NULL COMMENT '????????????',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_appId_taskId` (`app_id`, `task_id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;
  
-- ------------------------
-- ?????????????????????????????????
-- ------------------------
CREATE TABLE IF NOT EXISTS `analysis_task_static_instance`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app_id` bigint(20) NOT NULL COMMENT '??????id',
  `task_id` bigint(255) NOT NULL COMMENT '??????id',
  `status` int(10) NOT NULL COMMENT '????????????',
  `result_data` mediumtext CHARACTER SET utf8mb4 NOT NULL COMMENT '?????????????????????????????????????????????',
  `result_data_en` mediumtext CHARACTER SET utf8mb4 NULL COMMENT '??????????????????????????????',
  `priority` int(10) NOT NULL COMMENT '?????????',
  `active` bit(1) NOT NULL COMMENT '????????????',
  `creator` varchar(128) CHARACTER SET utf8mb4 NOT NULL COMMENT '?????????',
  `last_modify_user` varchar(128) CHARACTER SET utf8mb4 NULL DEFAULT NULL COMMENT '?????????',
  `create_time` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '????????????',
  `last_modify_time` bigint(20) UNSIGNED NULL DEFAULT NULL COMMENT '????????????',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_appId_taskId`(`app_id`, `task_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 ;


REPLACE INTO `analysis_task_static_instance`(`id`, `app_id`, `task_id`, `status`, `result_data`, `result_data_en`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`) VALUES (1, -1, -1, 2, '?????????????????? Shell ????????????????????? `job_success` `job_fail`???????????????????????????????????????????????????????????????????????????????????????????????? <a>https://bk.tencent.com/docs/</a>', 'Using built-in functions `job_success` `job_fail`, execution results can be grouped easily. Find out more tips with docs <a>https://bk.tencent.com/docs/</a>.', 100, b'1', 'admin', 'admin', 1583492717314, 1583492717318);
REPLACE INTO `analysis_task_static_instance`(`id`, `app_id`, `task_id`, `status`, `result_data`, `result_data_en`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`) VALUES (2, -1, -1, 2, '????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? ?????????????????????????????????????????????????????????[??????](https://bk.tencent.com/docs/)', 'Params involves sensitive information (such as passwords). How to avoid the risk of information leakage? The `password` variable can help you solve this problem! For more information and examples see docs (https://bk.tencent.com/docs/).', 100, b'1', 'admin', 'admin', 1583492717314, 1583492717318);
REPLACE INTO `analysis_task_static_instance`(`id`, `app_id`, `task_id`, `status`, `result_data`, `result_data_en`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`) VALUES (3, -1, -1, 2, '??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????', 'Job tags can help you manage template classification better, you can easily toggle different tags in left side on Jobs page.', 100, b'1', 'admin', 'admin', 1583492717314, 1583492717318);
REPLACE INTO `analysis_task_static_instance`(`id`, `app_id`, `task_id`, `status`, `result_data`, `result_data_en`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`) VALUES (4, -1, -1, 2, '????????????????????????????????????????????????????????????????????????????????????????????????????????????\r\n?????????????????????????????????????????????????????????', 'Favorite Jobs can be displayed on the homepage, so you can find the job you need faster when you came to Job.', 100, b'1', 'admin', 'admin', 1583492717314, 1583492717318);
REPLACE INTO `analysis_task_static_instance`(`id`, `app_id`, `task_id`, `status`, `result_data`, `result_data_en`, `priority`, `active`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`) VALUES (5, -1, -1, 2, '???????????????Shell ????????????????????????~ ??????????????? `var[0]=\'test1\'; var[1]=\'test2\';` ?????? `echo ${var[*]}` ???????????????????????????????????????`echo ${#var[*]}` ?????????????????????????????????????????????', 'You know what, Array variable is supported in Bash. How? `var[0]=\'test1\'; var[1]=\'test2\';` and using `echo ${var[*]}` to print all index values of Array variable, using `echo ${#var[*]}` to show how many index the Array variable has.', 100, b'1', 'admin', 'admin', 1583492717314, 1583492717318);


CREATE TABLE IF NOT EXISTS `white_ip_app_rel`
(
    `record_id`   bigint(20)                                             NOT NULL AUTO_INCREMENT,
    `app_id`      bigint(20)                                             NOT NULL COMMENT '??????ID',
    `creator`     varchar(128) CHARACTER SET utf8mb4 NOT NULL,
    `create_time` bigint(20) UNSIGNED                                    NULL DEFAULT NULL,
    PRIMARY KEY (`record_id`, `app_id`) USING BTREE,
    INDEX `idx_record_id` (`record_id`) USING BTREE,
    INDEX `idx_app_id` (`app_id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8mb4;


REPLACE INTO `analysis_task`(`id`, `code`, `app_ids`, `result_description_template`, `result_description_template_en`, `result_item_template`, `result_item_template_en`, `priority`, `active`, `period_seconds`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (-1, 'DefaultTipsProvider', '', NULL, NULL, '', NULL, 1, b'1', 3600, 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `analysis_task`(`id`, `code`, `app_ids`, `result_description_template`, `result_description_template_en`, `result_item_template`, `result_item_template_en`, `priority`, `active`, `period_seconds`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (2, 'TimerTaskFailWatcher', '', '????????????????????????????????????????????????????????????????????????????????????????????????', 'Attention! System has detected that many Crons have running failed recently, please click Details to check if there is problems in it.', '???????????????${taskName}?????????????????????????????????????????????????????????', 'Caution: Cron[${taskName}] has executed failed recently.', 1, b'1', 1200, 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `analysis_task`(`id`, `code`, `app_ids`, `result_description_template`, `result_description_template_en`, `result_item_template`, `result_item_template_en`, `priority`, `active`, `period_seconds`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (3, 'TimerTaskFailRateWatcher', '', '????????????????????????????????????????????????????????????????????? 60%???????????????', 'Attention! System has detected that many Crons success rate is lower than 60%??? it seems there are some problems, please pay attention.', '???????????????${taskName}?????????????????????????????? 60%???????????????', 'Caution: Cron[${taskName}] success-rate is lower than 60%.', 1, b'1', 1200, 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `analysis_task`(`id`, `code`, `app_ids`, `result_description_template`, `result_description_template_en`, `result_item_template`, `result_item_template_en`, `priority`, `active`, `period_seconds`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (4, 'ForbiddenScriptFinder', '', '?????????????????????????????????/???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????', 'Caution! System has detected that many Jobs using the script version in \"Banned\" status, it will not able to execute??? please handle it ASAP.', '${typeName}???${instanceName}????????????$stepName???????????? ????????? ?????????????????????????????????????????????????????????????????????', 'Caution: Job[${instanceName}]\'s step[$stepName] uses script version in \"Banned\" state, which will not be executed properly.', 1, b'1', 2400, 'admin', 'admin', 1, 1, NULL);
REPLACE INTO `analysis_task`(`id`, `code`, `app_ids`, `result_description_template`, `result_description_template_en`, `result_item_template`, `result_item_template_en`, `priority`, `active`, `period_seconds`, `creator`, `last_modify_user`, `create_time`, `last_modify_time`, `description`) VALUES (5, 'TaskPlanTargetChecker', '', '??????????????????????????????/?????????????????????????????????????????????Agent???????????????????????????????????????', 'Caution! System has detected that many Jobs using Abnormal status Host, it will cause the job fail to execute, please handle it ASAP.', '?????????${planName}????????????$stepName????????????????????????????????????$description??????????????????', 'Caution: Job plan[${planName}]\'s step[$stepName] contains abnormal hosts.', 1, b'1', 7200, 'admin', 'admin', 1, 1, NULL);




-- ------------------------
-- ???????????????????????????
-- ------------------------
CREATE TABLE IF NOT EXISTS `notify_template`  (
    `id`               int(11)                                                       NOT NULL AUTO_INCREMENT,
    `code`             varchar(64) CHARACTER SET utf8        NOT NULL,
    `name`             varchar(128) CHARACTER SET utf8       NOT NULL,
    `channel`          varchar(64) CHARACTER SET utf8        NOT NULL,
    `title`            text CHARACTER SET utf8               NOT NULL,
    `content`          mediumtext CHARACTER SET utf8         NOT NULL,
    `title_en`         text CHARACTER SET utf8               NULL,
    `content_en`       mediumtext CHARACTER SET utf8         NULL,
    `creator`          varchar(128) CHARACTER SET utf8mb4 NOT NULL,
    `last_modify_user` varchar(128) CHARACTER SET utf8mb4        NOT NULL,
    `create_time`      bigint(20) UNSIGNED                                           NOT NULL,
    `last_modify_time` bigint(20) UNSIGNED                                           NOT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_code` (`code`) USING BTREE,
    INDEX `idx_name` (`name`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 1
  CHARACTER SET = utf8;

-- ------------------------
-- ?????????????????????
-- ------------------------
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (1, 'beforeCronJobExecute', '?????????????????????????????????', 'mail', '????????????????????????????????????????????????',
        '<table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #fff; background: #fff;\">\r\n	<tbody>\r\n		<tr>\r\n			<td align=\"center\" valign=\"top\" width=\"100%\" style=\"padding: 16px;\">\r\n			   <table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"956\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-top:30px;\">\r\n					<tbody>\r\n						<tr>\r\n							<td valign=\"top\" align=\"center\" style=\"padding: 24px;\" bgcolor=\"#f9f8f6\">\r\n								<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6;\">\r\n									<tr>\r\n										<td class=\"email-title\" style=\"padding: 20px 36px; line-height: 1.5; border-bottom: 1px solid #e6e6e6; background: #fff; font-size: 22px;\">????????????????????????????????????????????????</td>\r\n									</tr>\r\n									<tr>\r\n										<td class=\"email-content\" style=\"padding: 0 36px; background: #fff;\">\r\n											<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n												<tr>\r\n													<td class=\"email-source\" style=\"padding: 14px 0; color: #bebebe;\">?????? ?????????????????? ???????????????</td>\r\n												</tr>\r\n\r\n												<tr class=\"email-information\">\r\n													<td class=\"table-info\">\r\n														<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n															<tr class=\"table-title\">\r\n																<td style=\"padding-top: 36px; padding-bottom: 14px; color: #707070;\">???????????????????????? <font style=\"font-weight:bold;color:red;\">{{ notify_time }}</font> ????????? <font style=\"font-weight:bold;\">????????????</font>???????????????</td>\r\n															</tr>\r\n															<tr>\r\n																<td>\r\n																	<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6; border-collapse: collapse;\">\r\n																		<tbody style=\"color: #707070;\">\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"><a href=\"{{BASE_HOST}}{{cron_uri}}\" style=\"color: #3c96ff\"> {{ cron_name }}</a></td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\">[{{ APP_ID }}] {{ APP_NAME }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">?????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_updater }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_type }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_rule }}</td>\r\n																			</tr>\r\n																		</tbody>\r\n																	</table>\r\n																</td>\r\n															</tr>\r\n														</table>\r\n													</td>\r\n												</tr>\r\n\r\n												<tr class=\"prompt-tips\">\r\n													<td style=\"padding-top: 32px; padding-bottom: 10px; color: #707070;\">???????????????????????????????????????????????????</td>\r\n												</tr>\r\n												<tr class=\"info-remark\">\r\n													<td style=\"padding: 20px 0; text-align: right; line-height: 24px; color: #707070;\">\r\n														<div>{{ triggerTime }}</div>\r\n													</td>\r\n												</tr>\r\n											</table>\r\n										</td>\r\n									</tr>\r\n									<tr class=\"email-footer\">\r\n										<td style=\" padding: 20px 0 20px 36px; border-top: 1px solid #e6e6e6; background: #fff; color: #c7c7c7;\">?????????????????????????????????????????????????????????????????????????????????</td>\r\n									</tr>\r\n								</table>\r\n							</td>\r\n						</tr>\r\n					</tbody>\r\n			   </table>\r\n			</td>\r\n		</tr>\r\n	</tbody>\r\n</table>\r\n',
        '???BlueKing JOB???Cron Pre-Launch Notification',
        '<table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #fff; background: #fff;\">\r\n	<tbody>\r\n		<tr>\r\n			<td align=\"center\" valign=\"top\" width=\"100%\" style=\"padding: 16px;\">\r\n			   <table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"956\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-top:30px;\">\r\n					<tbody>\r\n						<tr>\r\n							<td valign=\"top\" align=\"center\" style=\"padding: 24px;\" bgcolor=\"#f9f8f6\">\r\n								<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6;\">\r\n									<tr>\r\n										<td class=\"email-title\" style=\"padding: 20px 36px; line-height: 1.5; border-bottom: 1px solid #e6e6e6; background: #fff; font-size: 22px;\">???BlueKing JOB???Cron Pre-Launch Notification</td>\r\n									</tr>\r\n									<tr>\r\n										<td class=\"email-content\" style=\"padding: 0 36px; background: #fff;\">\r\n											<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n												<tr>\r\n													<td class=\"email-source\" style=\"padding: 14px 0; color: #bebebe;\">This message is from <b>BlueKing JOB</b></td>\r\n												</tr>\r\n\r\n												<tr class=\"email-information\">\r\n													<td class=\"table-info\">\r\n														<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n															<tr class=\"table-title\">\r\n																<td style=\"padding-top: 36px; padding-bottom: 14px; color: #707070;\">The Cron task below will <font style=\"font-weight:bold;\">launch automatically</font> after <font style=\"font-weight:bold;color:red;\">{{ notify_time }}</font> mins, please be noted!</td>\r\n															</tr>\r\n															<tr>\r\n																<td>\r\n																	<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6; border-collapse: collapse;\">\r\n																		<tbody style=\"color: #707070;\">\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">TASK NAME</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"><a href=\"{{BASE_HOST}}{{cron_uri}}\" style=\"color: #3c96ff\"> {{ cron_name }}</a></td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">BUSINESS</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\">[{{ APP_ID }}] {{ APP_NAME }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">OPERATOR</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_updater }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">REPEAT FREQUENCY</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_type }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">TIME SET</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_rule }}</td>\r\n																			</tr>\r\n																		</tbody>\r\n																	</table>\r\n																</td>\r\n															</tr>\r\n														</table>\r\n													</td>\r\n												</tr>\r\n\r\n												<tr class=\"prompt-tips\">\r\n													<td style=\"padding-top: 32px; padding-bottom: 10px; color: #707070;\">If You Have Any Questions or Concerns, Please Contact BK Assistant.</td>\r\n												</tr>\r\n												<tr class=\"info-remark\">\r\n													<td style=\"padding: 20px 0; text-align: right; line-height: 24px; color: #707070;\">\r\n														<div>{{ triggerTime }}</div>\r\n													</td>\r\n												</tr>\r\n											</table>\r\n										</td>\r\n									</tr>\r\n									<tr class=\"email-footer\">\r\n										<td style=\" padding: 20px 0 20px 36px; border-top: 1px solid #e6e6e6; background: #fff; color: #c7c7c7;\">Your name is in \"Notify To\" field of this Cron settings, that\'s why you received this message.</td>\r\n									</tr>\r\n								</table>\r\n							</td>\r\n						</tr>\r\n					</tbody>\r\n			   </table>\r\n			</td>\r\n		</tr>\r\n	</tbody>\r\n</table>',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (5, 'beforeCronJobEnd', '?????????????????????????????????', 'mail', '????????????????????????????????????????????????',
        '<table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #fff; background: #fff;\">\r\n	<tbody>\r\n		<tr>\r\n			<td align=\"center\" valign=\"top\" width=\"100%\" style=\"padding: 16px;\">\r\n			   <table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"956\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-top:30px;\">\r\n					<tbody>\r\n						<tr>\r\n							<td valign=\"top\" align=\"center\" style=\"padding: 24px;\" bgcolor=\"#f9f8f6\">\r\n								<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6;\">\r\n									<tr>\r\n										<td class=\"email-title\" style=\"padding: 20px 36px; line-height: 1.5; border-bottom: 1px solid #e6e6e6; background: #fff; font-size: 22px;\">????????????????????????????????????????????????</td>\r\n									</tr>\r\n									<tr>\r\n										<td class=\"email-content\" style=\"padding: 0 36px; background: #fff;\">\r\n											<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n												<tr>\r\n													<td class=\"email-source\" style=\"padding: 14px 0; color: #bebebe;\">?????? ?????????????????? ???????????????</td>\r\n												</tr>\r\n\r\n												<tr class=\"email-information\">\r\n													<td class=\"table-info\">\r\n														<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n															<tr class=\"table-title\">\r\n																<td style=\"padding-top: 36px; padding-bottom: 14px; color: #707070;\">???????????????????????? <font style=\"font-weight:bold;color:red;\">{{ notify_time }}</font> ????????? <font style=\"font-weight:bold;\">???????????????</font>???????????????</td>\r\n															</tr>\r\n															<tr>\r\n																<td>\r\n																	<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6; border-collapse: collapse;\">\r\n																		<tbody style=\"color: #707070;\">\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"><a href=\"{{BASE_HOST}}{{cron_uri}}\" style=\"color: #3c96ff\"> {{ cron_name }}</a></td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\">[{{ APP_ID }}] {{ APP_NAME }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">?????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_updater }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_type }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">????????????</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_rule }}</td>\r\n																			</tr>\r\n																		</tbody>\r\n																	</table>\r\n																</td>\r\n															</tr>\r\n														</table>\r\n													</td>\r\n												</tr>\r\n\r\n												<tr class=\"prompt-tips\">\r\n													<td style=\"padding-top: 32px; padding-bottom: 10px; color: #707070;\">???????????????????????????????????????????????????</td>\r\n												</tr>\r\n												<tr class=\"info-remark\">\r\n													<td style=\"padding: 20px 0; text-align: right; line-height: 24px; color: #707070;\">\r\n														<div>{{ triggerTime }}</div>\r\n													</td>\r\n												</tr>\r\n											</table>\r\n										</td>\r\n									</tr>\r\n									<tr class=\"email-footer\">\r\n										<td style=\" padding: 20px 0 20px 36px; border-top: 1px solid #e6e6e6; background: #fff; color: #c7c7c7;\">?????????????????????????????????????????????????????????????????????????????????</td>\r\n									</tr>\r\n								</table>\r\n							</td>\r\n						</tr>\r\n					</tbody>\r\n			   </table>\r\n			</td>\r\n		</tr>\r\n	</tbody>\r\n</table>\r\n',
        '???BlueKing JOB???Cron End-time Notification',
        '<table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; background-color: #fff; background: #fff;\">\r\n	<tbody>\r\n		<tr>\r\n			<td align=\"center\" valign=\"top\" width=\"100%\" style=\"padding: 16px;\">\r\n			   <table class=\"template-table\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"956\" style=\"font-size: 14px; min-width: auto; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-top:30px;\">\r\n					<tbody>\r\n						<tr>\r\n							<td valign=\"top\" align=\"center\" style=\"padding: 24px;\" bgcolor=\"#f9f8f6\">\r\n								<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6;\">\r\n									<tr>\r\n											<td class=\"email-title\" style=\"padding: 20px 36px; line-height: 1.5; border-bottom: 1px solid #e6e6e6; background: #fff; font-size: 22px;\">???BlueKing JOB???Cron End-time Notification</td>\r\n									</tr>\r\n									<tr>\r\n										<td class=\"email-content\" style=\"padding: 0 36px; background: #fff;\">\r\n											<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n												<tr>\r\n													<td class=\"email-source\" style=\"padding: 14px 0; color: #bebebe;\">This message is from <b>BlueKing JOB</b></td>\r\n												</tr>\r\n\r\n												<tr class=\"email-information\">\r\n													<td class=\"table-info\">\r\n														<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt;\">\r\n															<tr class=\"table-title\">\r\n																<td style=\"padding-top: 36px; padding-bottom: 14px; color: #707070;\">The Cron task below will <font style=\"font-weight:bold;\">Turn-Off</font> automatically after <font style=\"font-weight:bold;color:red;\">{{ notify_time }}</font> mins, please be noted!</td>\r\n															</tr>\r\n															<tr>\r\n																<td>\r\n																	<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; border: 1px solid #e6e6e6; border-collapse: collapse;\">\r\n																		<tbody style=\"color: #707070;\">\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">TASK NAME</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"><a href=\"{{BASE_HOST}}{{cron_uri}}\" style=\"color: #3c96ff\"> {{ cron_name }}</a></td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">BUSINESS</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\">[{{ APP_ID }}] {{ APP_NAME }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">OPERATOR</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_updater }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">REPEAT FREQUENCY</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_type }}</td>\r\n																			</tr>\r\n																			<tr>\r\n																				<td width=\"30%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: right; font-weight: bold; background-color: #f3f3f3;\">TIME SET</td>\r\n																				<td width=\"70%\" style=\" padding: 16px; border: 1px solid #e6e6e6;text-align: left; font-weight: normal;\"> {{ cron_rule }}</td>\r\n																			</tr>\r\n																		</tbody>\r\n																	</table>\r\n																</td>\r\n															</tr>\r\n														</table>\r\n													</td>\r\n												</tr>\r\n\r\n												<tr class=\"prompt-tips\">\r\n													<td style=\"padding-top: 32px; padding-bottom: 10px; color: #707070;\">If You Have Any Questions or Concerns, Please Contact BK Assistant.</td>\r\n												</tr>\r\n												<tr class=\"info-remark\">\r\n													<td style=\"padding: 20px 0; text-align: right; line-height: 24px; color: #707070;\">\r\n														<div>{{ triggerTime }}</div>\r\n													</td>\r\n												</tr>\r\n											</table>\r\n										</td>\r\n									</tr>\r\n									<tr class=\"email-footer\">\r\n										<td style=\" padding: 20px 0 20px 36px; border-top: 1px solid #e6e6e6; background: #fff; color: #c7c7c7;\">Your name is in \"Notify To\" field of this Cron settings, that\'s why you received this message.</td>\r\n									</tr>\r\n								</table>\r\n							</td>\r\n						</tr>\r\n					</tbody>\r\n			   </table>\r\n			</td>\r\n		</tr>\r\n	</tbody>\r\n</table>\r\n',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (2, 'beforeCronJobExecute', '?????????????????????????????????', 'rtx', '???????????????????????????????????????????????????',
        ' ????????????????????????{{ notify_time }}???????????????\r\n???????????????{{ cron_name }}\r\n???????????????{{ APP_NAME }}\r\n???????????????{{ cron_updater }}\r\n???????????????{{ cron_type }}\r\n???????????????{{ cron_rule }}\r\n???????????????{{BASE_HOST}}{{cron_uri}}',
        '???BlueKing JOB???Cron Pre-Launch Notification',
        'The task will launch automatically after {{ notify_time }} mins, please be noted!\r\n    Task Name: {{ cron_name }}\r\n        Business: {{ APP_NAME }}\r\n       Operator: {{ cron_updater }}\r\nREPEAT FREQ: {{ cron_type }}\r\n       Time Set: {{ cron_rule }}\r\n          Details: {{BASE_HOST}}{{cron_uri}}',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (6, 'beforeCronJobEnd', '?????????????????????????????????', 'rtx', '???????????????????????????????????????????????????',
        '????????????????????????{{ notify_time }}????????????????????????\r\n???????????????{{ cron_name }}\r\n???????????????{{ APP_NAME }}\r\n???????????????{{ cron_updater }}\r\n???????????????{{ cron_type }}\r\n???????????????{{ cron_rule }}\r\n???????????????{{BASE_HOST}}{{cron_uri}}',
        '???BlueKing JOB???Cron End-time Notification',
        'The task will Turn-Off automatically after {{ notify_time }} mins, please be noted!\r\n    Task Name: {{ cron_name }}\r\n        Business: {{ APP_NAME }}\r\n       Operator: {{ cron_updater }}\r\nREPEAT FREQ: {{ cron_type }}\r\n       Time Set: {{ cron_rule }}\r\n          Details: {{BASE_HOST}}{{cron_uri}}',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (3, 'beforeCronJobExecute', '?????????????????????????????????', 'sms',
        '??????????????????????????????????????????[{{ APP_NAME }}]?????????????????????[{{ cron_name }}]??????{{ notify_time }}??????????????????????????????????????????????????????',
        '??????????????????????????????????????????[{{ APP_NAME }}]?????????????????????[{{ cron_name }}]??????{{ notify_time }}??????????????????????????????????????????????????????',
        'Cron Pre-Launch Notification: There\'s a task of [{{ APP_NAME }}] will launch automatically after {{ notify_time }} mins, more details: {{BASE_HOST}}{{cron_uri}}???BlueKing JOB???',
        'Cron Pre-Launch Notification: There\'s a task of [{{ APP_NAME }}] will launch automatically after {{ notify_time }} mins, more details: {{BASE_HOST}}{{cron_uri}}???BlueKing JOB???',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (7, 'beforeCronJobEnd', '?????????????????????????????????', 'sms',
        '??????????????????????????????????????????[{{ APP_NAME }}]?????????????????????[{{ cron_name }}]??????{{ notify_time }}???????????????????????????????????????????????????????????????',
        '??????????????????????????????????????????[{{ APP_NAME }}]?????????????????????[{{ cron_name }}]??????{{ notify_time }}???????????????????????????????????????????????????????????????',
        'Cron End-time Notification: There\'s a task of [{{ APP_NAME }}] will Turn-Off automatically after {{ notify_time }} mins, more details: {{BASE_HOST}}{{cron_uri}}???BlueKing JOB???',
        'Cron End-time Notification: There\'s a task of [{{ APP_NAME }}] will Turn-Off automatically after {{ notify_time }} mins, more details: {{BASE_HOST}}{{cron_uri}}???BlueKing JOB???',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (4, 'beforeCronJobExecute', '?????????????????????????????????', 'weixin', '???????????????????????????????????????????????????',
        ' ????????????????????????{{ notify_time }}???????????????\r\n???????????????{{ cron_name }}\r\n???????????????{{ APP_NAME }}\r\n???????????????{{ cron_updater }}\r\n???????????????{{ cron_type }}\r\n???????????????{{ cron_rule }}\r\n???????????????{{BASE_HOST}}{{cron_uri}}',
        '???BlueKing JOB???Cron Pre-Launch Notification',
        'The task will launch automatically after {{ notify_time }} mins, please be noted!\r\n    Task Name: {{ cron_name }}\r\n        Business: {{ APP_NAME }}\r\n       Operator: {{ cron_updater }}\r\nREPEAT FREQ: {{ cron_type }}\r\n       Time Set: {{ cron_rule }}\r\n          Details: {{BASE_HOST}}{{cron_uri}}',
        'admin', 'admin', 0, 0);
REPLACE INTO `notify_template`(`id`, `code`, `name`, `channel`, `title`, `content`, `title_en`, `content_en`, `creator`,
                              `last_modify_user`, `create_time`, `last_modify_time`)
VALUES (8, 'beforeCronJobEnd', '?????????????????????????????????', 'weixin', '???????????????????????????????????????????????????',
        '????????????????????????{{ notify_time }}????????????????????????\r\n???????????????{{ cron_name }}\r\n???????????????{{ APP_NAME }}\r\n???????????????{{ cron_updater }}\r\n???????????????{{ cron_type }}\r\n???????????????{{ cron_rule }}\r\n???????????????{{BASE_HOST}}{{cron_uri}}',
        '???BlueKing JOB???Cron End-time Notification',
        'The task will Turn-Off automatically after {{ notify_time }} mins, please be noted!\r\n    Task Name: {{ cron_name }}\r\n        Business: {{ APP_NAME }}\r\n       Operator: {{ cron_updater }}\r\nREPEAT FREQ: {{ cron_type }}\r\n       Time Set: {{ cron_rule }}\r\n          Details: {{BASE_HOST}}{{cron_uri}}',
        'admin', 'admin', 0, 0);
