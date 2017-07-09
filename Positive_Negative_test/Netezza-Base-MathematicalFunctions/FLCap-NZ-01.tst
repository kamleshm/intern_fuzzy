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
--	Test Unit Number:		FLCap-Netezza-01
--
--	Name(s):		    	FLCap
--
-- 	Description:			Scalar function which caps an input value at a ceiling or upper boundary
--
--	Applications:		 
--
-- 	Signature:		    	FLCap(x  DOUBLE PRECISION, UB DOUBLE PRECISION)
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
SELECT FLCap(5.0, 3.0) AS Cap;

---- Positive Test 2: Cap of Value * -1
--- Return expected results, Good
SELECT FLCap(5.0 * -1, 3.0 * -1) AS Cap;

---- Positive Test 3: Cap of Large Value
--- Return expected results, Good
SELECT FLCap(5.0 * 1e100, 3.0 * 1e100) AS Cap;

---- Positive Test 4: Cap of Small Value
--- Return expected results, Good
SELECT FLCap(5.0 * 1e-100, 3.0 * 1e-100) AS Cap;

---- Positive Test 5: Close to Boundary -1e-307
SELECT FLCap(-1e-307, -1e-307) AS Cap;

---- Positive Test 6: Close to Boundary -1e307
SELECT FLCap(-1e307, -1e307) AS Cap;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Cap of Value * 1e-400
--- Return expected error, Good
SELECT FLCap(5.0 * 1e-400, 3.0 * 1e-400) AS Cap;

---- Negative Test 2: Cap of Value * 1e400
--- Return expected error, Good
SELECT FLCap(5.0 * 1e400, 3.0 * 1e400) AS Cap;

---- Negative Test 3: Valid Data Type Input
--- Return expected NULL value, Good
SELECT FLCap(NULL, 3.0) AS Cap;
SELECT FLCap(5.0, NULL) AS Cap;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
