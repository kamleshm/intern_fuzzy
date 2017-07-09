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
--	Test Unit Number:		FLPermut-TD-01
--
--	Name(s):		    	FLPermut
--
-- 	Description:			Scalar function which returns the number of permutations
--
--	Applications:		 
--
-- 	Signature:		    	FLPermut(n BIGINT, r BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
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
SELECT FLPermut(4,2) AS Permut;

---- Positive Test 2: Should be the Same
--- Return expected results, Good
SELECT FLPermut(140,139) AS Permut;
SELECT FLPermut(140,140) AS Permut;

---- Positive Test 3: Close to Upp Bound
--- Return expected results, Good
SELECT FLPermut(170,169) AS Permut;
SELECT FLPermut(171,167) AS Permut;
SELECT FLPermut(172,165) AS Permut;
SELECT FLPermut(173,164) AS Permut;

---- Positive Test 4: Input Zeros
--- Return expected results, Good
SELECT FLPermut(0,0) AS Permut;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Bound Output
--- Return expected error, Good
SELECT FLPermut(171,168);
SELECT FLPermut(172,166);

---- Negative Test 2: First Para < Second Para
--- Return expected error, Good
SELECT FLPermut(2,4);

---- Negative Test 3: Negative Input
--- Return expected error, Good
SELECT FLPermut(-3,2);
SELECT FLPermut(4,-2);

---- Negative Test 4: Invalid Data Type
--- Return expected error, Good
SELECT FLPermut(NULL,2);
SELECT FLPermut(2,NULL);
SELECT FLPermut(4.0,2);
SELECT FLPermut(4,2.0);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
