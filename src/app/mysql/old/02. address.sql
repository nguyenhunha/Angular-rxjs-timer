-- Get List
drop procedure if exists countryGetList;
	delimiter $$
	CREATE PROCEDURE countryGetList(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT * 
			FROM countries;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

drop procedure if exists provinceGetList;
	delimiter $$
	CREATE PROCEDURE provinceGetList(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN 	_countryId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT * 
			FROM provinces
			WHERE countryId = _countryId;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

drop procedure if exists districtGetList;
	delimiter $$
	CREATE PROCEDURE districtGetList(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN 	_provinceId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT * 
			FROM districts
			WHERE provinceId = _provinceId;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

drop procedure if exists wardGetList;
	delimiter $$
	CREATE PROCEDURE wardGetList(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN _districtId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message1);
		-- check username
		IF (@userId > 0) THEN			
			SELECT * FROM wards
			WHERE districtId =  _districtId;
		ELSE
			SET message = @message1;
		END IF;	
	END$$
delimiter;

drop procedure if exists addressOfUser;
	delimiter $$
	CREATE PROCEDURE addressOfUser(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN				
		CALL checkUser(_Name, _Pass, @userId, @message1);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	addressId,
					CONCAT( address, ', ', 
					wards.wardName, ', ',
					districts.districtName,	', ',
					provinces.provinceName, ', ',
					countries.countryName) AS address, 
					useraddress.isBlock, 
					useraddress.issuedDate, 
					useraddress.updatedDate			
			FROM useraddress			
			INNER JOIN countries ON useraddress.countryId = countries.countryId
			INNER JOIN provinces ON useraddress.provinceId = provinces.provinceId
			INNER JOIN districts ON useraddress.districtId = districts.districtId
			INNER JOIN wards ON useraddress.wardId = wards.wardId
			WHERE useraddress.chipOwner = @userId;
		ELSE
			SET message = @message1;
		END IF;	
	END$$
delimiter;

-- 4Select
drop procedure if exists country4Select;
	delimiter $$
	CREATE PROCEDURE country4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT countryId as Id, countryName as Name 
			FROM countries;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

drop procedure if exists province4Select;
	delimiter $$
	CREATE PROCEDURE province4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN _countryId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message1);
		-- check username
		IF (@userId > 0) THEN
			SELECT provinceId as Id, provinceName as Name 
			FROM provinces
			WHERE countryId =  _countryId;
		ELSE
			SET message = @message1;
		END IF;	
	END$$
delimiter;

drop procedure if exists district4Select;
	delimiter $$
	CREATE PROCEDURE district4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN  _provinceId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message1);
		-- check username
		IF (@userId > 0) THEN
			SELECT districtId as Id, districtName as Name 
			FROM districts
			WHERE provinceId =  _provinceId;
		ELSE
			SET message = @message1;
		END IF;	
	END$$
delimiter;

-- dialogController.js http://localhost/api/Address/apiGetWards4Select
drop procedure if exists ward4Select;
	delimiter $$
	CREATE PROCEDURE ward4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN  _districtId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT wardId as Id, wardName as Name 
			FROM wards
			WHERE districtId =  _districtId;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

-- http://localhost/api/Address/apiGetUserAddress4Select
drop procedure if exists useraddress4Select;
	delimiter $$
	CREATE PROCEDURE useraddress4Select(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	addressId as Id, 
					address as Name
			FROM useraddress
			WHERE chipOwner =  @userId;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

-- http://localhost/api/Address/apiGetUserAddress4SelectByChip
drop procedure if exists useraddress4SelectByChip;
	delimiter $$
	CREATE PROCEDURE useraddress4SelectByChip(
		IN 	_Name VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		IN _chipId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		-- check username
		IF (@userId > 0) THEN
			SELECT  t1.addressId as Id,
					t1.address as Name,
					(SELECT IF(COUNT(*)>0,'true','false')
						FROM gpiostates AS t2
						WHERE t2.chipId = _chipId
						AND t1.chipOwner = t2.chipOwner
						AND t1.addressId = t2.addressId
					) AS selected
			FROM useraddress AS t1
			WHERE t1.chipOwner =  @userId;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;

-- Update
drop procedure if exists countryUpdate;
	delimiter $$
	CREATE PROCEDURE countryUpdate(
		IN  _Name        VARCHAR(255),
		IN  _Pass        VARCHAR(255),
		IN  _countryId   INT     ,
		IN  _countryName VARCHAR(255),
		IN  _shortName   VARCHAR(255),
		IN  _isBlock     INT     ,
		OUT message      VARCHAR(255) )
	BEGIN
		CALL checkAdmin(_Name, _Pass, @adminId, @message1);
		--check admin
		IF (@adminId > 0) THEN
				UPDATE countries
				SET
					countryName = _countryName,
					shortName   = _shortName,
					isBlock     = _isBlock,
					updatedBy   = @adminId
				WHERE countryId = _countryId;
				CALL recordLog(@adminId, _countryName, 'update country');  
				SET message = 'UPDATE SUCCESS';
		ELSE
			SET message = @message1;
		END IF;
	END$$
delimiter;

drop procedure if exists provinceUpdate;
	delimiter $$
	CREATE PROCEDURE provinceUpdate(
		IN  _Name        VARCHAR(255),
		IN  _Pass        VARCHAR(255),
		IN  _provinceId   INT     ,
		IN  _provinceName VARCHAR(255),
		IN  _secondName   VARCHAR(255),
		IN  _isBlock     INT     ,
		OUT message      VARCHAR(255) )
	BEGIN
		CALL checkAdmin(_Name, _Pass, @adminId, @message1);
		--check admin
		IF (@adminId > 0) THEN
				UPDATE provinces
				SET
					provinceName = _provinceName,
					secondName   = _secondName,
					isBlock     = _isBlock,
					updatedBy   = @adminId
				WHERE provinceId = _provinceId;
				CALL recordLog(@adminId, _provinceName, 'update province');  
				SET message = 'UPDATE SUCCESS';
		ELSE
			SET message = @message1;
		END IF;
	END$$
delimiter;

drop procedure if exists districtUpdate;
	delimiter $$
	CREATE PROCEDURE districtUpdate(
		IN  _Name        VARCHAR(255),
		IN  _Pass        VARCHAR(255),
		IN  _districtId   INT     ,
		IN  _districtName VARCHAR(255),
		IN  _isBlock     INT     ,
		OUT message      VARCHAR(255) )
	BEGIN
		CALL checkAdmin(_Name, _Pass, @adminId, @message1);
		--check admin
		IF (@adminId > 0) THEN
				UPDATE districts
				SET
					districtName = _districtName,
					isBlock     = _isBlock,
					updatedBy   = @adminId
				WHERE districtId = _districtId;
				CALL recordLog(@adminId, _districtName, 'update district');  
				SET message = 'UPDATE SUCCESS';
		ELSE
			SET message = @message1;
		END IF;
	END$$
delimiter;

drop procedure if exists wardUpdate;
	delimiter $$
	CREATE PROCEDURE wardUpdate(
		IN  _Name     VARCHAR(255),
		IN  _Pass     VARCHAR(255),
		IN  _wardId   INT    ,
		IN  _wardName VARCHAR(255),
		IN  _isBlock  INT    ,
		OUT message   VARCHAR(255) )
	BEGIN
		CALL checkAdmin(_Name, _Pass, @adminId, @message1);
		--check admin
		IF (@adminId > 0) THEN
				UPDATE wards
				SET
					wardName   = _wardName,
					isBlock = _isBlock,
					updatedBy  = @adminId
				WHERE wardId = _wardId;
				CALL recordLog(@adminId, _wardName, 'update ward');  
				SET message = 'UPDATE SUCCESS';
		ELSE
			SET message = @message1;
		END IF;
	END$$
delimiter;

-- Add address

drop procedure if exists useraddressAdd;
	delimiter $$
	CREATE PROCEDURE useraddressAdd(
		IN  _Name     VARCHAR(255),
		IN  _Pass     VARCHAR(255),
		IN  _address VARCHAR(255),
		IN  _countryId  INT,
		IN  _provinceId  INT,
		IN  _districtId  INT,
		IN  _wardId  INT,
		OUT message   VARCHAR(255) )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		--check admin
		IF (@userId > 0) THEN
			INSERT INTO useraddress(address, countryId, provinceId, districtId, wardId, chipOwner, issuedDate)
			VALUES 			(_address, _countryId, _provinceId, _districtId, _wardId, @userId, now());
			
			CALL recordLog(@userId, _address, 'add address');
			SET message = 'ADD SUCCESS';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists useraddressDelete;
	delimiter $$
	CREATE PROCEDURE useraddressDelete(
		IN  _Name     VARCHAR(255),
		IN  _Pass     VARCHAR(255),
		IN  _addressId INT,
		OUT message   VARCHAR(255) )
	BEGIN
		CALL checkUser(_Name, _Pass, @userId, @message);
		--check admin
		IF (@userId > 0) THEN
			DELETE FROM useraddress
			WHERE addressId = _addressId
			AND chipOwner = @userId;
			CALL recordLog(@userId, _addressId, 'Delete address');
			SET message = 'DELETE SUCCESS';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

