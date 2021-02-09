

mypy_pkgs:
  pkg.installed:
    - mariadb-server
    - python-mysqldb
{% if grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
    - debconf-utils
{% endif %}
    
{% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}


{% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}

mysql_setup:
  debconf.set:
    - name: mariadb-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql:root_pw', '') }}' }
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql:root_pw', '') }}' }
    - require:
      - pkg: debconf-utils

{% endif %}


mysql:
  service.running:
    - watch:
      - pkg: mariadb-server
      - file: /etc/mysql/my.cnf

salt:
  mysql_database.present:
    - name: {{ pillar['returnerdb'] }}
    - character_set: utf8
    - collate: utf8_general_ci
    - connection_host: {{ pillar['SQL_HOST'] }}
    - connection_user: {{ pillar['SQL_ROOT_USER'] }}
    - connection_pass: {{ pillar['SQL_ROOT_PASSWORD'] }}
    - require:
      - mysql
      
sql_app_user:
  mysql_user.present:
    - name: {{ pillar['returner_user'] }}
    - password: {{ pillar['returner_pass'] }}
    - host: '%'
    - use:
      - mysql_database: salt      
      
      
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

USE `salt`;

--
-- Table structure for table `jids`
--

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_returns`
--

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Table structure for table `salt_events`
--

DROP TABLE IF EXISTS `salt_events`;
CREATE TABLE `salt_events` (
`id` BIGINT NOT NULL AUTO_INCREMENT,
`tag` varchar(255) NOT NULL,
`data` mediumtext NOT NULL,
`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`master_id` varchar(255) NOT NULL,
PRIMARY KEY (`id`),
KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;       
            
