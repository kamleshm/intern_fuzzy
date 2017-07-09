-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
-- 	Test Category:		    Math Functions
--
--	Test Unit Number:		FLLCM-TD-01
--
--	Name(s):		    	FLLCM
--
-- 	Description:			Scalar function which returns the least common multiple of two numbers
--
--	Applications:		 
--
-- 	Signature:		    	FLLCM(A BIGINT, B BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			BIGINT
--
--	Last Updated:			01-29-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   fzzlserial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLLCM(42,144);

---- Positive Test 2: Associative Law lcm(a, lcm(b, c)) = lcm(lcm(a, b), c)
--- Return expected results, Good
SELECT a.SerialVal AS a, 
       a.SerialVal + 100 AS b, 
	   a.SerialVal +1000 AS c, 
	   FLLCM(a, FLLCM(b, c)) AS GCD1,
	   FLLCM(FLLCM(a, b), c) AS GCD2
FROM   fzzlserial a
WHERE  a.SerialVal < 100;

---- Positive Test 3: Absorption Law lcm(a, gcd(a, b)) = a; gcd(a, lcm(a, b)) = a
--- Return expected results, Good
SELECT a.SerialVal AS a, 
       a.SerialVal + 100 AS b, 
	   FLLCM(a, FLGCD(a, b)) AS GCD1,
	   FLGCD(FLLCM(a, b), a) AS GCD2
FROM   fzzlserial a
WHERE  a.SerialVal < 100;

---- Positive Test 4: Least Common Multiple of -1 * Value
--- Return expected results, Good
SELECT FLLCM(42 * -1, 144 * -1);

---- Positive Test 5: Least Common Multiple of 0 and Value
--- Output zero; Need to Discuss. If we count zero as a common multiple, then zero would be the least common multiple of any two numbers
SELECT FLLCM(0, 144);

---- Positive Test 6: Least Common Multiple of Value and Value * n
--- Return expected results, Good
SELECT a.SerialVal, FLLCM(42, 42 * a.SerialVal) AS GCD
FROM   fzzlserial a
WHERE  a.SerialVal < 100;

---- Positive Test 7: Bound Testing
--- Return expected results, Good
SELECT FLLCM(1, CAST(1e9 AS BIGINT));

SELECT a.SerialVal, FLLCM(CAST(1e9 AS BIGINT), a.SerialVal) AS GCD
FROM   fzzlserial a
WHERE  a.SerialVal < 1e9 AND a.SerialVal > 1e9 -5;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---------- Negative Testing
---- Negative Test 1: Zeros
--- Return expected error, Good
SELECT FLLCM(0,0);

---- Negative Test 2: Bound Testing
--- Function caused a floating point exception: invalid arithmetic operation, Good
SELECT FLLCM(1, CAST(1e10 AS BIGINT));

---- Negative Test 3: Invalid data type
--- Return expected error, Good
SELECT FLLCM(42.0, 144);
SELECT FLLCM(NULL, 144);
SELECT FLLCM(42, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
