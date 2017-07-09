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
--	Test Unit Number:		FLGeoMean-Netezza-01
--
--	Name(s):		    	FLGeoMean
--
-- 	Description:			Aggregate function which returns the geometric mean
--
--	Applications:		 
--
-- 	Signature:		    	FLGeoMean(pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			10-18-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS --TestOutcome
--FROM   tblCustData a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive test case 1
SELECT  a.City,
        FLGeoMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Geo Mean of 10 * Value, Results should be 10 * Geo Mean
--- Return expected results, Good
SELECT  a.City,
        FLGeoMean(10 * a.SalesPerVisit),
        FLGeoMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Multiply by a very small number, Results should be 1e-100 * Geo Mean
--- Return expected results, Good
SELECT  a.City,
        FLGeoMean(1e-100 * a.SalesPerVisit),
        FLGeoMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Multiply by a very large number, Results Should be 1e100 * Geo Mean
--- Return expected results, Good
SELECT  a.City,
        FLGeoMean(1e100 * a.SalesPerVisit),
        FLGeoMean(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Return Null, Good
SELECT  FLGeoMean(a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Condition test (X>0): Geo Mean of -0.0 * Value
--- Output Expected Error, Good
SELECT  a.City,
        FLGeoMean(-0.0 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Condition test (X>0): Geo Mean of Value * -1.0
--- Output Expected Error, Good
SELECT  a.City,
        FLGeoMean(a.SalesPerVisit* -1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 4: Value(Double Precision) out of range: Geo Mean of 1.0e400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLGeoMean(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 5: Value(Double Precision) out of range: Geo Mean of 1.0e-400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLGeoMean(1E-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
