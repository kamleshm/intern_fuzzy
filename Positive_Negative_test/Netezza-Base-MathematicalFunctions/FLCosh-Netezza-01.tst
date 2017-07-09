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
--	Test Unit Number:		FLCosh-Netezza-01
--
--	Name(s):		    	FLCosh
--
-- 	Description:			Scalar function which returns the hyperbolic cosine
--
--	Applications:		 
--
-- 	Signature:		    	FLCosh(N DOUBLE PRECISION)
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
SELECT FLCosh(0.5) AS cosh;
SELECT FLCosh(50) AS cosh;
SELECT FLCosh(0) AS cosh;

---- Positive Test 2: Values should be same
--- Output, Good
SELECT FLCosh(3.14159265358979) AS cosh;
SELECT FLCosh(FLDeg2Rad(180))AS cosh;

---- Positive Test 3: Values should be same
--- Return expected results, Good
SELECT FLCosh(FLDeg2Rad(180))AS cosh;
SELECT flcosh(FLDeg2Rad(-180))AS cosh;

---- Positive Test 4: Values should be same
--- Return expected results, Good
SELECT flcosh(-3.14) AS cosh;
SELECT flcosh(3.14 * -1) AS cosh;
SELECT flcosh(-3.14 * -1) AS cosh;

---- Positive Test 5: Boundary Check
--- Return expected results, Good
SELECT flcosh(1e308) AS cosh;
SELECT flcosh(1e-307) AS cosh;
SELECT flcosh(-1e308) AS cosh;
SELECT flcosh(-1e-307) AS cosh;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary for arguments
--- Return expected error, Good
SELECT flcosh(1e400) AS cosh;
SELECT flcosh(1e-400) AS cosh;
SELECT flcosh(-1e400) AS cosh;
SELECT flcosh(-1e-400) AS cosh;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT flcosh(NULL) AS cosh;
SELECT flcosh(NULL * -1) AS cosh;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
