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
--	Test Unit Number:		FLBesselY-TD-01
--
--	Name(s):		    	FLBesselY
--
-- 	Description:			Scalar function which returns the value of the Bessel function of the second kind
--
--	Applications:		 
--
-- 	Signature:		    	FLBesselY(X DOUBLE PRECISION, Nu BIGINT)
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
SELECT FLBesselY(2.0, 1) AS BesselJ;

SELECT  a.SerialVal, FLBesselY(a.SerialVal,1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

SELECT  a.SerialVal, FLBesselY(2, CAST(a.SerialVal AS INT))
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

---- Positive Test 2:
SELECT  FLBesselY(1e-300, 10);

---- Positive Test 3: 
SELECT  FLBesselY(1e300, 10);

---- Positive Test 4:
SELECT  FLBesselY(10.45, 0);

---- Positive Test 5:
SELECT  FLBesselY(10.45, CAST(2**31-1 AS INT));


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)
---- Negative Test 1: X < 0
SELECT  FLBesselY(-2, 10);

---- Negative Test 2: X = 0
SELECT  FLBesselY(0, 10);

---- Negative Test 3: Nu < 0
SELECT  FLBesselY(10.45, -10);

---- NEgative Test 4: Null
SELECT  FLBesselY(NULL, 10);

---- NEgative Test 5: Null
SELECT  FLBesselY(10.45, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
