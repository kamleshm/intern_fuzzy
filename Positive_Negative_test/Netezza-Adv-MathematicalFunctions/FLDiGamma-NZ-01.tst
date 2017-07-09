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
--	Test Unit Number:		FLDiGamma-TD-01
--
--	Name(s):		    	FLDiGamma
--
-- 	Description:			Scalar function which returns the value of digamma function
--
--	Applications:		 
--
-- 	Signature:		    	FLDiGamma(x DOUBLE PRECISION)
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
SELECT FLDiGamma(1.0) AS DiGamma;

SELECT  a.SerialVal, FLDiGamma(a.SerialVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

---- Positive Test 2: 1e-300
SELECT FLDiGamma(1e-300) AS DiGamma;

---- Positive Test 4: 1e300
SELECT FLDiGamma(1e300) AS DiGamma;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number = 0
SELECT FLDiGamma(0) AS DiGamma;

---- Negative Test 2: Out of Boundary:  Number < 0
SELECT FLDiGamma(-1.0) AS DiGamma;

---- Negative Test 3: 
SELECT FLDiGamma(NULL) AS DiGamma;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
