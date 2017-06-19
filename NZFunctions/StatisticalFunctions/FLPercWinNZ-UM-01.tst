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
