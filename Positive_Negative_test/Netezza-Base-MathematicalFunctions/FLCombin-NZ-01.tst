-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Aster
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
--	Test Unit Number:		FLCombin-Aster-01
--
--	Name(s):		    	FLCombin
--
-- 	Description:			Scalar function which returns the number of combinations
--
--	Applications:		 
--
-- 	Signature:		    	FLCombin(n BIGINT, r BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			10-12-2015
--
--	Author:			    	<tanya.sinha@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT
\timing on


-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLCombin(4,2) AS Combin;

---- Positive Test 2: Close to Upper Bound
--- Return expected results, Good
SELECT FLCombin(1031,491) AS Combin;

---- Positive Test 3: Input Large Value, Results should be 1e10
--- Return expected results, Good
SELECT FLCombin(CAST (1e10 AS BIGINT),CAST ((1e10-1) AS BIGINT)) AS Combin0,
       FLCombin(CAST (1e5 AS BIGINT),CAST ((1e5-1) AS BIGINT)) AS Combin1,
       FLCombin(CAST (1e3 AS BIGINT),CAST ((1e3-1) AS BIGINT)) AS Combin2,
       FLCombin(1000 ,999) AS Combin3,
       FLCombin(100 ,99) AS Combin4,
       FLCombin(10 ,9) AS Combin5;

---- Positive Test 4: Zero, Results should be 1
--- Return expected results, Good
SELECT FLCombin(0,0) AS Combin;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Data Type
--- Return expected error, Good
SELECT FLCombin(NULL,2);
SELECT FLCombin(2,NULL);
SELECT FLCombin(4.0,2);
SELECT FLCombin(4,2.0);

---- Negative Test 2: First Parameter(n) < Second Parameter(r)
--- Return expected error, Good
SELECT FLCombin(2,4);

---- Negative Test 3: Negative Input
--- Return expected error, Good
SELECT FLCombin(-3,2);
SELECT FLCombin(4,-2);

--- Negative Test 4: Wrong number of Params
--- Return expected error, Good
SELECT FLCombin(4,2,1);

-- END: NEGATIVE TEST(s)

-- END: TEST SCRIPT
\timing off


