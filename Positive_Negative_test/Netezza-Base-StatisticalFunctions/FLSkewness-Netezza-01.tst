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
--	Test Unit Number:		FLSkewness-Netezza-01
--
--	Name(s):		    	FLSkewness
--
-- 	Description:			Aggregate function which returns the skewness
--
--	Applications:		 
--
-- 	Signature:		    	FLSkewness(pX DOUBLE PRECISION)
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

---- Positive Test 1: Manual Example
--- Same output as manual, good
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice) AS FLSkewness
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Positive Test 2: Compare outputs between when same inputs with Null values and without Null values
--- Same output, Meaning Null Values are stripped before the computation which is good.
---- Positive Test 2a: Test when input with Null values
SELECT a.TickerSymbol,
       FLSkewness(
CASE WHEN EXTRACT(Year FROM a.TxnDate) = 2000 THEN NULL
ELSE a.Volume END
) AS FLCountNull
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Positive Test 2b: Test when input without Null values
SELECT a.TickerSymbol,
       FLSkewness(
CASE WHEN EXTRACT(Year FROM a.TxnDate) = 2000 THEN NULL
ELSE a.Volume END
) AS FLCountNull
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL') AND EXTRACT(Year FROM a.TxnDate) <> 2000
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Positive Test 3a: Test when adding constant to each value, Results should not change
--- when adding 1e5, results change a little, which is due to precision limit of double and is expected
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice) AS FLSkewness0,
	   FLSkewness(a.ClosePrice+1) AS FLSkewness1,
	   FLSkewness(a.ClosePrice+1e2) AS FLSkewness2,
	   FLSkewness(a.ClosePrice+1e5) AS FLSkewness3   /* Small Changes */
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Positive Test 3b: Adding large value 1e10
--output error msg: caused a floating point exception: invalid arithmetic operation
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice+1e10) AS FLSkewness
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Positive Test 4: Test when input small number close to zero, Results should not change
--- when multiply by small number 1e-150, Output NaN, which is on account of very small value
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice) AS FLSkewness0,
	   FLSkewness(a.ClosePrice/1e50) AS FLSkewness1,
	   FLSkewness(a.ClosePrice/1e100) AS FLSkewness2, 
	   FLSkewness(a.ClosePrice/1e150) AS FLSkewness3   /* Output NaN*/
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Test when all Null values
--- Output NULL, good
SELECT a.TickerSymbol,
       FLSkewness(
CASE WHEN EXTRACT(Year FROM a.TxnDate) = 2000 THEN NULL
ELSE a.Volume END
) AS FLCountNull
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL') AND EXTRACT(Year FROM a.TxnDate) = 2000
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Negative Test 2: Test when the number of non-null values is less than 3
--- Output NULL, good
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice) AS FLSkewness
FROM  (SELECT TOP 2 a.TickerSymbol, a.ClosePrice
       FROM finStockPrice a
       WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
       ORDER BY 1
       ) AS a
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Negative Test 3: Value(Double Precision) out of range: Skewness of 1.0e400 * Value
--- Numeric overflow error, Good
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice * 1e400) AS FLSkewness
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

---- Negative Test 4: Value(Double Precision) out of range: Skewness of 1.0e-400 * Value
--- Numeric overflow error, Good
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice * 1e-400) AS FLSkewness
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
