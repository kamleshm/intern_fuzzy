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
--	Test Unit Number:		FLSparseCovarP-Netezza-01
--
--	Name(s):		    	FLSparseCovarP
--
-- 	Description:			Scalar function for calculating the population covariance between two variables stored in sparse form
--
--	Applications:		 
--
-- 	Signature:		    	FLSparseCovarP(SeriesSumXY, SeriesSum1, SeriesSum2, SeriesSumSq1, SeriesSumSq2, MaxNumOfObs)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			07-11-2017
--
--	Author:			    	Kamlesh Meena,Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
-- Same output, good
WITH tblHomeSurveyStats (MediaOutletID, VarSum, VarSqSum) AS
(
SELECT a.MediaOutletID,
       SUM(a.Num_Val) AS VarSum,
       SUM(a.Num_Val * a.Num_Val) AS VarSqSum
FROM   tblHomeSurveySparse a
GROUP BY a.MediaOutletID
)
SELECT a.MediaOutletID1,
       a.MediaOutletID2,
       FLSparseCovarP(a.VarSumXY,
                     x1.VarSum,
                     x2.VarSum,
		     x1.VarSqSum,
		     x2.VarSqSum,
                     9605) AS FLSparseCovarP
FROM   
       (
       SELECT a.MediaOutletID AS MediaOutletID1,
              b.MediaOutletID AS MediaOutletID2,
              SUM(a.Num_Val * b.Num_Val) AS VarSumXY
       FROM   tblHomeSurveySparse a,
              tblHomeSurveySparse b
       WHERE   b.ValueID = a.ValueID
       GROUP BY a.MediaOutletID, b.MediaOutletID
       ) AS a,
       tblHomeSurveyStats x1,
       tblHomeSurveyStats x2
WHERE  x1.MediaOutletID = a.MediaOutletID1
AND    x2.MediaOutletID = a.MediaOutletID2
AND    x1.MediaOutletID <= 10
AND    x2.MediaOutletID <= 10
AND    x1.MediaOutletID <= x2.MediaOutletID
ORDER BY 1, 2;

---- Positive Test 2: V1 = [1,2] V2 = [2,1]
--- Output expected results, Good
SELECT FLSparseCovarP(4, 3, 3, 5, 5, 2) AS FLSparseCovarP;

---- Positive Test 3: Input very large value 1e100
SELECT FLSparseCovarP(1e100, 3, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 1e100, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 1e100, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 3, 5, 5, CAST(2 ** 63 -1 AS BIGINT)) AS FLSparseCovarP; 

---- Positive Test 4: Input very small value 1e-100
SELECT FLSparseCovarP(1e-100, 3, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 1e-100, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 1e-100, 5, 5, 2) AS FLSparseCovarP;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number of Obs = 0
--- Output error: Argument 4 must be positive number
SELECT FLSparseCovarP(4, 3, 3, 5, 5, 0) AS FLSparseCovarP;

---- Negative Test 2: Test when Number of Obs = 1
--- Output Null
SELECT FLSparseCovarP(4, 3, 3, 5, 5, 1) AS FLSparseCovarP;

---- Negative Test 3: Input Out of boundary value
--- Numeric Overflow Error
SELECT FLSparseCovarP(1e400, 3, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 1e400, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 1e400, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 3, 5, 5, CAST (2**63 AS BIGINT)) AS FLSparseCovarP;

---- Negative Test 4: Input 1e-400
--- Return expected output, Good
SELECT FLSparseCovarP(1e-400, 3, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 1e-400, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 1e-400, 5, 5, 2) AS FLSparseCovarP;

---- Negative Test 5: Invalid Data Type
--- Return expected output, Good
SELECT FLSparseCovarP(4, 3, 3, 5, 5, 2.0) AS FLSparseCovarP;
SELECT FLSparseCovarP(NULL, 3, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, NULL, 3, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, NULL, 5, 5, 2) AS FLSparseCovarP;
SELECT FLSparseCovarP(4, 3, 3, 5, 5, NULL) AS FLSparseCovarP;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
