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
--	Test Unit Number:		FLGammaLn-Netezza-01
--
--	Name(s):		    	FLGammaLn
--
-- 	Description:			Scalar function which returns the natural logarithm of the gamma function
--
--	Applications:		 
--
-- 	Signature:		    	FLGammaLn(x DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			07-03-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLGammaLn(2.5) AS GammaLn;

---- Positive Test 2: 1 < Value < 2, should output negative value
--- Return expected results, Good
SELECT FLGammaLn(1.5) AS GammaLn;

---- Positive Test 3: Should Output 0
--- Return expected results
SELECT ROUND(FLGammaLn(2),8) AS GammaLn;
SELECT FLGammaLn(1) AS GammaLn;

---- Positive Test 4: Value * 1e100, Compared with R
--- Same results, Good
SELECT FLGammaLn(2.5 * 1e100) AS GammaLn;

---- Positive Test 5: Value * 1e-100, Compared with R
--- Same results, Good
SELECT FLGammaLn(2.5 * 1e-100) AS GammaLn;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Bound Check 0
--- Return expected value Infinity, Good
SELECT FLGammaLn(0) AS GammaLn;

---- Negative Test 2: Bound Check < 0
--- Return expected error, Good
SELECT FLGammaLn(-1.0) AS GammaLn;

---- Negative Test 3: Invalid Data Type
--- Return expected NULL, Good
SELECT FLGammaLn(NULL) AS GammaLn;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
