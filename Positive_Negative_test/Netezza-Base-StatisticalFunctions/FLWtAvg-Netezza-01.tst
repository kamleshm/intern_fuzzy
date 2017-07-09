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
--	Test Unit Number:		FLWtAvg-Netezza-01
--
--	Name(s):		    	FLWtAvg
--
-- 	Description:			Aggregate function which returns the weighted average of a data series
--
--	Applications:		 
--
-- 	Signature:		    	FLWtAvg(pWt DOUBLE PRECISION, pX DOUBLE PRECISION)
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

---- Positive Test 1: Positive test cases when all weights = 1, Compared with AVG()
--- Same output, Good
SELECT  a.City,
        FLWtAvg(1, a.SalesPerVisit),
		FLMean(a.SalesPerVisit),
		AVG(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Weighted Mean of Value + 1.0, Compared with AVG(), Results should be Mean + 1.0
--- Return expected results, Good
SELECT  a.City,
        FLWtAvg(1, a.SalesPerVisit + 1.0),
        FLMean(a.SalesPerVisit),
		AVG(a.SalesPerVisit + 1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Weighted Mean of Value + 1e10, Compared with AVG(), Results should be Mean + 1e10
--- Return expected results, Good
SELECT  a.City,
        FLWtAvg(1, a.SalesPerVisit + 1e10),
        FLMean(a.SalesPerVisit),
		AVG(a.SalesPerVisit + 1e10)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Weighted Mean of -1.0 * Value + 1.0, Results should be -1.0 * Mean + 1.0
--- Return expected results, Good
SELECT  a.City,
        FLWtAvg(1, -1 * a.SalesPerVisit + 1.0),
        FLMean(a.SalesPerVisit),
		AVG(-1 * a.SalesPerVisit + 1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Multiply by a very small number, Results should be 1e-100 * Mean
--- Return expected results, Good
SELECT  a.City,
        FLWtAvg(1, 1e-100 * a.SalesPerVisit),
		FLWtAvg(1e-100 * 1, 1e-100 * a.SalesPerVisit),
        FLMean(a.SalesPerVisit),
		AVG(1e-100 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very large number, Results should be 1e100 * Mean
--- Return expected results, Good
SELECT  a.City,
        FLWtAvg(1, 1e100 * a.SalesPerVisit),
		FLWtAvg(1e100 * 1, 1e100 * a.SalesPerVisit),
        FLMEAN(a.SalesPerVisit),
		AVG(1e100 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLWtAvg(1, a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

SELECT  FLWtAvg(a.RandVal, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: 0 weighting
--- Output Null, Good
SELECT  FLWtAvg(0, a.RandVal)
FROM    fzzlSerial a;

---- Negative Test 3: Weighted Mean of -1.0 * Value
--- Negative weights are ignored, Good
SELECT  a.City,
        FLWtAvg(1, -1 * a.SalesPerVisit),
		FLWtAvg(-1, a.SalesPerVisit),
		FLWtAvg(-1 * 1, -1 * a.SalesPerVisit),
		FLWtAvg(-1, -1 * a.SalesPerVisit),
		FLWtAvg(-0.5, a.SalesPerVisit),
		FLWtAvg(-1 * a.SalesPerVisit, a.SalesPerVisit),
        FLMean(a.SalesPerVisit),
		AVG(-1 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 4: Value(Double Precision) out of range: Weighted Mean of 1.0e400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLWtAvg(1, 1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtAvg(1e400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;


---- Negative Test 5: Value(Double Precision) out of range: Weighted Mean of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLWtAvg(1, 1e-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtAvg(1e-400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
