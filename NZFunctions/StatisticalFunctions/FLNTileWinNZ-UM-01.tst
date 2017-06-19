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
