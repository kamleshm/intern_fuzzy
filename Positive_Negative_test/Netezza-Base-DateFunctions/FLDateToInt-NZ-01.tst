-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
--	Test Unit Number:		FLDateToInt-TD-01
--
--	Name(s):		    	FLDateToInt
--
-- 	Description:			Scalar function converts DATE to a number of days since 1990/01/01
--
--	Applications:		 
--
-- 	Signature:		    	FLDateToInt(pDate   DATE)
--
--	Parameters:		    	See Documentation
--
--	Return value:			INTEGER
--
--	Last Updated:			01-29-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500
-- set session dateform = ANSIDATE;

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   tblTestDate a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT a.ObsID,
       a.DateIN1,
       FLDateToInt(a.DateIN1) FLDateToInt
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 2: Test for lower bound of Input DateTS
SELECT  Date '0001-01-01' AS DateIN1,
        FLDateToInt(DateIN1) FLDateToInt;      

---- Positive Test 3: Test for upper bound of Input DateTS
SELECT  Date '9999-12-31' AS DateIN1,
        FLDateToInt(DateIN1) FLDateToInt;
        
---- Positive Test 4: Test for turn of Input DateTS
SELECT  Date '1990-01-01' AS DateIN1,
        FLDateToInt(DateIN1) FLDateToInt;
		
---- Positive Test 5:
SELECT SUM(b.DiffErr) AS Err, CASE WHEN Err = 0 THEN 'Date-FT-FLDateToInt-Netezza-01: PASSED' ELSE 'Date-FT-FLDateToInt-Netezza-01: FAILED' END AS Msg
FROM
(
    SELECT a.DateIN1,
           FLDateToInt(a.DateIN1) AS FLDateToInt, 
    	   a.DateIN1 - Date('1990-01-01') AS TDDateToInt,
    	   CASE WHEN FLDateToInt = TDDateToInt THEN 0 ELSE 1 END AS DiffErr
    FROM tblTestDate a
) AS b;
        
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input For Date
--- Return expected error msg, Good
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateToInt(a.DateTS1) AS FLDateToInt
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        a.DateTS1,
        FLDateToInt(NULL) AS FLDateToInt
FROM    tblTestDate a
ORDER BY 1;

SELECT  FLDateToInt('2010') AS FLDateToInt;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
