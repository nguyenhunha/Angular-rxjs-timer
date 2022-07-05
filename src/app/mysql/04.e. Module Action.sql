drop procedure if exists module_Action_List_Find;
delimiter $$
	CREATE PROCEDURE module_Action_List_Find(		
		IN _moduleId INT,
		IN _actionDetail VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _actionId INT DEFAULT 0;
        DECLARE _actionIdCheck INT DEFAULT 0;
		SET ID = _actionId;			
		SELECT Count(*) INTO _actionIdCheck
		FROM `module_Action_List` 
		WHERE `actionDetail` = _actionDetail
		AND `moduleId` = _moduleId;

		IF (_actionIdCheck != 0) THEN
			SELECT `actionId` INTO _actionId
			FROM `module_Action_List` 
			WHERE `actionDetail` = _actionDetail
			AND `moduleId` = _moduleId;

			SET ID = _actionId;
			SET message = 'FOUND';
		ELSE
			SET message = 'NOT FOUND';
		END IF;		
	END$$
delimiter;



drop procedure if exists module_Action_List_Add;
delimiter $$
	CREATE PROCEDURE module_Action_List_Add(
		IN _moduleId INT,
		IN _actionDetail VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL `module_Action_List_Find`(_moduleId, _actionDetail, @actionId, @msgAction);
		IF (@msgAction = 'NOT FOUND' ) THEN 			
			INSERT INTO `module_Action_List`(
				`moduleId`,
				`actionDetail`)
			VALUES(
				_moduleId, 
				_actionDetail);
			SET message = 'ADD COMPLETED';	
		ELSE
			SET message = 'FOUND';               
		END IF;
	END$$
delimiter;