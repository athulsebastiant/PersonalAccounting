-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 30, 2024 at 06:59 AM
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
-- Database: `ac`
--
CREATE DATABASE IF NOT EXISTS `ac` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `ac`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `BStest` ()   BEGIN



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
SELECT jrlmaster.EntryID,jdate,jrlmaster.description,jrlmaster.createdBy,jrlmaster.createdDate,jrlmaster.modifiedBy,jrlmaster.modifiedDate,SUM(jrldetailed.DebitAmount)as 'total'
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
	IF @rowcount1 > @rowcount2 THEN
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
where AccountName IS NULL or AccountID IS NULL or credit IS NULL;

UPDATE PL 
set lossID = 0,lossname = " ",debit = 0
where lossName IS NULL or lossID IS NULL or debit IS NULL;

select * from pl;







END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pandltest3` ()   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `pl` ()   BEGIN
CREATE TEMPORARY TABLE profittable
SELECT ROW_NUMBER() OVER(order BY categoryID) AS row_num, accountsub.categoryID,accountsub.subcategoryID,accountsub.subcategoryName,SUM(CREDITAmount-debitAmount) as credit
from jrldetailed
inner join coa
on coa.AccountNo = jrldetailed.AccountID
INNER JOIN accountsub
on accountsub.CategoryID = coa.CategoryID and accountsub.SubcategoryID = coa.SubcategoryID
where jrldetailed.accountID IN (SELECT accountNo from coa where categoryID = 4) 
group by categoryID,subcategoryID;

CREATE TEMPORARY TABLE losstable
SELECT ROW_NUMBER() OVER(order BY categoryID) AS row_num,accountsub.categoryID,accountsub.subcategoryID,accountsub.subcategoryName,SUM(DebitAmount-creditAmount) as debit
from jrldetailed
inner join coa
on coa.AccountNo = jrldetailed.AccountID
INNER JOIN accountsub
on accountsub.CategoryID = coa.CategoryID and accountsub.SubcategoryID = coa.SubcategoryID
where jrldetailed.accountID IN (SELECT accountNo from coa where categoryID = 5)
 group by categoryID,subcategoryID;


select count(categoryID) into @rowcount1 from profittable ;

select count(categoryID) into @rowcount2 from losstable ;

SELECT @rowcount1,@rowcount2;





IF @rowcount1 > @rowcount2 THEN

select 'profit';
CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.categoryID,profittable.subcategoryID,profittable.subcategoryName,profittable.credit, losstable.categoryID as 'LC',losstable.subcategoryID as 'Lsc',losstable.subcategoryName as 'lossname',losstable.debit from profittable left join losstable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSEIF @rowcount2 > @rowcount1 THEN

select 'loss';
CREATE TEMPORARY TABLE pl
SELECT losstable.row_num as 'row',profittable.categoryID,profittable.subcategoryID,profittable.subcategoryName,profittable.credit,
losstable.categoryID as 'LC',losstable.subcategoryID as 'Lsc',
losstable.subcategoryName as 'lossname',losstable.debit 
from losstable
left join profittable on profittable.row_num = losstable.row_num order by losstable.row_num;


ELSE
SELECT 'no profit no loss';

CREATE TEMPORARY TABLE pl
SELECT profittable.row_num as 'row',profittable.categoryID,profittable.subcategoryID,profittable.subcategoryName,profittable.credit,losstable.categoryID as 'LC',losstable.subcategoryID as 'Lsc',
losstable.subcategoryName  as 'lossname',losstable.debit 
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
	INSERT INTO pl(subcategoryname,credit)
	values('Loss',  @totalExpense - @totalIncome);
	
	ELSE
	update pl
	set subcategoryname = 'Loss', credit = @totalExpense - @totalIncome
	where row = @rowcount1 + 1;
	END IF;
	

END IF;


UPDATE PL 
set categoryID = 0,subcategoryID =0,subcategoryName = " ",credit=0
where subcategoryName IS NULL and categoryID IS NULL and subcategoryID IS NULL and credit IS NULL;

UPDATE PL 
set Lc = 0,lsc =0,lossName = " ",debit = 0
where lossName IS NULL and lc IS NULL and lsc IS NULL and debit IS NULL;

select * from pl;







END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Triad` ()   BEGIN


CREATE TEMPORARY TABLE trialBalance SELECT accountsub.categoryID ,accountsub.subcategoryID, accountsub.subcategoryName, SUM(DebitAmount) AS Debit, SUM(CreditAmount) AS Credit FROM jrlDetailed inner join coa on jrldetailed.accountID = coa.AccountNo inner join accountsub on coa.CategoryID = accountsub.CategoryID and coa.SubcategoryID = accountsub.SubcategoryID GROUP BY categoryID,subcategoryID;

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
  INSERT INTO trialBalance (subcategoryName, Debit, Credit) 
  VALUES ('Total', @debitTotal, @creditTotal);

SELECT * FROM `trialbalance`;

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
  `createdDate` date DEFAULT NULL,
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `accountsub`
--

INSERT INTO `accountsub` (`CategoryID`, `SubcategoryID`, `SubcategoryName`, `createdBy`, `createdDate`, `modifiedBy`, `modifiedDate`) VALUES
(1, 1, 'Current Assets', NULL, NULL, NULL, NULL),
(1, 2, 'Fixed Assets', NULL, NULL, NULL, NULL),
(1, 3, 'Bank and Cash', NULL, NULL, NULL, NULL),
(1, 4, 'Accounts Receivable', NULL, NULL, NULL, NULL),
(1, 5, 'Inventory', NULL, NULL, NULL, NULL),
(1, 6, 'Employee Receivable', NULL, NULL, NULL, NULL),
(2, 1, 'Current Liabilities', NULL, NULL, NULL, NULL),
(2, 2, 'Long-term Liabilities', NULL, NULL, NULL, NULL),
(2, 3, 'Accounts Payable', NULL, NULL, NULL, NULL),
(2, 4, 'Short-term Debt', NULL, NULL, NULL, NULL),
(2, 5, 'Long-term Debt', NULL, NULL, NULL, NULL),
(2, 6, 'Employee Payable', NULL, NULL, NULL, NULL),
(3, 1, 'Share Capital', NULL, NULL, NULL, NULL),
(3, 2, 'Retained Earnings', NULL, NULL, NULL, NULL),
(4, 1, 'Sales Revenue', NULL, NULL, NULL, NULL),
(4, 2, 'Service Revenue', NULL, NULL, NULL, NULL),
(4, 3, 'Interest Income', NULL, NULL, NULL, NULL),
(4, 4, 'Rental Income', NULL, NULL, NULL, NULL),
(4, 5, 'Stock Market Earnings', NULL, NULL, NULL, NULL),
(5, 1, 'General Expenses', NULL, NULL, NULL, NULL),
(5, 2, 'Salaries and Wages', NULL, NULL, NULL, NULL),
(5, 3, 'Rent Expense', NULL, NULL, NULL, NULL),
(5, 4, 'Utilities Expense', NULL, NULL, NULL, NULL),
(5, 5, 'Depreciation Expense', NULL, NULL, NULL, NULL),
(5, 6, 'Cost of Goods Sold (COGS)', NULL, NULL, NULL, NULL),
(5, 7, 'Food Expenses', NULL, NULL, NULL, NULL),
(5, 8, 'Transportation Expenses', NULL, NULL, NULL, NULL),
(5, 9, 'Donation', NULL, NULL, NULL, NULL);

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
  `createdDate` date DEFAULT NULL,
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `coa`
--

INSERT INTO `coa` (`AccountNo`, `AccountName`, `CategoryID`, `SubcategoryID`, `createdBy`, `createdDate`, `modifiedBy`, `modifiedDate`) VALUES
(11001, 'Cash', 1, 1, NULL, NULL, NULL, NULL),
(11002, 'Accounts Receivable', 1, 1, NULL, NULL, NULL, NULL),
(12001, 'Office Equipment', 1, 2, NULL, NULL, NULL, NULL),
(12002, 'Machinery', 1, 2, NULL, NULL, NULL, NULL),
(13001, 'SBI', 1, 3, NULL, NULL, NULL, NULL),
(13002, 'Fed Bank', 1, 3, NULL, NULL, NULL, NULL),
(14001, 'Abraham', 1, 4, NULL, NULL, NULL, NULL),
(14002, 'KCCL', 1, 4, NULL, NULL, NULL, NULL),
(15001, 'Raw Materials', 1, 5, NULL, NULL, NULL, NULL),
(15002, 'Finished Goods', 1, 5, NULL, NULL, NULL, NULL),
(16001, 'Employee Advances', 1, 6, NULL, NULL, NULL, NULL),
(16002, 'Employee Loans', 1, 6, NULL, NULL, NULL, NULL),
(21001, 'Accounts Payable', 2, 1, NULL, NULL, NULL, NULL),
(21002, 'Accrued Liabilities', 2, 1, NULL, NULL, NULL, NULL),
(21003, 'Nellenkuzhy', 2, 1, NULL, NULL, NULL, NULL),
(21004, 'KSEB', 2, 1, NULL, NULL, NULL, NULL),
(21005, 'Marian College', 2, 1, NULL, NULL, NULL, NULL),
(22001, 'Mortgage Payable', 2, 2, NULL, NULL, NULL, NULL),
(22002, 'Bonds Payable', 2, 2, NULL, NULL, NULL, NULL),
(23001, 'Trade Payables', 2, 3, NULL, NULL, NULL, NULL),
(23002, 'Notes Payable', 2, 3, NULL, NULL, NULL, NULL),
(24001, 'Short-term Loans', 2, 4, NULL, NULL, NULL, NULL),
(24002, 'Overdrafts', 2, 4, NULL, NULL, NULL, NULL),
(25001, 'Long-term Loans', 2, 5, NULL, NULL, NULL, NULL),
(25002, 'Deferred Tax Liabilities', 2, 5, NULL, NULL, NULL, NULL),
(26001, 'Employee Salaries Payable', 2, 6, NULL, NULL, NULL, NULL),
(26002, 'Employee Benefits Payable', 2, 6, NULL, NULL, NULL, NULL),
(31001, 'Common Stock', 3, 1, NULL, NULL, NULL, NULL),
(31002, 'Preferred Stock', 3, 1, NULL, NULL, NULL, NULL),
(32001, 'Retained Earnings', 3, 2, NULL, NULL, NULL, NULL),
(32002, 'Dividends', 3, 2, NULL, NULL, NULL, NULL),
(41001, 'Product Sales', 4, 1, NULL, NULL, NULL, NULL),
(42001, 'Service Fees', 4, 2, NULL, NULL, NULL, NULL),
(42002, 'Owners Salary', 4, 2, NULL, NULL, NULL, NULL),
(43001, 'Interest Earned', 4, 3, NULL, NULL, NULL, NULL),
(44001, 'Rental Income', 4, 4, NULL, NULL, NULL, NULL),
(45001, 'Stock Market Earnings', 4, 5, NULL, NULL, NULL, NULL),
(51001, 'General Expenses', 5, 1, NULL, NULL, NULL, NULL),
(52001, 'Salaries Expense', 5, 2, NULL, NULL, NULL, NULL),
(52002, 'Wages Expense', 5, 2, NULL, NULL, NULL, NULL),
(53001, 'Office Rent', 5, 3, NULL, NULL, NULL, NULL),
(54001, 'Electricity Expense', 5, 4, NULL, NULL, NULL, NULL),
(54002, 'Water Bill', 5, 4, NULL, NULL, NULL, NULL),
(54003, 'Internet Expense', 5, 4, NULL, NULL, NULL, NULL),
(55001, 'Depreciation Expense', 5, 5, NULL, NULL, NULL, NULL),
(56001, 'COGS', 5, 6, NULL, NULL, NULL, NULL),
(57001, 'Food Expenses', 5, 7, NULL, NULL, NULL, NULL),
(58001, 'Transportation Expenses', 5, 8, NULL, NULL, NULL, NULL),
(59001, 'Donations', 5, 9, NULL, NULL, NULL, NULL);

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
  `createdDate` date DEFAULT NULL,
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDate` date DEFAULT NULL
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
  `CreditAmount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jrldetailed`
--

INSERT INTO `jrldetailed` (`EntryID`, `LineID`, `AccountID`, `EntityID`, `description`, `DebitAmount`, `CreditAmount`) VALUES
(1, 1, 13001, NULL, 'opening balance', 20000.00, 0.00),
(1, 2, 11001, NULL, 'opening balance', 0.00, 20000.00),
(2, 1, 54001, NULL, 'paying electricity', 1000.00, 0.00),
(2, 2, 11001, NULL, 'paying electricity', 0.00, 1000.00),
(3, 1, 11001, NULL, 'taking some cash', 3000.00, 0.00),
(3, 2, 13001, NULL, 'reducing from sbi', 0.00, 3000.00),
(4, 1, 57001, NULL, 'buying food', 200.00, 0.00),
(4, 2, 11001, NULL, 'paying for food', 0.00, 200.00),
(5, 1, 13001, NULL, 'getting money to sbi', 9000.00, 0.00),
(5, 2, 45001, NULL, 'stock market wins', 0.00, 9000.00),
(6, 1, 54002, NULL, 'pay water bill', 600.00, 0.00),
(6, 2, 11001, NULL, 'reducing from cash', 0.00, 600.00),
(7, 1, 13001, NULL, 'salary to bank', 30000.00, 0.00),
(7, 2, 42002, NULL, 'salary', 0.00, 30000.00),
(8, 1, 13001, NULL, 'interest to sbi', 100.00, 0.00),
(8, 2, 43001, NULL, 'interest', 0.00, 100.00),
(9, 1, 54003, NULL, 'pay net', 500.00, 0.00),
(9, 2, 13001, NULL, 'reducing from sbi', 0.00, 500.00),
(10, 1, 11001, NULL, 'cash increase', 30000.00, 0.00),
(10, 2, 21001, NULL, 'payable increase', 0.00, 30000.00),
(11, 1, 54001, NULL, 'current paid', 1000.00, 0.00),
(11, 2, 21004, NULL, 'liability to kseb', 0.00, 1000.00),
(12, 1, 57001, NULL, 'food paid', 500.00, 0.00),
(12, 2, 21003, NULL, 'payment on account', 0.00, 500.00),
(13, 1, 59001, NULL, 'donation', 36000.00, 0.00),
(13, 2, 11001, NULL, 'reducing from cash', 0.00, 36000.00);

-- --------------------------------------------------------

--
-- Table structure for table `jrlmaster`
--

CREATE TABLE `jrlmaster` (
  `EntryID` int(11) NOT NULL,
  `jdate` date DEFAULT NULL,
  `description` varchar(50) DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDate` date DEFAULT NULL,
  `modifiedBy` varchar(50) DEFAULT NULL,
  `modifiedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jrlmaster`
--

INSERT INTO `jrlmaster` (`EntryID`, `jdate`, `description`, `createdBy`, `createdDate`, `modifiedBy`, `modifiedDate`) VALUES
(1, '2024-01-01', 'opening balance', 'Athul', '2024-06-16', NULL, NULL),
(2, '2024-01-01', 'paying electricity', 'Athul', '2024-06-16', NULL, NULL),
(3, '2024-01-02', 'taking some cash', 'Athul', '2024-06-16', NULL, NULL),
(4, '2024-01-02', 'buying food', 'Athul', '2024-06-16', NULL, NULL),
(5, '2024-01-03', 'STock market earnings', 'Athul', '2024-06-16', NULL, NULL),
(6, '2024-01-06', 'paying water bill', 'Athul', '2024-06-16', NULL, NULL),
(7, '2024-01-07', 'getting salary', 'Athul', '2024-06-16', NULL, NULL),
(8, '2024-01-08', 'interest received', 'Athul', '2024-06-16', NULL, NULL),
(9, '2024-01-10', 'internet expense', 'Athul', '2024-06-16', NULL, NULL),
(10, '2024-01-10', 'took a loan', 'Athul', '2024-06-18', NULL, NULL),
(11, '2024-01-11', 'current payment on account', 'Athul', '2024-06-18', NULL, NULL),
(12, '2024-01-12', 'food expense on account', 'Athul', '2024-06-18', NULL, NULL),
(13, '2024-01-13', 'making a donation', 'Athul', '2024-06-21', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `trialbalance`
--

CREATE TABLE `trialbalance` (
  `AccountID` int(11) NOT NULL,
  `AccountName` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `SUM(debitAmount)` decimal(32,2) DEFAULT NULL,
  `SUM(creditAmount)` decimal(32,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trialbalance`
--

INSERT INTO `trialbalance` (`AccountID`, `AccountName`, `SUM(debitAmount)`, `SUM(creditAmount)`) VALUES
(11001, '                                                  ', 3000.00, 40200.00),
(13001, '                                                  ', 20000.00, 3000.00),
(54001, '                                                  ', 1000.00, 0.00),
(57001, '                                                  ', 200.00, 0.00);

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `jrlmaster`
--
ALTER TABLE `jrlmaster`
  MODIFY `EntryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
-- Database: `invoice_system`
--
CREATE DATABASE IF NOT EXISTS `invoice_system` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `invoice_system`;

-- --------------------------------------------------------

--
-- Table structure for table `invoice_order`
--

CREATE TABLE `invoice_order` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_receiver_name` varchar(250) NOT NULL,
  `order_receiver_address` text NOT NULL,
  `order_total_before_tax` decimal(10,2) NOT NULL,
  `order_total_tax` decimal(10,2) NOT NULL,
  `order_tax_per` varchar(250) NOT NULL,
  `order_total_after_tax` double(10,2) NOT NULL,
  `order_amount_paid` decimal(10,2) NOT NULL,
  `order_total_amount_due` decimal(10,2) NOT NULL,
  `note` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `invoice_order`
--

INSERT INTO `invoice_order` (`order_id`, `user_id`, `order_date`, `order_receiver_name`, `order_receiver_address`, `order_total_before_tax`, `order_total_tax`, `order_tax_per`, `order_total_after_tax`, `order_amount_paid`, `order_total_amount_due`, `note`) VALUES
(2, 123456, '2021-01-31 14:03:42', 'abcd', 'Admin\r\nA - 4000, Ashok Nagar, New Delhi,\r\n 110096 India.\r\n12345678912\r\nadmin@phpzag.com', 342400.00, 684800.00, '200', 1027200.00, 45454.00, 981746.00, 'this note txt'),
(682, 123456, '2021-08-19 15:13:36', 'ABCD pvt ltd', 'New Delhi India', 750000.00, 7500.00, '1', 757500.00, 20000.00, 737500.00, 'this is a note'),
(683, 123456, '2021-08-19 16:54:15', 'XYZ', 'Newyork USA', 1320000.00, 26400.00, '2', 1346400.00, 20000.00, 1326400.00, 'some note'),
(684, 123456, '2024-06-20 16:34:18', 'WWE ', 'Calicut', 1000.00, 50.00, '5', 1050.00, 1000.00, 50.00, 'bought two helmies');

-- --------------------------------------------------------

--
-- Table structure for table `invoice_order_item`
--

CREATE TABLE `invoice_order_item` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `item_code` varchar(250) NOT NULL,
  `item_name` varchar(250) NOT NULL,
  `order_item_quantity` decimal(10,2) NOT NULL,
  `order_item_price` decimal(10,2) NOT NULL,
  `order_item_final_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `invoice_order_item`
--

INSERT INTO `invoice_order_item` (`order_item_id`, `order_id`, `item_code`, `item_name`, `order_item_quantity`, `order_item_price`, `order_item_final_amount`) VALUES
(4100, 2, '13555', 'Face Mask', 120.00, 2000.00, 240000.00),
(4101, 2, '34', 'mobile', 10.00, 10000.00, 100000.00),
(4102, 2, '34', 'mobile battery', 1.00, 34343.00, 34343.00),
(4103, 2, '34', 'mobile cover', 10.00, 200.00, 2000.00),
(4104, 2, '36', 'testing', 1.00, 2400.00, 2400.00),
(4364, 682, '123456', 'iphone 6s', 12.00, 25000.00, 300000.00),
(4365, 682, '345678', 'one plus', 10.00, 45000.00, 450000.00),
(4368, 683, '00123', 'iphone 12', 10.00, 80000.00, 800000.00),
(4369, 683, '00124', 'iphone 8', 13.00, 40000.00, 520000.00),
(4370, 684, '404', 'Helmet', 2.00, 500.00, 1000.00);

-- --------------------------------------------------------

--
-- Table structure for table `invoice_user`
--

CREATE TABLE `invoice_user` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `mobile` bigint(20) NOT NULL,
  `address` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `invoice_user`
--

INSERT INTO `invoice_user` (`id`, `email`, `password`, `first_name`, `last_name`, `mobile`, `address`) VALUES
(123456, 'admin@phpzag.com', '12345', 'Admin', '', 12345678912, 'New Delhi 110096 India.');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `invoice_order`
--
ALTER TABLE `invoice_order`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `invoice_order_item`
--
ALTER TABLE `invoice_order_item`
  ADD PRIMARY KEY (`order_item_id`);

--
-- Indexes for table `invoice_user`
--
ALTER TABLE `invoice_user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `invoice_order`
--
ALTER TABLE `invoice_order`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=685;

--
-- AUTO_INCREMENT for table `invoice_order_item`
--
ALTER TABLE `invoice_order_item`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4371;

--
-- AUTO_INCREMENT for table `invoice_user`
--
ALTER TABLE `invoice_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=123457;
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
('root', '[{\"db\":\"ac\",\"table\":\"jrldetailed\"},{\"db\":\"ac\",\"table\":\"jrlmaster\"},{\"db\":\"ac\",\"table\":\"coa\"}]');

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
('root', '2024-06-22 12:26:00', '{\"Console\\/Mode\":\"collapse\"}');

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
-- Database: `rptesting`
--
CREATE DATABASE IF NOT EXISTS `rptesting` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `rptesting`;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mobile_number` varchar(20) NOT NULL,
  `payment_amount` decimal(10,2) NOT NULL,
  `order_id` varchar(50) DEFAULT NULL,
  `order_status` varchar(50) DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `name`, `email`, `mobile_number`, `payment_amount`, `order_id`, `order_status`) VALUES
(1, 'John Doe', 'johndoe@example.com', '+1234567890', 100.50, 'ABC123', 'success');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_id` (`order_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- Database: `test`
--
CREATE DATABASE IF NOT EXISTS `test` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `test`;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
