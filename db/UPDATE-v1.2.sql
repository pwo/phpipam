/* Update version */
UPDATE `settings` set `version` = '1.2';

/* reset db check field and donation */
UPDATE `settings` set `dbverified` = 0, `donate` = 0;

/* add subnetView Setting */
ALTER TABLE `settings` ADD `subnetView` TINYINT  NOT NULL  DEFAULT '0';

/* add 'user' to app_security set */
ALTER TABLE `api` CHANGE `app_security` `app_security` SET('crypt','ssl','user','none')  NOT NULL  DEFAULT 'ssl';

/* add english_US language */
INSERT INTO `lang` (`l_id`, `l_code`, `l_name`) VALUES (NULL, 'en_US', 'English (US)');

/* update the firewallZones table to suit the new layout */
ALTER TABLE `firewallZones` DROP COLUMN `vlanId`, DROP COLUMN `stacked`;

/* add a new table to store subnetId and zoneId */
CREATE TABLE `firewallZoneSubnet` (
  `zoneId` INT NOT NULL COMMENT '',
  `subnetId` INT(11) NOT NULL COMMENT '',
  INDEX `fk_zoneId_idx` (`zoneId` ASC)  COMMENT '',
  INDEX `fk_subnetId_idx` (`subnetId` ASC)  COMMENT '',
  CONSTRAINT `fk_zoneId`
    FOREIGN KEY (`zoneId`)
    REFERENCES `firewallZones` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_subnetId`
    FOREIGN KEY (`subnetId`)
    REFERENCES `subnets` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);

/* cpoy old subnet IDs from firewallZones table into firewallZoneSubnet */
INSERT INTO `firewallZoneSubnet` (zoneId,subnetId) SELECT id AS zoneId,subnetId from `firewallZones`;

/* remove the field subnetId from firewallZones, it's not longer needed */
ALTER TABLE `firewallZones` DROP COLUMN `subnetId`;

/* add fk constrain and index to firewallZoneMappings to automatically remove a mapping if a device has been deleted */
ALTER TABLE `firewallZoneMapping` ADD INDEX `devId_idx` (`deviceId` ASC)  COMMENT '';
ALTER TABLE `firewallZoneMapping` ADD CONSTRAINT `devId` FOREIGN KEY (`deviceId`) REFERENCES `devices` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;