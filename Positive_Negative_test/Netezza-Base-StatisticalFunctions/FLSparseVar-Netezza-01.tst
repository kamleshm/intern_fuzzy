-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
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
-- 	Test Category:		    Sparse Statistics Functions
--
--	Test Unit Number:		FLSparseVar-Netezza-01
--
--	Name(s):		    	FLSparseVar
--
-- 	Description:			Scalar function which returns the sample variance of the variable stored in sparse form
--
--	Applications:		 
--
-- 	Signature:		    	FLSparseVar(SumX DOUBLE PRECISION, SumSq DOUBLE PRECISION, NumObs BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			11-20-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same output, good
SELECT a.MediaOutletID,
       FLSparseVar(a.VarSum,
                   a.VarSqSum,
                   a.VarCount) AS FLSparseVar
FROM   ( 
       SELECT MediaOutletID,
              SUM(Num_Val) AS VarSum,
              SUM(Num_Val * Num_Val) AS VarSqSum,
              9605 AS VarCount
       FROM   tblHomeSurveySparse
       GROUP BY MediaOutletID
       ) AS a
WHERE  MediaOutletID <= 10
ORDER BY 1;

---- Positive Test 2:
SELECT FLSparseStdDev(575, 1001, 9605)**2, FLSparseVar(575, 1001, 9605);

---- Positive Test 3: Input Large Value 1e100
SELECT FLSparseStdDev(1e100, 1001, 9605)**2, FLSparseVar(1e100, 1001, 9605);
SELECT FLSparseStdDev(575, 1e100, 9605)**2, FLSparseVar(575, 1e100, 9605);
SELECT FLSparseStdDev(575, 1001, CAST(2 ** 63 -1 AS BIGINT))**2, FLSparseVar(575, 1001, CAST(2 ** 63 -1 AS BIGINT));

---- Positive Test 4: Input Vary Small Value 1e-100
SELECT FLSparseStdDev(1e-100, 1001, 9605)**2, FLSparseVar(1e-100, 1001, 9605);
SELECT FLSparseStdDev(575, 1e-100, 9605)**2, FLSparseVar(575, 1e-100, 9605);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number of Obs = 0
--- Error msg, Good
SELECT FLSparseVar(575, 1001, 0);

---- Negative Test 2: Number of Obs = 1
--- Null
SELECT FLSparseVar(575, 1001, 1);

---- Negative Test 3: Sumsq < 0
--- Return expected error, Good
SELECT FLSparseVar(575, -1001, 9605);

---- Negative Test 4: Input Out of Boundary Value
--- Return expected error, Good
SELECT FLSparseVar(1e400, 1001, 9605);
SELECT FLSparseVar(575, 1e400, 9605);
SELECT FLSparseVar(575, 1001, CAST(2 ** 63 AS BIGINT));

---- Negative Test 5: Input 1e-400
--- Return expected error, Precision error in Float type, Good
SELECT FLSparseVar(1e-400, 1001, 9605);
SELECT FLSparseVar(575, 1e-400, 9605);

---- Negative Test 6: Invalid DataType
--- Return expected error, Good
SELECT FLSparseVar(575, 1001, 96005.0);
SELECT FLSparseVar(NULL, 1001, 9605);
SELECT FLSparseVar(575, NULL, 9605);
SELECT FLSparseVar(575, 1001, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
