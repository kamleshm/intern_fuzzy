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
-- 	Test Category:		    Date Functions
--
--	Test Unit Number:		FLDateDiff-Netezza-01
--
--	Name(s):		    	FLDateDiff
--
-- 	Description:			Scalar function which calculates the difference between 2 DATE variables
--
--	Applications:		 
--
-- 	Signature:		    	FLDateDiff(pDatePartInd VARCHAR, pStartDate DATE, pEndDate DATE)
--
--	Parameters:		    	See Documentation
--
--	Return value:			INTEGER
--
--	Last Updated:			11-24-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500
--set session dateform = ANSIDATE;

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   tblTestDate a;

-- BEGIN: POSITIVE TEST(s)

       
---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('yy',a.DateIN1, a.DateIN2) AS DateDiffYear,
        FLDateDiff('qq',a.DateIN1, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('mm',a.DateIN1, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('dd',a.DateIN1, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('wk',a.DateIN1, a.DateIN2) AS DateDiffWeek        
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 2: Test for alternative DatePartInd Argument Input
-------- P3a
SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('yyyy',a.DateIN1, a.DateIN2) AS DateDiffYear,
        FLDateDiff('q',a.DateIN1, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('m',a.DateIN1, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('d',a.DateIN1, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('ww',a.DateIN1, a.DateIN2) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

--------- P2b
SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('year',a.DateIN1, a.DateIN2) AS DateDiffYear,
        FLDateDiff('quarter',a.DateIN1, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('month',a.DateIN1, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('day',a.DateIN1, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('week',a.DateIN1, a.DateIN2) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 3: Test for Lower bound of Start Date
SELECT  a.ObsID, 
        DATE '0001-01-01' AS DateINLower, 
        a.DateIN2,
        FLDateDiff('yy', DateINLower, a.DateIN2) AS DateDiffYear,
        FLDateDiff('qq', DateINLower, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('mm', DateINLower, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('dd', DateINLower, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        DATE '0001-01-01' AS DateINLower, 
        a.DateIN2,
        FLDateDiff('wk', DateINLower, a.DateIN2) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 4: Test for Upper bound of Start Date
SELECT  a.ObsID, 
        DATE '9999-12-31' AS DateINUpper, 
        a.DateIN2,
        FLDateDiff('yy', DateINUpper, a.DateIN2) AS DateDiffYear,
        FLDateDiff('qq', DateINUpper, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('mm', DateINUpper, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('dd', DateINUpper, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        DATE '9999-12-31' AS DateINUpper, 
        a.DateIN2,
        FLDateDiff('wk', DateINUpper, a.DateIN2) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 5: Test for Lower bound of End Date
SELECT  a.ObsID, 
        DateIN1, 
        DATE '0001-01-01' AS DateINLower,
        FLDateDiff('yy', a.DateIN1, DateINLower) AS DateDiffYear,
        FLDateDiff('qq', a.DateIN1, DateINLower) AS DateDiffQuarter,
        FLDateDiff('mm', a.DateIN1, DateINLower) AS DateDiffMonth,
        FLDateDiff('dd', a.DateIN1, DateINLower) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        DateIN1, 
        DATE '0001-01-01' AS DateINLower,
        FLDateDiff('wk', a.DateIN1, DateINLower) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 6: Test for Upper bound of End Date
SELECT  a.ObsID, 
        DateIN1, 
        DATE '9999-12-31' AS DateINUpper,
        FLDateDiff('yy', a.DateIN1, DateINUpper) AS DateDiffYear,
        FLDateDiff('qq', a.DateIN1, DateINUpper) AS DateDiffQuarter,
        FLDateDiff('mm', a.DateIN1, DateINUpper) AS DateDiffMonth,
        FLDateDiff('dd', a.DateIN1, DateINUpper) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        DateIN1, 
        DATE '9999-12-31' AS DateINUpper,
        FLDateDiff('wk', a.DateIN1, DateINUpper) AS DateDiffWeek
FROM    tblTestDate a
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input For Date Part Indicator
--- Return expected error msg, Good
SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('gg',a.DateIN1, a.DateIN2) AS DateDiffYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff(NULL,a.DateIN1, a.DateIN2) AS DateDiffYear
FROM    tblTestDate a
ORDER BY 1;

---- Negative Test 2: Invalid Date Input
--- Return expected error msg, Good
SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('yy',NULL, a.DateIN2) AS DateDiffYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1, a.DateIN2,
        FLDateDiff('yy',a.DateIN1, NULL) AS DateDiffYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  FLDateDiff('yy','2010', '2009') AS DateDiffYear;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
