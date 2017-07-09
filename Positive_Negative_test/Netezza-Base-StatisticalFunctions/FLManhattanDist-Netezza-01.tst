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
--	Test Unit Number:		FLManhattanDist-Netezza-01
--
--	Name(s):		    	FLManhattanDist
--
-- 	Description:			Aggregate function which returns the Manhattan distance between 2 points xi and yi, each having m dimensions
--
--	Applications:		 
--
-- 	Signature:		    	FLManhattanDist(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
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

---------- Positive Testing
---- Positive Test 1: One observation, Results should be 0
--- Return expected results, Good
SELECT  FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

---- Positive Test 2: Positive test case with multiple observations
SELECT  FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 3: Manhattan Distance of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  FLManhattanDist(-1 * a.RandVal, -1 * b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 4: Manhattan Distance of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLManhattanDist(a.RandVal + 1.0, b.RandVal + 1.0),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 5: Manhattan Distance of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLManhattanDist(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 6: Manhattan Distance of 10.0 * Value + 1.0, Results should be 10 * Manh Distance
--- Return expected results, Good
SELECT  FLManhattanDist(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 7: Multiply by a very small number, Results should be 1e-100 * Manh Distance
--- Return expected results, Good
SELECT  FLManhattanDist(1e-100 * a.RandVal, 1e-100 * b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 8: Multiply by a very large number, Results should be 1e100 * Manh Distance
--- Return expected results, Good
SELECT  FLManhattanDist(1e100 * a.RandVal, 1e100 * b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Positive Test 9: Add a very large number, Results should not change
--- Results change significantly, Report JR issue
SELECT  FLManhattanDist(1e10 + a.RandVal, 1e10 + b.RandVal),
        FLManhattanDist(1e100 + a.RandVal, 1e100 + b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= -1 AND b.SerialVal <= -1;

---- Negative Test 2: One of points are all Nulls, Results should be Null
--- Return expected results, Good
SELECT  FLManhattanDist(CASE WHEN a.SerialVal <=1 THEN NULL ELSE a.RandVal END, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

---- Negative Test 3:  Value(Double Precision) out of range: Manhattan Distance of 1.0e400 * Value
---  Numeric Overflow error, Good 
SELECT  FLManhattanDist(1e400 * a.RandVal, 1e400 * b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

---- Negative Test 4: Value(Double Precision) out of range: Manhattan Distance of 1.0e-400 * Value
---  Numeric Overflow error, Good 
SELECT  FLManhattanDist(1e-400 * a.RandVal, 1e-400 * b.RandVal),
        FLManhattanDist(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
