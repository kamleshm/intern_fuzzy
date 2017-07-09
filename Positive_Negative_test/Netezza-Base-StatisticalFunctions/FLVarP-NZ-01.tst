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
--	Test Unit Number:		FLVarP-Netezza-01
--
--	Name(s):		    	FLVarP
--
-- 	Description:			Aggregate function which returns the population variance
--
--	Applications:		 
--
-- 	Signature:		    	FLVarP(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			07-04-2017
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

---- Positive Test 1: Condition Test (Number of observation >= 1): One observation, Compared with VAR_POP()
--- Same Output, Good
SELECT  FLVarP(a.RandVal),
        VAR_POP(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 1;

---- Positive Test 2: Positive test cases, Compared with VAR_POP()
--- Same Output, Good
SELECT  a.City,
        FLVarP(a.SalesPerVisit),
        VAR_POP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Variance of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLVarP(-1 * a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Variance of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLVarP(a.SalesPerVisit + 1.0),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Variance of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLVarP(-1 * a.SalesPerVisit + 1.0),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Variance of 10.0 * Value + 1.0, should be 10^2 * Variance
--- Return expected results, Good
SELECT  a.City,
        FLVarP(10 * a.SalesPerVisit + 1.0),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very small number, should be 1e-100^2 * Variance
--- Return expected results, Good
SELECT  a.City,
        FLVarP(1e-100 * a.SalesPerVisit),
        VAR_POP(1e-100 * a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 8: Multiply by a very large number, should be 1e100^2 * Variance
--- Return expected results, Good
SELECT  a.City,
        FLVarP(1e100 * a.SalesPerVisit),
        VAR_POP(1e100 * a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 9: Add a very large number, results should not change
--- Results change due precision limit of platform
SELECT  a.City,
        FLVarP(1e100 + a.SalesPerVisit),
        VAR_POP(1e100 + a.SalesPerVisit),
        FLVarP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output NULL, Good
SELECT  FLVarP(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Value(Double Precision) out of range: Variance of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLVarP(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Variance of 1.0e-400 * Value
--- Returns 0 value, Good
SELECT  a.City,
        FLVarP(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
