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
---FLShuffleCorrelWin
-----****************************************************************
SELECT p.*
FROM(SELECT a.TickerSymbol,
            FLShuffleCorrelWin(a.closeprice, a.Volume) 
     OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
     FROM FINSTOCKPRICE a) AS p
WHERE p.ShuffleCorrel IS NOT NULL
ORDER BY 1
LIMIT 20;



-------------------------------------------------------------------------------------
-----****************************************************************
