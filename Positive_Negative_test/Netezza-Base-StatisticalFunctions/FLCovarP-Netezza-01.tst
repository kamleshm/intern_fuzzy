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
--	Test Unit Number:		FLCovarP-Netezza-01
--
--	Name(s):		    	FLCovarP
--
-- 	Description:			Aggregate function which returns the population covariance of 2 vectors
--
--	Applications:		 
--
-- 	Signature:		    	FLCovarP(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
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

---- Positive Test 1: : One observation, Compared with COVAR_POP()
--- Outputs from FLCovarP and COVAR_POP are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P1: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P1: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(a.RandVal, b.RandVal) AS FL,
               COUNT(*) AS CNT0,
               ABS(FL - BMark) AS Diff
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1) AS a;

---- Positive Test 2: Four observation, Compared with COVAR_POP()
--- Outputs from FLCovarP and COVAR_POP are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P2: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P2: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(a.RandVal, b.RandVal) AS FL,
               COUNT(*) AS CNT0
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 2 AND b.SerialVal <= 2) AS a;

---- Positive Test 3: 100 Observations, Compared with COVAR_POP()
--- Outputs from FLCovarP and COVAR_POP are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P3: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P3: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(a.RandVal, b.RandVal) AS FL,
               COUNT(*) AS CNT0
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 4: Population Covariance of -1.0 * Value, Results should not change
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP(-1 * a.RandVal, -1 * b.RandVal) are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P4: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P4: FAILED' END AS TestOutcome
FROM (  SELECT  FLCovarP(-1 * a.RandVal, -1 * b.RandVal) AS FL1,
                FLCovarP(a.RandVal, b.RandVal) FL0,
                COUNT(*) AS CNT0
        FROM    fzzlSerial a,
                fzzlSerial b
        WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 5: Population Covariance of Value + 1.0, Results should not change
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( a.RandVal + 1.0, b.RandVal + 1.0) are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P5: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P5: FAILED' END AS TestOutcome
FROM (  SELECT  FLCovarP(a.RandVal + 1.0, b.RandVal + 1.0) AS FL1,
                FLCovarP(a.RandVal, b.RandVal) AS FL0,
                COUNT(*) AS CNT
        FROM    fzzlSerial a,
                fzzlSerial b
        WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 6: Population Covariance of -1.0 * Value + 1.0, Results should not change
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( -1 * a.RandVal + 1.0, -1 * b.RandVal + 1.0) are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P6: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P6: FAILED' END AS TestOutcome
FROM (  SELECT  FLCovarP(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0) AS FL1,
                FLCovarP(a.RandVal, b.RandVal) AS FL0,
                COUNT(*) AS CNT
        FROM    fzzlSerial a,
                fzzlSerial b
        WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 7: Population Covariance of 10.0 * Value + 1.0, Results should be 10 * 10 * Covariance
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( 10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0)/100 are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P7: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P7: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0)/100 AS FL1,
               FLCovarP(a.RandVal, b.RandVal) AS FL0,
               COUNT(*) AS CNT
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 8: Multiply by a very small number, Results should be 1e-100^2 * Covariance
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( 1e-100 * a.RandVal, 1e-100 * b.RandVal)/1e-200 are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P8: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P8: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(1e-100 * a.RandVal, 1e-100 * b.RandVal)/(1e-200) AS FL1,
               FLCovarP(a.RandVal, b.RandVal) AS FL0,
               COUNT(*) AS CNT
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 9: Multiply by a very large number, Results should be 1e100^2 * Covariance
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( 1e100 * a.RandVal, 1e100 * b.RandVal)/1e200 are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff1 AS FLDiff, a.BDiff1 AS BDiff,
       CASE WHEN a.FLDiff1 < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P9: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P9: FAILED' END AS TestOutcome
FROM ( SELECT  FLCovarP(1e100 * a.RandVal, 1e100 * b.RandVal)/(1e200) AS FL1,
               FLCovarP(a.RandVal, b.RandVal) AS FL0,
               COUNT(*) AS CNT
       FROM    fzzlSerial a,
               fzzlSerial b
       WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

---- Positive Test 10:  Add constant number, Results should not change
---  FLCovarP(a.RandVal, b.RandVal) and FLCovarP( x + a.RandVal, x + b.RandVal) are comparable. If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.FLDiff AS FLDiff, a.BDiff AS BDiff,
       CASE WHEN a.FLDiff < 1e-12 THEN 'BasicStat-FT-FLCovarP-01P10: PASSED' ELSE 'BasicStat-FT-FLCovarP-01P10: FAILED' END AS TestOutcome
FROM (  SELECT  FLCovarP(a.RandVal, b.RandVal) AS FL0,
        FLCovarP(1e10 + a.RandVal, 1e10 + b.RandVal) AS FL1,
        FLCovarP(1e100 + a.RandVal, 1e100 + b.RandVal) AS FL2,
        COVAR_POP(1e100 + a.RandVal, 1e100 + b.RandVal) AS BMark2,
        COUNT(*) AS CNT
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- No data
--- Negative Test 1: Output Null, Good
SELECT  FLCovarP(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= -1 AND b.SerialVal <= -1;

---- Negative Test 2: Value(Double Precision) out of range: Population Covariance of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  FLCovarP(1e400 * a.RandVal, 1e400 * b.RandVal),
        FLCovarP(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Negative Test 3: Value(Double Precision) out of range: Population Covariance of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  FLCovarP(1e-400 * a.RandVal, 1e-400 * b.RandVal),
        FLCovarP(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlSerial a,
        fzzlSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
