drop procedure if exists communication_find;
delimiter $$
	CREATE PROCEDURE communication_find(
		IN _findCommunication VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _communicationId INT DEFAULT 0;
        DECLARE _communicationIdCheck INT DEFAULT 0;
		SET ID = _communicationId;
		SELECT COUNT(*) INTO _communicationIdCheck
		FROM `communication_List` 
		WHERE `description` = _findCommunication;

		IF (_communicationIdCheck != 0) THEN
			SELECT `communicationId` INTO _communicationId
			FROM `communication_List` 
			WHERE `description` = _findCommunication;

			SET ID = _communicationId;
			SET message = 'FOUND';
		ELSE
			SET message = 'NOT FOUND';
		END IF;		
	END$$
delimiter;




drop procedure if exists communication_List_Add;
delimiter $$
	CREATE PROCEDURE communication_List_Add(
		IN communication_Description VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN		    
		CALL `communication_find`(communication_Description, @communicationId, @msgCommunicationFind);
		IF (@msgCommunicationFind = 'NOT FOUND') THEN
			INSERT INTO `communication_List`(`description`)
			VALUES(communication_Description);
			SET message = 'COMMUNICATION ADD COMPLETED';
		ELSE
			SET message = 'COMMUNICATION FOUND';
		END IF;	
	END$$
delimiter;