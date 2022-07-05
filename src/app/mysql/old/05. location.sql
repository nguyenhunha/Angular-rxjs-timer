--chips.js: http://localhost/api/Location/apiGetZone4Select
drop procedure if exists zone4Select;
	delimiter $$
	CREATE PROCEDURE zone4Select(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT zoneId as Id, zoneName as Name 
			FROM zones
			WHERE chipOwner =  @userId
			AND addressId = _addressId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetArea4Select
drop procedure if exists area4Select;
	delimiter $$
	CREATE PROCEDURE area4Select(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _zoneId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT areaId as Id, areaName as Name 
			FROM areas
			WHERE chipOwner =  @userId
			AND zoneId = _zoneId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetBlock4Select
drop procedure if exists block4Select;
	delimiter $$
	CREATE PROCEDURE block4Select(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _areaId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT blockId as Id, blockName as Name 
			FROM blocks
			WHERE chipOwner =  @userId
			AND areaId = _areaId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetPosition4Select
drop procedure if exists position4Select;
	delimiter $$
	CREATE PROCEDURE position4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN _addressId INT,
		IN _blockId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT positionId as Id, positionName as Name 
			FROM positions
			WHERE chipOwner =  @userId
			AND addressId = _addressId
			AND blockId = _blockId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetZone4SelectByChip
drop procedure if exists zone4SelectByChip;
	delimiter $$
	CREATE PROCEDURE zone4SelectByChip(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _addressId INT,
		IN  _zoneId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT  t1.zoneId as Id,
					t1.zoneName as Name,
					(SELECT if(COUNT(t2.zoneId)>0,'true','false')
						FROM positions  AS t2
						
						WHERE t2.addressId = t1.addressId
						AND t2.zoneId = _zoneId
						) AS selected
			FROM zones AS t1
			WHERE t1.chipOwner =  @userId
			AND t1.addressId = _addressId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetArea4SelectByChip
drop procedure if exists area4SelectByChip;
	delimiter $$
	CREATE PROCEDURE area4SelectByChip(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _zoneId INT,
		IN _areaId INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	t1.areaId as Id,
					t1.areaName as Name,
					(SELECT IF(COUNT(*)>0,'true','false')
						FROM positions AS t2
						 
						WHERE t2.zoneId = t1.zoneId
						AND t1.areaId = _areaId
						) AS selected
			FROM areas AS t1
			WHERE t1.chipOwner =  @userId
			AND t1.zoneId = _zoneId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;	

--chips.js http://localhost/api/Location/apiGetBlock4SelectByChip
drop procedure if exists block4SelectByChip;
	delimiter $$
	CREATE PROCEDURE block4SelectByChip(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _areaId INT,
		IN _blockId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	t1.blockId as Id, 
					t1.blockName as Name,
					(SELECT IF(COUNT(*)>0,'true','false')
						FROM positions AS t2
						
						WHERE t2.blockId = t1.blockId
						AND t2.areaId = _areaId
						) AS selected
			FROM blocks AS t1
			WHERE t1.chipOwner =  @userId
			AND t1.blockId = _blockId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--chips.js http://localhost/api/Location/apiGetPosition4SelectByChip
drop procedure if exists position4SelectByChip;
	delimiter $$
	CREATE PROCEDURE position4SelectByChip(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN _addressId INT,
		IN _blockId INT,
		IN _position INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	t1.positionId as Id, 
					t1.positionName as Name,
					(SELECT IF(COUNT(*)>0,'true','false')
						FROM positions  AS t2 
						INNER JOIN gpiostates AS t3 ON t2.positionId = t3.positionId
						WHERE t2.addressId = t1.addressId
						AND t2.positionId = t1.positionId
						AND t2.positionId = _position
						) AS selected
			FROM positions AS t1
			WHERE t1.chipOwner =  @userId
			AND t1.addressId = _addressId
			AND blockId = _blockId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- position.js http://localhost/api/Location/apiAddUserZone
drop procedure if exists userZoneAdd;
	delimiter $$
	CREATE PROCEDURE userZoneAdd(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		IN 	_newZone VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			INSERT INTO zones(addressId, zoneName, chipOwner)
			VALUES (_addressId, _newZone, @userId);
			CALL recordLog( @userId, _newZone, 'Add new zone');  
			SET message = 'ADD DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- position.js http://localhost/api/Location/apiAddUserArea
drop procedure if exists userAreaAdd;
	delimiter $$
	CREATE PROCEDURE userAreaAdd(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_referenceId INT,
		IN 	_newName VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			INSERT INTO areas(zoneId, areaName, chipOwner)
			VALUES (_referenceId, _newName, @userId);
			CALL recordLog( @userId, _newName, 'Add new area');  
			SET message = 'ADD DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- position.js http://localhost/api/Location/apiAddUserBlock
drop procedure if exists userBlockAdd;
	delimiter $$
	CREATE PROCEDURE userBlockAdd(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_referenceId INT,
		IN 	_newName VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			INSERT INTO blocks(areaId, blockName, chipOwner)
			VALUES (_referenceId, _newName, @userId);
			CALL recordLog( @userId, _newName, 'Add new block');  
			SET message = 'ADD DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- position.js http://localhost/api/Location/apiAddUserPosition
drop procedure if exists userPositionAdd;
	delimiter $$
	CREATE PROCEDURE userPositionAdd(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		IN 	_zoneId INT,
		IN 	_areaId INT,
		IN 	_blockId INT,
		IN 	_newPosition VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			INSERT INTO positions(addressId, zoneId, areaId, blockId, positionName, chipOwner)
						VALUES (_addressId, _zoneId, _areaId, _blockId, _newPosition, @userId);
			CALL recordLog( @userId, _newPosition, 'Add new position');
			SET message = 'ADD DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- position.js http://localhost/api/Location/apiGetUserPositions
drop procedure if exists positionGetList;
	delimiter $$
	CREATE PROCEDURE positionGetList(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _addressId INT,
		IN _zoneId INT,
		IN _areaId INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT  t1.positionId, 
					t1.positionName, 
					(SELECT GROUP_CONCAT(DISTINCT chipCode SEPARATOR ', ') 
						FROM chips AS t1
						INNER JOIN gpiostates AS t2 ON t1.chipId = t2.chipId
						WHERE t2.positionId = t1.positionId)AS chipCode,

					i1.zoneId as  zoneId, 
					i1.zoneName as  zoneName, 
					i2.areaId as areaId, 
					i2.areaName as areaName, 
					i3.blockId as blockId,
					i3.blockName as blockName,
					(SELECT DISTINCT t3.chipId
						FROM gpiostates AS t2
						INNER JOIN chips as t3 ON t3.chipId = t2.chipId
						WHERE t2.positionId = t1.positionId
						) AS chipId,

					(SELECT DISTINCT t3.chipSpec
						FROM gpiostates AS t2
						INNER JOIN chips as t3 ON t3.chipId = t2.chipId
						WHERE t2.positionId = t1.positionId
						) AS chipSpec,
					(SELECT DISTINCT t3.boardId
						FROM gpiostates AS t2
						INNER JOIN boards as t3 ON t3.boardId = t2.boardId
						WHERE t2.positionId = t1.positionId
						) AS boardId,

					(SELECT DISTINCT t3.boardCode
						FROM gpiostates AS t2
						INNER JOIN boards as t3 ON t3.boardId = t2.boardId
						WHERE t2.positionId = t1.positionId
						) AS boardCode,

					(SELECT DISTINCT CONCAT(
							(select powersupplyName 
								from powersupply s1
								where s1.powerSupplyId = t3.powersupply),
							', connection: ', 
							(select connectionName 
								from connection AS s1
								where s1.connectionId = t3.connection), 
							', gpio Out: ',
							(select gpioOutNo
								from gpioout AS s1
								where s1.gpioOutId = t3.gpioOut),
							' ports, gpio In: ', 
							(select gpioInNo
								from gpioin AS s1
								where s1.gpioInId = t3.gpioIn),
								' ports')
						FROM gpiostates AS t2
						INNER JOIN boards as t3 ON t3.boardId = t2.boardId
						WHERE t2.positionId = t1.positionId
						) AS boardSpec,

						-- SHARING
						(SELECT GROUP_CONCAT(DISTINCT x2.groupName SEPARATOR ', ')
						FROM usersharing AS x1
						INNER JOIN usergroups AS x2 ON x2.userGroupId = x1.userGroupId
						INNER JOIN gpiostates AS x3 ON x3.positionId = x1.positionId
						WHERE x1.positionId = t1.positionId) AS sharingInfo

			FROM positions AS t1
			INNER JOIN zones AS i1 ON t1.zoneId = i1.zoneId
			INNER JOIN areas AS i2 ON t1.areaId = i2.areaId
			INNER JOIN blocks AS i3 ON t1.blockId = i3.blockId			
			WHERE t1.chipOwner =  @userId
			AND t1.addressId = _addressId
			AND t1.zoneId = _zoned
			AND t1.areaId = _areaId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- dialogController.js http://localhost/api/Location/apiDeleteUserZone
drop procedure if exists deleteUserZone;
	delimiter $$
	CREATE PROCEDURE deleteUserZone(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _zoneId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM zones
			WHERE zoneId = _zoneId
			AND chipOwner = @userId;
			CALL recordLog(@userId, _zoneId, 'Delete Zone');  
			SET message = 'DELETED DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- dialogController.js http://localhost/api/Location/apiDeleteUserArea
drop procedure if exists deleteUserArea;
	delimiter $$
	CREATE PROCEDURE deleteUserArea(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _areaId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM areas
			WHERE areaId = _areaId
			AND chipOwner = @userId;
			CALL recordLog(@userId, _areaId, 'Delete Area');  
			SET message = 'DELETED DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- dialogController.js http://localhost/api/Location/apiDeleteUserBlock
drop procedure if exists deleteUserBlock;
	delimiter $$
	CREATE PROCEDURE deleteUserBLock(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _blockId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM blocks
			WHERE blockId = _blockId
			AND chipOwner = @userId;
			CALL recordLog(@userId, _blockId, 'Delete Block');  
			SET message = 'DELETED DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;


SELECT * FROM zones