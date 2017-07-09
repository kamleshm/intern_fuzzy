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
--	Test Unit Number:		FLMod-TD-01
--
--	Name(s):		    	FLMod
--
-- 	Description:			Scalar function which returns the remainder after a number (dividend) is divided by another number (divisor)
--
--	Applications:		 
--
-- 	Signature:		    	FLMod(x BIGINT, n BIGINT)
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

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLMod(12,5) AS Modulo;

---- Positive Test 2: Dividend < Divisor
--- Return expected results, Good
SELECT FLMod(5,12) AS Modulo;
SELECT FLMod(0,12) AS Modulo;

---- Positive Test 3: Negative Dividend or Divisor, 
--- Return expected results, Good
SELECT FLMod(-12,5) AS Modulo;
SELECT FLMod(12,-5) AS Modulo;
SELECT FLMod(-12,-5) AS Modulo;

---- Positive Test 4: Should Output 0
--- Return expected results, Good
SELECT FLMod(12,1) AS Modulo;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Input Out of Boundary Values
--- Return expected results, Good
SELECT FLMod(CAST (2 ** 63 AS BIGINT),1) AS Modulo; 

---- Negative Test 2: Divisor = 0
--- Return expected error, Good
SELECT FLMod(12,0) AS Modulo;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLMod(12,1.0) AS Modulo;
SELECT FLMod(NULL,1) AS Modulo;
SELECT FLMod(12,NULL) AS Modulo;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
