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
--	Test Unit Number:		FLMean-Netezza-01
--
--	Name(s):		    	FLMean
--
-- 	Description:			Aggregate function which returns the arithmetic mean
--
--	Applications:		 
--
-- 	Signature:		    	FLMean(pX DOUBLE PRECISION)
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
FROM   finEquityReturns a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive Case, Compared with AVERAGE()
--- Same Output, Good
SELECT  a.City,
        FLMean(a.SalesPerVisit),
        AVG(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Mean of -1.0 * Value, Results should be -1.0 * Mean
--- Return expected results, Good
SELECT  a.City,
        FLMean(-1 * a.SalesPerVisit),
        FLMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Mean of Value + 1.0, Results should be Mean + 1.0
--- Return expected results, Good
SELECT  a.City,
        FLMean(a.SalesPerVisit + 1.0),
        FLMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Mean of -1.0 * Value + 1.0, Results should be -1.0 * Mean + 1.0
--- Return expected results, Good
SELECT  a.City,
        FLMean(-1 * a.SalesPerVisit + 1.0),
        FLMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Multiply by a very small number, Results should be 1e-100 * Mean
--- Return expected results, Good
SELECT  a.City,
        FLMean(1e-100 * a.SalesPerVisit),
        FLMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very large number, Results should be 1e100 * Mean
--- Return expected results, Good
SELECT  a.City,
        FLMean(1e100 * a.SalesPerVisit),
        FLMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Return Null, Good
SELECT  FLMean(a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Value(Double Precision) out of range: Mean of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLMean(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Mean of 1.0e-400 * Value
--- Returns 0 value, Good
SELECT  a.City,
        FLMean(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
