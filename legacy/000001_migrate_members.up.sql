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

INSERT INTO list_users SELECT
	u_id, u_active, u_email, CONCAT("old:", u_password),
	u_firstname, u_lastname,
		REGEXP_REPLACE(u_tel, '[^0-9+]', ''),
		REGEXP_REPLACE(u_mobile, '[^0-9+]', ''),
	u_street, u_zip, u_city,

	IF(u_dob > "1900-01-01", u_dob, NULL),

	IF(u_date_join > '1900-01-01', REGEXP_REPLACE(u_date_join, '0(-|$)', '1$1'), NULL), NOW()
FROM legacy.list_members;

UPDATE list_users SET
  u_home_phone = REGEXP_REPLACE(IF(LENGTH(u_home_phone) < 3, NULL, u_home_phone), '^0', '+49'),
  u_mobile     = REGEXP_REPLACE(IF(LENGTH(u_mobile    ) < 3, NULL,     u_mobile), '^0', '+49')
;
