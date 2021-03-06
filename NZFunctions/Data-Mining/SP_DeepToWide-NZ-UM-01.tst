-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- 
--
-- Functional Test Specifications:
--
-- 	Test Category:	    Data Mining Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
--timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---SP_DeepToWide
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_WideToDeep *****';

DROP TABLE tblFieldMap;
DROP TABLE tblAbaloneWTD;
EXEC SP_WideToDeep('tblAbaloneWide', 
                   'ObsID', 
                   'tblFieldMap', 
                   'tblAbaloneWTD', 
                   0);
				   
SELECT '***** EXECUTING SP_DeepToWide *****';

DROP TABLE tblAbaloneDTW;

EXEC SP_DeepToWide('tblAbaloneWTD', 
                   'tblFieldMap', 
                   'tblAbaloneWide',  
                   'tblAbaloneDTW');

SELECT	*
FROM tblAbaloneDTW
ORDER BY 1
LIMIT 10;



-- END: TEST(s)

-- END: TEST SCRIPT
--timing off