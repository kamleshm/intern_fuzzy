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
--	Test Unit Number:		FLHarMean-Netezza-01
--
--	Name(s):		    	FLHarMean
--
-- 	Description:			Aggregate function which returns the harmonic mean
--
--	Applications:		 
--
-- 	Signature:		    	FLHarMean(pX DOUBLE PRECISION)
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
FROM   tblCustData a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive test case 1
SELECT  a.City,
        FLHarMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Multiply by a very small number, Results should be 1e-100 * Har Mean
--- Return expected results, Good
SELECT  a.City,
        FLHarMean(1e-100 * a.SalesPerVisit),
        FLHarMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Multiply by a very large number, Results should be 1e100 * Har Mean
--- Return expected results, Good
SELECT  a.City,
        FLHarMean(1e100 * a.SalesPerVisit),
        FLHarMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)
---- Negative Test 1: No data
--- Return Null, Good
SELECT  FLHarMean(a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Condition test (X>0): Harmonic Mean of -1.0 * Value
--- Output expected error, Good
SELECT  a.City,
        FLHarMean(-1 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Condition test (X>0): Harmonic Mean of 0.0 * Value
--- Output expected error, Good
SELECT  a.City,
        FLHarMean(0.0 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 4: Value(Double Precision) out of range: Harmonic Mean of 1.0e400 * Value
---  Numeric Overflow error, Good 
SELECT  a.City,
        FLHarMean(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 5: Value(Double Precision) out of range: Harmonic Mean of 1.0e-400 * Value
--- Output expected error, Good
SELECT  a.City,
        FLHarMean(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
