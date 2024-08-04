-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 04, 2024 at 06:20 AM
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
(13001, 'SBI', 1, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(13002, 'Fed Bank', 1, 3, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(14001, 'Abraham', 1, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(14002, 'KCCL', 1, 4, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(15001, 'Raw Materials', 1, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(15002, 'Finished Goods', 1, 5, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(16001, 'Employee Advances', 1, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(16002, 'Employee Loans', 1, 6, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21001, 'Accounts Payable', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21002, 'Accrued Liabilities', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21003, 'Nellenkuzhy', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21004, 'KSEB', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
(21005, 'Marian College', 2, 1, NULL, '2024-06-30 05:55:18', NULL, '2024-06-30 05:55:18'),
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
  `mobileNo` int(11) DEFAULT NULL,
  `email` varchar(254) DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDateTime` timestamp NOT NULL DEFAULT current_timestamp(),
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDateTime` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(25, 2, 13001, NULL, 'paying from sbi', 0.00, 200.00, NULL, '2024-08-02 14:48:44', NULL, '2024-08-02 14:48:44');

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
(30, '2024-11-12', 'trip to buzan', NULL, '2024-08-02 15:40:09', NULL, '2024-08-02 15:40:09');

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
  `Phone` varchar(11) NOT NULL,
  `email` varchar(254) NOT NULL,
  `username` varchar(12) NOT NULL,
  `password` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users2`
--

INSERT INTO `users2` (`userId`, `Firstname`, `LastName`, `Phone`, `email`, `username`, `password`) VALUES
(1, 'Athul', 'Sebastian', '8921866268', 'athulsebastiant@gmail.com', 'atskingly', '$argon2id$v=19$m=655');

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
-- AUTO_INCREMENT for table `jrlmaster`
--
ALTER TABLE `jrlmaster`
  MODIFY `EntryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users2`
--
ALTER TABLE `users2`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  ADD CONSTRAINT `entity_ibfk_1` FOREIGN KEY (`AccountNo`) REFERENCES `coa` (`AccountNo`),
  ADD CONSTRAINT `entity_ibfk_2` FOREIGN KEY (`name`) REFERENCES `coa` (`AccountName`);

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
(16, 103, 0, 5, 250.00, '2024-07-28 13:14:26');

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
(101, 'Justin Bieber\'s concert', 'JB at Mumbai', '2024-07-31', '21:45:30', 'Mumbai', 'jbconcert.webp', 500, 242, 200.00),
(102, 'Tedx Mumbai', 'Ted talk season 4', '2024-07-31', '21:45:30', 'Mumbai', 'tedx.jpg', 500, 243, 200.00),
(103, 'Stand up with Atul Khatri', 'Renowned comedian Atul Khatri takes the audience for a fun time.', '2024-09-12', '10:17:46', 'Mumbai', 'atulkhatri.jpg', 100, 10, 50.00),
(104, 'IPL - MI vs CSK', 'Mumbai Indians vs Chennai Super Kings', '2024-08-14', '18:36:56', 'Mumbai', 'mi.webp', 600, 445, 400.00);

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
(5, 'Athul Sebastian', 'athulsebastiant@gmail.com', '08921866268', 100.00, 'OR53124169', 'success', 9),
(6, 'Justin', 'jb23@gmail.com', '01234567891', 400.00, 'OR54275688', 'success', 10),
(7, 'Ram', 'rrkabel@gg.com', '7453532325', 400.00, 'OR55547962', 'success', 11),
(8, 'Faf', 'ff@gg.cm', '2121212122121', 150.00, 'OR55739607', 'success', 12),
(9, 'Raju', 'rr@69hh.com', '212121124', 600.00, 'OR56512058', 'success', 13),
(10, 'Athul Sebastian', 'athulsebastiant@gmail.com', '08921866268', 999.99, 'OR51773264', 'success', 14),
(11, 'Athul Sebastian', 'athulsebastiant@gmail.com', '08921866268', 800.00, 'OR52058125', 'success', 15),
(12, 'Athul Sebastian', 'athulsebastiant@gmail.com', '08921866268', 250.00, 'OR52666257', 'success', 16);

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
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_id` (`booking_id`);

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
  MODIFY `booking_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `event_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

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
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `fk_payment_bookings` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
