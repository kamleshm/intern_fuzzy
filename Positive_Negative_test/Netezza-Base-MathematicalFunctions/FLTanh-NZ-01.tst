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
--	Test Unit Number:		FLTanh-Netezza-01
--
--	Name(s):		    	FLTanh
--
-- 	Description:			Scalar function which returns the hyperbolic tangent
--
--	Applications:		 
--
-- 	Signature:		    	FLTanh(N DOUBLE PRECISION)
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
SELECT FLTanh(0.5) AS tanh;
SELECT FLTanh(50) AS tanh;
SELECT FLTanh(0) AS tanh;

---- Positive Test 2: The Output of both should be same
--- Same Output, Good
SELECT FLTanh(0.785398163397449) AS tanh;
SELECT FLTanh(FLDeg2Rad(45))AS tanh;

---- Positive Test 3: Positive Tests
--- Return expected results, Good
SELECT FLTanh(FLDeg2Rad(45))AS tanh;
SELECT FLTanh(FLDeg2Rad(-315))AS tanh;

---- Positive Test 4: Boundary check for tangent
--- Return expected results, Good
SELECT FLTanh(0)AS tanh;
SELECT FLTanh(0.000000000001)AS tanh;
SELECT FLTanh(-0.000000000001)AS tanh;

---- Positive Test 5: Negative values or value * -1
--- Return expected results;
SELECT FLTanh(3.14 * -1) AS tanh;
SELECT FLTanh(-3.14 * -1) AS tanh;

---- Positive Test 6: Boundary Check
--- Return expected results, Good
SELECT FLTanh(1e308) AS tanh;
SELECT FLTanh(1e-307) AS tanh;
SELECT FLTanh(-1e308) AS tanh;
SELECT FLTanh(-1e-307) AS tanh;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary for arguments
--- Return expected error, Good
SELECT FLTanh(1e400) AS tanh;
SELECT FLTanh(1e-400) AS tanh;
SELECT FLTanh(-1e400) AS tanh;
SELECT FLTanh(-1e-400) AS tanh;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLTanh(NULL) AS tanh;
SELECT FLTanh(NULL * -1) AS tanh;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
