drop procedure if exists module_Operating_Add;
delimiter $$
	CREATE PROCEDURE module_Operating_Add(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		IN _userName VARCHAR(255),
		IN _buttonName VARCHAR(255),
		IN _actionDetail VARCHAR(255),
		IN _limitSwitchTopState INT,
		IN _buttonUpState INT,
		IN _buttonStopState INT,
		IN _buttonDownState INT,
		IN _limitSwitchBottomState INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_List_Add`(_userName, '', '', @msgCustomer);		
		
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			CALL `customer_findEmail`(_userName, @userId, @msgCustomer);
			IF (@moduleId != 0 && @userId != 0) THEN
				CALL `module_Button_List_AddOrUpdate`(	@moduleId, _buttonName, 
														_limitSwitchTopState, _buttonUpState, 
														_buttonDownState, _limitSwitchBottomState, @msgButton);
				CALL `module_Action_List_Add`(@moduleId, _actionDetail, @msgAction);
				
				CALL `module_Action_List_Find`(@moduleId , _actionDetail, @actionId, @msgAction);
				CALL `module_Button_List_Find`(@moduleId , _buttonName, @buttonId, @buttonState, @msgButton);
				IF (@buttonId != 0 && @actionId != 0) THEN
					INSERT INTO `module_Operating`(
						`moduleId`,
						`userId`,
						`buttonId`,
						`actionId`,
						`limitSwitchTopState`,
						`buttonUpState`,
						`buttonStopState`,
						`buttonDownState`,
						`limitSwitchBottomState`)
					VALUES(
						@moduleId, 
						@userId, 
						@buttonId, 
						@actionId, 
						_limitSwitchTopState, 
						_buttonUpState, 
						_buttonStopState, 
						_buttonDownState, 
						_limitSwitchBottomState);
					SET message = 'ADD COMPLETED';
				ELSE
					SET message = 'FAILED';
				END IF;				
			ELSE
				SET message = 'NOT FOUND';               
			END IF;
		ELSE
			SET message = 'CHECK INPUT DATA'; 
		END IF;
	END$$
delimiter;


drop procedure if exists module_Operating_By;
delimiter $$
	CREATE PROCEDURE module_Operating_By(
		IN _chipCode VARCHAR(255),
		IN _customerEmail VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgCustomer);
		CALL `chip_findCode`(_chipCode, @chipId, @msgChip);
		IF (@customerId != 0 && @chipId != 0) THEN 
			CALL `module_find`(_chipCode, _customerEmail,  @moduleId, @msgModule);
			IF (@moduleId != 0) THEN
				SELECT 	T4.customerEmail,
						T2.buttonName,
						T3.actionDetail,
						limitSwitchTopState,
						buttonUpState,
						buttonStopState,
						buttonDownState,
						limitSwitchBottomState,
						T1.reading_time
				FROM `module_Operating` AS T1
				INNER JOIN `module_Button_List` AS T2 ON T1.`buttonId` = T2.`buttonId`
				INNER JOIN `module_Action_List` AS T3 ON T1.`actionId` = T3.`actionId`
				INNER JOIN `customer_List` AS T4 ON T1.`userId` = T4.`customerId`
				WHERE T1.`moduleId` = @moduleId
				ORDER BY reading_time DESC
				LIMIT 10;

				SET message = @msgModule;
			ELSE
				SET message = @msgModule;
			END IF;
		ELSE
			SET message = 'NOT FOUND';
		END IF;
	END$$
delimiter;

CALL module_Operating_By('ESP32-D0WDQ6-1-6421788', 'nguyenhuunha@gmail.com', @msg)

SELECT customerEmail 
FROM `customer_List`
WHERE `userId` = 4;