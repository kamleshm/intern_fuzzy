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
--	Test Unit Number:		FLMedianWin-Netezza-01
--
--	Name(s):		    	FLMedianWin
--
-- 	Description:			Aggregate function which calculates the median
--
--	Applications:		 
--
-- 	Signature:		    	FLMedianwIN(pValue DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
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
FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: One observation
--- Return expected results, Good

SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal <=1
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;


---- Positive Test 2: Even number, Should return 50.5
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 3: Odd number, Should return 50
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=99
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 4: Median of -1.0 * Value, Results should be -50.5
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val * -1.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 5: Median of Value + 1.0, Result should be 51.5
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val+1.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 6: Median of -1.0 * Value + 1.0, Result should be -49.5
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(-1.0*a.Val+1.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 7: Median of 10.0 * Value + 1.0, Result should be 506
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(10*a.Val+1.0) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 8: Multiply by a very small number, Results should be 50.5 * 1e-100
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(1e-100 *a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 9: Multiply by a very large number, Results should be 50.5 * 1e100
--- Return expected results, Good
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(1e100 *a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Positive Test 10: Add a very large number, results should be 50.5 + 1e100
--- Return 1e100 since the precision limit of double
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(1e100 +a.Val) OVER(PARTITION BY a.Grp) AS Median
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
-- No Output
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, RandVal as Val
FROM fzzlSerial
WHERE SerialVal <=-1
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 2: Value(Double Precision) out of range: Median of 1.0e400 * Value
---  Numeric Overflow error, Good 
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(1e400 *a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Median of 1.0e-400 * Value
---  Returns 0 value, Good 
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(1e-400 *a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, SerialVal as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

---- Negative Test 4: Invalid Data Type: Input Varchar
--- Return expected error, Good
--- To be investigated
SELECT p.*
FROM (
SELECT a.Grp,
FLMedianWIN(a.Val) OVER(PARTITION BY a.Grp) AS Median
FROM (
SELECT 1 as Grp, CAST(SerialVal AS VARCHAR(30)) as Val
FROM fzzlSerial
WHERE SerialVal <=100
) a
) AS p
WHERE p.Median IS NOT NULL
ORDER BY 1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
