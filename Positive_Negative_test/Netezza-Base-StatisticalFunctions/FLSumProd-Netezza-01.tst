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
--	Test Unit Number:		FLSumProd-Netezza-01
--
--	Name(s):		    	FLSumProd
--
-- 	Description:			Aggregate function which returns the sum of the products of two data series
--
--	Applications:		 
--
-- 	Signature:		    	FLSumProd(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
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

---- Positive Test 1: Positive test cases, Results should be SUM(a.RandVal^2)
--- Return expected results, Good
SELECT  FLSumProd(a.RandVal, b.RandVal), SUM(a.RandVal**2),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 2: Sum of the Products of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  FLSumProd(-1 * a.RandVal, -1 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 3: Sum of the Products of 10.0 * Value, Results should be 10 * 10 * Sum of the Products
--- Return expected results, Good
SELECT  FLSumProd(10 * a.RandVal, 10 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 4: Multiply by a very small number, Results should be 1e-100^2 * Sum of the Products
--- Return expected results, Good
SELECT  FLSumProd(1e-100 * a.RandVal, 1e-100 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 5: Multiply by a very large number, Results should be 1e100^2 * Sum of the Products
--- Return expected results, Good
SELECT  FLSumProd(1e100 * a.RandVal, 1e100 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 6: Add a very large number, Should be SUM((1e100 + a.RandVal)**2)
--- Return expected results, Good
SELECT CASE WHEN a.FLSumProd =a.SUMSQ THEN 'BasicStat-FT-FLSumProd-01P6: PASSED' ELSE 'BasicStat-FT-FLSumProd-01P6: FAILED' END AS TestOutcome
FROM
(SELECT  FLSumProd(1e100 + a.RandVal, 1e100 + b.RandVal) as FLSumProd, SUM((1e100 + a.RandVal)**2) as SUMSQ
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= -1 AND b.SerialVal <= -1;

---- Negative Test 2: value(Double Precision) out of range: Sum of the Products of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  FLSumProd(1e400 * a.RandVal, 1e400 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Negative Test 3: value(Double Precision) out of range: Sum of the Products of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  FLSumProd(1e-400 * a.RandVal, 1e-400 * b.RandVal),
        FLSumProd(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
