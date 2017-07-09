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
--	Test Unit Number:		FLWtVar-Netezza-01
--
--	Name(s):		    	FLWtVar
--
-- 	Description:			Aggregate function which returns the weighted variance of a data series
--
--	Applications:		 
--
-- 	Signature:		    	FLWtVar(pWt DOUBLE PRECISION, pX DOUBLE PRECISION)
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

---- Positive Test 1: Positive test cases when all weights = 1, Compared with VAR_POP()
--- Same Output, Good
SELECT  a.City,
        FLWtVar(1, a.SalesPerVisit),
		FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Weighted Variance of -1.0 * Value
--- Return Null, Good
SELECT  a.City,
        FLWtVar(1, -1 * a.SalesPerVisit),
		FLWtVar(-1, a.SalesPerVisit),
		FLWtVar(-1 * 1, -1 * a.SalesPerVisit),
		FLWtVar(-1, -1 * a.SalesPerVisit),
		FLWtVar(-0.5, a.SalesPerVisit),
		FLWtVar(-1 * a.SalesPerVisit, a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Weighted Variance of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLWtVar(1, a.SalesPerVisit + 1.0),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Weighted Variance of Value + 1e100, Results should not change
--- Results change due to precision issue of platform
SELECT  a.City,
        FLWtVar(1, a.SalesPerVisit + 1e100),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Weighted Variance of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLWtVar(1, -1 * a.SalesPerVisit + 1.0),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very small number, Results should be 1e-100^2 * Variance
--- When weights are small, doesn't return expected results, due to precision issue
SELECT  a.City,
        FLWtVar(1, 1e-100 * a.SalesPerVisit),
		FLWtVar(1e-100 * 1, 1e-100 * a.SalesPerVisit), /* doesn't return expected results */
		FLWtVar(1e-10 * 1, 1e-100 * a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very large number, Results should be 1e100^2 * Variance
--- Large weights and values combination will cause numeric overflow which is on account of large values and is expected
SELECT  a.City,
        FLWtVar(1, 1e100 * a.SalesPerVisit),
		FLWtVar(1e100 * 1, 1e100 * a.SalesPerVisit), /* Output Error: FLWtVar caused a floating point exception: Numeric overflow */
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLWtVar(1, a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

SELECT  FLWtVar(a.RandVal, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: 0 weighting
--- Output Null, Good
SELECT  FLWtVar(0, a.RandVal)
FROM    fzzlSerial a;

---- Negative Test 3: Sum(weightings) = 0; Sum(-1 , -2 , 3) =0
--- Output Null, Good
SELECT FLWtVar(z.pWtVal, z.pSerialVal)
FROM (
      SELECT a.SerialVal AS pSerialVal, CASE WHEN a.SerialVal <= 2 THEN -1*a.SerialVal ELSE a.SerialVal END AS pWtVal
      FROM fzzlSerial a
      WHERE a.SerialVal <=3
) AS z;

---- Negative Test 4: Value(Double Precision) out of range: Weighted Variance of 1.0e400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLWtVar(1, 1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtVar(1e400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 5: Value(Double Precision) out of range: Weighted Variance of 1.0e-400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLWtVar(1, 1e-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtVar(1e-400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
