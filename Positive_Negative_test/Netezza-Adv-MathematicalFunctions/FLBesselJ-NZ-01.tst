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
--	Test Unit Number:		FLBesselJ-TD-01
--
--	Name(s):		    	FLBesselJ
--
-- 	Description:			Scalar function which returns the value of the Bessel function of the first kind
--
--	Applications:		 
--
-- 	Signature:		    	FLBesselJ(X DOUBLE PRECISION, Nu BIGINT)
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

---- Positive Test 1: 
SELECT FLBesselJ(2.0, 1) AS BesselJ;

SELECT  a.SerialVal, FLBesselJ(a.SerialVal,1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

SELECT  a.SerialVal, FLBesselJ(2, CAST(a.SerialVal AS INT))
FROM    fzzlSerial a
WHERE   a.SerialVal <= 100
ORDER BY 1;

---- Positive Test 2:
SELECT  FLBesselJ(1e-300, 10);

---- Positive Test 3: 
SELECT  FLBesselJ(1e300, 10);

---- Positive Test 4:
SELECT  FLBesselJ(-1e300, 10);

---- Positive Test 5:
SELECT  FLBesselJ(-1e300, 11);

---- Positive Test 6:
SELECT  FLBesselJ(10.45, 0);

---- Positive Test 7:
SELECT  FLBesselJ(10.45, CAST(2**31-1 AS INT));


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Nu < 0
SELECT  FLBesselJ(10.45, -10);

---- NEgative Test 2: Null
SELECT  FLBesselJ(NULL, 10);

---- NEgative Test 3: Null
SELECT  FLBesselJ(10.45, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
