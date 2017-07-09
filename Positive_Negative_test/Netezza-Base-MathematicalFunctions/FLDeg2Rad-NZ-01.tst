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
--	Test Unit Number:		FLCorrel-TD-01
--
--	Name(s):		    	FLCorrel
--
-- 	Description:			Aggregate function which returns the correlation of 2 vectors
--
--	Applications:		 
--
-- 	Signature:		    	FLCorrel(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
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
SELECT FLDeg2Rad(180.0) AS Radian;

---- Positive Test 2: Positive Cases
--- Return expected results, Good
SELECT a.SerialVal, 
       FLDeg2Rad(a.SerialVal) AS Radian
FROM   fzzlserial a
WHERE  a.SerialVal <= 180
ORDER BY 1;

---- Positive Test 3: Value * -1.0
--- Return expected results, Good
SELECT FLDeg2Rad(-180.0) AS Radian;

---- Positive Test 4: Value * 1e100
--- Return expected results, Good
SELECT FLDeg2Rad(180.0 * 1e100) AS Radian;

---- Positive Test 5: Value * 1e-100
--- Return expected results, Good
SELECT FLDeg2Rad(180.0 * 1e-100) AS Radian;

---- Positive Test 6: Value * 1e-307
--- Return expected results, Good
SELECT FLDeg2Rad(180.0 * 1e-307) AS Radian;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of boundary 1e-400
--- Return expected error, Good
SELECT FLDeg2Rad(1e-400) AS Radian;

---- Negative Test 2: Invalid Input
--- Return expected error, Good
SELECT FLDeg2Rad(NULL) AS Radian;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
