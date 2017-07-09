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
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FLWtStdDev-Netezza-01
--
--	Name(s):		    	FLWtStdDev
--
-- 	Description:			Aggregate function which returns the weighted standard deviation of a data series
--
--	Applications:		 
--
-- 	Signature:		    	FLWtStdDev(pWt DOUBLE PRECISION, pX DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
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

---- Positive Test 1: Positive test cases when all weights = 1, compared with STDDEV_POP
--- Same output, Good
SELECT  a.City,
        FLWtStdDev(1, a.SalesPerVisit),
		FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 2: Weighted Standard Dev of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLWtStdDev(1, -1 * a.SalesPerVisit),
		FLWtStdDev(-1, a.SalesPerVisit),
		FLWtStdDev(-1 * 1, -1 * a.SalesPerVisit),
		FLWtStdDev(-0.5, -1 * a.SalesPerVisit),
		FLWtStdDev(-1 * a.SalesPerVisit, -1 * a.SalesPerVisit),
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 3: Weighted Standard Dev of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  a.City,
        FLWtStdDev(1, a.SalesPerVisit + 1.0),
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 4: Weighted Standard Dev of Value + 1e100, Results should not change
--- Results change due to precision limit of platform
--- for very large input values, the floating point exception error may happen as it has been noted in the user manual
SELECT  a.City,
        FLWtStdDev(1, a.SalesPerVisit + 1e100),
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 5: Weighted Standard Dev of -1.0 * Value + 1.0, Results should not change
--- Return expected error, Good
SELECT  a.City,
        FLWtStdDev(1, -1 * a.SalesPerVisit + 1.0),
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 6: Multiply by a very small number, Results should be 1e-100 * SD
--- When weights are small, doesn't return expected results, due to precision limit of platform
SELECT  a.City,
        FLWtStdDev(1, 1e-100 * a.SalesPerVisit),
		FLWtStdDev(1e-100 * 1, 1e-100 * a.SalesPerVisit), /*doesn't return expected results*/
		FLWtStdDev(1e-10 * 1, 1e-100 * a.SalesPerVisit),
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Positive Test 7: Multiply by a very large number, Results should be 1e100 * SD
--- Large weights and values combination will cause numeric overflow, which is on account of large values and is expected
SELECT  a.City,
        FLWtStdDev(1, 1e100 * a.SalesPerVisit),
		FLWtStdDev(1e100 * 1, 1e100 * a.SalesPerVisit),  /* Output Error: FLWtStdDev caused a floating point exception: Numeric overflow */
        FLStdDevP(a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
SELECT  FLWtStdDev(1, a.RandVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

SELECT  FLWtStdDev(a.RandVal, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: 0 weighting
--- Output Null, Good
SELECT  FLWtStdDev(0, a.RandVal)
FROM    fzzlSerial a;

---- Negative Test 3: Sum(weightings) = 0; Sum(-1 , -2 , 3) =0
--- Output expected results, Good
SELECT FLWtStdDev(z.pWtVal, z.pSerialVal)
FROM (
      SELECT a.SerialVal AS pSerialVal, CASE WHEN a.SerialVal <= 2 THEN -1*a.SerialVal ELSE a.SerialVal END AS pWtVal
      FROM fzzlSerial a
      WHERE a.SerialVal <=3
) AS z;

---- Negative Test 4: Value(Double Precision) out of range: Weighted Standard Dev of 1.0e400 * Value
--- Numeric Overflow error, Good 
SELECT  a.City,
        FLWtStdDev(1, 1e400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtStdDev(1e400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

---- Negative Test 5: Value(Double Precision) out of range: Weighted Standard Dev of 1.0e-400 * Value
--- Numeric Overflow error, Good
SELECT  a.City,
        FLWtStdDev(1, 1e-400 * a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;

SELECT  a.City,
        FLWtStdDev(1e-400, a.SalesPerVisit)
FROM    tblCustData a
GROUP BY a.City
ORDER BY 1;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
