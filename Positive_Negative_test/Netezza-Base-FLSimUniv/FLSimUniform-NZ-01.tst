
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- 
--
-- Functional Test Specifications:
--
-- 	Test Category:		    Simulate Univariate
--
--	Test Unit Number:	    FLSimUniform-NZ-01
--
--	Name(s):		    FLSimUniform
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Uniform distribution
--
--	Applications:		
--
-- 	Signature:		    FLSimUniform(Q, LowBD, UppBD)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Float8
--
--	Last Updated:		    12-24-2014
--
--	Author:			    <Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

--	Test case 1a:
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.0, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--	Test case 1b:
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 1e-300, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation below 1e-307
--	Test case 1c:
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 1e-310, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--	Test case 1d:
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.0, 1e300) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation above 1e308
--	Test case 1e:
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.0, 1e310) AS SimUniform
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;

--	Test case 1f:
SELECT a.SerialVal,
	FLSimUniform(-1, 0.0, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--	Test case 1g:
SELECT a.SerialVal,
	FLSimUniform(2**31, 0.0, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 1.0, 0.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.5, 0.5) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--             Test with most likely mismatched data type for the function which is
--	            usually data types within the parameter list
--
-- 	 Not applicable - all parameters are Float 8


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimUniform(a.RandVal, 0.0, 1.0, 1.0) AS SimUniform
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- END: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
