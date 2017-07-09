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
-- 	Test Category:	    	Simulate Univariate
--
--	Test Unit Number:	FLSimBeta-NZ-01
--
--	Name(s):		FLSimBeta
--
-- 	Description:	    	Scalar function which returns the cumulative probability of a Beta distribution
--
--	Applications:	    	The beta distribution can be used to model events which are constrained to take 
--  				place within an interval defined by a minimum and maximum value 
--
-- 	Signature:		FLSimBeta(Q, LowBD, UppBD, Shape1, Shape2)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Float 8
--
--	Last Updated:	    	12-24-2014
--
--	Author:			<Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a
SELECT a.SerialVal, 
	FLSimBeta(a.Randval, 0.0, 1.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1b
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 1e-300, 1.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation below 1e-307
--  Case 1c
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 1e-310, 1.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1d
SELECT a.SerialVal,
 	FLSimBeta(a.RandVal, 0.0, 1e300, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation above 1e308
--  Case 1e
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 0.0, 1e310, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1f
SELECT a.SerialVal, FLSimBeta(a.RandVal, 0.0, 1.0, 1e-300, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation below 1e-307
--  Case 1g
SELECT a.SerialVal, FLSimBeta(a.RandVal, 0.0, 1.0, 1e-310, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1h
SELECT a.SerialVal, FLSimBeta(a.RandVal, 0.0, 1.0, 1.0, 1e300) AS FLSimBeta
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation above 1e308
--  Case 1i
SELECT a.SerialVal, FLSimBeta(a.RandVal, 0.0, 1.0, 1.0, 1e310) AS FLSimBeta
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;

--	Case 1j
SELECT a.SerialVal, 
	FLSimBeta(-1, 0.0, 1.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--	Case 1k
SELECT a.SerialVal, 
	FLSimBeta(2**31, 0.0, 1.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 3.0, 2.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Case 1b: Shape1 < 0.0
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, -1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    
 
-- Case 1c: Shape1 == 0.0
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, 0.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;         

-- Case 1d: Shape2 < 0.0
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, 1.0, -2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Case 1e: Shape2 == 0.0
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, 1.0, 0.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;             

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 2.0, 1.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    
     
-- Case 2b:
-- Not applicable

-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, 1.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    
     
-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimBeta(a.RandVal, 2.0, 3.0, 1.0, 2.0, 2.0) AS FLSimBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
