
drop procedure if exists chip_findCode;
delimiter $$
	CREATE PROCEDURE chip_findCode(
		IN _findCode VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _chipId INT DEFAULT 0;
        DECLARE _chipIdCheck INT DEFAULT 0;
		SET ID = _chipId;
		SELECT COUNT(*) INTO _chipIdCheck
		FROM chip_List 
		WHERE chipCode = _findCode;

		IF (_chipIdCheck != 0) THEN
			SELECT chipId INTO _chipId
			FROM chip_List 
			WHERE chipCode = _findCode;

			SET ID = _chipId;
			SET message = 'FOUND';
		ELSE
			SET message = 'NOT FOUND';
		END IF;		
	END$$
delimiter;




drop procedure if exists chip_List_Add;
delimiter $$
	CREATE PROCEDURE chip_List_Add(
		IN _chipCode VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN		    
		CALL `chip_findCode`(_chipCode, @customerId, @msgCustomerFind);
		IF (@msgCustomerFind = 'NOT FOUND') THEN
			INSERT INTO chip_List(chipCode)
			VALUES(_chipCode);
			SET message = 'CHIPCODE ADD COMPLETED';
		ELSE
			SET message = 'CHIPCODE FOUND';
		END IF;	
	END$$
delimiter;

