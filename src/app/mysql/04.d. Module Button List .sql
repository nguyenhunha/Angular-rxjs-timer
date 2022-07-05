drop procedure if exists module_Button_List_Find;
delimiter $$
	CREATE PROCEDURE module_Button_List_Find(		
		IN _moduleId INT,
		IN _buttonName VARCHAR(255),
		OUT ID INT, 	
		OUT STATE INT,				
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _buttonId INT DEFAULT 0;
        DECLARE _buttonIdCheck INT DEFAULT 0;
		SET ID = _buttonId;		

		SELECT Count(*) INTO _buttonIdCheck
		FROM module_Button_List
		WHERE buttonName = _buttonName
		AND moduleId = _moduleId;

		IF (_buttonIdCheck != 0) THEN
			SELECT buttonId INTO _buttonId
			FROM module_Button_List 
			WHERE buttonName = _buttonName
			AND moduleId = _moduleId;

			SET ID = _buttonId;
			SET STATE = 1;
			SET message = 'FOUND';
		ELSE
			SET message = 'NOT FOUND';
		END IF;		
	END$$
delimiter;



drop procedure if exists module_Button_List_AddOrUpdate;
delimiter $$
	CREATE PROCEDURE module_Button_List_AddOrUpdate(
		IN _moduleId INT,
		IN _buttonName VARCHAR(255),
		IN _limitSwitchTopState INT,
		IN _buttonUpState INT,
		IN _buttonDownState INT,
		IN _limitSwitchBottomState INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL `module_Button_List_Find`(_moduleId, _buttonName, @buttonId, @buttonState, @msgCustomer);	
		IF (@buttonId = 0) THEN
			IF (_buttonName = 'Top Limit Switch') THEN
				INSERT INTO `module_Button_List`(
					`moduleId`,
					`buttonName`,
					`buttonState`)
				VALUES(
					_moduleId, 
					_buttonName,
					_limitSwitchTopState);
			END IF;
			IF (_buttonName = 'Up Button') THEN
				INSERT INTO `module_Button_List`(
					`moduleId`,
					`buttonName`,
					`buttonState`)
				VALUES(
					_moduleId, 
					_buttonName,
					_buttonUpState);
			END IF;

			IF (_buttonName = 'Stop Button') THEN
				INSERT INTO `module_Button_List`(
					`moduleId`,
					`buttonName`,
					`buttonState`)
				VALUES(
					_moduleId, 
					_buttonName,
					0);
			END IF;

			IF (_buttonName = 'Down Button') THEN
				INSERT INTO `module_Button_List`(
					`moduleId`,
					`buttonName`,
					`buttonState`)
				VALUES(
					_moduleId, 
					_buttonName,
					_buttonDownState);
			END IF;

			IF (_buttonName = 'Bottom Limit Switch') THEN
				INSERT INTO `module_Button_List`(
					`moduleId`,
					`buttonName`,
					`buttonState`)
				VALUES(
					_moduleId, 
					_buttonName,
					_limitSwitchBottomState);
			END IF;
			SET message = 'ADD COMPLETED';	
		ELSE
			UPDATE `module_Button_List`
			SET buttonState = _limitSwitchTopState
			WHERE buttonName = 'Top Limit Switch'
			AND moduleId = _moduleId;

			UPDATE `module_Button_List`
			SET buttonState = _buttonUpState
			WHERE buttonName = 'Up Button'
			AND moduleId = _moduleId;

			UPDATE `module_Button_List`
			SET buttonState = _buttonDownState
			WHERE buttonName = 'Down Button'
			AND moduleId = _moduleId;	

			UPDATE `module_Button_List`
			SET buttonState = _limitSwitchBottomState
			WHERE buttonName = 'Bottom Limit Switch'
			AND moduleId = _moduleId;	

			SET message = 'UPDATED';             
		END IF;
	END$$
delimiter;


drop procedure if exists module_Button_View_By;
delimiter $$
	CREATE PROCEDURE module_Button_View_By(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			IF (@moduleId != 0) THEN
				SELECT * FROM `module_Button_List`
				WHERE `moduleId` = @moduleId;

				SET message = @msgModule;
			ELSE
				SET message = @msgModule;
			END IF;
		ELSE
			SET message = 'NOT FOUND';
		END IF;
	END$$
delimiter;

