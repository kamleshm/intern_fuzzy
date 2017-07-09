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
--	Test Unit Number:		FLFact-TD-01
--
--	Name(s):		    	FLFact
--
-- 	Description:			Scalar function which returns the factorial of a non-negative integer
--
--	Applications:		 
--
-- 	Signature:		    	FLFact(N BIGINT)
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

-- :q
-- .set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLFact(5) AS Factorial;

---- Positive Test 2: Positive Tests
--- Return expected results, Good
SELECT a.SerialVal, FLFact(a.SerialVal)
FROM 
    (SELECT TOP 170 SerialVal 
	 FROM fzzlSerial 
	 ORDER BY 1
	 ) AS a;

---- Positive Test 3: Boundary Check
--- Return expected results, Good
SELECT FLFact(0) AS Factorial;
SELECT FLFact(170) AS Factorial;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary
--- Return expected error, Good
SELECT FLFact(-1) AS Factorial;
SELECT FLFact(171) AS Factorial;

---- Negative Test 2: Invalid Data Type
--- Return expected error, Good
SELECT FLFact(NULL) AS Factorial; 
SELECT FLFact(1.2) AS Factorial;
SELECT FLFact(a) AS Factorial;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
