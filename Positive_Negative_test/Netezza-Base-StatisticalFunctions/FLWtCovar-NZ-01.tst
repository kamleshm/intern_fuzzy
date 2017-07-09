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
--	Test Unit Number:		FLWtCovar-Netezza-01
--
--	Name(s):		    	FLWtCovar
--
-- 	Description:			The function calculates the weighted covariance in three methods
--	Applications:		 
--
-- 	Signature:		    	FLWtCovar(DataColumn1 DOUBLE PRECISION,
--										DataColumn2 DOUBLE PRECISION,
--										WeightColumn DOUBLE PRECISION,
--										Method INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			07-04-2017
--
--  Author:				Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive test
--- Gives expected output
SELECT a.TickerSymbol AS Ticker1, b.TickerSymbol AS Ticker2, FLWtCovar(c.StockReturn, d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2, 1) AS FLWtCovar1,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,2) AS FLWtCovar2,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,3) AS FLWtCovar3
FROM finStockPrice a,finStockPrice b,finStockReturns c,finStockReturns d
WHERE b.TickerID <> a.TickerID AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND c.TickerID = a.TickerID AND d.TickerID = b.TickerID
AND c.DateIdx = b.DateIdx AND d.DateIdx = c.DateIdx
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1,2 LIMIT 10;

---- Positive Test 2: Positive test case with change in values
--- Gives expected Output
SELECT a.TickerSymbol AS Ticker1, b.TickerSymbol AS Ticker2, FLWtCovar(c.StockReturn, d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION), 1) AS FLWtCovar1,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION),2) AS FLWtCovar2,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION),3) AS FLWtCovar3
FROM finStockPrice a,finStockPrice b,finStockReturns c,finStockReturns d
WHERE b.TickerID <> a.TickerID AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND c.TickerID = a.TickerID AND d.TickerID = b.TickerID
AND c.DateIdx = b.DateIdx AND d.DateIdx = c.DateIdx
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1,2 LIMIT 10;

---- Positive Test 3: Condition Test (Number of observation >= 2): Two observations
--- Return expected results, Good
SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 1), /* Method 1 = COVAR_POP */
        FLWtCovar(a.RandVal, b.RandVal, 1, 2), /* Method 2 = Method 3 */
	FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 2 AND b.SerialVal <= 2 AND a.SerialVal = b.SerialVal;

---- Positive Test 4: Positive test cases when weights are the same, Results should not change
--- Methods outputs are different, due to precision limit of platform
SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(a.RandVal, b.RandVal, 1, 3),
	FLWtCovar(a.RandVal, b.RandVal, 1e-100, 1),
	FLWtCovar(a.RandVal, b.RandVal, 1e-100, 2),
	FLWtCovar(a.RandVal, b.RandVal, 1e-100, 3), /* Method 3 outputs are different */
	FLWtCovar(a.RandVal, b.RandVal, 1e100, 1),
	FLWtCovar(a.RandVal, b.RandVal, 1e100, 2),
	FLWtCovar(a.RandVal, b.RandVal, 1e100, 3), /* Method 3 Outputs are different */
	COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;


---- Positive Test 5: Weighted Covariance of -1.0 * Value, Results should not change
--- Return expected results, Good
SELECT  FLWtCovar(-1 * a.RandVal, -1 * b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(-1 * a.RandVal, -1 * b.RandVal, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(-1 * a.RandVal, -1 * b.RandVal, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;


---- Positive Test 6: Weighted Covariance of Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLWtCovar(a.RandVal + 1.0, b.RandVal + 1.0, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(a.RandVal + 1.0, b.RandVal + 1.0, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(a.RandVal + 1.0, b.RandVal + 1.0, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;


---- Positive Test 7: Add a very large number, Results should not change
--- Results change due to precision limit of platform
SELECT  FLWtCovar(1e100 + a.RandVal, 1e100 + b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(1e100 + a.RandVal, 1e100 + b.RandVal, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(1e100 + a.RandVal, 1e100 + b.RandVal, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 8: Weighted Covariance of -1.0 * Value + 1.0, Results should not change
--- Return expected results, Good
SELECT  FLWtCovar(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(-1.0 * a.RandVal + 1.0, -1.0 * b.RandVal + 1.0, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 9: Weighted Covariance of 10.0 * Value + 1.0, Results should be 10^2 * Covariance
--- Return expected results, Good
SELECT  FLWtCovar(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(10 * a.RandVal + 1.0, 10 * b.RandVal + 1.0, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 10: Multiply by a very small number, Results should be 1e-100^2 * Covariance
--- Return expected results, Good
SELECT  FLWtCovar(1e-100 * a.RandVal, 1e-100 * b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(1e-100 * a.RandVal, 1e-100 * b.RandVal, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(1e-100 * a.RandVal, 1e-100 * b.RandVal, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Positive Test 11: Multiply by a very large number, Results should be 1e100^2 * Covariance
--- Return expected results, Good
SELECT  FLWtCovar(1e100 * a.RandVal, 1e100 * b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal, 1, 1),
	FLWtCovar(1e100 * a.RandVal, 1e100 * b.RandVal, 1, 2),
        FLWtCovar(a.RandVal, b.RandVal, 1, 2),
	FLWtCovar(1e100 * a.RandVal, 1e100 * b.RandVal, 1, 3),
        FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: TicketSymbol no match
--- Output Null
SELECT a.TickerSymbol AS Ticker1, b.TickerSymbol AS Ticker2, FLWtCovar(c.StockReturn, d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2, 1) AS FLWtCovar1,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,2) AS FLWtCovar2,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,3) AS FLWtCovar3
FROM finStockPrice a,finStockPrice b,finStockReturns c,finStockReturns d
WHERE b.TickerID <> a.TickerID AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('zzz')
AND b.TickerSymbol IN ('zzz')
AND c.TickerID = a.TickerID AND d.TickerID = b.TickerID
AND c.DateIdx = b.DateIdx AND d.DateIdx = c.DateIdx
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1,2 LIMIT 10;

---- Negative Test 2: TicketSymbol no match for b
--- Output Null
SELECT a.TickerSymbol AS Ticker1, b.TickerSymbol AS Ticker2, FLWtCovar(c.StockReturn, d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2, 1) AS FLWtCovar1,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,2) AS FLWtCovar2,
FLWtCovar(c.StockReturn,d.StockReturn,
CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,3) AS FLWtCovar3
FROM finStockPrice a,finStockPrice b,finStockReturns c,finStockReturns d
WHERE b.TickerID <> a.TickerID AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND b.TickerSymbol IN ('zzz')
AND c.TickerID = a.TickerID AND d.TickerID = b.TickerID
AND c.DateIdx = b.DateIdx AND d.DateIdx = c.DateIdx
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1,2 LIMIT 10;

---- Negative Test 3: No data
--- Output Null, Good
--- To be investigated
SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 1),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= -1 AND b.SerialVal <= -1;

---- Negative Test 4: Condition Test (Number of observation >= 2): One observation
--- Method 1 has output, Method 2 outputs "FLWtCovar caused a floating point exception, divide by zero", Method 3 outputs " FLWtCovar caused a floating point exception, Invalid arithmetic operation"
SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 1),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 2),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

SELECT  FLWtCovar(a.RandVal, b.RandVal, 1, 3),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 1 AND b.SerialVal <= 1;

---- Negative Test 5: Value(Double Precision) out of range: Weighted Covariance of 1.0e400 * Value
--- Numeric Overflow error, Good 
SELECT  FLWtCovar(1e400 * a.RandVal, 1e400 * b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

---- Negative Test 6: Value(Double Precision) out of range: Weighted Covariance of 1.0e-400 * Value
--- Returns 0 value, Good 
SELECT  FLWtCovar(1e-400 * a.RandVal, 1e-400 * b.RandVal, 1, 1),
        FLWtCovar(a.RandVal, b.RandVal,1,1),
        COUNT(*)
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 100 AND b.SerialVal <= 100 AND a.SerialVal = b.SerialVal;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
