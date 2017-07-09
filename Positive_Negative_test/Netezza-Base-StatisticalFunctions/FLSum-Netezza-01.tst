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
--	Test Unit Number:		FLSum-Netezza-01
--
--	Name(s):		    	FLSum
--
-- 	Description:			Aggregate function which returns the sum
--
--	Applications:		 
--
-- 	Signature:		    	FLSum(pX DOUBLE PRECISION)
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

---- Positive Test 1: Compared with SUM()
--- Same Output, Good
SELECT  a.City,
        FLSum(a.SalesPerVisit),
		SUM(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: SUM of -1.0 * Value, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(-1 * a.SalesPerVisit),
        FLSum(a.SalesPerVisit),
		SUM(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: SUM of Value + 1.0, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(a.SalesPerVisit + 1.0),
		SUM(a.SalesPerVisit + 1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: SUM of -1.0 * Value + 1.0, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(-1 * a.SalesPerVisit + 1.0),
		SUM(-1 * a.SalesPerVisit + 1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: SUM of 10.0 * Value + 1.0, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(10 * a.SalesPerVisit + 1.0),
		SUM(10 * a.SalesPerVisit + 1.0)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very small number, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(1e-100 * a.SalesPerVisit),
        FLSum(a.SalesPerVisit),
		SUM(1e-100 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very large number, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(1e100 * a.SalesPerVisit),
        FLSum(a.SalesPerVisit),
		SUM(1e100 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 8: Add a very large number, Compared with SUM()
--- Return expected results, Good
SELECT  a.City,
        FLSum(1e100 + a.SalesPerVisit),
		SUM(1e100 + a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLSum(a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1; 

---- Negative Test 2: Value(Double Precision) out of range: SUM of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLSum(1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: SUM of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLSum(1e-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
