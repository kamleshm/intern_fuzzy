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
SELECT p.TickerSymbol,
       q.SerialVal,
       SUBSTR(p.ShuffleCorrel, (q.SerialVal -1) * 21 + 1, 20)::DOUBLE 
       AS Correl
FROM(
      SELECT a.TickerSymbol,
             FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
      OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
      FROM finstockprice a
     ) AS p,
     fzzlSerial q
WHERE q.SerialVal <= 100
AND p.ShuffleCorrel IS NOT NULL
ORDER BY 1,2
LIMIT 20;
-------------------------------------------------------------------------------------
