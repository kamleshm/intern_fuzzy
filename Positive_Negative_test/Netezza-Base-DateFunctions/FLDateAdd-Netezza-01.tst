-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
--  Test Category:          Basic Statistics
--
--  Test Unit Number:       FLDateAdd-Netezza-01
--
--  Name(s):                FLDateAdd
--
--  Description:            Scalar function which adds to a date part of the DATE variable
--
--  Applications:        
--
--  Signature:              FLDateAdd(pDatePartInd VARCHAR, pNumber INTEGER, pDate DATE)
--
--  Parameters:             See Documentation
--
--  Return value:           DATE
--
--  Last Updated:           11-24-2014
--
--  Author:                 Surya Deepak Garimella, Ankit.Mahato@fuzzyl.com
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500
--set session dateform = ANSIDATE;

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   tblTestDate a;

-- BEGIN: POSITIVE TEST(s)


---- Positive Test 1a: Manual Example
--- Same Output, Good
SELECT a.ObsID, 
       a.DateIN1,
       FLDateAdd('yy', 1, a.DateIN1) AS DateAddYear,
       FLDateAdd('mm', 1, a.DateIN1) AS DateAddMonth,
       FLDateAdd('dd', 1, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 1b: Test for WEEK and QUARTER input
SELECT a.ObsID, 
       a.DateIN1,
       FLDateAdd('qq', 1, a.DateIN1) AS DateAddQuarter,
       FLDateAdd('wk', 1, a.DateIN1) AS DateAddWeek
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 2: Test for Lower Bound of input date 
SELECT DATE '0001-01-01' AS DateL,
       CAST(y.SerialVal - 1 AS INT) AS AddYear,
       CAST(m.SerialVal - 1 AS INT) AS AddMonth,
       CAST(d.SerialVal - 1 AS INT) AS AddDate,
       FLDateAdd('yy', AddYear, DateL) AS DateAddYear,
       FLDateAdd('mm', AddMonth, DateL) AS DateAddMonth,
       FLDateAdd('dd', AddDate, DateL) AS DateAddDay
FROM   fzzlSerial AS y,
       fzzlSerial AS m,
       fzzlSerial AS d
WHERE  AddYear IN (0, 1, 10, 9998, 9999)
AND    AddMonth IN (0, 1, 10, 100, 1000, 9999)
AND    AddDate IN (0, 1, 10, 100, 1000, 9999)
ORDER BY 1,2,3,4;

---- Positive Test 3: Test for Upper Bound of input date
SELECT DATE '9999-12-31' AS DateU,
       CAST(y.SerialVal - 1 AS INT) AS AddYear,
       CAST(m.SerialVal - 1 AS INT) AS AddMonth,
       CAST(d.SerialVal - 1 AS INT) AS AddDate,
       FLDateAdd('yy', AddYear, DateU) AS DateAddYear,
       FLDateAdd('mm', AddMonth, DateU) AS DateAddMonth,
       FLDateAdd('dd', AddDate, DateU) AS DateAddDay
FROM   fzzlSerial AS y,
       fzzlSerial AS m,
       fzzlSerial AS d
WHERE  AddYear IN (0, 1, 10, 9998, 9999)
AND    AddMonth IN (0, 1, 10, 100, 1000, 9999)
AND    AddDate IN (0, 1, 10, 100, 1000, 9999)
ORDER BY 1,2,3,4;

---- Positive Test 4: Test with return date smaller than '0001-01-01', According to User Manual, it should return '0001-01-01'
SELECT DATE '2000-01-01' AS Date1,
       DATE '0001-01-01' AS DateL,
       Date1 - DateL + 1 AS PreNumOfDates,
       CAST(2001 * 12 AS INT) AS PreNumOfMonths,
       FLDateAdd('yy', -2001, Date1) AS DateAddYear,
       FLDateAdd('mm', -PreNumOfMonths, Date1) AS DateAddMonth,
       FLDateAdd('dd', -PreNumOfDates, Date1) AS DateAddDate;
       
       
---- Positive Test 5: Upper Bound of Input Arguments
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', 9999, a.DateIN1) AS DateAddYear,
       FLDateAdd('qq', 99999, a.DateIN1) AS DateAddQuarter,
       FLDateAdd('mm', 999999, a.DateIN1) AS DateAddMonth,
       FLDateAdd('wk', 9999999, a.DateIN1) AS DateAddWeek,
       FLDateAdd('dd', 99999999, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 6: Lower Bound of Input Arguments
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', -9999, a.DateIN1) AS DateAddYear,
       FLDateAdd('qq', -99999, a.DateIN1) AS DateAddQuarter,
       FLDateAdd('mm', -999999, a.DateIN1) AS DateAddMonth,
       FLDateAdd('wk', -9999999, a.DateIN1) AS DateAddWeek,
       FLDateAdd('dd', -99999999, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 7: Test for DatePartInd input
SELECT a.ObsID, 
       a.DateIN1,
       FLDateAdd('yyyy', 1, a.DateIN1) AS DateAddYear,
       FLDateAdd('m', 1, a.DateIN1) AS DateAddMonth,
       FLDateAdd('d', 1, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input For Date Part Indicator
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('aa', 1, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd(NULL, 1, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 2: Invalid Input For Number to Add (Non-Integer)
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', 1.2, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', 'NaN', a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', NULL, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 3: Invalid Date Input
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', 1, NULL) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

SELECT FLDateAdd('yy', 1, '2010');
SELECT FLDateAdd('yy', 1, NULL);

---- Negative Test 4a: Out of Bound Value for Year
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', 10000, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('yy', -10000, a.DateIN1) AS DateAddYear
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 4b: Out of Bound Value for Quarter
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('qq', 100000, a.DateIN1) AS DateAddQuarter
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('qq', -100000, a.DateIN1) AS DateAddQuarter
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 4c: Out of Bound Value for Month
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('mm', 1000000, a.DateIN1) AS DateAddMonth
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('mm', -1000000, a.DateIN1) AS DateAddMonth
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 4d: Out of Bound Value for Week
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('wk', 10000000, a.DateIN1) AS DateAddWeek
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('wk', -10000000, a.DateIN1) AS DateAddWeek
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 4e: Out of Bound Value for Day
--- Return expected error, Good
SELECT a.ObsID, a.DateIN1,
       FLDateAdd('dd', 100000000, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateAdd('dd', -100000000, a.DateIN1) AS DateAddDay
FROM tblTestDate a
ORDER BY 1;

-- END: NEGATIVE TEST(s)

--  END: TEST SCRIPT
