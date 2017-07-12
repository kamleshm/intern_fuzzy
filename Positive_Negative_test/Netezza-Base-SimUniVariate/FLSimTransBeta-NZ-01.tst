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
--	Test Unit Number:	FLSimTransBeta-NZ-01
--
--	Name(s):		FLSimTransBeta
--
-- 	Description:	    	Scalar function which returns a random number drawn from a transformed beta distribution
--
--	Applications:	    	 
--
-- 	Signature:		FLSimTransBeta(Q, Scale, Shape1, Shape2, Shape3)
--
--	Parameters:		See Documentation
--
--	Return value:	    	DOUBLE PRECISION
--
--	Last Updated:	    	07-11-2017
--
--	Author:			<Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>, <Kamlesh.Meena@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a
SELECT a.SerialVal, 
	FLSimTransBeta(a.RandVal, 1.0, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1b
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1e-300, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1c
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1e300, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation below 1e-320
--  Case 1d
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1e-325, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1e
SELECT a.SerialVal,
 	FLSimTransBeta(a.RandVal, 1.0, 1e-300, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1f
SELECT a.SerialVal,
 	FLSimTransBeta(a.RandVal, 1.0, 1e300, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation above 1e308
--  Case 1g
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 1e310, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1h
SELECT a.SerialVal, FLSimTransBeta(a.RandVal, 1.0, 2.0, 1e-300, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a 
WHERE a.SerialVal <= 5
ORDER BY 1;

-- Expected failure due to Netezza system limitation below 1e-307
--  Case 1i
SELECT a.SerialVal, FLSimTransBeta(a.RandVal, 1.0, 2.0, 1e-310, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a 
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1j
SELECT a.SerialVal, FLSimTransBeta(a.RandVal, 1.0, 2.0, 1e300, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a 
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1k
SELECT a.SerialVal, FLSimTransBeta(a.RandVal, 1.0, 2.0, 3.0, 1e-300) AS FLSimTransBeta
FROM fzzlConstantSerial a 
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1l
SELECT a.SerialVal, FLSimTransBeta(a.RandVal, 1.0, 2.0, 3.0, 1e300) AS FLSimTransBeta
FROM fzzlConstantSerial a 
WHERE a.SerialVal <= 5
ORDER BY 1;

--	Case 1m
SELECT a.SerialVal, 
	FLSimTransBeta(-1, 1.0, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;

--  Case 1n
SELECT a.SerialVal,
	FLSimTransBeta(2**31, 1.0, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Scale < 0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, -1.0, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;  

-- Case 1b: Scale = 0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 0.0, 2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Case 1c: Shape1 < 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, -2.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    
 
-- Case 1d: Shape1 == 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 0.0, 3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;     
  
-- Case 1e: Shape2 < 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 2.0, -3.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- Case 1f: Shape2 == 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 2.0, 0.0, 5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 

-- Case 1g: Shape3 < 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 2.0, 3.0, -5.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 

-- Case 1h: Shape3 == 0.0
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 1.0, 2.0, 3.0, 0.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1; 
          

-- Category 2: Undefined results or error conditions due to equality
-- Not applicable

-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 2.0, 3.0, 1.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    
     
-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	FLSimTransBeta(a.RandVal, 2.0, 3.0, 1.0, 2.0, 2.0) AS FLSimTransBeta
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;    

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
