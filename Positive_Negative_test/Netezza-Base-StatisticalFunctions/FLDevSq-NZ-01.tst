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
--	Test Unit Number:		FLDevSq-Netezza-01
--
--	Name(s):		    	FLDevSq
--
-- 	Description:			Aggregate function which returns the sum of the squares of the deviation from the arithmetic mean
--
--	Applications:		 
--
-- 	Signature:		    	FLDevSq(pX DOUBLE PRECISION)
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

--.run file=../PulsarLogOn.sql
\time
--.set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   tblCustData a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive test cases, Results should be n * VAR_POP()
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(a.SalesPerVisit), 
		VAR_POP(a.SalesPerVisit) * Count(*)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Deviation Square of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(-1 * a.SalesPerVisit),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Deviation Square of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(a.SalesPerVisit + 1.0),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Deviation Square of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(-1 * a.SalesPerVisit + 1.0),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Deviation Square of 10.0 * Value + 1.0, Results should be 10^2 * Deviation Square
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(10 * a.SalesPerVisit + 1.0),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very small number, Results should be 1e-100^2 * Deviation Square
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(1e-100 * a.SalesPerVisit),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very large number, Results should be 1e100^2 * Deviation Square
--- Return expected results, Good
SELECT  a.City,
        FLDevSq(1e100 * a.SalesPerVisit),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 8: Add a very large number, Results should not change
--- Results changes due to Precision limit
--- Need to be investigated
SELECT  a.City,
        FLDevSq(1e100 + a.SalesPerVisit),
		FLDevSq(1e10 + a.SalesPerVisit),
        FLDevSq(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLDevSq(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Value(Double Precision) out of range: Deviation Square of of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLDevSq(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Deviation Square of 1.0e-400 * Value
--- Returns 0 value, Good
SELECT  a.City,
        FLDevSq(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
