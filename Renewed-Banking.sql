CREATE TABLE IF NOT EXISTS `bank_accounts_new` (
  `id` varchar(50) NOT NULL,
  `amount` int(11) DEFAULT 0,
  `transactions` longtext DEFAULT '[]',
  `auth` longtext DEFAULT '[]',
  `isFrozen` int(11) DEFAULT 0,
  `creator` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `banking_transactions` (
  `identifier` varchar(30) NOT NULL,
  `trans_id` varchar(36) NOT NULL,
  `title` text NOT NULL,
  `amount` int(11) NOT NULL,
  `trans_type` varchar(10) NOT NULL,
  `message` text NOT NULL,
  `receiver` text NOT NULL,
  `issuer` text NOT NULL,
  `time` int(11) NOT NULL,
  PRIMARY KEY (`identifier`,`trans_id`),
  UNIQUE KEY `identifier` (`identifier`,`trans_id`),
  KEY `identifier_2` (`identifier`,`trans_id`)
);