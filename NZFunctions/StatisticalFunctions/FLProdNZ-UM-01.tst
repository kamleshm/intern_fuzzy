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
