
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
--	Test Unit Number:	    FLSimLogarithmic-NZ-01
--
--	Name(s):		    FLSimLogarithmic
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Logarithmic distribution
--
--	Applications:		 
--
-- 	Signature:		    FLSimLogarithmic(Q,Prob)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Float 8
--
--	Last Updated:		    17-11-2017
--
--	Author:			    <Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>, <Kamlesh.Meena@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-- 	BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

-- Case 1a:
SELECT a.SerialVal,
	FLSimLogarithmic(a.RandVal, 0.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;      

-- Case 1b:
SELECT a.SerialVal,
	FLSimLogarithmic(-1, 0.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;  

-- Case 1c:
SELECT a.SerialVal,
	FLSimLogarithmic(2**31, 0.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;   

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Prob < 0.0
SELECT a.SerialVal,
	FLSimLogarithmic(a.RandVal, -0.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;            

-- Case 1b: Prob == 0.0
SELECT a.SerialVal,
	FLSimLogarithmic(a.RandVal, 0.0) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;       

-- Case 1c: Prob > 1
SELECT a.SerialVal,
	FLSimLogarithmic(a.RandVal, 1.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;       

-- Case 1d: Prob == 1
SELECT a.SerialVal,
	FLSimLogarithmic(a.RandVal, 1.0) AS FLSimLogarithmic
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
--  Not applicable - all parameter data types are the same

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT a.SerialVal,
	 FLSimLogarithmic(a.RandVal) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;       

-- Case 4b: More than expected # of parameters
SELECT a.SerialVal,
	 FLSimLogarithmic(a.RandVal, 0.45, 0.45) AS FLSimLogarithmic
FROM fzzlConstantSerial a
WHERE a.SerialVal <= 5
ORDER BY 1;       

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
