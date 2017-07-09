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
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FLCountPos-Netezza-01
--
--	Name(s):		    	FLCountPos
--
-- 	Description:			Aggregate function which returns the count of positive values
--
--	Applications:		 
--
-- 	Signature:		    	FLCountPos(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			BIGINT
--
--	Last Updated:			11-20-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Count of 0.0 * Value, Results should be 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 0 THEN 'BasicStat-FT-FLCountPos-01P1: PASSED' ELSE 'BasicStat-FT-FLCountPos-01P1: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.SerialVal * -0.0) AS CNTPos,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

---- Positive Test 2: Count of -1.0 * Value, Results should be 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 0 THEN 'BasicStat-FT-FLCountPos-01P2: PASSED' ELSE 'BasicStat-FT-FLCountPos-01P2: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.SerialVal * -1.0) AS CNTPos,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

---- Positive Test 3: Count of Value - 1e4, Results should be 100000 - 1e4
--- Compare query output with 100000 - 1e4, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 100000 - 1e4 THEN 'BasicStat-FT-FLCountPos-01P3: PASSED' ELSE 'BasicStat-FT-FLCountPos-01P3: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.SerialVal - 1e4) AS CNTPos,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 100000) AS a;

---- Positive Test 4: Multiple a very small number, Results should be 10
--- Compare query output with 10, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 10 THEN 'BasicStat-FT-FLCountPos-01P4: PASSED' ELSE 'BasicStat-FT-FLCountPos-01P4: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.SerialVal * 1e-100) AS CNTPos,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

---- Positive Test 5: Multiple a very large number, Results should be 10
--- Compare query output with 10, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 10 THEN 'BasicStat-FT-FLCountPos-01P5: PASSED' ELSE 'BasicStat-FT-FLCountPos-01P5: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.SerialVal * 1e100) AS CNTPos,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

----  Negative Test 1: No data, should return 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTPos AS CNTPos, CASE WHEN a.CNTPos = 0 THEN 'BasicStat-FT-FLCountPos-01N1: PASSED' ELSE 'BasicStat-FT-FLCountPos-01N1: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountPos(a.RandVal) AS CNTPos,
                COUNT(*) CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= -1) AS a;

----  Negative Test 2a: Invalid Data Type: Input VarChar
--- Output error, FLCountPos doesn't not exist, Good
SELECT  FLCountPos(a.City)
FROM    tblCustData a;

----  Negative Test 2b: Invalid Data Type: Input VarChar
--- Output error, FLCountPos doesn't not exist, Good
SELECT  FLCountPos(CAST (a.RandVal AS VARCHAR(30))),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
