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
--	Test Unit Number:		FLDatePart-Netezza-01
--
--	Name(s):		    	FLDatePart
--
-- 	Description:			Scalar function which extracts a part of the DATE variable
--
--	Applications:		 
--
-- 	Signature:		    	FLDatePart(pDatePartInd VARCHAR, pDate DATE)
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
SELECT  a.ObsID, a.DateIN1,
        FLDatePart('yy', a.DateIN1) AS DatePartYear,
        FLDatePart('qq', a.DateIN1) AS DatePartQuarter,
        FLDatePart('mm', a.DateIN1) AS DatePartMonth,
        FLDatePart('dy', a.DateIN1) AS DatePartDayOfYear,
        FLDatePart('dd', a.DateIN1) AS DatePartDay,
        FLDatePart('wk', a.DateIN1) AS DatePartWeek,
        FLDatePart('dw', a.DateIN1) AS DatePartWeekday
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 2: Test for alternative DatePartInd Argument Input
SELECT  a.ObsID, 
        a.DateIN1,
        FLDatePart('yyyy', a.DateIN1) AS DatePartYear,
        FLDatePart('q', a.DateIN1) AS DatePartQuarter,
        FLDatePart('m', a.DateIN1) AS DatePartMonth,
        FLDatePart('y', a.DateIN1) AS DatePartDayOfYear,
        FLDatePart('d', a.DateIN1) AS DatePartDay,
        FLDatePart('ww', a.DateIN1) AS DatePartWeek,
        FLDatePart('dw', a.DateIN1) AS DatePartWeekday
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 3: Test for lower bound of input date
SELECT  DATE '0001-01-01' AS DateIN1,
        FLDatePart('yy', DateIN1) AS DatePartYear,
        FLDatePart('qq', DateIN1) AS DatePartQuarter,
        FLDatePart('mm', DateIN1) AS DatePartMonth,
        FLDatePart('dy', DateIN1) AS DatePartDayOfYear,
        FLDatePart('dd', DateIN1) AS DatePartDay,
        FLDatePart('wk', DateIN1) AS DatePartWeek,
        FLDatePart('dw', DateIN1) AS DatePartWeekday;
        
---- Positive Test 4: Test for upper bound of input date
SELECT  DATE '9999-12-31' AS DateIN1,
        FLDatePart('yy', DateIN1) AS DatePartYear,
        FLDatePart('qq', DateIN1) AS DatePartQuarter,
        FLDatePart('mm', DateIN1) AS DatePartMonth,
        FLDatePart('dy', DateIN1) AS DatePartDayOfYear,
        FLDatePart('dd', DateIN1) AS DatePartDay,
        FLDatePart('wk', DateIN1) AS DatePartWeek,
        FLDatePart('dw', DateIN1) AS DatePartWeekday;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Invalid Input For Date Part Indicator
--- Return expected error msg, Good
SELECT  a.ObsID, a.DateIN1,
        FLDatePart('gg',a.DateIN1) AS DatePartYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, a.DateIN1,
        FLDatePart(NULL,a.DateIN1) AS DatePartYear
FROM    tblTestDate a
ORDER BY 1;

---- Negative Test 2: Invalid Date Input
--- Return expected error msg, Good
SELECT  a.ObsID, a.DateIN1,
        FLDatePart('yy',NULL) AS DatePartYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  FLDatePart('yy','2010') AS DatePartYear;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
