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
