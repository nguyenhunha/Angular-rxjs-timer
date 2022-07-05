drop procedure if exists module_Status_Add;
delimiter $$
	CREATE PROCEDURE module_Status_Add(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		IN _temperature FLOAT,
		IN _humidity FLOAT,
		IN _isClosed INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			IF (@moduleId != 0) THEN
				INSERT INTO `module_Status`(
					`moduleId`,
					`temperature`,
					`humidity`,
					`isClosed`)
                VALUES(
					@moduleId, 
					_temperature, 
					_humidity, 
					_isClosed);

				UPDATE `module_Button_List`
				SET buttonState = _isClosed
				WHERE buttonName = 'Bottom Limit Switch'
				AND moduleId = @moduleId;	

				SET message = 'ADD COMPLETED';	
			ELSE
				SET message = 'NOT FOUND';               
			END IF;
		ELSE
			SET message = 'CHECK INPUT DATA'; 
		END IF;
	END$$
delimiter;


drop procedure if exists module_Status_View;
delimiter $$
	CREATE PROCEDURE module_Status_View(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			IF (@moduleId != 0) THEN
				SELECT * FROM `module_Status`  WHERE `moduleId` = @moduleId ORDER BY reading_time DESC LIMIT 10;
			ELSE
				SET message = 'NOT FOUND';
			END IF;
		ELSE
			SET message = 'NOT FOUND';
		END IF;
	END$$
delimiter;

SELECT * FROM `module_Status` WHERE `moduleId` = 3 ORDER BY reading_time DESC LIMIT 10;