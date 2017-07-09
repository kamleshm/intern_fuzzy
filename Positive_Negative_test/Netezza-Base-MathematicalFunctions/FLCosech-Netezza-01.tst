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
--	Test Unit Number:		FLCosech-Netezza-01
--
--	Name(s):		    	FLCosech
--
-- 	Description:			Scalar function which returns the hyperbolic cosecant
--
--	Applications:		 
--
-- 	Signature:		    	FLCosech(N DOUBLE PRECISION)
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
--- Output, Good
SELECT FLCosech(0.5) AS Cosech;
SELECT FLCosech(50) AS Cosech;


---- Positive Test 2: Positive Tests
--- Output, Good
SELECT FLCosech(0.785398163397448) AS Cosech;
SELECT FLCosech(FLDeg2Rad(45))AS Cosech;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLCosech(FLDeg2Rad(45))AS Cosech;
SELECT FLCosech(FLDeg2Rad(-315))AS Cosech;

---- Positive Test 4: Boundary check for cosech
--- Return expected results, Good
SELECT FLCosech(FLDeg2Rad(0))AS Cosech;
SELECT FLCosech(FLDeg2Rad(-0.000000000001))AS Cosech;
SELECT FLCosech(FLDeg2Rad(0.000000000001))AS Cosech;

---- Positive Test 5: Negative values or value * -1
--- Return expected results
SELECT FLCosech(3.14 * -1) AS Cosech;
SELECT FLCosech(-3.14 * -1) AS Cosech;

---- Positive Test 6: Boundary Check
--- Return expected results, Good
SELECT FLCosech(1e308) AS Cosech;
SELECT FLCosech(1e-307) AS Cosech;
SELECT FLCosech(-1e308) AS Cosech;
SELECT FLCosech(-1e-307) AS Cosech;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary for arguments
--- Return expected error, Good
SELECT FLCosech(1e400) AS Cosech;
SELECT FLCosech(1e-400) AS Cosech;
SELECT FLCosech(-1e400) AS Cosech;
SELECT FLCosech(-1e-400) AS Cosech;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLCosech(NULL) AS Cosech;
SELECT FLCosech(NULL * -1) AS Cosech;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
