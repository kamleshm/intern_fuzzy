-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2017 Fuzzy Logix, LLC
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
--	Test Unit Number:		FLNormGain-NZ-01
--
--	Name(s):		    	FLNormGain
--
-- 	Description:			Scalar function which returns the normalized gain over a threshold.
--
--	Applications:		 
--
-- 	Signature:		    	FLNormGain(x DOUBLE PRECISION, y DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			05-15-2017
--
--	Author:			    	<Sam.Sharma@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Output less than 100
--- Return expected results, Good
SELECT FLNormGain(102, 50.5) AS FLNormGain;

---- Positive Test 2: Output over 100
--- Return expected results, Good
SELECT FLNormGain(78, 50.5) AS FLNormGain;

---- Positive Test 3: First parameter as negative.
--- Return expected results - 0, Good
SELECT FLNormGain(-100.1, 50.5) AS FLNormGain;

---- Positive Test 4: First parameter as negative.
--- Return expected results - 0, Good
SELECT FLNormGain(-78, 50.5) AS FLNormGain;

---- Positive Test 5: Close to Boundary 1e307: Returns a large number
SELECT FLNormGain(1e307, 6) AS FLNormGain;

---- Positive Test 6: Close to Boundary 1e307: Returns Infinity
SELECT FLNormGain(1e307, 5) AS FLNormGain;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: First paramter as NULL.
--- Return expected error/empty output, Good
SELECT FLNormGain(null, 5) AS FLNormGain;

---- Negative Test 2: First paramter as NULL.
--- Return expected error/empty output, Good
SELECT FLNormGain(78.0, null) AS FLNormGain;

-- 	END: TEST SCRIPT
