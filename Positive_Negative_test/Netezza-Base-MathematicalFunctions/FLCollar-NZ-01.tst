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
--	Test Unit Number:		FLCollar-Netezza-01
--
--	Name(s):		    	FLCollar
--
-- 	Description:			Scalar function which limits input value within the specified range i.e., between the lower and upper boundaries
--
--	Applications:		 
--
-- 	Signature:		    	FLCollar(x DOUBLE PRECISION, LB DOUBLE PRECISION, UB DOUBLE PRECISION)
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
SELECT FLCollar(39.0, -5.0, 5.0) AS Collar;
SELECT FLCollar(-39.0, -5.0, 5.0) AS Collar;

---- Positive Test 2:Input Large Values
--- Return expected results, Good
SELECT FLCollar(39.0 * 1e100, -5.0 * 1e100, 5.0 * 1e100) AS Collar;

---- Positive Test 3: Condition Test (LB >= UB): LB = UB
--- Return expected results, Good
SELECT FLCollar(39.0, 5.0, 5.0) AS Collar;

---- Positive Test 4: Close to Boundary 
SELECT FLCollar(-1e307, -1e-307, 1e307) AS Collar;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Value * 1e400
--- Numeric overflow error, Good
SELECT FLCollar(39.0 * 1e400, 5.0 * 1e400, -5.0 * 1e400) AS Collar;

---- Negative Test 2: Value * 1e-400
--- Numeric overflow error, Good
SELECT FLCollar(39.0 * 1e-400, 5.0 * 1e-400, -5.0 * 1e-400) AS Collar;

---- Negative Test 3: Condition Test (LB >= UB): LB > UB
--- Return expected error, Good
SELECT FLCollar(39.0, 5.0, -5.0) AS Collar;

---- Negative Test 4: Invalid Data Type
--- Return expected NULL value, Good
SELECT FLCollar(NULL, -5.0, 5.0) AS Collar;
SELECT FLCollar(39.0, NULL, 5.0) AS Collar;
SELECT FLCollar(39.0, -5.0, NULL) AS Collar;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
