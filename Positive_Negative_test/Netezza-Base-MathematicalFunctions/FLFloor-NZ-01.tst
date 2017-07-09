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
--	Test Unit Number:		FLFloor-Netezza-01
--
--	Name(s):		    	FLFloor
--
-- 	Description:			Scalar function which limits the input value from falling below the lower boundary
--
--	Applications:		 
--
-- 	Signature:		    	FLFloor(x DOUBLE PRECISION, LB DOUBLE PRECISION)
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
SELECT FLFloor(-3.0, -2.0) AS FLoor;

---- Positive Test 2: FLoor of Value * -1
--- Return expected results, Good
SELECT FLFloor(-3.0 * -1, -2.0 * -1) AS FLoor;

---- Positive Test 3: FLoor of Large Value
--- Return expected results, Good
SELECT FLFloor(3.0 * 1e100, 5.0 * 1e100) AS FLoor;

---- Positive Test 4: FLoor of Small Value
--- Return expected results, Good
SELECT FLFloor(3.0 * 1e-100, 5.0 * 1e-100) AS FLoor;

---- Positive Test 5: Close to Boundary 
SELECT FLFloor(-1e307, 1e307) AS FLoor;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: FLoor of Value * 1e-400
--- Return expected value 0, Good
SELECT FLFloor(5.0 * 1e-400, 3.0 * 1e-400) AS FLoor;

---- Negative Test 2: FLoor of Value * 1e400
--- Return expected error, Good
SELECT FLFloor(5.0 * 1e400, 3.0 * 1e400) AS FLoor;

---- Negative Test 3: Valid Input
--- Return expected NULL value, Good
SELECT FLFloor(NULL, 3.0) AS FLoor;
SELECT FLFloor(5.0, NULL) AS FLoor;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
