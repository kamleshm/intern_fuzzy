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
--	Test Unit Number:		FLSparseMean-Netezza-01
--
--	Name(s):		    	FLSparseMean
--
-- 	Description:			Scalar function which returns the arithmetic mean of values stored in sparse form
--
--	Applications:		 
--
-- 	Signature:		    	FLSparseMean(SumX DOUBLE PRECISION, NumObs BIGINT)
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
-- Same output, good
SELECT a.MediaOutletID,
       FLSparseMean(a.VarSum,
                    a.VarCount) AS FLSparseMean
FROM   ( 
       SELECT MediaOutletID,
              SUM(Num_Val) AS VarSum,
              9605 AS VarCount
       FROM   tblHomeSurveySparse
       GROUP BY MediaOutletID
       ) AS a
WHERE  a.MediaOutletID <= 10
ORDER BY 1;

---- Positive Test 2:
SELECT FLSparseMean(575, 9605);

---- Positive Test 3: Input Large Value 1e100
--- Return expected results, Good
SELECT FLSparseMean(1e100, 9605);
SELECT FLSparseMean(575, CAST (2 ** 63 -1 AS BIGINT));

---- Positive Test 4: Input Vary Small Value 1e-100
--- Return expected results, Good
SELECT FLSparseMean(1e-100, 9605);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Number of Obs = 0
--- Return Error: Must be positive, Good
SELECT FLSparseMean(575, 0);

---- Negative Test 2: Input Value Out of Boundary
--- Return expected error, Good
SELECT FLSparseMean(CAST (2 ** 63 AS BIGINT), 9605);

---- Negative Test 3: Invalid DataType
--- Return expected error, Good
SELECT FLSparseMean(NULL, 9605);
SELECT FLSparseMean(575, NULL);
SELECT FLSparseMean(575, 9605.0);


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
