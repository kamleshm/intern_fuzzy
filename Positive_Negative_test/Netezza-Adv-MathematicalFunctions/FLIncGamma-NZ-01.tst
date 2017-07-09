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
--	Test Unit Number:		FLIncGamma-TD-01
--
--	Name(s):		    	FLIncGamma
--
-- 	Description:			Scalar function which returns the value of Incomplete Gamma function 
--
--	Applications:		 
--
-- 	Signature:		    	FLIncGamma(IntBdX DOUBLE PRECISION, ExpS DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			02-18-2014
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
SELECT FLIncGamma(1.0, 2.0) AS IncGamma;

SELECT  a.SerialVal, FLIncGamma(1.0,a.SerialVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

SELECT  a.SerialVal, FLIncGamma(a.serialval,2)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

---- Positive Test 2: ExpS = 1e-300
SELECT FLIncGamma(1.0,1e-300) AS IncGamma;

---- Positive Test 3: ExpS=1e300
SELECT FLIncGamma(1.0, 1e300) AS IncGamma;

---- Positive Test 4: IntBdX = 1e-300
SELECT FLIncGamma(1e-300,2.0) AS IncGamma;

---- Positive Test 4: IntBdX = 1e300
SELECT FLIncGamma(1e300, 2.0) AS IncGamma;

---- Positive Test 1a: Verify Teradat reported JIRA TD-201
SELECT FLIncGamma(1e3, 1e3) AS IncGamma;

---- Positive Test 1b: Verify Teradat reported JIRA TD-201
SELECT FLIncGamma(1e4, 1e4) AS IncGamma;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Return Null, Good
SELECT  FLIncGamma(1.0, a.SerialVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Out of Boundary: ExpS = 0
SELECT FLIncGamma(1.0, 0.0) AS IncGamma;

---- Negative Test 3: Out of Boundary: ExpS < 0
SELECT FLIncGamma(1.0, -2.0) AS IncGamma;

---- Negative Test 4: Out of Boundary: IntBdX = 0
SELECT FLIncGamma(0.0, 2.0) AS IncGamma;

---- Negative Test 5: Out of Boundary: IntBdX < 0
SELECT FLIncGamma(-1.0, 2.0) AS IncGamma; 


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
