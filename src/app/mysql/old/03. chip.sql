-- 
drop procedure if exists chip4Select;
	delimiter $$
	CREATE PROCEDURE chip4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT chips.chipId as Id, chips.chipCode as Name
      FROM chips
      WHERE chipOwner =  @userId 
			AND chips.chipId NOT IN 
            (SELECT gpiostates.chipId FROM gpiostates 
                        where gpiostates.chipId is not null);
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- http://localhost/api/Boards/apiGetUserChips
drop procedure if exists userChips;
  delimiter $$
  CREATE PROCEDURE userChips(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN   
      CALL checkUser(_Name, _Pass, @userId, @message);
      IF (@userId > 0) THEN    
        SELECT  *,
                -- BOARD AND CHIPS
                (SELECT DISTINCT t2.boardId
                  FROM gpiostates AS t2
                  WHERE t2.chipId = t1.chipId) as boardId,

                (SELECT DISTINCT t3.boardCode
                  FROM gpiostates AS t2
                  INNER JOIN boards AS t3 ON t2.boardId = t3.boardId
                  WHERE t2.chipId = t1.chipId) as boardCode,
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
                    WHERE t2.chipId = t1.chipId
                    ) AS boardSpec,


                -- ADDRESS
                (SELECT DISTINCT t2.addressId
                  FROM gpiostates AS t2
                  INNER JOIN useraddress AS t3 ON t2.addressId = t2.addressId
                  WHERE t2.chipId = t1.chipId) as addressId,

                (SELECT DISTINCT t4.address
                  FROM gpiostates AS t3
                  INNER JOIN useraddress AS t4 ON t3.addressId = t4.addressId
                  WHERE t3.chipId = t1.chipId) as address,               

                --  LOCATION
                (SELECT DISTINCT t3.zoneId
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t3 ON t2.positionId = t3.positionId
                  WHERE t2.chipId = t1.chipId) as zoneId,

                (SELECT DISTINCT t3.zoneName
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t4 ON t4.positionId = t2.positionId
                  INNER JOIN zones AS t3 ON t3.zoneId = t4.zoneId                  
                  WHERE t2.chipId = t1.chipId
                  ) as zoneName,                
                
                (SELECT DISTINCT t3.areaId
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t3 ON t2.positionId = t3.positionId
                  WHERE t2.chipId = t1.chipId) as areaId,
                
                (SELECT DISTINCT t3.areaName
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t4 ON t4.positionId = t2.positionId
                  INNER JOIN areas AS t3 ON t3.areaId = t4.areaId                  
                  WHERE t2.chipId = t1.chipId
                  ) as areaName,                
                (SELECT DISTINCT t3.blockId
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t3 ON t2.positionId = t3.positionId
                  WHERE t2.chipId = t1.chipId) as blockId,
                (SELECT DISTINCT t3.blockName
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t4 ON t4.positionId = t2.positionId
                  INNER JOIN blocks AS t3 ON t3.blockId = t4.blockId                  
                  WHERE t2.chipId = t1.chipId
                  ) as blockName,
                  
                (SELECT DISTINCT t2.positionId
                  FROM gpiostates AS t2
                  WHERE t2.chipId = t1.chipId) as positionId,

                (SELECT DISTINCT t3.positionName
                  FROM gpiostates AS t2
                  INNER JOIN positions AS t3 ON t3.positionId = t2.positionId
                  WHERE t2.chipId = t1.chipId) as positionName,
                -- SHARING
                (SELECT GROUP_CONCAT(DISTINCT x2.groupName SEPARATOR ', ')
                FROM usersharing AS x1
                INNER JOIN usergroups AS x2 ON x2.userGroupId = x1.userGroupId
                INNER JOIN gpiostates AS x3 ON x3.positionId = x1.positionId
                WHERE x3.chipId = t1.chipId) AS sharingInfo

        FROM chips AS t1
        WHERE t1.chipOwner = @userId;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter;



-- 
drop procedure if exists getChips;
  delimiter $$
  CREATE PROCEDURE getChips(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT *
        FROM chips;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter;

-- http://localhost/api/Chips/apiFindChipByCode
drop procedure if exists findChipByCode;
  delimiter $$
  CREATE PROCEDURE findChipByCode(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _chipCode VARCHAR(255),    
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkUser(_Name, _Pass, @userId, @message);
      IF (@userId > 0) THEN    
        SELECT chipId
        FROM chips
        WHERE chipCode = _chipCode
        AND chipOwner = @userId;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter;

-- 
drop procedure if exists chipUpdate;
  delimiter $$
  CREATE PROCEDURE chipUpdate(
    IN  _Name     VARCHAR(255),
    IN  _Pass     VARCHAR(255),
    IN  _chipId   INT    ,
    IN  _boardId  INT    ,
    IN  _chipCode VARCHAR(255),
    IN  _chipSpec VARCHAR(255),
    IN  _isBlock  INT    ,
    OUT message   VARCHAR(255))
  BEGIN
    CALL checkUser(_Name, _Pass, @userId, @message);
    -- Check Admin
    IF(@userId > 0) THEN      
        UPDATE chips
        SET	
            chipCode = _chipCode,
            chipSpec = _chipSpec
        WHERE chipId = _chipId;
        CALL recordLog(@userId, _chipCode, 'Edit chip Spec');    
        SET message = 'Update Done';
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;

-- http://localhost/api/Chips/apiAddUserChip
drop procedure if exists chipAdd;
  delimiter $$
  CREATE PROCEDURE chipAdd(
    IN  _Name     VARCHAR(255),
    IN  _Pass     VARCHAR(255),
    IN  _chipCode VARCHAR(255),
    IN  _chipSpec VARCHAR(255),
    OUT message   VARCHAR(255))
  BEGIN
    CALL checkUser(_Name, _Pass, @userId, @message);
    -- Check Admin
    IF(@userId > 0) THEN      
        INSERT INTO chips(chipCode, chipSpec, chipOwner, createdDate)
                  VALUES(_chipCode, _chipSpec, @userId, now());
        CALL recordLog(@userId, _chipCode, 'Add new chip');    
        SET message = 'Add Done';
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;

-- http://localhost/api/Boards/apiDeleteUserChip
drop procedure if exists chipDelete;
  delimiter $$
  CREATE PROCEDURE chipDelete(
    IN  _Name     VARCHAR(255),
    IN  _Pass     VARCHAR(255),
    IN  _chipId   INT,
    OUT message   VARCHAR(255))
  BEGIN
    CALL checkUser(_Name, _Pass, @userId, @message);
    -- Check Admin
    IF(@userId > 0) THEN      
        DELETE FROM chips 
        WHERE chipId = _chipId
        AND chipOwner = @userID;              
        CALL recordLog(@userId, _chipId, 'Delete chip');    
        SET message = 'Delete Done';
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;