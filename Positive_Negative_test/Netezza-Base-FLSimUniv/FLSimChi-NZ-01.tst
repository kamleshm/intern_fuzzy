
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
--	Test Unit Number:	    FLSimChi-NZ-01
--
--	Name(s):		    FLSimChi
--
-- 	Description:		    Scalar function which returns the density of a Chi distribution
--
--	Applications:		 
--
-- 	Signature:		    FLSimChi(Q, LowBD, Scale, DF)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Float 8
--
--	Last Updated:		    12-24-2014
--
--	Author:			    <Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--


-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a:
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1.0, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1b:
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1e300, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation above 1e308
--	Case 1c:
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1e310, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1d:
SELECT a.SerialVal,
	FLSimChi(-1, 0.0, 1.0, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 

--	Case 1e:
SELECT a.SerialVal,
	FLSimChi(2**31, 0.0, 1.0, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;       

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Scale < 0.0
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, -1.0, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Case 1b: Scale  == 0.0
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 0.0, 2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      

-- Case 1c: DF < 0.0
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1.0, -2) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;  

-- Case 1d: DF == 0.0
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1.0, 0) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      

-- Case 1e: DF > 100.0
SELECT a.SerialVal, 
	FLSimChi(a.RandVal, 0.0, 1.0, 102) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;  

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b:
-- Not Applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1.0) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimChi(a.RandVal, 0.0, 1.0, 2.0, 2.0) AS SimChi
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      
    
-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
