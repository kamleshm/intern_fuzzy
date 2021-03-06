
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
--	Test Unit Number:	    FLSimNegBinomial-NZ-01
--
--	Name(s):		    FLSimNegBinomial
--
-- 	Description:		    Scalar function which returns a random number drawn from a binomial distribution
--
--	Applications:		 
--
-- 	Signature:		    FLSimNegBinomial(Rand, Prob, Size)
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
	FLSimNegBinomial(a.RandVal, 0.45, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1b:
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 1e-300, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation below 1e-307
--	Case 1c:
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 1e-310, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1g:
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.45, CAST(2**31-1 AS INT)) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Expected failure due to Netezza system limitation above 1e308
--	Case 1h:
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.45, CAST(2**31 AS INT)) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1i:
SELECT a.SerialVal,
	FLSimNegBinomial(-1, 0.45, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

--	Case 1j:
SELECT a.SerialVal,
	FLSimNegBinomial(2**31, 0.45, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 
    
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases\

-- Case 1a: Prob < 0.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, -0.45, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 1b: Prob  == 0.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.0, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;   

-- Case 1c: Prob  > 1.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 1.5, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;   

-- Case 1d: Prob  = 1.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 1.0, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;   

-- Case 1c: Size < 0.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.45, -10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     

-- Case 1d: Size  == 0.0
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.45, 0) AS FLSimNegBinomial
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
	FLSimNegBinomial(a.RandVal, 0.45) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimNegBinomial(a.RandVal, 0.45, 10, 10) AS FLSimNegBinomial
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;        
    
-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
