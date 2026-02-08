CREATE TABLE IF NOT EXISTS `owned_vehicles` (
	`owner` varchar(60) NOT NULL,
	`plate` varchar(12) NOT NULL,
	`vehicle` longtext NOT NULL,
	`type` varchar(20) NOT NULL DEFAULT 'car',
	`job` varchar(20) DEFAULT NULL,
	`stored` tinyint(1) NOT NULL DEFAULT 0,
    `lb_garage` varchar(60) DEFAULT 'Main',
    `image` varchar(255) DEFAULT NULL,

	PRIMARY KEY (`plate`)
);

-- Use these if the table already exists but columns are missing
ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `lb_garage` varchar(60) DEFAULT 'Main';
ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `image` varchar(255) DEFAULT NULL;
ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `stored` tinyint(1) NOT NULL DEFAULT 0;
