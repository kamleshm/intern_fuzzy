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
--	Test Unit Number:		FLTrunc-TD-01
--
--	Name(s):		    	FLTrunc
--
-- 	Description:			Scalar function which truncates the input value to the specified number of decimal places
--
--	Applications:		 
--
-- 	Signature:		    	FLTrunc(x DOUBLE PRECISION, P BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			01-29-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: The number of decimal places < the number of decimal digits available
--- Return expected results, Good
SELECT FLTrunc(-12.34567, 2) AS Trunc;
SELECT FLTrunc(-12.34500, 2) AS Trunc;
SELECT FLTrunc(-12.34467, 2) AS Trunc; 

SELECT FLTrunc(-12.34567, 0) AS Trunc; 

---- Positive Test 2: The number of decimal places = the number of decimal digits available
--- Return expected results, Good
SELECT FLTrunc(-12.34567, 5) AS Trunc; 
SELECT FLTrunc(-12.34500, 5) AS Trunc;  
SELECT FLTrunc(-12.34467, 5) AS Trunc; 

---- Positive Test 3: The number of decimal places > the number of decimal digits available
--- Return expected results, Good
SELECT FLTrunc(-12.34567, 10) AS Trunc; 

---- Positive Test 4: Value * -1
--- Return expected results, Good
SELECT FLTrunc(-12.34567 * -1, 2) AS Trunc;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Negative Input for Number of Decimal Places
--- Return expected error, Good 
SELECT FLTrunc(-12.34567, -2) AS Trunc;

---- Negative Test 2: Invalid Data Type
--- Return expected error, Good 
SELECT FLTrunc(NULL, 5) AS Trunc;
SELECT FLTrunc(-12.34567, NULL) AS Trunc;
SELECT FLTrunc(-12.34567, 5.5) AS Trunc;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
