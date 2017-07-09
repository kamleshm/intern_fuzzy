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
--	Test Unit Number:		FLSinh-Netezza-01
--
--	Name(s):		    	FLSinh
--
-- 	Description:			Scalar function which returns the hyperbolic sine
--
--	Applications:		 
--
-- 	Signature:		    	FLSinh(N DOUBLE PRECISION)
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
SELECT FLSinh(0.5) AS Sinh;
SELECT FLSinh(50) AS Sinh;
SELECT FLSinh(0) AS Sinh;

---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLSinh(1.5707963267949) AS Sinh;
SELECT FLSinh(FLDeg2Rad(90))AS Sinh;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLSinh(FLDeg2Rad(-90))AS Sinh;
SELECT FLSinh(FLDeg2Rad(270))AS Sinh;

---- Positive Test 4: Negative values or value * -1
--- Return expected results, Good
SELECT FLSinh(-3.14) AS Sinh;
SELECT FLSinh(3.14 * -1) AS Sinh;
SELECT FLSinh(-3.14 * -1) AS Sinh;

---- Positive Test 5: Boundary Check
--- Return expected results, Good
SELECT FLSinh(1e308) AS Sinh;
SELECT FLSinh(1e-307) AS Sinh;
SELECT FLSinh(-1e308) AS Sinh;
SELECT FLSinh(-1e-307) AS Sinh;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary for arguments
--- Return expected error, Good
SELECT FLSinh(1e400) AS Sinh;
SELECT FLSinh(1e-400) AS Sinh;
SELECT FLSinh(-1e400) AS Sinh;
SELECT FLSinh(-1e-400) AS Sinh;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLSinh(NULL) AS Sinh;
SELECT FLSinh(NULL * -1) AS Sinh;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
