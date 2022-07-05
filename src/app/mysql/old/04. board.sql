-- getBoards
drop procedure if exists boardGetList;
  delimiter $$
  CREATE PROCEDURE boardGetList(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT *
        FROM boards;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter;

-- http://localhost/api/Boards/apiGetBoard4Select
drop procedure if exists board4Select;
  delimiter $$
  CREATE PROCEDURE board4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT boardId as Id, boardCode as Name
        FROM boards;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

-- http://localhost/api/Boards/apiGetBoard4SelectByChip
drop procedure if exists board4SelectByChip;
  delimiter $$
  CREATE PROCEDURE board4SelectByChip(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _boardId INT,
    OUT message VARCHAR(255)  )
  BEGIN
    CALL checkUser(_name, _pass, @userId, @message);
    IF (@userId > 0) THEN
      SELECT  boardId as Id,
              boardCode as Name,
              (SELECT IF(COUNT(*)>0,'true','false')
                FROM gpioStates AS t2
                WHERE t1.boardId = t2.boardId
                AND t1.boardId = _boardId
              ) AS selected
      FROM boards AS t1;      
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;


drop procedure if exists boardType4Select;
  delimiter $$
  CREATE PROCEDURE boardType4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT boardTypeId as Id, boardTypeName as Name
        FROM boardType;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

drop procedure if exists powerSupply4Select;
  delimiter $$
  CREATE PROCEDURE powerSupply4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT powerSupplyId as Id, powerSupplyName as Name
        FROM powerSupply;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

drop procedure if exists connection4Select;
  delimiter $$
  CREATE PROCEDURE connection4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT connectionId as Id, connectionName as Name
        FROM connection;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

drop procedure if exists gpioOut4Select;
  delimiter $$
  CREATE PROCEDURE gpioOut4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT gpioOutId as Id, gpioOutName as Name
        FROM gpioOut;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

drop procedure if exists gpioIn4Select;
  delimiter $$
  CREATE PROCEDURE gpioIn4Select(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkAdmin(_Name, _Pass, @adminId, @message);
      IF (@adminId > 0) THEN    
        SELECT gpioInId as Id, gpioInName as Name
        FROM gpioIn;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

drop procedure if exists boardTemplateGetInfo;
  delimiter $$
  CREATE PROCEDURE boardTemplateGetInfo(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _boardId INT,
    OUT message VARCHAR(255)  )
  BEGIN 
      CALL checkUser(_Name, _Pass, @userId, @message);
      IF (@userId > 0) THEN
        SELECT *
        FROM boardtemplates
        WHERE boardId = _boardId;
      ELSE
        SET message = @message;
      END IF;     
  END$$
delimiter ;

-- boardUpdate
drop procedure if exists boardAdd;
  delimiter $$
  CREATE PROCEDURE boardAdd(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _boardCode VARCHAR(255),
    IN _boardType VARCHAR(255),
    IN _powerSupply VARCHAR(255),
    IN _connection VARCHAR(255),
    IN _gpioOut     VARCHAR(255),
    IN _gpioIn   VARCHAR(255),
    OUT message VARCHAR(255))
  BEGIN
    CALL checkAdmin(_Name, _Pass, @adminId, @message);
    -- Check Admin
    IF(@adminId > 0) THEN      
        INSERT INTO boards(boardCode, boardType, powerSupply, connection, gpioOut, gpioIn, createdBy)
        VALUES            (_boardCode, _boardType, _powerSupply, _connection, _gpioOut, _gpioIn, @adminId);
        CALL recordLog(@adminId, _boardCode, 'Add new board Spec');    
        SET message = 'Add Done';
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;

drop procedure if exists boardUpdate;
  delimiter $$
  CREATE PROCEDURE boardUpdate(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _boardId        INT,
    IN _boardCode VARCHAR(255),
    IN _boardSpec VARCHAR(255),
    IN _isAC        INT,
    IN _powerSupply INT,
    IN _gpioOut     INT,
    IN _gpioInput   INT,
    IN _isBlock   INT,
    OUT message VARCHAR(255))
  BEGIN
    CALL checkAdmin(_Name, _Pass, @adminId, @message);
    -- Check Admin
    IF(@adminId > 0) THEN      
        UPDATE boards
        SET
            boardCode   = _boardCode,
            boardSpec   = _boardSpec,
            isAC        = _isAC,
            powerSupply = _powerSupply,
            gpioOut     = _gpioOut,
            gpioInput   = _gpioInput,
            isBlock     = _isBlock
        WHERE boardId = _boardId;
        CALL recordLog(@adminId, _boardCode, 'Edit board Spec');    
        SET message = 'Update Done';
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;

-- getBoardInfo
drop procedure if exists boardCheckExisted;
  delimiter $$
  CREATE PROCEDURE boardCheckExisted(
    IN _boardCode VARCHAR(255),
    OUT message VARCHAR(255))
  BEGIN      
    DECLARE ID INT DEFAULT 0;
    SELECT DISTINCT boardId 
    INTO ID
    FROM boards
    WHERE boardCode = _boardCode; 
    IF (ID>0) THEN      
      SET message = "FOUND";
    ELSE
      SET message = "NOT FOUND";
    END IF;    
  END$$
delimiter;

drop procedure if exists boardDelete;
  delimiter $$
  CREATE PROCEDURE boardDelete(
    IN _Name VARCHAR(255),
    IN _Pass VARCHAR(255),
    IN _boardId INT,
    OUT message VARCHAR(255))
  BEGIN   
    CALL checkAdmin(_Name, _Pass, @adminId, @message);
    -- Check Admin
    IF(@adminId > 0) THEN
      DELETE FROM boards
      WHERE boardId = _boardId
      AND createdBy = @adminId;
    ELSE
      SET message = @message;
    END IF;
  END$$
delimiter;
