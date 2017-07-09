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
--	Test Unit Number:		FLNormLoss-NZ-01
--
--	Name(s):		    	FLNormLoss
--
-- 	Description:			Scalar function which returns the normalized loss below a threshold.
--
--	Applications:		 
--
-- 	Signature:		    	FLNormLoss(x DOUBLE PRECISION, y DOUBLE PRECISION)
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
SELECT FLNormLoss(36, 50.5) AS FLNormLoss;

---- Positive Test 2: Output over 100
--- Return expected results, Good
SELECT FLNormLoss(-36, 50.5) AS FLNormLoss;

---- Positive Test 3: First parameter as positive.
--- Return expected results - 0, Good
SELECT FLNormLoss(100.1, 50.5) AS FLNormLoss;

---- Positive Test 4: First parameter as large.
--- Return expected results - 0, Good
SELECT FLNormLoss(1e307, 50.5) AS FLNormLoss;

---- Positive Test 5: Close to Boundary 1e307: Returns a large number
SELECT FLNormLoss(-1e307, 6) AS FLNormLoss;

---- Positive Test 6: Close to Boundary 1e307: Returns Infinity
SELECT FLNormLoss(-1e307, 5) AS FLNormLoss;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: First paramter as NULL.
--- Return expected error/empty output, Good
SELECT FLNormLoss(null, 5) AS FLNormLoss;

---- Negative Test 2: First paramter as NULL.
--- Return expected error/empty output, Good
SELECT FLNormLoss(78.0, null) AS FLNormLoss;

-- 	END: TEST SCRIPT
