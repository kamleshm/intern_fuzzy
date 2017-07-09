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
--	Test Unit Number:		FLCountNull-Netezza-01
--
--	Name(s):		    	FLCountNull
--
-- 	Description:			Aggregate function which returns the count of null values
--
--	Applications:		 
--
-- 	Signature:		    	FLCountNull(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			BIGINT
--
--	Last Updated:			07-03-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Count of 0.0 * Value, Results should be 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTNull AS CNTNull, CASE WHEN a.CNTNull = 0 THEN 'BasicStat-FT-FLCountNull-01P1: PASSED' ELSE 'BasicStat-FT-FLCountNull-01P1: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountNull(a.SerialVal * -0.0) AS CNTNull,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

---- Positive Test 2: Count of Values, Results should be 1e4
--- Compare query output with 1e4, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTNull AS CNTNull, CASE WHEN a.CNTNull = 1e4 THEN 'BasicStat-FT-FLCountNull-01P2: PASSED' ELSE 'BasicStat-FT-FLCountNull-01P2: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountNull(CASE WHEN a.SerialVal <= 1e4 THEN NULL ELSE a.SerialVal END) AS CNTNull,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 100000) AS a;

---- Positive Test 3: Multiple a very small number, Results should be 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTNull AS CNTNull, CASE WHEN a.CNTNull = 0 THEN 'BasicStat-FT-FLCountNull-01P3: PASSED' ELSE 'BasicStat-FT-FLCountNull-01P3: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountNull(a.SerialVal * 1e-100) AS CNTNull,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

---- Positive Test 4: Multiple a very large number, Results should be 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTNull AS CNTNull, CASE WHEN a.CNTNull = 0 THEN 'BasicStat-FT-FLCountNull-01P4: PASSED' ELSE 'BasicStat-FT-FLCountNull-01P4: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountNull(a.SerialVal * 1e100) AS CNTNull,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 10) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data, should return 0
--- Compare query output with 0, if true then return "passed", otherwise, return "failed"
SELECT  a.CNTNull AS CNTNull, CASE WHEN a.CNTNull = 0 THEN 'BasicStat-FT-FLCountNull-01N1: PASSED' ELSE 'BasicStat-FT-FLCountNull-01N1: FAILED' END AS TestOutcome
FROM (  SELECT  FLCountNull(a.RandVal) AS CNTNull,
                COUNT(*) AS CNT
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= -1) AS a;

---- Negative Test 2a: Invalid Data Type: Input VarChar
--- Output error, FLCountNull doesn't not exist, Good
SELECT  FLCountNull(a.City)
FROM    tblCustData a;

---- Negative Test 2b: Invalid Data Type: Input VarChar
--- Output error, FLCountNull doesn't not exist, Good
SELECT  FLCountNull(CAST (a.RandVal AS VARCHAR(30))),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
