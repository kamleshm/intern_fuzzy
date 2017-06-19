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
