CREATE TABLE `list_users` (
  `u_id` int(11) NOT NULL AUTO_INCREMENT,
  `u_active` tinyint(1) NOT NULL,
  `u_email` varchar(128) NOT NULL,
  `u_password` varchar(80) NOT NULL,

  `u_firstname` varchar(128) NOT NULL,
  `u_lastname` varchar(128) NOT NULL,
  `u_home_phone` varchar(64) DEFAULT NULL,
  `u_mobile` varchar(64) DEFAULT NULL,

  `u_street` varchar(128) DEFAULT NULL,
  `u_zip` varchar(12) DEFAULT NULL,
  `u_city` varchar(128) DEFAULT NULL,

  `u_dob` date DEFAULT NULL,

  `u_ts_create` timestamp DEFAULT NULL,
  `u_ts_update` timestamp NOT NULL,

  PRIMARY KEY (`u_id`),
  UNIQUE KEY `u_email` (`u_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
