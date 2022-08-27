ALTER TABLE management_funds
  ADD transactions longtext DEFAULT '[]', 
  ADD isFrozen int(11) DEFAULT 0;

CREATE TABLE IF NOT EXISTS `player_transactions` (
  `id` varchar(50) NOT NULL,
  `isFrozen` int(11) DEFAULT 0,
  `transactions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
  PRIMARY KEY (`id`)
);
