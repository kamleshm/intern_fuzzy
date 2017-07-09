
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
--	Test Unit Number:	    FLSimInvGamma-NZ-01
--
--	Name(s):		    FLSimInvGamma
--
-- 	Description:		    Scalar function which returns a random number drawn from an inverse gamma distribution
--
--	Applications:		 
--
-- 	Signature:		    FLSimInvGamma(Rand, Alpha, Beta)
--
--	Parameters:		    See Documentation
--
--	Return value:		    DOUBLE PRECISION
--
--	Last Updated:		    12-26-2014
--
--	Author:			    <Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1b:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1e-300, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation below 1e-307
--	Case 1c:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1e-310, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1d:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1e300, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation above 1e308
--	Case 1e:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1e310, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1f:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 1e-300) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1g:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 1e300) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation above 1e308
--	Case 1h:
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 1e310) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1i:
SELECT a.SerialVal,
	FLSimInvGamma(-1, 1.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1j:
SELECT a.SerialVal,
	FLSimInvGamma(2**31, 1.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases\

-- Case 1a: Alpha < 0.0
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, -1.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 1b: Alpha  == 0.0
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 0.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      

-- Case 1c: Beta < 0.0
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, -1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 1d: Beta  == 0.0
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 0.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b: 
--  Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimInvGamma(a.RandVal, 1.0, 1.0, 1.0) AS FLSimInvGamma
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        
    
-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
