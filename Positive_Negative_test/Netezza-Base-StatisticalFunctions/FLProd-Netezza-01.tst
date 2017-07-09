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
--	Test Unit Number:		FLProd-Netezza-01
--
--	Name(s):		    	FLProd
--
-- 	Description:			Aggregate function which returns the product
--
--	Applications:		 
--
-- 	Signature:		    	FLProd(pX DOUBLE PRECISION)
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

---- Positive Test 1: Positive test cases
SELECT  a.City,
        FLProd(a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Product of -1.0 * Value,  Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLProd(-1 * a.SalesPerVisit),
        FLProd(a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Product of 10.0 * Value, Results should be 1E30 * Product of Value
--- Return expected results, Good
SELECT  a.City,
        FLProd(10 * a.SalesPerVisit),
        FLProd(a.SalesPerVisit),
		Count(*)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Multiply by a very small number, Results should be 1e-300 * Product of Value
--- Return expected results, Good
SELECT  a.City,
        FLProd(1e-10 * a.SalesPerVisit),
        FLProd(a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Multiply by a very large number, results should be 1e300* Product of Value which is out of boundary of double
--- Return numeric overflow, Good
SELECT  a.City,
        FLProd(1e10 * a.SalesPerVisit),
        FLProd(a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLProd(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Value(Double Precision) out of range: Product of 1.0e400 * Value
--- Return expected error, Good
SELECT  a.City,
        FLProd(1e400 * a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Product of 1.0e-400 * Value
--- Return expected error, Good
SELECT  a.City,
        FLProd(1e-400 * a.SalesPerVisit)
FROM    tblCustData a
WHERE   a.OBSID <= 30
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
