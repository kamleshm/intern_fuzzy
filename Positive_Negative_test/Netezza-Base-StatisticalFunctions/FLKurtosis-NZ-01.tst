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
--	Test Unit Number:		FLKurtosis-Netezza-01
--
--	Name(s):		    	FLKurtosis
--
-- 	Description:			Aggregate function which returns the kurtosis
--
--	Applications:		 
--
-- 	Signature:		    	FLKurtosis(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
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

---- Positive Test 1: Condition Test (Number of observation >= 4): Four observations
--- Return expected results, Good
SELECT  FLKurtosis(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 4;

---- Positive Test 2: Positive test cases
SELECT  a.City,
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Kurtosis of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLKurtosis(-1 * a.SalesPerVisit),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Kurtosis of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLKurtosis(a.SalesPerVisit + 1.0),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Kurtosis of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLKurtosis(-1 * a.SalesPerVisit + 1.0),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Kurtosis of 10.0 * Value + 1.0, Results should not change
--- Return expected results,Good
SELECT  a.City,
        FLKurtosis(10 * a.SalesPerVisit + 1.0),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very small number, Results should not change
--- When multiply by a very small number will return NaN due to precision limit
--- to be investigated
SELECT  a.City,
        FLKurtosis(1e-10 * a.SalesPerVisit),
        FLKurtosis(1e-100 * a.SalesPerVisit), /* Return NaN */
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 8: Multiply by a very large number, Results should not change
---- When multiply by a very large number, will return error, which is on account of large values and is expected
SELECT  a.City,
        FLKurtosis(1e10 * a.SalesPerVisit),
		FLKurtosis(1e100 * a.SalesPerVisit), /* FLKurtosis caused a floating point exception: numeric overflow */
        STDDEV_POP(1e100 * a.SalesPerVisit),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 9: Add a very large number, Results should not change
--- When adding constant, results will change
SELECT  a.City,
        FLKurtosis(1e2+ a.SalesPerVisit), /* minor change due to precision limit */
		FLKurtosis(1e5+ a.SalesPerVisit),  /* results change due to precision limit */
        FLKurtosis(1e10 + a.SalesPerVisit), /* Kurtosis caused a floating point exception: numeric overflow */
		FLKurtosis(1e100 + a.SalesPerVisit), /* FLKurtosis caused a floating point exception: numeric overflow */
        STDDEV_POP(1e100 + a.SalesPerVisit),
        FLKurtosis(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLKurtosis(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Condition Test (Number of observation >= 4): Three observations
--- Output Null, Good
SELECT  FLKurtosis(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <=3;

---- Negative Test 3: Value(Double Precision) out of range: Kurtosis of 1.0e400 * Value
---  Numeric Overflow error, Good 
SELECT  a.City,
        FLKurtosis(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 4: Value(Double Precision) out of range: Kurtosis of 1.0e-400 * Value
---  Numeric Overflow error, Good 
SELECT  a.City,
        FLKurtosis(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
