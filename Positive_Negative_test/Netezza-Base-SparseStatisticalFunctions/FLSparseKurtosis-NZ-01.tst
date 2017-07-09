-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    Sparse Statistics Functions
--
--	Test Unit Number:		FLSparseKurtosis-Netezza-01
--
--	Name(s):		    	FLSparseKurtosis
--
-- 	Description:			Scalar function which returns the kurtosis of a values stored in sparse form
--
--	Applications:		 
--
-- 	Signature:		    	FLSparseKurtosis(SumX DOUBLE PRECISION, SumSq DOUBLE PRECISION, SumCu DOUBLE PRECISION, SumQd DOUBLE PRECISION, NumObs BIGINT)
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
-- Same output, good
SELECT a.MediaOutletID,
       FLSparseKurtosis(a.VarSum,
                        a.VarSqSum,
                        a.VarCuSum,
                        a.VarQdSum,
                        a.VarCount) AS FLSparseKurtosis
FROM   ( 
       SELECT MediaOutletID,
              SUM(Num_Val) AS VarSum,
              SUM(Num_Val * Num_Val) AS VarSqSum,
              SUM(Num_Val * Num_Val *Num_Val) AS VarCuSum,
              SUM(Num_Val * Num_Val *Num_Val * Num_Val) AS VarQdSum,
              9605 AS VarCount
       FROM   tblHomeSurveySparse
       GROUP BY MediaOutletID
       ) AS a
WHERE  MediaOutletID <= 10
ORDER BY 1;

---- Positive Test 2: 
SELECT FLSparseKurtosis(575, 575, 575, 575, 9605);

---- Positive Test 3: Input Large Value 1e100
SELECT FLSparseKurtosis(1e100, 575, 575, 575, 9605);  /* Error Numeric Overflow Due To Invalid Input */
SELECT FLSparseKurtosis(575, 1e100, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 1e100, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 575, 1e100, 9605);
SELECT FLSparseKurtosis(575, 575, 575, CAST(2 ** 63 -1 AS BIGINT)); 

---- Positive Test 4: Input Vary Small Value 1e-100
SELECT FLSparseKurtosis(1e-100, 575, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 1e-100, 575, 575, 9605); /* Error A Floating Point Exception: Divide By Zero Due To Invalid Input */
SELECT FLSparseKurtosis(575, 575, 1e-100, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 575, 1e-100, 9605);


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number of Obs = 0
--- Return error
SELECT FLSparseKurtosis(575, 575, 575, 575, 0);

---- Negative Test 2: Number of Obs = 1
--- Null
SELECT FLSparseKurtosis(575, 575, 575, 575, 1);

---- Negative Test 3: Number of Obs = 2
--- Null
SELECT FLSparseKurtosis(575, 575, 575, 575, 2);

---- Negative Test 4: Number of Obs = 3
--- Null
SELECT FLSparseKurtosis(575, 575, 575, 575, 3);

---- Negative Test 5: Sumsq < 0
--- Expected error msg, Good
SELECT FLSparseKurtosis(575, -575, 575, 575, 9605);

---- Negative Test 6: SumQd < 0
--- Expected error msg, Good
SELECT FLSparseKurtosis(575, 575, 575, -575, 9605);

---- Negative Test 7: Input Out of Boundary Value
SELECT FLSparseKurtosis(1e400, 575, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 1e400, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 1e400, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 575, 1e400, 9605);
SELECT FLSparseKurtosis(575, 575, 575, 575, CAST(2 ** 63 AS BIGINT));

---- Negative Test 8: Input 1e-400
--- Expected error msg, Good
SELECT FLSparseKurtosis(1e-400, 575, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 1e-400, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 1e-400, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 575, 1e-400, 9605);

---- Negative Test 9: Invalid DataType
--- Expected error msg, Good
SELECT FLSparseKurtosis(575, 575, 575, 575, 9605.0);

SELECT FLSparseKurtosis(NULL, 575, 575, 575, 9605);
SELECT FLSparseKurtosis(575, NULL, 575, 575, 9605);
SELECT FLSparseKurtosis(575, 575, NULL, 575, 9605);
SELECT FLSparseKurtosis(575, 575, 575, NULL, 9005);
SELECT FLSparseKurtosis(575, 575, 575, 575, NULL);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
