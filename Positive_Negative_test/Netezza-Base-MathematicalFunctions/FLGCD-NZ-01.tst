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
--	Test Unit Number:		FLGCD-TD-01
--
--	Name(s):		    	FLGCD
--
-- 	Description:			Scalar function which returns the greatest common divisor of two numbers
--
--	Applications:		 
--
-- 	Signature:		    	FLGCD(A BIGINT, B BIGINT)
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
SELECT FLGCD(42,144);

---- Positive Test 2: Associative Law gcd(a, gcd(b, c)) = gcd(gcd(a, b), c)
--- Return expected results, Good
SELECT a.SerialVal AS a, 
       a.SerialVal + 100 AS b, 
	   a.SerialVal +1000 AS c, 
	   FLGCD(a, FLGCD(b, c)) AS GCD1,
	   FLGCD(FLGCD(a, b), c) AS GCD2
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

---- Positive Test 4: Greatest Common Divisor of -1 * Value
--- Return expected results, Good
SELECT FLGCD(42 * -1, 144 * -1);

---- Positive Test 5: Greatest Common Divisor of 0 and Value
SELECT FLGCD(0, 144);

---- Positive Test 6: Greatest Common Divisor of Value and Value * n
--- Return expected results, Good
SELECT a.SerialVal, FLGCD(42, 42 * a.SerialVal) AS GCD
FROM   fzzlserial a
WHERE  a.SerialVal < 100;

---- Positive Test 7: Bound Testing 
--- Return expected results, Good
SELECT FLGCD(1, CAST(1e9 AS BIGINT));

SELECT a.SerialVal, FLGCD(CAST(1e9 AS BIGINT), a.SerialVal) AS GCD
FROM   fzzlserial a
WHERE  a.SerialVal < 1e5 AND a.SerialVal > 1e5 -10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Zeros
--- Return expected error, Good
SELECT FLGCD(0,0);

---- Negative Test 2: Out of Boundary
--- Return expected error, Good
SELECT FLGCD(1, CAST(1e10 AS BIGINT));

---- Negative Test 3: Invalid data type
--- Return expected error, Good
SELECT FLGCD(42.0, 144);
SELECT FLGCD(NULL, 144);
SELECT FLGCD(144, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
