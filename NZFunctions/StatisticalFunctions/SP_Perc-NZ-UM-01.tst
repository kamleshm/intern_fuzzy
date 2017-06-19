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

-----****************************************************************
---SP_Perc
-----****************************************************************
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice',
             'CLOSEPRICE',
             'TICKERSYMBOL',
             '0.1,0.3,0.5,0.7,0.9',
             'FinStockPricePerc');

SELECT  *
FROM    FinStockPricePerc
LIMIT 20;
