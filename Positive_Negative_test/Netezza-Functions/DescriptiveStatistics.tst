-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    Math Functions
--
--	Last Updated:			05-15-2017
--
--	Author:			    	<anurag.reddy@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----*******************************************************************************************************************************
---FLCorrel
-----*******************************************************************************************************************************
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCorrel(a.EquityReturn, b.EquityReturn) AS FLCorrel
FROM finEquityReturns a,
     finEquityReturns b
WHERE b.TxnDate = a.TxnDate
AND a.TickerSymbol = 'MSFT'
AND b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;


---------------------------------------------------------------------
-----****************************************************************
---FLCount
-----****************************************************************
SELECT a.TickerSymbol,
       FLCount(a.ClosePrice) AS FLCount
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCountIf
-----****************************************************************
SELECT a.TickerSymbol,
 FLCountIf(a.Volume > 10000) AS FLCountIf
FROM  finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCountNeg
-----****************************************************************
SELECT a.TickerSymbol,
       FLCountNeg(a.ClosePrice - 20) AS FLCountNeg
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCountNull
-----****************************************************************
SELECT a.TickerSymbol,
 	FLCountNull(CASE 
                   WHEN EXTRACT(Year FROM a.TxnDate) = 2000 THEN NULL
 	ELSE a.Volume 
                   END) AS FLCountNull
FROM  finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCountPos
-----****************************************************************
SELECT a.TickerSymbol,
       FLCountPos(a.ClosePrice - 20) AS FLCountPos
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCountZero
-----****************************************************************
SELECT a.TickerSymbol,
       FLCountZero(a.ClosePrice - 20) AS FLCountZero
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLCovar
-----****************************************************************
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCovar(a.EquityReturn, b.EquityReturn) AS FLCovar
FROM finEquityReturns a,
     finEquityReturns b
WHERE b.TxnDate = a.TxnDate
AND a.TickerSymbol = 'MSFT'
AND b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;



---------------------------------------------------------------------
-----****************************************************************
---FLCovarP
-----****************************************************************
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLCovarP(a.EquityReturn, b.EquityReturn) AS FLCovarP
FROM  finEquityReturns a,
	finEquityReturns b
WHERE b.TxnDate = a.TxnDate
AND  a.TickerSymbol = 'MSFT'
AND  b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1, 2;



---------------------------------------------------------------------
-----****************************************************************
---FLDevSq
-----****************************************************************
SELECT a.TickerSymbol,
 	FLDevSq(a.ClosePrice) AS FLDevSq
FROM  finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLGeoMean
-----****************************************************************
SELECT a.TickerSymbol,
       FLGeoMean(a.ClosePrice) AS FLGeoMean
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLHarMean
-----****************************************************************
SELECT a.TickerSymbol,
       FLHarMean(a.ClosePrice) AS FLHarMean
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLMean
-----****************************************************************
SELECT a.TickerSymbol,
 	FLMean(a.ClosePrice) AS FLMean
FROM   finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLKurtosis
-----****************************************************************
SELECT a.TickerSymbol,
        FLKurtosis(a.ClosePrice) AS FLKurtosis
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLMax
-----****************************************************************
SELECT a.TickerSymbol,
       FLMax(a.ClosePrice) AS FLMax
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLMedianWin
-----****************************************************************
SELECT *
FROM(SELECT a.TickerSymbol,
	    FLMedianWin(a.ClosePrice) OVER (PARTITION BY TickerSymbol) 
            AS Median
     FROM finStockPrice a
     WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')) b
WHERE b.Median IS NOT NULL
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLMin
-----****************************************************************
SELECT a.TickerSymbol,
       FLMin(a.ClosePrice) AS FLMin
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLNTileWin
-----****************************************************************
WITH z (pTickerSymbol, pGroupID, pValue, pRequiredNtile) AS (
SELECT a.TickerSymbol, a.TickerID, a.ClosePrice, 4
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL'))
SELECT z.pTickerSymbol,
       z.pGroupID,
       z.pValue,
       FLNTileWin(z.pValue, 4) OVER(PARTITION BY z.pGroupID) AS nTile
FROM   z
ORDER BY 1,2,3
LIMIT 20;



---------------------------------------------------------------------
-----****************************************************************
---FLPercWin
-----****************************************************************
WITH z (pTickerSymbol,pGroupID, pValue) AS (
SELECT a.TickerSymbol,a.TickerID, a.ClosePrice
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL'))
SELECT pTickerSymbol,
       Perc10
FROM (SELECT z.pTickerSymbol,
             FLPercWin(z.pValue,0.1) OVER (PARTITION BY z.pTickerSymbol)
             AS Perc10
      FROM   z) p
WHERE  Perc10 is not null
ORDER BY 1; 



---------------------------------------------------------------------
-----****************************************************************
---FLPercentWin
-----****************************************************************
WITH z (pTxnDate,pGroupID,pTickerSymbol,pValue, pRankOrder) AS (
SELECT a.TxnDate,a.TickerID, a.TickerSymbol, a.ClosePrice, 'D'
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND    a.TxnDate BETWEEN '2002-01-01' AND '2002-02-01')
SELECT z.pTickerSymbol,
       z.pTxnDate,
       z.pGroupID,
       z.pValue,
       FLPercentWin(z.pValue) OVER(PARTITION BY z.pGroupID) AS Percentage
FROM   z
ORDER BY 1,2
LIMIT 20;



---------------------------------------------------------------------
-----****************************************************************
---FLProd
-----****************************************************************
SELECT a.TickerSymbol,
       EXTRACT(YEAR FROM b.TxnDate) AS CalendarYear,
       COUNT(b.TxnDate) AS NumTxnDates,
       FLProd(1.0 + LN(b.ClosePrice/a.ClosePrice)) - 1.0 AS AnnualReturn
FROM finStockPrice a,
     finStockPrice b
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND b.TickerID = a.TickerID
AND b.DateIdx = a.DateIdx + 1
GROUP BY a.TickerSymbol, EXTRACT(YEAR FROM b.TxnDate)
ORDER BY 1,2
LIMIT 20;



---------------------------------------------------------------------
-----****************************************************************
---FLRank
-----****************************************************************
WITH z (pTxnDate,pGroupID,pTickerSymbol,pValue, pRankOrder) AS (
SELECT a.TxnDate,
       a.TickerID, 
       a.TickerSymbol, 
       a.ClosePrice, 
       'D'
FROM   finStockPrice a
WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND    a.TxnDate BETWEEN '2002-01-01' AND '2002-02-01')
SELECT z.pTickerSymbol,
       z.pTxnDate,
       z.pGroupID,
       z.pValue,
       FLRank(z.pValue, z.pRankOrder) OVER (PARTITION BY z.pTickerSymbol)
       AS Rank
FROM   z
ORDER BY 1,2
LIMIT 20;



---------------------------------------------------------------------
-----****************************************************************
---FLSkewness
-----****************************************************************
SELECT a.TickerSymbol,
       FLSkewness(a.ClosePrice) AS FLSkewness
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLStdDev
-----****************************************************************
SELECT a.TickerSymbol,
       FLStdDev(a.ClosePrice) AS FLStdDev
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLStdDevP
-----****************************************************************
SELECT a.TickerSymbol,
       FLStdDevP(a.ClosePrice) AS FLStdDevP
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLSum
-----****************************************************************
SELECT a.TickerSymbol,
       FLSum(a.ClosePrice) AS FLSum
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLSumProd
-----****************************************************************
SELECT a.TickerSymbol,
       FLSumProd(a.Volume, a.ClosePrice) AS FLSumProd
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLVar
-----****************************************************************
SELECT a.TickerSymbol,
       FLVar(a.ClosePrice) AS FLVar
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLVarP
-----****************************************************************
SELECT a.TickerSymbol,
       FLVarP(a.ClosePrice) AS FLVarP
FROM finStockPrice a
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLWtAvg
-----****************************************************************
SELECT a.TickerSymbol,
       FLWtAvg(a.Volume, b.StockReturn) AS FLWtAvg
FROM finStockPrice a,
     finStockReturns b
WHERE b.TickerID = a.TickerID
AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLWtCovar
-----****************************************************************
SELECT a.TickerSymbol AS Ticker1,
       b.TickerSymbol AS Ticker2,
       FLWtCovar(c.StockReturn,
                 d.StockReturn,
                 CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,
                 1) AS FLWtCovar1,
       FLWtCovar(c.StockReturn,
                 d.StockReturn,
                 CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,
                 2) AS FLWtCovar2,
       FLWtCovar(c.StockReturn,
                 d.StockReturn,
                 CAST((a.Volume + b.Volume) AS DOUBLE PRECISION)/2,
                 3) AS FLWtCovar3
FROM   finStockPrice a,
       finStockPrice b,
       finStockReturns c,
       finStockReturns d
WHERE  b.TickerID <> a.TickerID AND b.DateIdx = a.DateIdx
AND    a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND    b.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
AND    c.TickerID = a.TickerID AND d.TickerID = b.TickerID
AND    c.DateIdx = b.DateIdx AND d.DateIdx = c.DateIdx
GROUP BY a.TickerSymbol, b.TickerSymbol
ORDER BY 1,2;



---------------------------------------------------------------------
-----****************************************************************
---FLWtStdDev
-----****************************************************************
SELECT a.TickerSymbol,
        FLWtStdDev(a.Volume, b.StockReturn) AS FLWtStdDev
FROM finStockPrice a,
     finStockReturns b
WHERE b.TickerID = a.TickerID
AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;



---------------------------------------------------------------------
-----****************************************************************
---FLWtVar
-----****************************************************************
SELECT a.TickerSymbol,
       FLWtVar(a.Volume, b.StockReturn) AS FLWtVar
FROM finStockPrice a,
     finStockReturns b
WHERE b.TickerID = a.TickerID
AND b.DateIdx = a.DateIdx
AND a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
GROUP BY a.TickerSymbol
ORDER BY 1;
