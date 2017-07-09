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
--	Test Unit Number:	    FLSimTriangular-NZ-01
--
--	Name(s):		    FLSimTriangular
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Triangular distribution
--
--	Applications:	
--  		
--
-- 	Signature:		    FLSimTriangular(Q, LowBD, UppBD, Theta)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Double Precision
--
--	Last Updated:		    12-24-2014
--
--	Author:			    <Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values
-- Case 1a:
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, 2.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 

-- Case 1b:
SELECT a.SerialVal,
	FLSimTriangular(-1, -4.0, 4.0, 2.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Case 1c:
SELECT a.SerialVal,
	FLSimTriangular(2**31, -4.0, 4.0, 2.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;   

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, 5.0, 4.0, 2.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Case 1b: LowBD == UppBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, 4.0, 4.0, 2.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Case 1c: Theta < LowBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, -6.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;            

-- Case 1d: Theta == LowBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, -4.0) AS SimTriangular
FROM fzzlConstantSerial a WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 1e: Theta > UppBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, 6.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 

-- Case 1f: Theta == UppBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, 4.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Category 2: Undefined results or error conditions due to equality
-- Case 2a: LowBD == UppBD
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, -4.0, 4.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;             

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimTriangular(a.RandVal, -4.0, 4.0, 3.0, 3.0) AS SimTriangular
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;             
    
-- BEGIN: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
