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
-- 	Test Category:		    Math Functions
--
--	Test Unit Number:		FLSech-Netezza-01
--
--	Name(s):		    	FLSech
--
-- 	Description:			Scalar function which returns the hyperbolic secant
--
--	Applications:		 
--
-- 	Signature:		    	FLSech(N DOUBLE PRECISION)
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

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive Tests
--- Same Output, Good
SELECT FLSech(0.5) AS sech;
SELECT FLSech(50) AS sech;


---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLSech(0.785398163397448) AS sech;
SELECT FLSech(FLDeg2Rad(45))AS sech;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLSech(FLDeg2Rad(45))AS sech;
SELECT FLSech(FLDeg2Rad(-315))AS sech;

---- Positive Test 4: Boundary check for secant
--- Return expected results, Good
SELECT FLSech(FLDeg2Rad(90))AS sech;
SELECT FLSech(FLDeg2Rad(90.000000000001))AS sech;
SELECT FLSech(FLDeg2Rad(89.999999999999))AS sech;

---- Positive Test 5: Same values
--- Return expected results;
SELECT FLSech(3.14 * -1) AS sech;
SELECT FLSech(-3.14 * -1) AS sech;

---- Positive Test 6: Boundary Check
--- Return expected results, Good
SELECT FLSech(1e308) AS sech;
SELECT FLSech(1e-307) AS sech;
SELECT FLSech(-1e308) AS sech;
SELECT FLSech(-1e-307) AS sech;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary for arguments
--- Return expected error, Good
SELECT FLSech(1e400) AS sech;
SELECT FLSech(1e-400) AS sech;
SELECT FLSech(-1e400) AS sech;
SELECT FLSech(-1e-400) AS sech;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLSech(NULL) AS sech;
SELECT FLSech(NULL * -1) AS sech;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
