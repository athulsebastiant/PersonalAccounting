-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 29, 2024 at 05:40 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ac2`
--
CREATE DATABASE IF NOT EXISTS `ac2` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ac2`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `bstest8` ()   BEGIN



CREATE TEMPORARY TABLE assettable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num, AccountID,SPACE(50) as AccountName,SUM(debitAmount- creditAmount) as debit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 1) group by accountID;

UPDATE assettable JOIN COA ON assettable.AccountID = COA.AccountNo SET assettable.AccountName = COA.AccountName;

CREATE TEMPORARY TABLE liatable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(creditAmount - DebitAmount) as credit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 2) group by accountID;

CREATE TEMPORARY TABLE equitytable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(creditAmount - DebitAmount) as credit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 3) group by accountID;

UPDATE equitytable JOIN COA ON equitytable.AccountID = COA.AccountNo SET equitytable.AccountName = COA.AccountName;

UPDATE liatable JOIN COA ON liatable.AccountID = COA.AccountNo SET liatable.AccountName = COA.AccountName;

select sum(credit) into @totalLia from liatable;

insert into liatable (AccountName,credit) values ('Total Liabilities',@totalLia);


SELECT SUM(CREDITAmount-debitAmount) as credit into @profit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 4);

SELECT SUM(DebitAmount-creditAmount) as debit into @loss from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 5);

select @profit - @loss;



insert into equitytable (AccountName,credit) values ('Current year earnings',@profit - @loss);

select sum(credit) into @totalEqu from equitytable;


insert into equitytable (AccountName,credit) values ('Total Equity',@totalEqu );


CREATE TEMPORARY TABLE le SELECT row_num,AccountID,AccountName,credit from liatable UNION SELECT row_num,AccountID,AccountName, credit from equitytable;

select count(accountID) into @rowcount1 from assettable ;

select count(accountID) into @rowcount2 from le ;

SELECT @rowcount1,@rowcount2;

IF @rowcount1 > @rowcount2 THEN
CREATE TEMPORARY TABLE bs SELECT assettable.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from assettable left join le on assettable.row_num = le.row_num;
ELSEIF @rowcount2 > @rowcount1 THEN
CREATE TEMPORARY TABLE bs SELECT le.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from le left join assettable on assettable.row_num = le.row_num;
ELSE
CREATE TEMPORARY TABLE bs SELECT assettable.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from assettable inner join le on assettable.row_num = le.row_num;
END IF;


select sum(debit) into @totalAssets from bs;

select (@totalLia + @totalEqu) into @totalLE;


SELECT @totalLE;


	
INSERT INTO bs(AccountID,AccountName,debit,acName,credit)
values(0,'Total Assets', @totalAssets,'Total Liabilities and Equity',  @totalLE);




UPDATE bs 
set AccountID = 0,AccountName = " ",debit=0
where AccountName IS NULL and AccountID IS NULL and debit is null ;

UPDATE bs
set AccountNo=0,ACNAME = " ",credit=0
where credit IS NULL and ACname IS NULL and accountNo IS NULL;






SELECT * from bs;




END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `bstest80` ()   BEGIN



CREATE TEMPORARY TABLE assettable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num, AccountID,SPACE(50) as AccountName,SUM(debitAmount- creditAmount) as debit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 1) group by accountID;

UPDATE assettable JOIN COA ON assettable.AccountID = COA.AccountNo SET assettable.AccountName = COA.AccountName;

CREATE TEMPORARY TABLE liatable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(creditAmount - DebitAmount) as credit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 2) group by accountID;

CREATE TEMPORARY TABLE equitytable SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(creditAmount - DebitAmount) as credit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 3) group by accountID;

UPDATE equitytable JOIN COA ON equitytable.AccountID = COA.AccountNo SET equitytable.AccountName = COA.AccountName;

UPDATE liatable JOIN COA ON liatable.AccountID = COA.AccountNo SET liatable.AccountName = COA.AccountName;

select sum(credit) into @totalLia from liatable;

insert into liatable (AccountName,credit) values ('Total Liabilities',@totalLia);


SELECT SUM(CREDITAmount-debitAmount) as credit into @profit from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 4);

SELECT SUM(DebitAmount-creditAmount) as debit into @loss from jrldetailed where accountID IN (SELECT accountNo from coa where categoryID = 5);





insert into equitytable (AccountName,credit) values ('Current year earnings',@profit - @loss);

select sum(credit) into @totalEqu from equitytable;


insert into equitytable (AccountName,credit) values ('Total Equity',@totalEqu );


CREATE TEMPORARY TABLE le SELECT row_num,AccountID,AccountName,credit from liatable UNION SELECT row_num,AccountID,AccountName, credit from equitytable;

select count(accountID) into @rowcount1 from assettable ;

select count(accountID) into @rowcount2 from le ;


IF @rowcount1 > @rowcount2 THEN
CREATE TEMPORARY TABLE bs SELECT assettable.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from assettable left join le on assettable.row_num = le.row_num;
ELSEIF @rowcount2 > @rowcount1 THEN
CREATE TEMPORARY TABLE bs SELECT le.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from le left join assettable on assettable.row_num = le.row_num;
ELSE
CREATE TEMPORARY TABLE bs SELECT assettable.row_num,assettable.AccountID,assettable.AccountName,debit,le.accountID as 'accountNo',le.accountName as 'ACname',credit from assettable inner join le on assettable.row_num = le.row_num;
END IF;


select sum(debit) into @totalAssets from bs;

select (@totalLia + @totalEqu) into @totalLE;




	
INSERT INTO bs(AccountID,AccountName,debit,acName,credit)
values(0,'Total Assets', @totalAssets,'Total Liabilities and Equity',  @totalLE);




UPDATE bs 
set AccountID = 0,AccountName = " ",debit=0
where AccountName IS NULL and AccountID IS NULL and debit is null ;

UPDATE bs
set AccountNo=0,ACNAME = " ",credit=0
where credit IS NULL and ACname IS NULL and accountNo IS NULL;






SELECT * from bs;




END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateTrialBalance` ()   BEGIN
  -- Create a temporary table to hold the trial balance data
  CREATE TEMPORARY TABLE trialBalance
  SELECT 
    AccountID,
    SPACE(50) AS AccountName,
    SUM(DebitAmount) AS Debit,
    SUM(CreditAmount) AS Credit
  FROM jrlDetailed
  GROUP BY AccountID;

  -- Update the temporary table to set the AccountName from the COA table
  UPDATE trialBalance 
  JOIN COA ON trialBalance.AccountID = COA.AccountNo 
  SET trialBalance.AccountName = COA.AccountName;

  -- Adjust the Debit and Credit columns in the temporary table
  UPDATE trialBalance 
  SET Debit = Debit - Credit, Credit = 0
  WHERE Debit > Credit;

  UPDATE trialBalance 
  SET Credit = Credit - Debit, Debit = 0
  WHERE Debit <= Credit;

  -- Calculate the totals for Debit and Credit
  SELECT SUM(Debit) INTO @debitTotal FROM trialBalance;
  SELECT SUM(Credit) INTO @creditTotal FROM trialBalance;

  -- Insert the totals row into the temporary table
  INSERT INTO trialBalance (AccountName, Debit, Credit) 
  VALUES ('Total', @debitTotal, @creditTotal);

  -- Select the final trial balance
  SELECT * FROM trialBalance;

  -- Drop the temporary table to clean up
  DROP TEMPORARY TABLE IF EXISTS trialBalance;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `getJrnlList` ()   BEGIN
CREATE TEMPORARY TABLE jrlList
SELECT jrlmaster.EntryID,jdate,jrlmaster.description,jrlmaster.createdBy,jrlmaster.createdDateTime,jrlmaster.modifiedBy,jrlmaster.modifiedDateTime,SUM(jrldetailed.DebitAmount)as 'total'
from jrlmaster
inner join jrldetailed
where jrlmaster.EntryID = jrldetailed.EntryID
group by EntryID;

SELECT * from jrlList;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCOAData` (IN `p_AccountNo` INT, IN `p_AccountName` VARCHAR(255), IN `p_CategoryID` INT, IN `p_SubcategoryID` INT)   BEGIN
    INSERT INTO coa (AccountNo, AccountName, CategoryID, SubcategoryID)
    VALUES (p_AccountNo, p_AccountName, p_CategoryID, p_SubcategoryID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertCOAData2` (IN `p_AccountNo` INT, IN `p_AccountName` VARCHAR(50), IN `p_CategoryID` INT, IN `p_SubcategoryID` INT, OUT `p_status` VARCHAR(10))   BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction in case of an error
        ROLLBACK;
        SET p_status = 'fail';
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert data into the coa table
    INSERT INTO coa (AccountNo, AccountName, CategoryID, SubcategoryID)
    VALUES (p_AccountNo, p_AccountName, p_CategoryID, p_SubcategoryID);

    -- Commit the transaction
    COMMIT;
    SET p_status = 'success';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertEntities` (IN `jsonData` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE jsonLength INT;
    DECLARE entityId VARCHAR(50);
    DECLARE entityType VARCHAR(50);
    DECLARE accountNo VARCHAR(50);
    DECLARE entityName VARCHAR(100);
    DECLARE mobileNo VARCHAR(20);
    DECLARE email VARCHAR(100);

    -- Get the length of the JSON array
    SET jsonLength = JSON_LENGTH(jsonData);

    -- Loop through the JSON array
    WHILE i < jsonLength DO
        -- Extract values from the JSON array
        SET entityId = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].entityId')));
        SET entityType = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].type')));
        SET accountNo = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].account')));
        SET entityName = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].name')));
        SET mobileNo = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].mobile')));
        SET email = JSON_UNQUOTE(JSON_EXTRACT(jsonData, CONCAT('$[', i, '].email')));

        -- Insert the data into the entity table
        INSERT INTO entity(EntityId, type, AccountNo, name, mobileNo, email)
        VALUES (entityId, entityType, accountNo, entityName, mobileNo, email);

        -- Increment the counter
        SET i = i + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pandl3` ()   BEGIN
CREATE TEMPORARY TABLE profittable
SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num, AccountID,SPACE(50) as AccountName,SUM(CREDITAmount-debitAmount) as credit
from jrldetailed
where accountID IN (SELECT accountNo from coa where categoryID = 4) 
group by accountID;

UPDATE profittable
JOIN COA ON profittable.AccountID = COA.AccountNo
SET profittable.AccountName = COA.AccountName;

CREATE TEMPORARY TABLE losstable
SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(DebitAmount-creditAmount) as debit
from jrldetailed
where accountID IN (SELECT accountNo from coa where categoryID = 5)
 group by accountID;

UPDATE losstable
JOIN COA ON losstable.AccountID = COA.AccountNo
SET losstable.AccountName = COA.AccountName;


select count(accountID) into @rowcount1 from profittable ;

select count(accountID) into @rowcount2 from losstable ;

SELECT @rowcount1,@rowcount2;





IF @rowcount1 > @rowcount2 THEN

select 'profit';
CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit, losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit from profittable left join losstable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSEIF @rowcount2 > @rowcount1 THEN

select 'loss';
CREATE TEMPORARY TABLE pl
SELECT losstable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit,losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit 
from losstable
left join profittable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSE
SELECT 'no profit no loss';

CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit,losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit 
from losstable
inner join profittable on profittable.row_num = losstable.row_num order by losstable.row_num;

END IF;

select * from pl;

select sum(debit) into @totalExpense from pl;
select sum(credit) into @totalIncome from pl;
select @totalIncome;
select @totalExpense;

IF @totalIncome >= @totalExpense THEN
	IF @rowcount1 > @rowcount2 THEN
	UPDATE pl
	set lossname = 'Profit', debit = @totalIncome - @totalExpense
	where row = @rowcount2 + 1;
	
	ELSE
	INSERT INTO pl(lossname,debit)
	values('Profit', @totalIncome - @totalExpense);
	END IF;


ELSE
	IF @rowcount1 >= @rowcount2 THEN
	INSERT INTO pl(accountName,credit)
	values('Loss',  @totalExpense - @totalIncome);
	
	ELSE
	update pl
	set Accountname = 'Loss', credit = @totalExpense - @totalIncome
	where row = @rowcount1 + 1;
	END IF;
	

END IF;


UPDATE PL 
set AccountID = 0,AccountName = " ",credit=0
where AccountName IS NULL and AccountID IS NULL and credit IS NULL;

UPDATE PL 
set lossID = 0,lossname = " ",debit = 0
where lossName IS NULL and lossID IS NULL and debit IS NULL;

select * from pl;







END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pandl30` ()   BEGIN
CREATE TEMPORARY TABLE profittable
SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num, AccountID,SPACE(50) as AccountName,SUM(CREDITAmount-debitAmount) as credit
from jrldetailed
where accountID IN (SELECT accountNo from coa where categoryID = 4) 
group by accountID;

UPDATE profittable
JOIN COA ON profittable.AccountID = COA.AccountNo
SET profittable.AccountName = COA.AccountName;

CREATE TEMPORARY TABLE losstable
SELECT ROW_NUMBER() OVER(order BY AccountID) AS row_num,AccountID,SPACE(50) as AccountName,SUM(DebitAmount-creditAmount) as debit
from jrldetailed
where accountID IN (SELECT accountNo from coa where categoryID = 5)
group by accountID;

UPDATE losstable
JOIN COA ON losstable.AccountID = COA.AccountNo
SET losstable.AccountName = COA.AccountName;


select count(accountID) into @rowcount1 from profittable ;

select count(accountID) into @rowcount2 from losstable ;







IF @rowcount1 > @rowcount2 THEN


CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit, losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit from profittable left join losstable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSEIF @rowcount2 > @rowcount1 THEN

CREATE TEMPORARY TABLE pl
SELECT losstable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit,losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit 
from losstable
left join profittable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSE


CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.accountID,profittable.accountName,profittable.credit,losstable.accountID as 'lossid',losstable.accountName as 'lossname',losstable.debit 
from losstable
inner join profittable on profittable.row_num = losstable.row_num order by losstable.row_num;

END IF;


select sum(debit) into @totalExpense from pl;
select sum(credit) into @totalIncome from pl;

IF @totalIncome >= @totalExpense THEN
	IF @rowcount1 > @rowcount2 THEN
	UPDATE pl
	set lossname = 'Profit', debit = @totalIncome - @totalExpense
	where row = @rowcount2 + 1;
	
	ELSE
	INSERT INTO pl(lossname,debit)
	values('Profit', @totalIncome - @totalExpense);
	END IF;


ELSE
	IF @rowcount1 >= @rowcount2 THEN
	INSERT INTO pl(accountName,credit)
	values('Loss',  @totalExpense - @totalIncome);
	
	ELSE
	update pl
	set Accountname = 'Loss', credit = @totalExpense - @totalIncome
	where row = @rowcount1 + 1;
	END IF;
	

END IF;


UPDATE PL 
set AccountID = 0,AccountName = " ",credit=0
where AccountName IS NULL and AccountID IS NULL and credit IS NULL;

UPDATE PL 
set lossID = 0,lossname = " ",debit = 0
where lossName IS NULL and lossID IS NULL and debit IS NULL;

select * from pl;







END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure` (IN `p_jdate` VARCHAR(255), IN `p_description` TEXT, IN `p_entries` JSON)   BEGIN
    -- Declare variables to store the output
    DECLARE v_output TEXT;

    -- Create the output string
    SET v_output = CONCAT(
        'Journal Date: ', p_jdate, '\n',
        'Description: ', p_description, '\n',
        'Entries: ', p_entries
    );

    -- Output the result
    SELECT v_output AS result;

    -- If you want to insert this data into a table, you could do something like this:
    -- (Assuming you have a table named 'journal_entries' with appropriate columns)
    -- INSERT INTO journal_entries (jdate, description, entries)
    -- VALUES (p_jdate, p_description, p_entries);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure1` (IN `p_jdate` DATE, IN `p_description` TEXT, IN `p_entries` JSON)   BEGIN
    DECLARE v_description_id INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_account INT;
    DECLARE v_label VARCHAR(255);
    DECLARE v_debit DECIMAL(10,2);
    DECLARE v_credit DECIMAL(10,2);

    -- Insert into jrlmaster
    INSERT INTO jrlmaster (jdate, `description`, createdDateTime) 
    VALUES (p_jdate, p_description, CURRENT_TIMESTAMP());

    -- Get the last inserted ID
    SET v_description_id = LAST_INSERT_ID();

    -- Loop through the entries JSON array
    WHILE JSON_EXTRACT(p_entries, CONCAT('$[', v_i, ']')) IS NOT NULL DO
        SET v_account = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].account')));
        SET v_label = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].label')));
        SET v_debit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].debit'))) AS 				DECIMAL(10,2)), 0.0);
		SET v_credit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].credit'))) AS 			DECIMAL(10,2)), 0.0);
        -- Insert into jrldetailed
        INSERT INTO jrldetailed (EntryID, LineID, AccountID, `description`, DebitAmount, CreditAmount)
        VALUES (v_description_id, v_i + 1, v_account, v_label, v_debit, v_credit);

        SET v_i = v_i + 1;
    END WHILE;

    -- Output the result
    SELECT CONCAT('Successfully inserted journal entry with ID: ', v_description_id) AS result;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure2` (IN `p_jdate` DATE, IN `p_description` TEXT, IN `p_entries` JSON, OUT `p_status` VARCHAR(20))   BEGIN
    DECLARE v_description_id INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_account INT;
    DECLARE v_label VARCHAR(255);
    DECLARE v_debit DECIMAL(10,2);
    DECLARE v_credit DECIMAL(10,2);

    -- Declare a handler for any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction and set the status to error
        ROLLBACK;
        SET p_status = 'error';
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert into jrlmaster
    INSERT INTO jrlmaster (jdate, description, createdDateTime) 
    VALUES (p_jdate, p_description, CURRENT_TIMESTAMP());

    -- Get the last inserted ID
    SET v_description_id = LAST_INSERT_ID();

    -- Loop through the entries JSON array
    WHILE JSON_EXTRACT(p_entries, CONCAT('$[', v_i, ']')) IS NOT NULL DO
        SET v_account = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].account')));
        SET v_label = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].label')));
        SET v_debit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].debit'))) AS DECIMAL(10,2)), 0.0);
        SET v_credit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].credit'))) AS DECIMAL(10,2)), 0.0);

        -- Insert into jrldetailed
        INSERT INTO jrldetailed (EntryID, LineID, AccountID, description, DebitAmount, CreditAmount)
        VALUES (v_description_id, v_i + 1, v_account, v_label, v_debit, v_credit);

        SET v_i = v_i + 1;
    END WHILE;

    -- If everything is successful, commit the transaction and set success status
    COMMIT;
    SET p_status = 'success';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure3` (IN `p_jdate` DATE, IN `p_description` TEXT, IN `p_entries` JSON, OUT `p_status` VARCHAR(10))   BEGIN
    DECLARE v_description_id INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_account INT;
    DECLARE v_entity INT;
    DECLARE v_label VARCHAR(255);
    DECLARE v_debit DECIMAL(10,2);
    DECLARE v_credit DECIMAL(10,2);

    -- Declare a handler for any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction and set the status to error
        ROLLBACK;
        SET p_status = 'error';
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert into jrlmaster
    INSERT INTO jrlmaster (jdate, description, createdDateTime)
    VALUES (p_jdate, p_description, CURRENT_TIMESTAMP());

    -- Get the last inserted ID
    SET v_description_id = LAST_INSERT_ID();

    -- Loop through the entries JSON array
    WHILE JSON_EXTRACT(p_entries, CONCAT('$[', v_i, ']')) IS NOT NULL DO
        SET v_account = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].account')));
        SET v_entity = JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].entity'));
        SET v_label = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].label')));
        SET v_debit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].debit'))) AS DECIMAL(10,2)), 0.0);
        SET v_credit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].credit'))) AS DECIMAL(10,2)), 0.0);

        -- Handle NULL for EntityID
        IF v_entity IS NULL OR JSON_UNQUOTE(v_entity) = 'null' THEN
            SET v_entity = NULL;
        ELSE
            SET v_entity = CAST(JSON_UNQUOTE(v_entity) AS INT);
        END IF;

        -- Insert into jrldetailed
        INSERT INTO jrldetailed (EntryID, LineID, AccountID, EntityID, description, DebitAmount, CreditAmount)
        VALUES (v_description_id, v_i + 1, v_account, v_entity, v_label, v_debit, v_credit);

        SET v_i = v_i + 1;
    END WHILE;

    -- If everything is successful, commit the transaction and set success status
    COMMIT;
    SET p_status = 'success';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure4` (IN `p_jdate` DATE, IN `p_description` TEXT, IN `p_entries` JSON, OUT `p_status` VARCHAR(10))   BEGIN
    DECLARE v_description_id INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_account INT;
    DECLARE v_entity INT;
    DECLARE v_label VARCHAR(255);
    DECLARE v_debit DECIMAL(10,2);
    DECLARE v_credit DECIMAL(10,2);

    -- Declare a handler for any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction and set the status to error
        ROLLBACK;
        SET p_status = 'error';
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert into jrlmaster
    INSERT INTO jrlmaster (jdate, description, createdDateTime)
    VALUES (p_jdate, p_description, CURRENT_TIMESTAMP());

    -- Get the last inserted ID
    SET v_description_id = LAST_INSERT_ID();

    -- Loop through the entries JSON array
    WHILE JSON_EXTRACT(p_entries, CONCAT('$[', v_i, ']')) IS NOT NULL DO
        SET v_account = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].account')));
        SET v_entity = JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].entity'));
        SET v_label = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].label')));
        SET v_debit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].debit'))) AS DECIMAL(10,2)), 0.0);
        SET v_credit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].credit'))) AS DECIMAL(10,2)), 0.0);

        -- Insert into jrldetailed
        INSERT INTO jrldetailed (EntryID, LineID, AccountID, EntityID, description, DebitAmount, CreditAmount)
        VALUES (v_description_id, v_i + 1, v_account, v_entity, v_label, v_debit, v_credit);

        SET v_i = v_i + 1;
    END WHILE;

    -- If everything is successful, commit the transaction and set success status
    COMMIT;
    SET p_status = 'success';

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `YourStoredProcedure5` (IN `p_jdate` DATE, IN `p_description` TEXT, IN `p_entries` JSON, OUT `p_status` VARCHAR(10))   BEGIN
    DECLARE v_description_id INT;
    DECLARE v_i INT DEFAULT 0;
    DECLARE v_account INT;
    DECLARE v_entity INT;
    DECLARE v_label VARCHAR(255);
    DECLARE v_debit DECIMAL(10,2);
    DECLARE v_credit DECIMAL(10,2);
    DECLARE v_error_message TEXT;

    -- Declare a handler for any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Get the error message
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        
        -- Rollback the transaction and set the status to error
        ROLLBACK;
        SET p_status = CONCAT('error: ', v_error_message);
    END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert into jrlmaster
    INSERT INTO jrlmaster (jdate, description, createdDateTime)
    VALUES (p_jdate, p_description, CURRENT_TIMESTAMP());

    -- Get the last inserted ID
    SET v_description_id = LAST_INSERT_ID();

    -- Loop through the entries JSON array
    WHILE JSON_EXTRACT(p_entries, CONCAT('$[', v_i, ']')) IS NOT NULL DO
        SET v_account = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].account')));
        SET v_entity = NULLIF(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].entity'))), 'null');
        SET v_label = JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].label')));
        SET v_debit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].debit'))) AS DECIMAL(10,2)), 0.0);
        SET v_credit = COALESCE(CAST(JSON_UNQUOTE(JSON_EXTRACT(p_entries, CONCAT('$[', v_i, '].credit'))) AS DECIMAL(10,2)), 0.0);

        -- Insert into jrldetailed
        INSERT INTO jrldetailed (EntryID, LineID, AccountID, EntityID, description, DebitAmount, CreditAmount)
        VALUES (v_description_id, v_i + 1, v_account, v_entity, v_label, v_debit, v_credit);

        SET v_i = v_i + 1;
    END WHILE;

    -- If everything is successful, commit the transaction and set success status
    COMMIT;
    SET p_status = 'success';

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `accountmaster`
--

CREATE TABLE `accountmaster` (
  `CategoryID` int(11) NOT NULL,
  `CategoryName` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accountmaster`
--

INSERT INTO `accountmaster` (`CategoryID`, `CategoryName`) VALUES
(1, 'Asset'),
(3, 'Capital'),
(5, 'Expenses'),
(4, 'Income'),
(2, 'Liabilities');

-- --------------------------------------------------------

--
-- Table structure for table `accountsub`
--

CREATE TABLE `accountsub` (
  `CategoryID` int(11) NOT NULL,
  `SubcategoryID` int(11) NOT NULL,
  `SubcategoryName` varchar(40) NOT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accountsub`
--

INSERT INTO `accountsub` (`CategoryID`, `SubcategoryID`, `SubcategoryName`, `createdBy`, `createdDateTime`, `modifiedBy`, `modifiedDateTime`) VALUES
(1, 1, 'Current Assets', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(1, 2, 'Fixed Assets', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(1, 3, 'Bank and Cash', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(1, 4, 'Accounts Receivable', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(1, 5, 'Inventory', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(1, 6, 'Employee Receivable', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 1, 'Current Liabilities', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 2, 'Long-term Liabilities', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 3, 'Accounts Payable', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 4, 'Short-term Debt', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 5, 'Long-term Debt', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(2, 6, 'Employee Payable', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(3, 1, 'Share Capital', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(3, 2, 'Retained Earnings', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(4, 1, 'Sales Revenue', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(4, 2, 'Service Revenue', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(4, 3, 'Interest Income', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(4, 4, 'Rental Income', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(4, 5, 'Stock Market Earnings', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 1, 'General Expenses', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 2, 'Salaries and Wages', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 3, 'Rent Expense', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 4, 'Utilities Expense', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 5, 'Depreciation Expense', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 6, 'Cost of Goods Sold (COGS)', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 7, 'Food Expenses', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 8, 'Transportation Expenses', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(5, 9, 'Donation', NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18');

-- --------------------------------------------------------

--
-- Table structure for table `coa`
--

CREATE TABLE `coa` (
  `AccountNo` int(11) NOT NULL,
  `AccountName` varchar(50) NOT NULL,
  `CategoryID` int(11) NOT NULL,
  `SubcategoryID` int(11) NOT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coa`
--

INSERT INTO `coa` (`AccountNo`, `AccountName`, `CategoryID`, `SubcategoryID`, `createdBy`, `createdDateTime`, `modifiedBy`, `modifiedDateTime`) VALUES
(11001, 'Cash', 1, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(11002, 'Accounts Receivable', 1, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(12001, 'Office Equipment', 1, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(12002, 'Machinery', 1, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(12003, 'Ivory Tusks', 1, 2, NULL, '2024-08-11 16:21:46', NULL, '2024-08-11 16:21:46'),
(13001, 'SBI', 1, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(13002, 'Fed Bank', 1, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(13003, 'Kotak', 1, 3, NULL, '2024-08-11 16:23:36', NULL, '2024-08-11 16:23:36'),
(14001, 'Abraham', 1, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(14002, 'KCCL', 1, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(14003, 'Roshan', 1, 4, NULL, '2024-08-11 16:23:36', NULL, '2024-08-11 16:23:36'),
(15001, 'Raw Materials', 1, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(15002, 'Finished Goods', 1, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(16001, 'Employee Advances', 1, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(16002, 'Employee Loans', 1, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21001, 'Accounts Payable', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21002, 'Accrued Liabilities', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21003, 'Nellenkuzhy', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21004, 'KSEB', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21005, 'Marian College', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21006, 'Open Kitchen', 2, 1, NULL, '2024-08-14 03:10:42', NULL, '2024-08-14 03:10:42'),
(21007, 'Lulu', 2, 1, NULL, '2024-08-14 03:11:56', NULL, '2024-08-14 03:11:56'),
(21008, 'Max', 2, 1, NULL, '2024-08-14 03:11:56', NULL, '2024-08-14 03:11:56'),
(22001, 'Mortgage Payable', 2, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(22002, 'Bonds Payable', 2, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(23001, 'Trade Payables', 2, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(23002, 'Notes Payable', 2, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(24001, 'Short-term Loans', 2, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(24002, 'Overdrafts', 2, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(25001, 'Long-term Loans', 2, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(25002, 'Deferred Tax Liabilities', 2, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(26001, 'Employee Salaries Payable', 2, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(26002, 'Employee Benefits Payable', 2, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(31001, 'Common Stock', 3, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(31002, 'Preferred Stock', 3, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(32001, 'Retained Earnings', 3, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(32002, 'Dividends', 3, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(41001, 'Product Sales', 4, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(42001, 'Service Fees', 4, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(42002, 'Owners Salary', 4, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(43001, 'Interest Earned', 4, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(44001, 'Rental Income', 4, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(45001, 'Stock Market Earnings', 4, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(51001, 'General Expenses', 5, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(51003, 'Gym Membership', 5, 1, NULL, '2024-08-27 14:06:20', NULL, '2024-08-27 14:06:20'),
(51004, 'Therapy Expense', 5, 1, NULL, '2024-08-29 03:39:39', NULL, '2024-08-29 03:39:39'),
(52001, 'Salaries Expense', 5, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(52002, 'Wages Expense', 5, 2, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(53001, 'Office Rent', 5, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(54001, 'Electricity Expense', 5, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(54002, 'Water Expense', 5, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(54003, 'Internet Expense', 5, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(55001, 'Depreciation Expense', 5, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(56001, 'COGS', 5, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(57001, 'Food Expenses', 5, 7, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(58001, 'Transportation Expenses', 5, 8, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(59001, 'Donations', 5, 9, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18');

-- --------------------------------------------------------

--
-- Table structure for table `entity`
--

CREATE TABLE `entity` (
  `EntityID` int(11) NOT NULL,
  `type` varchar(20) NOT NULL,
  `AccountNo` int(11) NOT NULL,
  `name` varchar(60) NOT NULL,
  `mobileNo` bigint(20) DEFAULT NULL,
  `email` varchar(254) DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `entity`
--

INSERT INTO `entity` (`EntityID`, `type`, `AccountNo`, `name`, `mobileNo`, `email`, `createdBy`, `createdDateTime`, `modifiedBy`, `modifiedDateTime`) VALUES
(1, 'Supplier', 21007, 'Lulu Hypermart', 8945110987, 'luluhm@outlook.com', NULL, '2024-08-20 04:46:32', NULL, '2024-08-20 04:50:16'),
(2, 'Customer', 14002, 'KCCL Ltd.', 2147483647, 'kcclin@gmail.com', NULL, '2024-08-20 04:46:32', NULL, '2024-08-20 04:46:32'),
(3, 'Customer', 14003, 'Roshan Mathews', 8892421246, 'rm11@gmail.com', NULL, '2024-08-22 03:37:25', NULL, '2024-08-22 03:37:25'),
(4, 'Supplier', 21003, 'Tomy N', 5571236025, 'nn23@gmail.com', NULL, '2024-08-22 03:39:13', NULL, '2024-08-22 03:39:13'),
(5, 'Supplier', 21005, 'Marian College Kuttikkanam', 5166676513, 'mcka@gmail.com', NULL, '2024-08-22 03:43:13', NULL, '2024-08-22 03:43:13');

-- --------------------------------------------------------

--
-- Table structure for table `jrldetailed`
--

CREATE TABLE `jrldetailed` (
  `EntryID` int(11) NOT NULL,
  `LineID` int(11) NOT NULL,
  `AccountID` int(11) NOT NULL,
  `EntityID` int(11) DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  `DebitAmount` decimal(10,2) NOT NULL,
  `CreditAmount` decimal(10,2) NOT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jrldetailed`
--

INSERT INTO `jrldetailed` (`EntryID`, `LineID`, `AccountID`, `EntityID`, `description`, `DebitAmount`, `CreditAmount`, `createdBy`, `createdDateTime`, `modifiedBy`, `modifiedDateTime`) VALUES
(1, 1, 13001, NULL, 'opening balance', 20000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(1, 2, 11001, NULL, 'opening balance', 0.00, 20000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(2, 1, 54001, NULL, 'paying electricity', 1000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(2, 2, 11001, NULL, 'paying electricity', 0.00, 1000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(3, 1, 11001, NULL, 'taking some cash', 3000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(3, 2, 13001, NULL, 'reducing from sbi', 0.00, 3000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(4, 1, 57001, NULL, 'buying food', 200.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(4, 2, 11001, NULL, 'paying for food', 0.00, 200.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(5, 1, 13001, NULL, 'getting money to sbi', 9000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(5, 2, 45001, NULL, 'stock market wins', 0.00, 9000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(6, 1, 54002, NULL, 'pay water bill', 600.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(6, 2, 11001, NULL, 'reducing from cash', 0.00, 600.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(7, 1, 13001, NULL, 'salary to bank', 30000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(7, 2, 42002, NULL, 'salary', 0.00, 30000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(8, 1, 13001, NULL, 'interest to sbi', 100.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(8, 2, 43001, NULL, 'interest', 0.00, 100.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(9, 1, 54003, NULL, 'pay net', 500.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(9, 2, 13001, NULL, 'reducing from sbi', 0.00, 500.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(10, 1, 11001, NULL, 'cash increase', 30000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(10, 2, 21001, NULL, 'payable increase', 0.00, 30000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(11, 1, 54001, NULL, 'current paid', 1000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(11, 2, 21004, NULL, 'liability to kseb', 0.00, 1000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(12, 1, 57001, NULL, 'food paid', 500.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(12, 2, 21003, NULL, 'payment on account', 0.00, 500.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(13, 1, 59001, NULL, 'donation', 36000.00, 0.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(13, 2, 11001, NULL, 'reducing from cash', 0.00, 36000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(25, 1, 57001, NULL, 'buying pizza', 200.00, 0.00, NULL, '2024-08-02 14:48:44', NULL, '2024-08-02 14:48:44'),
(25, 2, 13001, NULL, 'paying from sbi', 0.00, 200.00, NULL, '2024-08-02 14:48:44', NULL, '2024-08-02 14:48:44'),
(31, 1, 13001, NULL, 'int', 200.00, 0.00, NULL, '2024-08-08 05:34:32', NULL, '2024-08-08 05:34:32'),
(31, 2, 43001, NULL, 'int', 0.00, 200.00, NULL, '2024-08-08 05:34:32', NULL, '2024-08-08 05:34:32'),
(32, 1, 12002, NULL, 'buying a machinery', 0.00, 0.00, NULL, '2024-08-11 04:01:05', NULL, '2024-08-11 04:01:05'),
(32, 2, 13001, NULL, 'buying a machinery', 0.00, 0.00, NULL, '2024-08-11 04:01:05', NULL, '2024-08-11 04:01:05'),
(33, 1, 12002, NULL, 'Secondary machinery', 1000.00, 0.00, NULL, '2024-08-11 04:13:12', NULL, '2024-08-11 04:13:12'),
(33, 2, 13001, NULL, 'buying secondary machinery', 0.00, 1000.00, NULL, '2024-08-11 04:13:12', NULL, '2024-08-11 04:13:12'),
(34, 1, 14003, NULL, 'Paying roshan', 500.00, 0.00, NULL, '2024-08-25 04:14:59', NULL, '2024-08-25 04:14:59'),
(34, 2, 13001, NULL, 'Money from Sbi', 0.00, 500.00, NULL, '2024-08-25 04:14:59', NULL, '2024-08-25 04:14:59'),
(35, 1, 14003, NULL, 'Paid roshan', 500.00, 0.00, NULL, '2024-08-25 04:17:01', NULL, '2024-08-25 04:17:01'),
(35, 2, 13001, NULL, 'From SBI', 0.00, 500.00, NULL, '2024-08-25 04:17:01', NULL, '2024-08-25 04:17:01'),
(38, 1, 54001, NULL, 'ee', 300.00, 0.00, NULL, '2024-08-25 05:25:19', NULL, '2024-08-25 05:25:19'),
(38, 2, 21004, NULL, 'kseb', 0.00, 300.00, NULL, '2024-08-25 05:25:19', NULL, '2024-08-25 05:25:19');

-- --------------------------------------------------------

--
-- Table structure for table `jrlmaster`
--

CREATE TABLE `jrlmaster` (
  `EntryID` int(11) NOT NULL,
  `jdate` date DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jrlmaster`
--

INSERT INTO `jrlmaster` (`EntryID`, `jdate`, `description`, `createdBy`, `createdDateTime`, `modifiedBy`, `modifiedDateTime`) VALUES
(1, '2024-01-01', 'opening balance', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(2, '2024-01-01', 'paying electricity', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(3, '2024-01-02', 'taking some cash', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(4, '2024-01-02', 'buying food', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(5, '2024-01-03', 'STock market earnings', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(6, '2024-01-06', 'paying water bill', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(7, '2024-01-07', 'getting salary', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(8, '2024-01-08', 'interest received', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(9, '2024-01-10', 'internet expense', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(10, '2024-01-10', 'took a loan', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(11, '2024-01-11', 'current payment on account', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(12, '2024-01-12', 'food expense on account', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(13, '2024-01-13', 'making a donation', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19'),
(25, '2024-11-12', 'buying pizza', NULL, '2024-08-02 14:48:44', NULL, '2024-08-02 14:48:44'),
(30, '2024-11-12', 'trip to buzan', NULL, '2024-08-02 15:40:09', NULL, '2024-08-02 15:40:09'),
(31, '2024-06-08', 'Sbi interest', NULL, '2024-08-08 05:34:32', NULL, '2024-08-08 05:34:32'),
(32, '2024-08-11', 'Bought machinery', NULL, '2024-08-11 04:01:05', NULL, '2024-08-11 04:01:05'),
(33, '2024-08-11', 'Machinery2', NULL, '2024-08-11 04:13:12', NULL, '2024-08-11 04:13:12'),
(34, '2024-08-25', 'Paying Roshan', NULL, '2024-08-25 04:14:59', NULL, '2024-08-25 04:14:59'),
(35, '2024-08-25', 'Paying Roshan', NULL, '2024-08-25 04:17:01', NULL, '2024-08-25 04:17:01'),
(38, '2024-08-25', 'paying electricity bill', NULL, '2024-08-25 05:25:19', NULL, '2024-08-25 05:25:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userId` int(11) NOT NULL,
  `Firstname` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Phone` varchar(11) NOT NULL,
  `email` varchar(254) NOT NULL,
  `username` varchar(12) NOT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userId`, `Firstname`, `LastName`, `Phone`, `email`, `username`, `password`) VALUES
(33, 'Athul', 'Sebastian', '8921866268', 'athulsebastiant@gmail.com', 'atskings', '$argon2id$v=19$m=65536,t=4,p=1$ZWo0NnVEMThmT2J6ZEROVw$tlY6FiET93nJl7+yEjLMmCuV0OBSn4qGrSl6LkLYnQk'),
(34, 'King', 'Sebastian', '8921866267', 'kingsebastiant@gmail.com', 'atskings2', '$argon2id$v=19$m=65536,t=4,p=1$alcxVVgwM2NKa21MMUp3Mw$G1M48GJZQBi4+xUl3mhyCmX+5vFc5MX+Z2cWN/FqnhY');

-- --------------------------------------------------------

--
-- Table structure for table `users2`
--

CREATE TABLE `users2` (
  `userId` int(11) NOT NULL,
  `Firstname` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Phone` bigint(20) DEFAULT NULL,
  `email` varchar(254) NOT NULL,
  `username` varchar(12) NOT NULL,
  `password` varchar(254) NOT NULL,
  `user_type` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users2`
--

INSERT INTO `users2` (`userId`, `Firstname`, `LastName`, `Phone`, `email`, `username`, `password`, `user_type`) VALUES
(3, 'Gin', 'V', 5786812791, 'gg@ff.a', 'gooboy21', '$argon2id$v=19$m=65536,t=4,p=1$bmdwVlAycVpDcjY3VkpLLg$fZCmDwvQ1fl8/za+FikWEbYQF2eg8ORT3RIt/tY2brQ', 'Admin'),
(4, 'Donny', 'Boss', 6663334578, 'djkhalid@gmail.com', 'DBoss213', '$argon2id$v=19$m=65536,t=4,p=1$ZU9wM2NNUENZMWdqRGpvMA$IZbgBDaYhXL3Oy+X46KB90msaiNHvAiMFbwe0TRDOyU', 'Bookkeeper'),
(5, 'Sardar', 'P', 1320562965, 'spd22@gmail.com', 'spdAudits', '$argon2id$v=19$m=65536,t=4,p=1$THY5dHZreU9tQW5HeXhkeA$k8ag8OfWTuSVr1GG4oXTgBm8YHfrem+38bhtDM37JqA', 'Auditor');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `accountmaster`
--
ALTER TABLE `accountmaster`
  ADD PRIMARY KEY (`CategoryID`),
  ADD UNIQUE KEY `CategoryName` (`CategoryName`);

--
-- Indexes for table `accountsub`
--
ALTER TABLE `accountsub`
  ADD PRIMARY KEY (`CategoryID`,`SubcategoryID`),
  ADD UNIQUE KEY `SubcategoryName` (`SubcategoryName`);

--
-- Indexes for table `coa`
--
ALTER TABLE `coa`
  ADD PRIMARY KEY (`AccountNo`),
  ADD UNIQUE KEY `AccountName` (`AccountName`,`CategoryID`,`SubcategoryID`),
  ADD KEY `CategoryID` (`CategoryID`,`SubcategoryID`);

--
-- Indexes for table `entity`
--
ALTER TABLE `entity`
  ADD PRIMARY KEY (`EntityID`),
  ADD UNIQUE KEY `type` (`type`,`AccountNo`,`name`),
  ADD KEY `AccountNo` (`AccountNo`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `jrldetailed`
--
ALTER TABLE `jrldetailed`
  ADD PRIMARY KEY (`EntryID`,`LineID`),
  ADD KEY `AccountID` (`AccountID`),
  ADD KEY `EntityID` (`EntityID`);

--
-- Indexes for table `jrlmaster`
--
ALTER TABLE `jrlmaster`
  ADD PRIMARY KEY (`EntryID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userId`);

--
-- Indexes for table `users2`
--
ALTER TABLE `users2`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `Phone` (`Phone`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `entity`
--
ALTER TABLE `entity`
  MODIFY `EntityID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `jrlmaster`
--
ALTER TABLE `jrlmaster`
  MODIFY `EntryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users2`
--
ALTER TABLE `users2`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `accountsub`
--
ALTER TABLE `accountsub`
  ADD CONSTRAINT `accountsub_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `accountmaster` (`CategoryID`);

--
-- Constraints for table `coa`
--
ALTER TABLE `coa`
  ADD CONSTRAINT `coa_ibfk_1` FOREIGN KEY (`CategoryID`) REFERENCES `accountmaster` (`CategoryID`),
  ADD CONSTRAINT `coa_ibfk_2` FOREIGN KEY (`CategoryID`,`SubcategoryID`) REFERENCES `accountsub` (`CategoryID`, `SubcategoryID`);

--
-- Constraints for table `entity`
--
ALTER TABLE `entity`
  ADD CONSTRAINT `entity_ibfk_1` FOREIGN KEY (`AccountNo`) REFERENCES `coa` (`AccountNo`);

--
-- Constraints for table `jrldetailed`
--
ALTER TABLE `jrldetailed`
  ADD CONSTRAINT `jrldetailed_ibfk_1` FOREIGN KEY (`EntryID`) REFERENCES `jrlmaster` (`EntryID`),
  ADD CONSTRAINT `jrldetailed_ibfk_2` FOREIGN KEY (`AccountID`) REFERENCES `coa` (`AccountNo`),
  ADD CONSTRAINT `jrldetailed_ibfk_3` FOREIGN KEY (`EntityID`) REFERENCES `entity` (`EntityID`);
--
-- Database: `evm`
--
CREATE DATABASE IF NOT EXISTS `evm` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `evm`;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(10) UNSIGNED NOT NULL,
  `event_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `num_tickets` int(11) NOT NULL,
  `total_price` decimal(10,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `event_id`, `user_id`, `num_tickets`, `total_price`, `created_at`) VALUES
(4, 102, 0, 5, 1000.00, '2024-07-27 08:46:21'),
(5, 101, 0, 5, 1000.00, '2024-07-27 08:47:28'),
(6, 101, 0, 1, 200.00, '2024-07-27 09:01:07'),
(7, 103, 0, 4, 200.00, '2024-07-27 09:06:37'),
(8, 103, 0, 2, 100.00, '2024-07-27 09:33:23'),
(9, 103, 0, 2, 100.00, '2024-07-27 09:35:24'),
(10, 101, 0, 2, 400.00, '2024-07-27 09:54:35'),
(11, 102, 0, 2, 400.00, '2024-07-27 10:15:47'),
(12, 103, 0, 3, 150.00, '2024-07-27 10:18:59'),
(13, 101, 0, 3, 600.00, '2024-07-27 10:31:52'),
(14, 104, 0, 3, 1200.00, '2024-07-28 12:59:33'),
(15, 104, 0, 2, 800.00, '2024-07-28 13:04:18'),
(16, 103, 0, 5, 250.00, '2024-07-28 13:14:26'),
(17, 104, 0, 2, 800.00, '2024-08-07 12:52:42'),
(18, 101, 0, 2, 400.00, '2024-08-21 12:15:16'),
(19, 101, 0, 2, 400.00, '2024-08-21 12:17:02'),
(20, 101, 0, 2, 400.00, '2024-08-21 12:20:37');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `event_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `total_tickets` int(11) NOT NULL,
  `available_tickets` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`event_id`, `title`, `description`, `date`, `time`, `location`, `image`, `total_tickets`, `available_tickets`, `price`) VALUES
(101, 'Justin Bieber\'s concert', 'JB at Mumbai', '2024-09-03', '21:45:30', 'Mumbai', 'jbconcert.webp', 500, 240, 200.00),
(102, 'Tedx Mumbai', 'Ted talk season 4', '2024-09-05', '21:45:30', 'Mumbai', 'tedx.jpg', 500, 243, 200.00),
(103, 'Stand up with Atul Khatri', 'Renowned comedian Atul Khatri takes the audience for a fun time.', '2024-09-12', '10:17:46', 'Mumbai', 'atulkhatri.jpg', 100, 10, 50.00),
(104, 'IPL - MI vs CSK', 'Mumbai Indians vs Chennai Super Kings', '2024-08-14', '18:36:56', 'Mumbai', 'mi.webp', 600, 443, 400.00);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `mobile_number` varchar(255) DEFAULT NULL,
  `payment_amount` decimal(5,2) DEFAULT NULL,
  `order_id` varchar(10) DEFAULT NULL,
  `order_status` varchar(10) DEFAULT NULL,
  `booking_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`id`, `name`, `email`, `mobile_number`, `payment_amount`, `order_id`, `order_status`, `booking_id`) VALUES
(0, 'Lilly', 'lillygeorge0225@gmail.com', '08921866267', 400.00, 'OR23037676', 'success', 20);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(10) UNSIGNED NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `event_id` (`event_id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `event_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`event_id`) REFERENCES `events` (`event_id`);
--
-- Database: `phpmyadmin`
--
CREATE DATABASE IF NOT EXISTS `phpmyadmin` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `phpmyadmin`;

-- --------------------------------------------------------

--
-- Table structure for table `pma__bookmark`
--

CREATE TABLE `pma__bookmark` (
  `id` int(10) UNSIGNED NOT NULL,
  `dbase` varchar(255) NOT NULL DEFAULT '',
  `user` varchar(255) NOT NULL DEFAULT '',
  `label` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `query` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Bookmarks';

-- --------------------------------------------------------

--
-- Table structure for table `pma__central_columns`
--

CREATE TABLE `pma__central_columns` (
  `db_name` varchar(64) NOT NULL,
  `col_name` varchar(64) NOT NULL,
  `col_type` varchar(64) NOT NULL,
  `col_length` text DEFAULT NULL,
  `col_collation` varchar(64) NOT NULL,
  `col_isNull` tinyint(1) NOT NULL,
  `col_extra` varchar(255) DEFAULT '',
  `col_default` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Central list of columns';

-- --------------------------------------------------------

--
-- Table structure for table `pma__column_info`
--

CREATE TABLE `pma__column_info` (
  `id` int(5) UNSIGNED NOT NULL,
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `column_name` varchar(64) NOT NULL DEFAULT '',
  `comment` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `mimetype` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `transformation` varchar(255) NOT NULL DEFAULT '',
  `transformation_options` varchar(255) NOT NULL DEFAULT '',
  `input_transformation` varchar(255) NOT NULL DEFAULT '',
  `input_transformation_options` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Column information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__designer_settings`
--

CREATE TABLE `pma__designer_settings` (
  `username` varchar(64) NOT NULL,
  `settings_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Settings related to Designer';

-- --------------------------------------------------------

--
-- Table structure for table `pma__export_templates`
--

CREATE TABLE `pma__export_templates` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL,
  `export_type` varchar(10) NOT NULL,
  `template_name` varchar(64) NOT NULL,
  `template_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved export templates';

-- --------------------------------------------------------

--
-- Table structure for table `pma__favorite`
--

CREATE TABLE `pma__favorite` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Favorite tables';

-- --------------------------------------------------------

--
-- Table structure for table `pma__history`
--

CREATE TABLE `pma__history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db` varchar(64) NOT NULL DEFAULT '',
  `table` varchar(64) NOT NULL DEFAULT '',
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp(),
  `sqlquery` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='SQL history for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__navigationhiding`
--

CREATE TABLE `pma__navigationhiding` (
  `username` varchar(64) NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_type` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Hidden items of navigation tree';

-- --------------------------------------------------------

--
-- Table structure for table `pma__pdf_pages`
--

CREATE TABLE `pma__pdf_pages` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `page_nr` int(10) UNSIGNED NOT NULL,
  `page_descr` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='PDF relation pages for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__recent`
--

CREATE TABLE `pma__recent` (
  `username` varchar(64) NOT NULL,
  `tables` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Recently accessed tables';

--
-- Dumping data for table `pma__recent`
--

INSERT INTO `pma__recent` (`username`, `tables`) VALUES
('root', '[{\"db\":\"ac2\",\"table\":\"coa\"},{\"db\":\"ac2\",\"table\":\"jrlmaster\"},{\"db\":\"ac2\",\"table\":\"jrldetailed\"},{\"db\":\"ac2\",\"table\":\"entity\"},{\"db\":\"ac2\",\"table\":\"users2\"},{\"db\":\"evm\",\"table\":\"payment\"},{\"db\":\"evm\",\"table\":\"bookings\"},{\"db\":\"evm\",\"table\":\"users\"},{\"db\":\"ac2\",\"table\":\"accountsub\"},{\"db\":\"ac2\",\"table\":\"accountmaster\"}]');

-- --------------------------------------------------------

--
-- Table structure for table `pma__relation`
--

CREATE TABLE `pma__relation` (
  `master_db` varchar(64) NOT NULL DEFAULT '',
  `master_table` varchar(64) NOT NULL DEFAULT '',
  `master_field` varchar(64) NOT NULL DEFAULT '',
  `foreign_db` varchar(64) NOT NULL DEFAULT '',
  `foreign_table` varchar(64) NOT NULL DEFAULT '',
  `foreign_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Relation table';

-- --------------------------------------------------------

--
-- Table structure for table `pma__savedsearches`
--

CREATE TABLE `pma__savedsearches` (
  `id` int(5) UNSIGNED NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `search_name` varchar(64) NOT NULL DEFAULT '',
  `search_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Saved searches';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_coords`
--

CREATE TABLE `pma__table_coords` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `pdf_page_number` int(11) NOT NULL DEFAULT 0,
  `x` float UNSIGNED NOT NULL DEFAULT 0,
  `y` float UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table coordinates for phpMyAdmin PDF output';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_info`
--

CREATE TABLE `pma__table_info` (
  `db_name` varchar(64) NOT NULL DEFAULT '',
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `display_field` varchar(64) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Table information for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__table_uiprefs`
--

CREATE TABLE `pma__table_uiprefs` (
  `username` varchar(64) NOT NULL,
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `prefs` text NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Tables'' UI preferences';

--
-- Dumping data for table `pma__table_uiprefs`
--

INSERT INTO `pma__table_uiprefs` (`username`, `db_name`, `table_name`, `prefs`, `last_update`) VALUES
('root', 'ac2', 'jrldetailed', '{\"sorted_col\":\"`EntryID` ASC, `LineID` ASC\"}', '2024-08-26 07:24:12');

-- --------------------------------------------------------

--
-- Table structure for table `pma__tracking`
--

CREATE TABLE `pma__tracking` (
  `db_name` varchar(64) NOT NULL,
  `table_name` varchar(64) NOT NULL,
  `version` int(10) UNSIGNED NOT NULL,
  `date_created` datetime NOT NULL,
  `date_updated` datetime NOT NULL,
  `schema_snapshot` text NOT NULL,
  `schema_sql` text DEFAULT NULL,
  `data_sql` longtext DEFAULT NULL,
  `tracking` set('UPDATE','REPLACE','INSERT','DELETE','TRUNCATE','CREATE DATABASE','ALTER DATABASE','DROP DATABASE','CREATE TABLE','ALTER TABLE','RENAME TABLE','DROP TABLE','CREATE INDEX','DROP INDEX','CREATE VIEW','ALTER VIEW','DROP VIEW') DEFAULT NULL,
  `tracking_active` int(1) UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Database changes tracking for phpMyAdmin';

-- --------------------------------------------------------

--
-- Table structure for table `pma__userconfig`
--

CREATE TABLE `pma__userconfig` (
  `username` varchar(64) NOT NULL,
  `timevalue` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `config_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User preferences storage for phpMyAdmin';

--
-- Dumping data for table `pma__userconfig`
--

INSERT INTO `pma__userconfig` (`username`, `timevalue`, `config_data`) VALUES
('root', '2024-08-29 03:31:41', '{\"Console\\/Mode\":\"show\",\"Console\\/Height\":-73.01050000000001}');

-- --------------------------------------------------------

--
-- Table structure for table `pma__usergroups`
--

CREATE TABLE `pma__usergroups` (
  `usergroup` varchar(64) NOT NULL,
  `tab` varchar(64) NOT NULL,
  `allowed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='User groups with configured menu items';

-- --------------------------------------------------------

--
-- Table structure for table `pma__users`
--

CREATE TABLE `pma__users` (
  `username` varchar(64) NOT NULL,
  `usergroup` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Users and their assignments to user groups';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pma__central_columns`
--
ALTER TABLE `pma__central_columns`
  ADD PRIMARY KEY (`db_name`,`col_name`);

--
-- Indexes for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `db_name` (`db_name`,`table_name`,`column_name`);

--
-- Indexes for table `pma__designer_settings`
--
ALTER TABLE `pma__designer_settings`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_user_type_template` (`username`,`export_type`,`template_name`);

--
-- Indexes for table `pma__favorite`
--
ALTER TABLE `pma__favorite`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__history`
--
ALTER TABLE `pma__history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `username` (`username`,`db`,`table`,`timevalue`);

--
-- Indexes for table `pma__navigationhiding`
--
ALTER TABLE `pma__navigationhiding`
  ADD PRIMARY KEY (`username`,`item_name`,`item_type`,`db_name`,`table_name`);

--
-- Indexes for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  ADD PRIMARY KEY (`page_nr`),
  ADD KEY `db_name` (`db_name`);

--
-- Indexes for table `pma__recent`
--
ALTER TABLE `pma__recent`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__relation`
--
ALTER TABLE `pma__relation`
  ADD PRIMARY KEY (`master_db`,`master_table`,`master_field`),
  ADD KEY `foreign_field` (`foreign_db`,`foreign_table`);

--
-- Indexes for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `u_savedsearches_username_dbname` (`username`,`db_name`,`search_name`);

--
-- Indexes for table `pma__table_coords`
--
ALTER TABLE `pma__table_coords`
  ADD PRIMARY KEY (`db_name`,`table_name`,`pdf_page_number`);

--
-- Indexes for table `pma__table_info`
--
ALTER TABLE `pma__table_info`
  ADD PRIMARY KEY (`db_name`,`table_name`);

--
-- Indexes for table `pma__table_uiprefs`
--
ALTER TABLE `pma__table_uiprefs`
  ADD PRIMARY KEY (`username`,`db_name`,`table_name`);

--
-- Indexes for table `pma__tracking`
--
ALTER TABLE `pma__tracking`
  ADD PRIMARY KEY (`db_name`,`table_name`,`version`);

--
-- Indexes for table `pma__userconfig`
--
ALTER TABLE `pma__userconfig`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `pma__usergroups`
--
ALTER TABLE `pma__usergroups`
  ADD PRIMARY KEY (`usergroup`,`tab`,`allowed`);

--
-- Indexes for table `pma__users`
--
ALTER TABLE `pma__users`
  ADD PRIMARY KEY (`username`,`usergroup`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pma__bookmark`
--
ALTER TABLE `pma__bookmark`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__column_info`
--
ALTER TABLE `pma__column_info`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__export_templates`
--
ALTER TABLE `pma__export_templates`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__history`
--
ALTER TABLE `pma__history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__pdf_pages`
--
ALTER TABLE `pma__pdf_pages`
  MODIFY `page_nr` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pma__savedsearches`
--
ALTER TABLE `pma__savedsearches`
  MODIFY `id` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;