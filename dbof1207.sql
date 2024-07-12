-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 12, 2024 at 09:58 AM
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
(13, 2, 11001, NULL, 'reducing from cash', 0.00, 36000.00, NULL, '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19');

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
(13, '2024-01-13', 'making a donation', 'Athul', '2024-06-30 05:55:19', NULL, '2024-06-30 05:55:19');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userId` int(11) NOT NULL,
  `Firstname` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `Phone` int(11) NOT NULL,
  `email` varchar(254) NOT NULL,
  `username` varchar(12) NOT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userId`, `Firstname`, `LastName`, `Phone`, `email`, `username`, `password`) VALUES
(1, 'A', 'B', 2147483647, 'athulsebastiant@gmail.com', '122ass1d', '$2y$10$SykHYp8pzIcya'),
(2, 'Ba', 'demba', 1212121212, 'admin@phpzag.com', 'king2342', '$2y$10$snti3hZQWOW5udSZGoZaPOfSwzOAbqlKsgbjqpoQl2sj4aMqX5FuO');

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
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `jrlmaster`
--
ALTER TABLE `jrlmaster`
  MODIFY `EntryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
