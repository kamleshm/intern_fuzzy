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
--	Test Unit Number:		FLCorrel-Netezza-01
--
--	Name(s):		    	FLCorrel
--
-- 	Description:			Aggregate function which returns the correlation of 2 vectors
--
--	Applications:		 
--
-- 	Signature:		    	FLCorrel(pX DOUBLE PRECISION, pY DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			07-03-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time

--.run file=../PulsarLogOn.sql

--.set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   finEquityReturns a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, good
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel
FROM   finEquityReturns a,
       finEquityReturns b
WHERE  b.TxnDate = a.TxnDate
AND    a.TickerSymbol = 'MSFT'
AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;

---- Positive Test 2: Test How does function deal with Null values by Comparing outputs between same inputs with Null values and without Null values
--- FLCorrel(With Nulls) and FLCorrel(Without Nulls) are comparable, If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCorrel-01P2: PASSED' ELSE 'BasicStat-FT-FLCorrel-01P2: FAILED' END AS TestOutcome
FROM ( SELECT a.FLCorrel - b.FLCorrel AS Diff
       FROM ( SELECT a.TickerSymbol AS Ticker1,
                     b.TickerSymbol AS Ticker2,
                     FLCorrel(CASE WHEN EXTRACT(Year FROM a.TxnDate) = 2005 THEN NULL ELSE a.EquityReturn END, b.EquityReturn) AS FLCorrel
	          FROM   finEquityReturns a,
                     finEquityReturns b
              WHERE  b.TxnDate = a.TxnDate
              AND    a.TickerSymbol = 'MSFT'
              AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
              GROUP BY a.TickerSymbol, b.TickerSymbol
            ) AS a,
	        ( SELECT a.TickerSymbol AS Ticker1,
                     b.TickerSymbol AS Ticker2,
                     FLCorrel(CASE WHEN EXTRACT(Year FROM a.TxnDate) = 2005 THEN NULL ELSE a.EquityReturn END, b.EquityReturn) AS FLCorrel
              FROM   finEquityReturns a,
                     finEquityReturns b
              WHERE  b.TxnDate = a.TxnDate
              AND    a.TickerSymbol = 'MSFT'
              AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
              AND    EXTRACT(Year FROM a.TxnDate) <> 2005
              GROUP BY a.TickerSymbol, b.TickerSymbol
	        ) AS b
       WHERE a.Ticker1 = b.Ticker1 AND a.Ticker2 = b.Ticker2
	   ) AS a;

---- Positive Test 3: Adding constant to each value, Results should not change
--- Failures due to Known precision issue, CORR function also has the same issue.
--- FLCorrel(a.EquityReturn, b.EquityReturn) and FLCorrel(a.EquityReturn + x, b.EquityReturn + x) are comparable, If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff as Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCorrel-01P3: PASSED' ELSE 'BasicStat-FT-FLCorrel-01P3: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
              b.TickerSymbol AS Ticker2,
              FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel0,
              FLCorrel(a.EquityReturn+1, b.EquityReturn+1) AS FLCorrel1,
              FLCorrel(a.EquityReturn+1e2, b.EquityReturn+1e2) AS FLCorrel2,
              FLCorrel(a.EquityReturn+1e5, b.EquityReturn+1e5) AS FLCorrel3,
              ABS(FLCorrel1- FLCorrel0) AS Diff10,
              ABS(FLCorrel2- FLCorrel0) AS Diff20,
              ABS(FLCorrel3- FLCorrel0) AS Diff30,
              Diff10 + Diff20 +Diff30 AS Diff
	   FROM   finEquityReturns a,
	          finEquityReturns b
        WHERE  b.TxnDate = a.TxnDate
        AND    a.TickerSymbol = 'MSFT'
        AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
        GROUP BY a.TickerSymbol, b.TickerSymbol) AS a;

---- Positive Test 4: Multiply by a very large value, Results should not change
--- FLCorrel(a.EquityReturn, b.EquityReturn) and FLCorrel(a.EquityReturn * x, b.EquityReturn * x) are comparable, If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCorrel-01P4: PASSED' ELSE 'BasicStat-FT-FLCorrel-01P4: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
              b.TickerSymbol AS Ticker2,
	      FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel0,
              FLCorrel(a.EquityReturn * 1e5, b.EquityReturn * 1e5) AS FLCorrel1,
	      FLCorrel(a.EquityReturn * 1e150, b.EquityReturn * 1e150) AS FLCorrel2,
	      ABS(FLCorrel1 - FLCorrel0) AS Diff10,
	      ABS(FLCorrel2 - FLCorrel0) AS Diff20,
	      Diff10 + Diff20 AS Diff
       FROM   finEquityReturns a,
              finEquityReturns b
       WHERE  b.TxnDate = a.TxnDate
       AND    a.TickerSymbol = 'MSFT'
       AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
       GROUP BY a.TickerSymbol, b.TickerSymbol) AS a;

---- Positive Test 5a: Multiply by a very small value that close to zero, Results should not change
--- FLCorrel(a.EquityReturn, b.EquityReturn) and FLCorrel(a.EquityReturn * x, b.EquityReturn * x) are comparable, If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff AS Diff,
       CASE WHEN a.Diff < 1e-12 THEN 'BasicStat-FT-FLCorrel-01P5a: PASSED' ELSE 'BasicStat-FT-FLCorrel-01P5a: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
              b.TickerSymbol AS Ticker2,
	      FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel0,
              FLCorrel(a.EquityReturn/1e5, b.EquityReturn/1e5) AS FLCorrel1,
	      FLCorrel(a.EquityReturn/1e150, b.EquityReturn/1e150) AS FLCorrel2,
	      ABS(FLCorrel1 - FLCorrel0) AS Diff10,
	      ABS(FLCorrel2 - FLCorrel0) AS Diff20,
	      Diff10 + Diff20 AS Diff
       FROM   finEquityReturns a,
              finEquityReturns b
       WHERE  b.TxnDate = a.TxnDate
       AND    a.TickerSymbol = 'MSFT'
       AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
       GROUP BY a.TickerSymbol, b.TickerSymbol) AS a;

---- Positive Test 5b: Multiply by 1e-300, Results should not change
--- Failures due to Known precision issue, CORR function also has the same issue.
--- FLCorrel(a.EquityReturn, b.EquityReturn) and FLCorrel(a.EquityReturn / x, b.EquityReturn / x) are comparable, If the their difference <= 1e-12 then PASS, Otherwise, FAIL
SELECT a.Diff10 AS Diff,
       CASE WHEN  a.Diff10 < 1e-12 THEN 'BasicStat-FT-FLCorrel-01P5b: PASSED' ELSE 'BasicStat-FT-FLCorrel-01P5b: FAILED' END AS TestOutcome
FROM (SELECT a.TickerSymbol AS Ticker1,
             b.TickerSymbol AS Ticker2,
             FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel0,
             FLCorrel(a.EquityReturn/1e300, b.EquityReturn/1e300) AS FLCorrel1,
             ABS(FLCorrel1 - FLCorrel0) AS Diff10
      FROM   finEquityReturns a,
             finEquityReturns b
      WHERE  b.TxnDate = a.TxnDate
      AND    a.TickerSymbol = 'MSFT'
      AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
      GROUP BY a.TickerSymbol, b.TickerSymbol) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No Data
SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN 'BasicStat-FT-FLCorrel-01N1: PASSED' ELSE 'BasicStat-FT-FLCorrel-01N1: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
              b.TickerSymbol AS Ticker2,
              FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel
       FROM   finEquityReturns a,
              finEquityReturns b
       WHERE  b.TxnDate = a.TxnDate
       AND    a.TickerSymbol = 'MSFT'
       AND    b.TickerSymbol = 'APPLE'
       GROUP BY a.TickerSymbol, b.TickerSymbol
      ) AS a;

---- Negative TEST 2: NULL Input
--- If Output Null then Pass, otherwise, Fail
SELECT a.FLCorrel AS FLCorrel,
       CASE WHEN FLCorrel IS NULL THEN 'BasicStat-FT-FLCorrel-01N2: PASSED' ELSE 'BasicStat-FT-FLCorrel-01N2: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
              b.TickerSymbol AS Ticker2,
              FLCorrel(NULL, NULL) AS FLCorrel
       FROM   finEquityReturns a,
              finEquityReturns b
       WHERE  b.TxnDate = a.TxnDate
       AND    a.TickerSymbol = 'MSFT'
       AND    b.TickerSymbol = 'AAPL'
       GROUP BY a.TickerSymbol, b.TickerSymbol
      ) AS a;
	  
---- Negative Test 3: Condition Test (Number of observation >= 2): The number of non-null pairs is not enough (<2)
--- If Output Null then Pass, otherwise, Fail
SELECT a.FLCorrel AS FLCorrel,
       CASE WHEN FLCorrel IS NULL THEN 'BasicStat-FT-FLCorrel-01N3: PASSED' ELSE 'BasicStat-FT-FLCorrel-01N3: FAILED' END AS TestOutcome
FROM ( SELECT FLCorrel(a.EquityR1, a.EquityR2) AS FLCorrel
       FROM ( SELECT a.TickerSymbol AS Ticker1, b.TickerSymbol AS Ticker2, a.EquityReturn AS EquityR1, b.EquityReturn AS EquityR2
              FROM   finEquityReturns a,  
	             finEquityReturns b
	      WHERE  b.TxnDate = a.TxnDate
	      AND    a.TickerSymbol = 'MSFT'
	      AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
              ORDER BY 1  
		LIMIT 1
	     ) AS a
     ) AS a;
	 
---- Negative Test 4: Value(Double Precision) out of range: Correlation of 1.0e400 * Value
--- Numeric Overflow error, Good
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCorrel(a.EquityReturn*1e400, b.EquityReturn*1e400) AS FLCorrel
FROM   finEquityReturns a,
       finEquityReturns b
WHERE  b.TxnDate = a.TxnDate
AND    a.TickerSymbol = 'MSFT'
AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;

---- Negative Test 5: Value(Double Precision) out of range: Correlation of 1.0e-400 * Value
--- Returns NULL value as correlation is not defined, Good
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCorrel(a.EquityReturn*1e-400, b.EquityReturn*1e-400) AS FLCorrel
FROM   finEquityReturns a,
       finEquityReturns b
WHERE  b.TxnDate = a.TxnDate
AND    a.TickerSymbol = 'MSFT'
AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;

---- Negative Test 6: Input all identical values
--- If Output Null then Pass, otherwise, Fail
SELECT a.FLCorrel AS FLCorrel,
       CASE WHEN FLCorrel IS NULL THEN 'BasicStat-FT-FLCorrel-01N6: PASSED' ELSE 'BasicStat-FT-FLCorrel-01N6: FAILED' END AS TestOutcome
FROM ( SELECT a.TickerSymbol AS Ticker1,
			  b.TickerSymbol AS Ticker2,
              FLCorrel(1, 1) AS FLCorrel
       FROM   finEquityReturns a,
              finEquityReturns b
       WHERE  b.TxnDate = a.TxnDate
       AND    a.TickerSymbol = 'MSFT'
       AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
       GROUP BY a.TickerSymbol, b.TickerSymbol) AS a;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
