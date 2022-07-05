drop procedure if exists combinationList;
	delimiter $$
	CREATE PROCEDURE combinationList(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _addressId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT 	DISTINCT 
					gpiostates.addressId 		as addressId,
					useraddress.address      	as address,
					gpiostates.positionId 		as positionId,
					positions.positionName 		as position,
					gpiostates.chipId          as chipId,
					chips.chipCode     			as chipCode,
					gpiostates.boardId         as boardId,
					boards.boardCode    		as boardCode
			FROM gpiostates 
			INNER JOIN useraddress ON useraddress.addressId = gpiostates.addressId
			INNER JOIN positions   ON positions.positionId 	= gpiostates.positionId
			INNER JOIN chips       ON chips.chipId     		= gpiostates.chipId
			INNER JOIN boards      ON boards.boardId    	= gpiostates.boardId
			WHERE gpiostates.chipOwner = @userId
			AND gpiostates.addressId = _addressId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists combinationDelete;
	delimiter $$
	CREATE PROCEDURE combinationDelete(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),		
		IN _addressId INT,
		IN _positionId INT,
		IN _chipId INT,
		IN _boardId INT,	
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM gpiostates
			WHERE chipOwner = @userId
			AND chipId = _chipId
			AND boardId = _boardId
			AND addressId = _addressId
			AND positionId = _positionId;
			CALL recordLog(@userId, _chipId + ", " +  _boardId + ", "  + _addressId + ", " + positionId, 'Destroy Combination');  
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists getChipByPosition;
	delimiter $$
	CREATE PROCEDURE getChipByPosition(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		IN 	_positionId INT,	
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT DISTINCT gpiostates.chipId as Id, chips.chipCode as Name 
			FROM gpiostates
			INNER JOIN chips ON chips.chipId = gpiostates.chipId
			WHERE gpiostates.addressId = _addressId
			AND gpiostates.positionId = _positionId
			AND gpiostates.chipOwner = @userId
			ORDER BY gpiostates.positionId ASC;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists getGPIOByChip;
	delimiter $$
	CREATE PROCEDURE getGPIOByChip(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		IN 	_positionId INT,	
		IN 	_chipId INT,	
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT * 
			FROM gpiostates
			WHERE addressId = _addressId
			AND positionId = _positionId
			AND chipId = _chipId
			AND chipOwner = @userId
			ORDER BY gpio ASC;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists getDashBoardChipByPosition;
	delimiter $$
	CREATE PROCEDURE getDashBoardChipByPosition(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),	
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT DISTINCT 
				gpiostates.chipId as chipId, 
				chips.chipCode as chipCode,
				gpiostates.addressId as addressId, 
				useraddress.address as address,
				gpiostates.positionId as positionId,
				positions.positionName as position
			FROM gpiostates
			INNER JOIN useraddress ON useraddress.addressId = gpiostates.addressId
			INNER JOIN positions   ON positions.positionId 	= gpiostates.positionId
			INNER JOIN chips   ON chips.chipId 	= gpiostates.chipId
			WHERE gpiostates.chipOwner = @userId
			ORDER BY gpiostates.positionId ASC;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists getChip2Config;
	delimiter $$
	CREATE PROCEDURE getChip2Config(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _chipId INT,
		IN _addressId INT,
		IN _positionId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT 	gpioStateId,
					gpio,
					connectionNo,
					connectionName,					
					isLeader,
					isPowerSupply,
					isDisabled,
					securityLevel
			FROM gpiostates
			WHERE chipId = _chipId
			AND addressId = _addressId
			AND positionId =_positionId
			AND chipOwner = @userId
			ORDER BY connectionNo ASC;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- CHECK AND UPDATE STATE
drop procedure if exists getChip2Operate;
	delimiter $$
	CREATE PROCEDURE getChip2Operate(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _chipId INT,
		IN _addressId INT,
		IN _positionId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			CALL gpioCheckIsLeaderOn(_name, _pass, _chipId, @leaderGPIO, @leaderState, @msg);
			SELECT 	gpioStateId,
					chipId,
					gpio,
					connectionNo,
					connectionName,
					state,
					@leaderGPIO 	as leaderGPIO,
					@leaderState 	as leaderState,
					buttonDisabled,
					isPowerSupply,
					securityLevel
			FROM gpiostates
			WHERE chipId = _chipId
			AND addressId = _addressId
			AND positionId =_positionId
			AND chipOwner = @userId
			AND isDisabled = 0
			ORDER BY connectionNo ASC;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpioCheckIsLeaderOn;
	delimiter $$
	CREATE PROCEDURE gpioCheckIsLeaderOn(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _chipId INT,
		OUT leaderGPIO INT,
		OUT leaderState INT,
		OUT message VARCHAR(255))
	BEGIN
		SET leaderGPIO = -1;
		SET leaderState = -1;
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT gpio, state INTO leaderGPIO, leaderState
			FROM gpiostates 
			WHERE chipOwner = @userId
			AND chipId = _chipId
			AND isDisabled = 0
			AND isLeader = 1;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpioStateUserChange;
	delimiter $$
	CREATE PROCEDURE gpioStateUserChange(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _gpioStateId INT,
		IN  _state INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET state = _state
			WHERE chipOwner = @userId
			AND gpioStateId	= _gpioStateId;	

			CALL recordLog(@userId, CONCAT(_gpioStateId, " - ", _state), 'change state:');  

			SET message = 'Updated';		
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpioStateTurnOffAll;
	delimiter $$
	CREATE PROCEDURE gpioStateTurnOffAll(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _chipId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET state = 0
			WHERE chipOwner = @userId
			AND chipId	= _chipId;	
			CALL recordLog(@userId, _chipId, 'Turn Off All Switches');  	

			CALL gpioCheckIsLeaderOn(_name, _pass, _chipId, @leaderGPIO, @leaderState, @msg);

			UPDATE gpiostates
			SET buttonDisabled = 1
			WHERE chipOwner = @userId
			AND chipId	= _chipId
			AND gpio NOT IN (@leaderGPIO);
			CALL recordLog(@userId, _chipId, 'Disable All Sub Switches');
			SET message = 'Turn OFF All';	
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpiostatesetAllReady;
	delimiter $$
	CREATE PROCEDURE gpiostatesetAllReady(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _chipId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET buttonDisabled = 0
			WHERE chipOwner = @userId
			AND chipId	= _chipId;
			CALL recordLog(@userId, _chipId, 'Turn On Main Switches');  
			SET message = 'Set All Ready';	
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists getDashBoardChip2Operate;
	delimiter $$
	CREATE PROCEDURE getDashBoardChip2Operate(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _chipId INT,
		IN _addressId INT,
		IN _positionId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT 	gpioStateId,
					connectionName,
					gpio,
					state,
					isLeader,
					isPowerSupply,
					securityLevel
			FROM gpiostates
			WHERE chipId = _chipId
			AND addressId = _addressId
			AND positionId =_positionId
			AND chipOwner = @chipId;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- http://localhost/api/GPIO/apiCombine2GPIOState
drop procedure if exists combine2gpiostates;
    delimiter $$
    CREATE PROCEDURE combine2gpiostates(
        IN _name VARCHAR(255),
        IN _pass VARCHAR(255),
        IN _chipId INT,
        IN _boardId INT,
        OUT message VARCHAR(255)
    )
    BEGIN
		DECLARE _checkInstalled INT DEFAULT 0;
        CALL checkUser(_name, _pass, @userId, @msg);
		IF (@userId > 0) THEN

			SELECT IF(COUNT(*)>0,'1','0') INTO _checkInstalled
			FROM gpiostates
			WHERE chipId = _chipId
			AND chipOwner = @userId;

			IF (_checkInstalled = 0) THEN
				INSERT INTO gpiostates(
					chipId, 
					boardId, 
					connectionNo,
					connectionName, 
					gpio, 
					chipOwner, 
					createdDate)
				SELECT 
					_chipId, 
					_boardId, 
					connectionNo,
					connectionName, 
					gpio, 
					@userId, 
					now() 
				FROM boardTemplates 
				WHERE boardId = _boardId;
				CALL recordLog(@userId, CONCAT(_chipId ,", ",  _boardId ), 'Add New Combination');  
				SET message = 'ADD NEW DONE';	
			END IF;
        else
            SET message = @msg;
        end if;        
    END$$
delimiter;


drop procedure if exists updateUserChipConfig;
	delimiter $$
	CREATE PROCEDURE updateUserChipConfig(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _gpioStateId INT,
		IN  _connectionNo INT,
		IN  _connectionName VARCHAR(255),
		IN  _gpio INT,
		IN  _isLeader INT,
		IN  _isPowerSupply INT,
		IN  _isDisabled INT,
		IN  _securityLevel INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET     connectionNo   = _connectionNo,
					connectionName = _connectionName,
					gpio           = _gpio,
					isLeader       = _isLeader,
					isPowerSupply  = _isPowerSupply,
					isDisabled     = _isDisabled,
					securityLevel  = _securityLevel
			WHERE chipOwner = @userId
			AND gpioStateId = _gpioStateId;
			CALL recordLog(@userId, _gpioStateId, 'Edit userchip config');  
			SET message = 'DONE';			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpioInfo;
	delimiter $$
    CREATE PROCEDURE gpioInfo(
        IN 	_name VARCHAR(255),
        IN 	_pass VARCHAR(255),
        IN 	_boardId VARCHAR(255),
        OUT message VARCHAR(255)  )
    BEGIN
        CALL checkUser(_name, _pass, @userId, @msg);
		IF (@userId > 0) THEN   
            SELECT *
            FROM gpiostates
            WHERE chipOwner = @userId 
            AND boardId = _boardId;
        ELSE
            SET message = @msg;
        END IF;
    END$$
delimiter;

drop procedure if exists checkChipInstalled;
	delimiter $$
	CREATE PROCEDURE checkChipInstalled(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _chipId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT IF(COUNT(*)>0,'1','0')
			AS result
			FROM gpiostates
			WHERE chipId = _chipId
			AND chipOwner = @userId;			
		ELSE
			SET message = @message;
		END IF;		
	END$$
delimiter;



-- http://localhost/api/GPIO/apiUpdateLocation2GPIOStates
drop procedure if exists updateLocation2GPIOstates;
	delimiter $$
	CREATE PROCEDURE updateLocation2GPIOstates(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _chipId INT,
		IN  _addressId INT,
		IN  _positionId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET     addressId 		   = _addressId,
					positionId 		   = _positionId
			WHERE chipOwner = @userId
			AND 	chipId = _chipId;
			CALL recordLog(@userId, CONCAT('chipId: ', _chipId,' , addressId: ', _addressId, ' , positionId: ', _positionId), 'Update location info to GPIOstates');  				
			SET message = 'Updated Done';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- http://localhost/api/GPIO/apiRemoveLocationFromGPIOStates
drop procedure if exists removeLocationFromGPIOstates;
	delimiter $$
	CREATE PROCEDURE removeLocationFromGPIOstates(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _chipId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			UPDATE gpiostates
			SET addressId  = NULL,
				positionId = NULL
			WHERE chipOwner = @userId
			AND 	chipId = _chipId;
			CALL recordLog(@userId, CONCAT('chipId: ', _chipId,' , addressId: 0 , positionId: 0'), 'Clear location info FROM gpiostates');  				
			SET message = 'Clear Location Info Done';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists gpioUserChipDelete;
	delimiter $$
	CREATE PROCEDURE gpioUserChipDelete(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN _chipId INT,		
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM gpiostates
			WHERE chipId = _chipId
			AND chipOwner = @userId;
			CALL recordLog(@userId, _chipId, 'Remove all gpio of chip');
			SET message = 'REMOVED SUCCESS';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;
