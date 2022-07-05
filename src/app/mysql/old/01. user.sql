drop procedure if exists recordLog;
    delimiter $$
    CREATE PROCEDURE recordLog(
        IN _userId INT,
        IN _logName VARCHAR(255),
        IN _description VARCHAR(255))
    BEGIN
        DECLARE _logNameLength INT;
        DECLARE _descriptionLength INT;
        SELECT LENGTH(_logName) INTO _logNameLength;    
        SELECT LENGTH(_description) INTO _descriptionLength;
        IF (_userId > 0 AND _logNameLength > 0 AND _descriptionLength > 0) THEN
            INSERT INTO userlog (userId, logName, description)
            VALUES(_userId, _logName, _description);
        END IF;
    END$$
delimiter;

-- checkUser
drop procedure if exists checkUser;
	delimiter $$
	CREATE PROCEDURE checkUser(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		OUT ID INT, 					
		OUT message VARCHAR(255))		
	BEGIN
		DECLARE _userId INT DEFAULT 0;
		DECLARE _passChecking INT DEFAULT 0;
		DECLARE _blockChecking INT DEFAULT 0;
		
		SELECT DISTINCT userId INTO _userId
		FROM users 
		WHERE username = _name;
		-- check name
		IF (_userId > 0) THEN
			SELECT COUNT(*)  INTO _passChecking
			FROM users
			WHERE  username = _name
			AND password = _pass;
			IF (_passChecking > 0) THEN
				SELECT isBlock INTO _blockChecking
				FROM users
				WHERE  username = _name;
				IF (_blockChecking = 0) THEN
					SET ID = _userId;
					SET message = 'USERNAME FOUND';
				ELSE
					SET message = 'ACCOUNT WAS BLOCKED';
				END IF;			
			ELSE
				SET message = 'WRONG PASSWORD';
			END IF;	
		ELSE
			SET message = 'USERNAME NOT FOUND';
		END IF;
	END$$
delimiter;

-- checkAdmin
drop procedure if exists checkAdmin;
	delimiter $$
	CREATE PROCEDURE checkAdmin(
		IN 	_adminName VARCHAR(255),
		IN 	_Pass VARCHAR(255),
		OUT AdminId INT,				
		OUT message VARCHAR(255))		
	BEGIN	
		DECLARE _passChecking INT DEFAULT 0;
		DECLARE _userId INT DEFAULT 0;
		DECLARE _block INT DEFAULT 0;

		SET message = 'No Authorization';
		SET _userId = 0;		
		
		SELECT DISTINCT userId INTO _userId
		FROM users 
		WHERE username = _adminName
		AND isAdmin = 1; 
		-- Check Name		
		IF (_userId > 0) THEN	
			SET _passChecking = 0;
			SELECT COUNT(*) INTO _passChecking FROM users						
			WHERE password = _Pass AND 	username = _adminName;	
			-- check password
			IF (_passChecking > 0) THEN					
				SELECT isBlock INTO _block FROM users WHERE username = _adminName;	
				-- check block
				IF (_block = 0) THEN
					SET AdminId = _userId;				
					SET message = 'ACCOUNT FOUND';	
				ELSE
					SET message = 'ACCOUNT IS BLOCKED';
				END IF;			
			ELSE
				SET message = 'WRONG PASSWORD';
			END IF;
		ELSE
			SET message = 'ACCOUNT NOT FOUND';
		END IF;
	END$$
delimiter;

-- getList
drop procedure if exists userGetList;
	delimiter $$
	CREATE PROCEDURE userGetList (
		IN _userName VARCHAR(255),
		IN _Pass VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN		
		
		CALL checkAdmin(_userName, _Pass, @Id, @message);
		IF (@Id > 0) THEN
			SELECT *
			FROM users;		
			SET message = 'OK';	
		ELSE
			SET message =  @message;
		END IF;
	END$$
delimiter;

drop procedure if exists userGetInfo;
	delimiter $$
	CREATE PROCEDURE userGetInfo (
		IN _userName VARCHAR(255),
		IN _Pass VARCHAR(255))
	BEGIN	
		SELECT *
		FROM users
		WHERE username = _userName;		
	END$$
delimiter;


drop procedure if exists userAdd;
	delimiter $$
	CREATE PROCEDURE userAdd(
		IN _username VARCHAR(255),
		IN _userpassword VARCHAR(255),
		IN _firstname VARCHAR(255),
		IN _lastname VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		DECLARE _userId INT;
		SET _userId = 0;	
		SET message = 'FAILED';
		-- check lenght of Name					
		SELECT COUNT(*) INTO _userId
		FROM users
		WHERE username = _userName;
		-- check exists
		IF(_userId = 0) THEN
			INSERT INTO users(username, password, firstname, lastname, createdDate)
			VALUES (_username, _userpassword, _firstname, _lastname,  now());
			CALL recordLog(_userId, _username, _username);
			SET message = 'ADD NEW USERNAME';
		ELSE
			SET message = 'USERNAME WAS EXISTS';
		END IF;
	END$$
delimiter;

drop procedure if exists userGroupMemberAdd;
	delimiter $$
	CREATE PROCEDURE userGroupMemberAdd(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _userGroupId		INT,
		IN _member     VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN                
			INSERT INTO usergroupmembers(userGroupId, member, createdDate)
				VALUES(_userGroupId, _member, now());	
			CALL recordLog(@userId, _member, 'Add member');
			SET message = 'ADD Member WAS SUCCESS'; 
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- userUpdate
drop procedure if exists userUpdate;
	delimiter $$
	CREATE PROCEDURE userUpdate(
		IN _userName VARCHAR(255),
		IN _Pass VARCHAR(255),
        IN _userId INT,
		IN _isAdmin INT,
		IN _isBlock INT,
		OUT message VARCHAR(255))
	BEGIN	
		CALL checkAdmin(_userName, _Pass, @adminId, @message);
		IF(@adminId > 0) THEN                
			UPDATE users 
			SET	isAdmin = _isAdmin,
				isBlock = _isBlock
			WHERE userId = _userId;
			CALL recordLog(@adminId, _userName, 'change to isAdmin:' );
			SET message = 'CHANGE USERNAME WAS SUCCESS'; 
		ELSE
			SET message = @message;
		END IF;		
	END$$
delimiter;

drop procedure if exists userDelete;
	delimiter $$
	CREATE PROCEDURE userDelete(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _userId INT,
		OUT message VARCHAR(255))
	BEGIN		
		SET message = 'FAILED';	
		CALL checkAdmin(_name, _pass, @adminId, @message);
		IF (@adminId > 0) THEN
			DELETE FROM users
			WHERE userId = _userId;
			CALL recordLog(@adminId, _userId, CONCAT('delete userId: ',_userId));
			SET message = 'Delete USERNAME';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists googleUserUpdate;
	delimiter $$
	CREATE PROCEDURE googleUserUpdate(
		IN _username VARCHAR(255),
		IN _googleId VARCHAR(255),        
		IN _fullname VARCHAR(255),
		IN _firstName VARCHAR(255),
		IN _lastname VARCHAR(255),
		IN _photo VARCHAR(255),
		IN _googleToken TEXT,
		OUT message VARCHAR(255))
	BEGIN	
		DECLARE _newChecking INT;
		
		SET _newChecking = 0;
		SELECT COUNT(*) INTO _newChecking
		FROM users 
		WHERE username = _username;
	
		IF (_newChecking > 0) THEN
			UPDATE users 
			SET password 	= _googleId,				
				fullname    = _fullname,
				firstName   = _firstName,
				lastname    = _lastname,
				photo       = _photo,
				googleToken = _googleToken
			WHERE username = _username;
			SET message = 'LOGIN AND UPDATE WAS SUCCESS';
		ELSE
			INSERT	INTO users(username, password, fullname, firstname, lastname, photo, googleToken)
			VALUES 			  (_username, _googleId, _fullname, _firstName, _lastname, _photo, _googleToken);
			SET message = 'LOGIN AND ADD INFO WAS SUCCESS';
		END IF;			
	END$$
delimiter;

-- userGroupAddNew
drop procedure if exists userGroupAdd;
	delimiter $$
	CREATE PROCEDURE userGroupAdd(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _addressId		INT,
		IN _groupName     VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN                
			INSERT INTO usergroups(leader, addressId, groupName, createdDate)
				VALUES(@userId, _addressId, _groupName, now());	
			CALL recordLog(@userId, _groupName, 'Add groupName');
			SET message = 'ADD GroupName WAS SUCCESS'; 
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- userGroupUpdate
drop procedure if exists userGroupUpdate;
	delimiter $$
	CREATE PROCEDURE userGroupUpdate(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _userGroupId   INT,
		IN _groupName     VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN                
			UPDATE usergroups 
			SET	groupName = _groupName
			WHERE userGroupId = _userGroupId
			AND leader = @userId;
			CALL recordLog(@userId, _groupName, 'change groupName');
			SET message = 'CHANGE GroupName WAS SUCCESS'; 
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;


drop procedure if exists userGroupDelete;
	delimiter $$
	CREATE PROCEDURE userGroupDelete(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _userGroupId	  INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN
			DELETE FROM usergroups
			WHERE userGroupId = _userGroupId
			AND leader = @userId;
			CALL recordLog(@userId, _userGroupId, 'Delete groupName');
			SET message = 'Delete GroupName WAS SUCCESS';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- chips.js http://localhost/api/Users/apiGetGroup4Select
drop procedure if exists usergroups4SelectByPosition;
	delimiter $$
	CREATE PROCEDURE usergroups4SelectByPosition(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _addressId		INT,
		IN _positionId		INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT 	t1.userGroupId as Id, 
					t1.groupName as Name,
					(SELECT IF(COUNT(x1.userGroupId)>0,'true','false')
						FROM usersharing AS x1
						INNER JOIN positions AS x2 ON x2.positionId = x1.positionId
						WHERE x1.chipOwner = t1.leader
						AND x2.positionId = _positionId
						AND x1.userGroupId = t1.userGroupId) AS selected
			FROM usergroups t1
			WHERE t1.leader = @userId
			AND t1.addressId = _addressId
			Order by Id ASC;
		ELSE
			SET message = @message;
		END IF;	
	END$$
delimiter;


drop procedure if exists usergroupsGetList;
	delimiter $$
	CREATE PROCEDURE usergroupsGetList(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _addressId		INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SELECT *, (SELECT GROUP_CONCAT(t2.member SEPARATOR ', ') FROM usergroupmembers AS t2 WHERE t1.userGroupId = t2.userGroupId) AS members
			FROM usergroups AS t1
			WHERE t1.leader = @userId
			AND t1.addressId = _addressId
			Order by t1.userGroupId ASC;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;


drop procedure if exists userGroupMemberGetList;
	delimiter $$
	CREATE PROCEDURE userGroupMemberGetList(
		IN 	_name VARCHAR(255),
		IN 	_pass VARCHAR(255),
		IN 	_addressId INT,
		OUT message VARCHAR(255)  )
	BEGIN				
		CALL checkUser(_name, _pass, @userId, @message1);
		-- check username
		IF (@userId > 0) THEN
			SELECT 	t1.userGroupMemberId,
					t2.addressId,
					t2.leader,
					t1.userGroupId,
					t2.groupName,
					t1.member
			FROM usergroupmembers as t1
			INNER JOIN usergroups AS t2 ON t1.userGroupId = t2.userGroupId
			WHERE t2.leader = @userId
			AND t2.addressId = _addressId;			
		ELSE
			SET message = @message1;
		END IF;	
	END$$
delimiter;

drop procedure if exists userGroupMemberUpdate;
	delimiter $$
	CREATE PROCEDURE userGroupMemberUpdate(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _userGroupMemberId   INT,
		IN _member     VARCHAR(255),
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN                
			UPDATE usergroupmembers 
			SET	member = _member
			WHERE userGroupMemberId = _userGroupMemberId;
			CALL recordLog(@userId, _member, 'change member name');
			SET message = 'CHANGE Member Name WAS SUCCESS'; 
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

drop procedure if exists userGroupMemberDelete;
	delimiter $$
	CREATE PROCEDURE userGroupMemberDelete(
		IN _name          VARCHAR(255),
		IN _pass          VARCHAR(255),
		IN _userGroupMemberId	  INT,
		OUT message VARCHAR(255))
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF(@userId > 0) THEN
			DELETE FROM usergroupmembers
			WHERE userGroupMemberId = _userGroupMemberId;
			CALL recordLog(@userId, _userGroupMemberId, 'Delete member');
			SET message = 'Delete member WAS SUCCESS';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- chips.js http://localhost/api/Users/apiSharingInfo2Table
drop procedure if exists sharingInfo2Table;
	delimiter $$
	CREATE PROCEDURE sharingInfo2Table(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _addressId INT,
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			select t1.groupName,
					(SELECT GROUP_CONCAT(t2.member SEPARATOR ', ')
						FROM usergroupmembers AS t2
						WHERE t2.userGroupId = t1.userGroupId
						) AS groupMembers
			from usergroups AS t1
			WHERE t1.addressId = _addressId;
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

-- chips.js http://localhost/api/Users/apiSelectedGroupAndMember2Table
drop procedure if exists memberOfUserGroupSelected;
	delimiter $$
	CREATE PROCEDURE memberOfUserGroupSelected(
		IN  _name VARCHAR(255),
		IN  _pass VARCHAR(255),
		IN  _addressId INT,
		IN  _groupList VARCHAR(255),
		OUT message VARCHAR(255) )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			select t1.groupName,
					(SELECT GROUP_CONCAT(t2.member SEPARATOR ',\n')
						FROM usergroupmembers AS t2
						WHERE t2.userGroupId = t1.userGroupId
						) AS groupMembers
			from usergroups AS t1
			WHERE FIND_IN_SET(t1.usergroupId, _groupList)
			AND t1.addressId = _addressId;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--  chip.js http://localhost/api/Users/apiUpdateUserGroupSharing
drop procedure if exists updateUserGroupSharing;
	delimiter $$
	CREATE PROCEDURE updateUserGroupSharing(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _positionId INT,
		IN _userGroupIdList VARCHAR(255),
		OUT message VARCHAR(255)  )
	BEGIN
		DECLARE myGroupIdCount INT DEFAULT 0;
		DECLARE _myGroupId INT DEFAULT 0;
 		DECLARE i INT DEFAULT 0;

		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			SET myGroupIdCount = func_get_split_string_total(_userGroupIdList,',');
			WHILE i < myGroupIdCount DO
				SET i = i + 1;
				SET _myGroupId = func_get_split_string(_userGroupIdList, ',', i);
				IF (_positionId >0) THEN
					INSERT INTO usersharing(positionId, userGroupId, chipOwner, createdDate)
							VALUES(_positionId, _myGroupId, @userId, now());
					CALL recordLog(@userId, CONCAT('userGroupId: ',_myGroupId,', position: ',_positionId), 'Add new userSharing with positionId and usergroupId');
					SET message = 'ADDED DONE'; 									
				END IF;				
			END WHILE;			
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;

--  chip.js http://localhost/api/Users/apiRemoveUserGroupSharing
drop procedure if exists removeUserGroupSharing;
	delimiter $$
	CREATE PROCEDURE removeUserGroupSharing(
		IN _name VARCHAR(255),
		IN _pass VARCHAR(255),
		IN _positionId INT,
		OUT message VARCHAR(255)  )
	BEGIN
		CALL checkUser(_name, _pass, @userId, @message);
		IF (@userId > 0) THEN
			DELETE FROM usersharing
			WHERE chipOwner = @userId
			AND positionId = _positionId;

			CALL recordLog(@userId, CONCAT('position: ', _positionId), 'Remove userSharing with positionId and usergroupId');
			SET message = 'REMOVED DONE';
		ELSE
			SET message = @message;
		END IF;
	END$$
delimiter;
