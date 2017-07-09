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
--	Test Unit Number:		FLRad2Deg-TD-01
--
--	Name(s):		    	FLRad2Deg
--
-- 	Description:			Scalar function which converts radians to degrees
--
--	Applications:		 
--
-- 	Signature:		    	FLRad2Deg(rad DOUBLE PRECISION)
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
SELECT FLRad2Deg(FLDeg2Rad(180.0)) AS Degree;
SELECT FLRad2Deg(3.14159265358979) AS Degree;

---- Positive Test 2: Value * -1.0
--- Return expected results, Good
SELECT FLRad2Deg(3.14159265358979 * -1.0) AS Degree;

---- Positive Test 3: Value * 1e100
--- Return expected results, Good
SELECT FLRad2Deg(3.14159265358979 * 1e100) AS Degree;

---- Positive Test 4: Value * 1e-100
--- Return expected results, Good
SELECT FLRad2Deg(3.14159265358979 * 1e-100) AS Degree;

---- Positive Test 5: Value * 1e-307
--- Return expected results, Good
SELECT FLRad2Deg(3.14159265358979 * 1e-307) AS Degree;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of boundary 1e-400
--- Return expected error, Good
SELECT FLRad2Deg(1e-400) AS Radian;

---- Negative Test 2: Invalid Input
--- Return expected error, Good
SELECT FLRad2Deg(NULL) AS Degree;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
