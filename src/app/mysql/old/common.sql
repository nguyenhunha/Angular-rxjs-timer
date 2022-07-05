delimiter //

CREATE PROCEDURE removeProcessed(
    table_name VARCHAR(255), 
    keyField VARCHAR(255), 
    maxId INT, 
    num_rows INT)

BEGIN
  SET @table_name = table_name;
  SET @keyField = keyField;
  SET @maxId = maxId;
  SET @num_rows = num_rows;

  SET @sql_text1 = concat(
      'SELECT MIN(',@keyField,') 
      INTO @a FROM ',@table_name);
  PREPARE stmt1 FROM @sql_text1;
  EXECUTE stmt1;
  DEALLOCATE PREPARE stmt1;

  loop_label:  LOOP

    SET @sql_text2 = concat(
        'SELECT ',@keyField,
        ' INTO @z FROM ',@table_name,
        ' WHERE ',@keyField,' >= ',@a,
        ' ORDER BY ',@keyField,
        ' LIMIT ',@num_rows,',1');


    PREPARE stmt2 FROM @sql_text2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;    

    END LOOP;
END
//

delimiter ;

drop procedure if exists checkTableIsEmpty;
    delimiter $$
    CREATE PROCEDURE checkTableIsEmpty(
        IN 	tableName VARCHAR(255),
        Out X INT)
    BEGIN
        SET @X = 0;
        SET @sqlString = concat(
             'SELECT count(*) INTO ', @X,' FROM ',@tableName);
        PREPARE stmt1 FROM @sqlString;
        EXECUTE stmt1;
        DEALLOCATE PREPARE stmt1;
        SET X = @X;        
    END$$
delimiter;


CALL checkTableIsEmpty('zones', @X);
SELECT @X
SELECT @msg

drop procedure if exists example;
    delimiter $$
    CREATE PROCEDURE example()
    BEGIN
        SELECT *
        FROM boards;
    END$$
delimiter;

CALL example()

select * from zones