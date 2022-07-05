drop procedure if exists customer_findEmail;
delimiter $$
	CREATE PROCEDURE customer_findEmail(
		IN _findEmail VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))
	BEGIN		
        DECLARE _customerId INT DEFAULT 0;
        DECLARE _customerIdCheck INT DEFAULT 0;
		SET ID = _customerId;

		SELECT COUNT(*) INTO _customerIdCheck
		FROM customer_List 
		WHERE customerEmail = _findEmail;

		IF (_customerIdCheck = 1) THEN
			SELECT customerId INTO _customerId
			FROM customer_List 
			WHERE customerEmail = _findEmail;

			SET ID = _customerId;
			SET message = 'FOUND';
		ELSE
			SET message = 'NOT FOUND';
		END IF;		
	END$$
delimiter;

drop procedure if exists customer_List_Add;
delimiter $$
	CREATE PROCEDURE customer_List_Add(
		IN _customerEmail VARCHAR(255),
		IN _customerPhone1 VARCHAR(255),
		IN _customerPhone2 VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL `customer_findEmail`(_customerEmail, @customerId, @msgFindCustomer);
		-- check name
		IF (@customerId = 0) THEN
			INSERT INTO customer_List(customerEmail, customerPhone1, customerPhone2)
			VALUES(_customerEmail, _customerPhone1, _customerPhone2);
			SET message = 'CUSTOMER ADD COMPLETED';
		ELSE
			SET message = 'CUSTOMER FOUND';
		END IF;	
	END$$
delimiter;