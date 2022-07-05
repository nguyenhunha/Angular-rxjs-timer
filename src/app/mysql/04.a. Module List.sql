drop procedure if exists module_find;
delimiter $$
	CREATE PROCEDURE module_find(		
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _moduleId INT DEFAULT 0;
        DECLARE _moduleIdCheck INT DEFAULT 0;
		SET ID = _moduleId;
		CALL `chip_findCode`(_chipCode, @chipId, @msgChipCode);
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);		

		IF (@chipId != 0 && @customerId != 0) THEN			
			SELECT Count(*) INTO _moduleIdCheck
			FROM module_List 
			WHERE chipId = @chipId
			AND customerId = @customerId;

			IF (_moduleIdCheck != 0) THEN

				SELECT moduleId INTO _moduleId
				FROM module_List 
				WHERE chipId = @chipId
				AND customerId = @customerId;

				SET ID = _moduleId;
				SET message = 'FOUND';
			ELSE
				SET message = 'NOT FOUND';
			END IF;			
		ELSE
			SET message = 'MISSING';
		END IF;				
	END$$
delimiter;

drop procedure if exists module_HardwareInfo_Http_Post;
delimiter $$
	CREATE PROCEDURE module_HardwareInfo_Http_Post(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		IN _userName VARCHAR(255),
        IN _moduleName VARCHAR(255),
        IN _deviceName VARCHAR(255),
		IN _customerPhone1 VARCHAR(255),
		IN _customerPhone2 VARCHAR(255),
		IN _buttonUpName VARCHAR(255),
		IN _buttonStopName VARCHAR(255),
		IN _buttonDownName VARCHAR(255),
		IN _limitSwitchTopName VARCHAR(255),
		IN _limitSwitchBottomName VARCHAR(255),		
		IN _address VARCHAR(255),
		IN _block VARCHAR(255),
		IN _zone VARCHAR(255),
		IN _area VARCHAR(255),
		IN _position VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN        
        CALL `customer_List_Add`( _userName, '', '', @msgCustomerAdd);
                                
        CALL `customer_List_Add`( _customerEmail, _customerPhone1, _customerPhone2, @msgCustomerAdd);

        CALL `chip_List_Add`(_chipCode, @msg);

        CALL `module_List_Add`(_chipCode, _customerEmail, _moduleName, _address,
                        		'', '', '', _position, @chipId, @customerId, @msgModuleAdd); 
        
		CALL `module_find`(_chipCode, _customerEmail, @moduleId, @msgFindName);
        IF (@moduleId != 0) THEN 
			
			CALL `module_Button_List_Find`(@moduleId, _buttonUpName, @buttonId, @buttonState, @msgButton);
			IF (@buttonId = 0) THEN			
				INSERT INTO `module_Button_List`(`moduleId`, `buttonName`, `buttonState`)
				VALUES(@moduleId,  _buttonUpName, 0);
			END IF;
			
			CALL `module_Button_List_Find`(@moduleId, _buttonStopName, @buttonId, @buttonState, @msgButton);
			IF (@buttonId = 0) THEN			
				INSERT INTO `module_Button_List`(`moduleId`, `buttonName`, `buttonState`)
				VALUES(@moduleId,  _buttonStopName, 0);
			END IF;

			CALL `module_Button_List_Find`(@moduleId, _buttonDownName, @buttonId, @buttonState, @msgButton);
			IF (@buttonId = 0) THEN			
				INSERT INTO `module_Button_List`(`moduleId`, `buttonName`, `buttonState`)
				VALUES(@moduleId,  _buttonDownName, 0);
			END IF;

			CALL `module_Button_List_Find`(@moduleId, _limitSwitchTopName, @buttonId, @buttonState, @msgButton);
			IF (@buttonId = 0) THEN			
				INSERT INTO `module_Button_List`(`moduleId`, `buttonName`, `buttonState`)
				VALUES(@moduleId,  _limitSwitchTopName, 0);
			END IF;

			CALL `module_Button_List_Find`(@moduleId, _limitSwitchBottomName, @buttonId, @buttonState, @msgButton);
			IF (@buttonId = 0) THEN			
				INSERT INTO `module_Button_List`(`moduleId`, `buttonName`, `buttonState`)
				VALUES(@moduleId,  _limitSwitchBottomName, 0);
			END IF;

            SET message = 'SUCCESS';
        ELSE
            SET message = 'FAILED';
        END IF;
	END$$
delimiter;

drop procedure if exists module_List_Add;
delimiter $$
	CREATE PROCEDURE module_List_Add(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		IN _moduleName VARCHAR(255),
		IN _address VARCHAR(255),
		IN _zone VARCHAR(255),
		IN _block VARCHAR(255),
		IN _area VARCHAR(255),
		IN _position VARCHAR(255),
		OUT ID1 INT,
		OUT ID2 INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			IF (@msgModule = 'FOUND') THEN
				SET message = 'FOUND';
			ELSE
				INSERT INTO `module_List`(
					`chipId`,
					`customerId`,
					`moduleName`,
					`address`,
					`zone`,
					`block`,
					`area`, 
					`position`)
                VALUES(
					@chipId, 
					@customerId, 
					_moduleName, 
					_address, 
					_zone, 
					_block, 
					_area, 
					_position);
                SET message = 'ADD COMPLETED';
				SET ID1 = @chipId;
				SET ID2 = @customerId;
			END IF;
		ELSE
			SET message = 'CHECK INPUT DATA';
		END IF;
	END$$
delimiter;

