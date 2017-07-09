-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
-- 	Test Category:			Math Functions
--
--	Test Unit Number:		FLIncBeta-TD-01
--
--	Name(s):		    	FLIncBeta
--
-- 	Description:			Scalar function which returns the value of Incomplete beta function 
--
--	Applications:		 
--
-- 	Signature:		    	FLIncBeta(IntBd DOUBLE PRECISION, ExpA  DOUBLE PRECISION, ExpB  DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			02-19-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive Case
SELECT FLIncBeta(0.5,1.0,2.0) AS IncGamma;

SELECT  a.SerialVal, FLIncBeta(0.5,a.SerialVal, 2.0)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

SELECT  a.SerialVal, FLIncBeta(0.5,1.0, a.serialval)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

---- Positive Test 2: IntBd = 1e-300
SELECT FLIncBeta(1e-300,1.0,2.0) AS IncGamma;

---- Positive Test 3: IntBd = 0
SELECT FLIncBeta(0,1.0,2.0) AS IncGamma;

---- Positive Test 4: ExpA=1e-300
SELECT FLIncBeta(0.5,1e-300,2.0) AS IncGamma;

---- Positive Test 5: ExpA=1e300
SELECT FLIncBeta(0.5,1e300,2.0) AS IncGamma;

---- Positive Test 6: ExpB = 1e-300
SELECT FLIncBeta(0.5,1.0,1e-300) AS IncGamma;

---- Positive Test 7: ExpB = 1e300
SELECT FLIncBeta(0.5,1.0,1e300) AS IncGamma;



-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Out of Boundary: IntBd < 0
SELECT FLIncBeta(-0.5,1.0,2.0) AS IncGamma;

---- Negative Test 2: Out of Boundary: IntBd > 1
SELECT FLIncBeta(1.5,1.0,2.0) AS IncGamma;

---- Negative Test 3: Out of Boundary: ExpA < 0
SELECT FLIncBeta(0.5,-1.0,2.0) AS IncGamma;

---- Negative Test 4: Out of Boundary: ExpA = 0
SELECT FLIncBeta(0.5,0.0,2.0) AS IncGamma;

---- Negative Test 5: Out of Boundary: ExpB < 0
SELECT FLIncBeta(0.5,1.0,-2.0) AS IncGamma;

---- Negative Test 6: Out of Boundary: ExpB = 0
SELECT FLIncBeta(0.5,1.0,0.0) AS IncGamma; 


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
