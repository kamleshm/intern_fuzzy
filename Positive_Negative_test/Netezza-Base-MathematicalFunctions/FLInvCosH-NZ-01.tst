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
--	Test Unit Number:		FLinvcosh-Netezza-01
--
--	Name(s):		    	FLinvcosh
--
-- 	Description:			Scalar function which returns the hyperbolic arccosine
--
--	Applications:		 
--
-- 	Signature:		    	FLinvcosh(N DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			05-15-2017
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive Tests
--- Same Output, Good
SELECT FLinvcosh(0.5) AS acosh;
SELECT FLinvcosh(-0.5) AS acosh;


---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLinvcosh(1) AS acosh;
SELECT FLinvcosh(FLCosh(1.5707963267949))AS acosh;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLinvcosh(FLCosh(FLDeg2Rad(45)))AS acosh;
SELECT FLinvcosh(FLCosh(FLDeg2Rad(-315)))AS acosh;

---- Positive Test 4: Boundary check
--- Return expected results, Good
SELECT FLinvcosh(1)AS acosh;
SELECT FLinvcosh(-1)AS acosh;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary
--- Return expected error, Good
SELECT FLinvcosh(1.0000000001) AS acosh;
SELECT FLinvcosh(-1.0000000001) AS acosh;
SELECT FLinvcosh(1e400) AS acosh;
SELECT FLinvcosh(-1e-400) AS acosh;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLinvcosh(NULL) AS acosh;
SELECT FLinvcosh(NULL * -1) AS acosh;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
