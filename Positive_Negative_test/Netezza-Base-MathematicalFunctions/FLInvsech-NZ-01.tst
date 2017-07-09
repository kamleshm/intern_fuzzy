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
--	Test Unit Number:		FLinvsech-Netezza-01
--
--	Name(s):		    	FLinvsech
--
-- 	Description:			Scalar function which returns the hyperbolic arcsecant
--
--	Applications:		 
--
-- 	Signature:		    	FLinvsech(N DOUBLE PRECISION)
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
SELECT FLinvsech(5) AS asech;
SELECT FLinvsech(50) AS asech;


---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLinvsech(10) AS asech;
SELECT FLinvsech(FLSech(1.47062890563334))AS asech;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLinvsech(FLSech(FLDeg2Rad(45)))AS asech;
SELECT FLinvsech(FLSech(FLDeg2Rad(-315)))AS asech;

---- Positive Test 4: Boundary check
--- Return expected results, Good
SELECT FLinvsech(1)AS asech;
SELECT FLinvsech(-1)AS asech;
SELECT FLinvsech(1e308)AS asech;
SELECT FLinvsech(-1e308)AS asech;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary
--- Return expected error, Good
SELECT FLinvsech(0.99999999999) AS asech;
SELECT FLinvsech(-0.99999999999) AS asech;
SELECT FLinvsech(1e-400) AS asech;
SELECT FLinvsech(-1e-400) AS asech;
SELECT FLinvsech(1e400) AS asech;
SELECT FLinvsech(-1e400) AS asech;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLinvsech(NULL) AS asech;
SELECT FLinvsech(NULL * -1) AS asech;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
