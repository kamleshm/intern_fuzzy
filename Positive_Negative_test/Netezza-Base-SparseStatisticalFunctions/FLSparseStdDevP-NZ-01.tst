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
-- 	Test Category:		    Sparse Statistics Functions
--
--	Test Unit Number:		FLSparseStdDevP-Netezza-01
--
--	Name(s):		    	FLSparseStdDevP
--
-- 	Description:			Scalar function which returns the population standard deviation of a variable stored in sparse format
--
--	Applications:		 
--
-- 	Signature:		    	FLSparseStdDevP(SumX DOUBLE PRECISION, SumXSq DOUBLE PRECISION, NumObs BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			04-26-2017
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--	Author:				<Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   tblHomeSurveySparse a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same output, good
SELECT a.MediaOutletID,
       FLSparseStdDevP(a.VarSum,
                   a.VarSqSum,
                   a.VarCount) AS FLStdDevP
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
SELECT SQRT(FLSparseVarP(575, 1001, 9605)), FLSparseStdDevP(575, 1001, 9605);

---- Positive Test 3: Input Large Value 1e100
SELECT SQRT(FLSparseVarP(1e100, 1001, 9605)), FLSparseStdDevP(1e100, 1001, 9605);
SELECT SQRT(FLSparseVarP(575, 1e100, 9605)), FLSparseStdDevP(575, 1e100, 9605);
SELECT SQRT(FLSparseVarP(575, 1001, CAST(2 ** 63 -1 AS BIGINT))), FLSparseStdDevP(575, 1001, CAST(2 ** 63 -1 AS BIGINT));

---- Positive Test 4: Input Vary Small Value 1e-100
SELECT SQRT(FLSparseVarP(1e-100, 1001, 9605)), FLSparseStdDevP(1e-100, 1001, 9605);
SELECT SQRT(FLSparseVarP(575, 1e-100, 9605)), FLSparseStdDevP(575, 1e-100, 9605);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number of Obs = 0
--- Return Error, Good
SELECT FLSparseStdDevP(575, 1001, 0);

---- Negative Test 2: Number of Obs = 1
--- Null
SELECT FLSparseStdDevP(575, 1001, 1);

---- Negative Test 3: Sumsq < 0
--- Expected error, Good
SELECT FLSparseStdDevP(575, -1001, 9605);

---- Negative Test 4: Input Out of Boundary Value
--- Expected error, Good
SELECT FLSparseStdDevP(1e400, 1001, 9605);
SELECT FLSparseStdDevP(575, 1e400, 9605);
SELECT FLSparseStdDevP(575, 1001, CAST(2 ** 63 AS BIGINT));

---- Negative Test 5: Input 1e-400
--- Expected error, Good
SELECT FLSparseStdDevP(1e-400, 1001, 9605);
SELECT FLSparseStdDevP(575, 1e-400, 9605);

---- Negative Test 6: Invalid DataType
--- Expected error, Good
SELECT FLSparseStdDevP(575, 1001, 96005.0);
SELECT FLSparseStdDevP(NULL, 1001, 9605);
SELECT FLSparseStdDevP(575, NULL, 9605);
SELECT FLSparseStdDevP(575, 1001, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT