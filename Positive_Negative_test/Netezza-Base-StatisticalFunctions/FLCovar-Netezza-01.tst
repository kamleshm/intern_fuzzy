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
--	Test Unit Number:		FLCovar-Netezza-01
--
--	Name(s):		    	FLCovar
--
-- 	Description:			Aggregate function which returns the sample covariance of 2 vectors
--
--	Applications:		 
--
-- 	Signature:		    	FLCovar(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
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

---- Positive Test 1: Condition Test (Number of observation >= 2): Two observations, Compared with COVAR_SAMP()
--- Return expected results, Good
SELECT  FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 2 AND b.SerialVal <= 2 AND a.SerialVal = b.SerialVal;

---- Positive Test 2: Positive test cases: Four observations, Compared with COVAR_SAMP()
--- Return different results, COVAR_SAMP() returns wrong results
SELECT  FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 2 AND b.SerialVal <= 2;

---- Positive Test 3: Positive test cases, Compared with COVAR_SAMP()
--- Return expected results, Good
SELECT  FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 4: Sample Covariance of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  FLCovar(-1 * a.RandVal, -1 * b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 5: Sample Covariance of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLCovar(a.RandVal + 1.0, b.RandVal + 1.0),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 6: Sample Covariance of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLCovar(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 7: Sample Covariance of 10.0 * Value + 1.0, Results should be 10 * 10 * Covariance
--- Return expected results, Good
SELECT  FLCovar(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 8: Multiply by a very small number, Results should be 1e-100^2 * Covariance
--- Return expected results, Good
SELECT  FLCovar(1e-100 * a.RandVal, 1e-100 * b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 9: Multiply by a very large number, Results should be 1e100^2 * Covariance
--- Return expected results, Good
SELECT  FLCovar(1e100 * a.RandVal, 1e100 * b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 10: Add large constant number, Results should not change
--- Results changes due to precision limit
SELECT  FLCovar(1e10 + a.RandVal, 1e10 + b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        FLCovar(1e100 + a.RandVal, 1e100 + b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= -1 AND b.SerialVal <= -1;

---- Negative Test 2: Condition Test (Number of observation >= 2): One observation
--- Output Null, Good
SELECT  FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

---- Negative Test 3: Value(Double Precision) out of range: Sample Covariance of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  FLCovar(1e400 * a.RandVal, 1e400 * b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Negative Test 4: Value(Double Precision) out of range: Sample Covariance of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  FLCovar(1e-400 * a.RandVal, 1e-400 * b.RandVal),
        FLCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
