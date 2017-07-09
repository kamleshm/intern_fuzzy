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
--	Test Unit Number:		FLPercWin-Netezza-01
--
--	Name(s):		    	FLPercWin
--
-- 	Description:			User defined table function which returns the specified percentile
--
--	Applications:		 
--
-- 	Signature:		    	FLPercWin(pValue DOUBLE PRECISION, pPerc DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			11-21-2014
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

---- Positive Test 1: One observation, Any quantile should be the value itself
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal <=1
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal =2
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 2: Two observations
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal <=2
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 3: Positive test cases, Results should be 50.5, Compared with FLMedianUdt()
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;


---- Positive Test 4: Mixed with Nulls, Results shoud not change
--- Return expected results
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.50) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, CASE WHEN SerialVal <= 100 THEN SerialVal ELSE NULL END as Val
FROM fzzlSerial
WHERE SerialVal <=200
) a
) AS p

ORDER BY 1;


---- Positive Test 5: Percentile of -1.0 * Value, Results should be -25.75
--- Return expected results
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(-1.0*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 6: Percentile of Value + 1.0, Results should be 75.25 + 1
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val+1.0, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 7: Percentile of -1.0 * Value + 1.0, Results should be -25.75 + 1
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(-1.0*a.Val+1.0, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 8: Percentile of 10.0 * Value + 1.0, Results should be  75.25 * 10 + 1
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(10.0*a.Val+1.0, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 9: Multiply by a very small number, Results should be 1e-100 * 75.25
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e-100*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 10: Multiply by a very large number, Results should be 1e100 * 75.25
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e100*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 11: Add a very large number, Should return 1e100+ 75.25
--- Precision issue, return 1e100, which is expected
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e100+a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- No Output
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal <=-1
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 2: Value(Double Precision) out of range: Percentile of 1.0e400 * Value
--- Return expected error, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e400*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Percentile of 1.0e-400 * Value
--- Return expected error, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e-400*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 4: Invalid Data Type:Input Varchar
--- Return expected error, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(1e100*a.Val, 0.75) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, CAST(SerialVal AS VARCHAR(30)) as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;


---- Negative Test 5: Percentile
---- Negative Test 5a: Very Small value, Results should be 1
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 1e-100) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, serialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 5b: 0 Percentile, Results should be 1
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 0.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, serialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 5c: 1 percentile, Results should be 100
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 1.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, serialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 5d: percentile> 1, Should be Error msg
--- Return expected error, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLPercWin(a.Val, 20.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, serialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
