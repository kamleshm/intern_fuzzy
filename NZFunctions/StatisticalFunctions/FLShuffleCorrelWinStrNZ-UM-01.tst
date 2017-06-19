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
---FLShuffleCorrelWinStr
-----****************************************************************
SELECT p.*
FROM (  SELECT a.TickerSymbol,
        FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
        OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrelStr
        FROM finstockprice a) AS p
WHERE p.ShuffleCorrelStr IS NOT NULL
ORDER BY 1
LIMIT 20;

-------------------------------------------------------------------------------------
