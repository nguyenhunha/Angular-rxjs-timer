



drop procedure if exists customer_List_Add;
delimiter $$
	CREATE PROCEDURE customer_List_Add(
		IN _customerEmail VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN		
    DECLARE _customerId INT DEFAULT 0;
		SELECT Count(*) INTO _customerId
		FROM customer_List 
		WHERE customerEmail = _customerEmail;
		-- check name
		IF (_customerId = 0) THEN
      INSERT INTO customer_List(customerEmail)
      VALUES(_customerEmail);
      SET message = 'CUSTOMER ADD COMPLETED';
		ELSE
			SET message = 'CUSTOMER FOUND';
		END IF;	
	END$$
delimiter;

SELECT Count(*)
		FROM customer_List 
		WHERE customerEmail = 'btphuongnga@gmail.com';

CALL `customer_List_Add`('btphuongnga@gmail.com', @msg)
select @msg