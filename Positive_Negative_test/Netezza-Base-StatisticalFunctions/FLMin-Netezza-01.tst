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
--	Test Unit Number:		FLMin-Netezza-01
--
--	Name(s):		    	FLMin
--
-- 	Description:			Aggregate function which returns the minimum value
--
--	Applications:		 
--
-- 	Signature:		    	FLMin(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
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

---- Positive Test 1: Result should be 1
--- Return expected result, Good
SELECT  FLMin(a.SerialVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 2: Min At of 0.0 * Value, Result should be 0
--- Return expected result, Good
SELECT  FLMin( a.SerialVal * -0.0),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 3: Min At ties, Result should be 1 
--- Return expected result, Good
SELECT  FLMin( CASE WHEN a.SerialVal < 5 THEN 1 ELSE a.SerialVal END),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 4: Min At of -1.0 * Value, Result should be -10
--- Return expected result, Good
SELECT  FLMin(a.SerialVal * -1.0),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 5: Min At of Value - 10, Result should be -9
--- Return expected result, Good
SELECT  FLMin( a.SerialVal - 10),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 6: Multiple a very small number, Result should be 1 * 1e-100
--- Return expected result, Good
SELECT  FLMin(SerialVal * 1e-100),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 7: Multiple a very large number, Result should be 1 * 1e100
--- Return expected result, Good
SELECT  FLMin( a.SerialVal * 1e100),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLMin(a.SerialVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2a: Invalid Data type: Input VarChar
--- Return expected error, Good
SELECT  FLMin(a.City)
FROM    tblCustData a;

---- Negative Test 2b: Invalid Data type: Input VarChar for 2nd Argument
--- Return expected error, Good
SELECT  FLMin(CAST (a.RandVal AS VARCHAR(30))),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
