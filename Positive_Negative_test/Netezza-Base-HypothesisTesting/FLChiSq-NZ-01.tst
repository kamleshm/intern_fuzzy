-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- 
--
-- Functional Test Specifications:
--
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLChiSq-NZ-01
--
--	Name(s):		FLChiSq
--
-- 	Description:	    	FLChiSq produces the expected value and the Chi-square for each cell in the contingency
--				table. The probability of Chi-square can then be calculated using the scalar function 
--				FLCDFChiSq. 
--
--	Applications:	    	This function is specially useful in the following situations: there are a very large 
--				number of cells in the contingency table one needs to evaluate each cell in the 
--				contingency table to understand the drivers of Chi-square.
--
-- 	Signature:		FLChiSq(StatType VARCHAR(10), RefRow_ID BIGINT, RefCol_ID BIGINT, 
--				DataRow_ID BIGINT, DataCol_ID BIGINT, CellValue DOUBLE PRECISION)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	01-14-2015
--
--	Author:			<Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com> 
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: NEGATIVE TEST(s)

---- Case 1a: Incorrect Parameters
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs
--This case runs and outputs results.

---- Case 1b: Incorrect Parameters
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('CHI_SQUARED', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs
--This case runs and outputs results.

---- Case 1c: Case sensitivity test
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('exP_Val', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue,
        FLChiSq('ChI_Sq', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ChiSq
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result:
/*
ERROR [HY000] ERROR:  Invalid parameter in function call
 */

---- Case 1d: Case sensitivity test
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('Exp_Val', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue,
        FLChiSq('Chi_Sq', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ChiSq
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result:
/*
ERROR [HY000] ERROR:  Invalid parameter in function call
 */

---- Case 1e: Missing row or columns
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
AND     b.UsageCode <> 1
AND     c.UsageCode <> 1
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs
--This case runs and outputs results.

---- Case 1f: Row and/or column is same
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', 1, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs
--This case runs and outputs results.

---- Case 1g: Row and/or column is same
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', b.UsageCode, 1, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs
--This case runs and outputs results.

---- Case 1h: Count in cells is zero
SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, 0) AS ExpectedValue
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: return NULL value
/*
ERROR [HY000] ERROR:  0 : Float8 result is a NaN
 */

-- Case 1i: Replace a column or row with zero
CREATE VIEW vwProductUsage AS
SELECT  a.ProductCode,
        a.CurrentUsageCode,
        a.FutureUsageCode,
        CASE WHEN a.CurrentUsageCode = 1 THEN 0 ELSE a.UsageCount END AS UsageCount
FROM    tblProductUsage a;

SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VAL', b.UsageCode, c.UsageCode, d.CurrentUsageCode,
                d.FutureUsageCode, d.UsageCount
               )AS ExpectedValue,
        FLChiSq('CHI_SQ', b.UsageCode, c.UsageCode, d.CurrentUsageCode,
                d.FutureUsageCode, d.UsageCount
               ) AS ChiSq
FROM    tblUsageCode b, 
        tblUsageCode c, 
        vwProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;

DROP VIEW vwProductUsage;

-- Result: floating point exception: invalid arithmetic operation
/*
ERROR [HY000] ERROR:  0 : Float8 result is a NaN
 */

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

SELECT  d.ProductCode,
        b.UsageCode,
        c.UsageCode,
        FLChiSq('EXP_VALUES', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ExpectedValue,
        FLChiSq('CHI_SQ', b.UsageCode, c.UsageCode, d.CurrentUsageCode, d.FutureUsageCode, d.UsageCount) AS ChiSq
FROM    tblUsageCode b, tblUsageCode c, tblProductUsage d
WHERE   d.ProductCode <= 10
GROUP BY d.ProductCode, b.UsageCode, c.UsageCode
ORDER BY 1, 2, 3;
-- Result: standard outputs

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
