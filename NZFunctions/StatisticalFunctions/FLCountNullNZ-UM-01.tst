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
