SET foreign_key_checks = 0;
drop table `chip_List`;
drop table `customer_List`;
drop table `module_Action_List`;
drop table `module_Button_list`;
drop table `module_List`;
drop table `module_Status`;
drop table `module_Operating`;
SET foreign_key_checks = 1;

delete from `module_Operating`
delete from `module_Status`
delete from `module_Button_List`
delete from `module_Action_List`
delete from `module_List`
delete from `customer_List`
delete from `chip_List`



CREATE TABLE IF NOT EXISTS `customer_List` (
  `customerId` int(11) NOT NULL AUTO_INCREMENT,
  `customerEmail` varchar(255) NOT NULL,
  `customerPhone1` varchar(255) NULL,
  `customerPhone2` varchar(255) NULL,
  `dateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`customerId`),
  UNIQUE KEY `UK_customerEmail` (`customerEmail`)
); 


CREATE TABLE IF NOT EXISTS `chip_List` (
  `chipId` int(11) NOT NULL AUTO_INCREMENT,
  `chipCode` varchar(255) NOT NULL,
  `dateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`chipId`),
  UNIQUE KEY `UK_chipCode` (`chipCode`)
);

CREATE TABLE IF NOT EXISTS `module_List` (
  `moduleId` int(11) NOT NULL AUTO_INCREMENT,
  `chipId` INT NOT NULL,
  `customerId`   INT NOT NULL,
  `moduleName` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `zone` varchar(255) NOT NULL,
  `block` varchar(255) NOT NULL,
  `area` varchar(255) NOT NULL,
  `position` varchar(255) NOT NULL,
  `dateCreated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`moduleId`),
  FOREIGN KEY (`chipId`) REFERENCES `chip_List` (`chipId`),
  FOREIGN KEY (`customerId`) REFERENCES `customer_List` (`customerId`)
);

CREATE TABLE `module_Status`(
    `moduleId` INT NOT NULL,  
    `temperature` FLOAT,
    `humidity` FLOAT,
    `isClosed` TINYINT,
    `reading_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (`moduleId`) REFERENCES `module_List` (`moduleId`)
);



CREATE TABLE `module_Action_List`(
    `actionId` int(11) NOT NULL AUTO_INCREMENT,
    `moduleId` INT NOT NULL,
    `actionDetail` VARCHAR(255) NOT NULL,
    `reading_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`actionId`),
  FOREIGN KEY (`moduleId`) REFERENCES `module_List` (`moduleId`),
  UNIQUE(`moduleId`, `actionDetail`)
);

CREATE TABLE `module_Button_List`(
    `buttonId` int(11) NOT NULL AUTO_INCREMENT,
    `moduleId` INT NOT NULL,
    `buttonName` VARCHAR(255) NOT NULL,
    `buttonState` TINYINT,
    `reading_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`buttonId`),
  FOREIGN KEY (`moduleId`) REFERENCES `module_List` (`moduleId`),
  UNIQUE(`moduleId`, `buttonName`)
);


CREATE TABLE `module_Operating`(
    `moduleId` INT NOT NULL,
    `userId` INT NOT NULL,
    `buttonId` INT NOT NULL,
    `actionId` INT NOT NULL,
    `limitSwitchTopState` TINYINT NOT NULL,
    `buttonUpState` TINYINT NOT NULL,
    `buttonStopState` TINYINT NOT NULL,
    `buttonDownState` TINYINT NOT NULL,
    `limitSwitchBottomState` TINYINT NOT NULL,
    `reading_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (`moduleId`) REFERENCES `module_List` (`moduleId`),
  FOREIGN KEY (`userId`) REFERENCES `customer_List` (`customerId`),
  FOREIGN KEY (`buttonId`) REFERENCES `module_Button_List` (`buttonId`),
  FOREIGN KEY (`actionId`) REFERENCES `module_Action_List` (`actionId`)
);


