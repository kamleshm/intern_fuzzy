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
--	Test Unit Number:		FLinvcoth-Netezza-01
--
--	Name(s):		    	FLinvcoth
--
-- 	Description:			Scalar function which returns the hyperbolic arccotangent
--
--	Applications:		 
--
-- 	Signature:		    	FLinvcoth(N DOUBLE PRECISION)
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
SELECT FLinvcoth(5) AS acoth;
SELECT FLinvcoth(50) AS acoth;


---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLinvcoth(10) AS acoth;
SELECT FLinvcoth(FLCoth(0.099668652491162))AS acoth;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLinvcoth(FLCoth(FLDeg2Rad(45)))AS acoth;
SELECT FLinvcoth(FLCoth(FLDeg2Rad(-315)))AS acoth;

---- Positive Test 4: Boundary check
--- Return expected results, Good
SELECT FLinvcoth(1e-307)AS acoth;
SELECT FLinvcoth(-1e-307)AS acoth;
SELECT FLinvcoth(1e308)AS acoth;
SELECT FLinvcoth(-1e308)AS acoth;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary
--- Return expected error, Good
SELECT FLinvcoth(1e-400) AS acoth;
SELECT FLinvcoth(-1e-400) AS acoth;
SELECT FLinvcoth(1e400) AS acoth;
SELECT FLinvcoth(-1e400) AS acoth;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLinvcoth(NULL) AS acoth;
SELECT FLinvcoth(NULL * -1) AS acoth;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
