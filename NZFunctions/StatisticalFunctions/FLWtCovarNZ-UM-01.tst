-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    Statistical Functions
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-- BEGIN: TEST(s)
-----*******************************************************************************************************************************
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
