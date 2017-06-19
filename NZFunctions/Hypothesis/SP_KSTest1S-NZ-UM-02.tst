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
-- 	Test Category:	    	Hypothesis Testing Functions
--
--	Last Updated:		    05-29-2017
--
--	Author:			        <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---SP_KSTest1S
-----*******************************************************************************************************************************
DROP TABLE UM_tblKSTestOut;

--Input TABLE
SELCET *
FROM tblKSTest
LIMIT 20;

--Execute SP_KSTest1S
CALL SP_KSTest1S('NORMAL', 
                 'tblKSTest', 
                 'Num_Val', 
                  NULL, 
                  NULL, 
                  NULL, 
                 'GROUPID', 
                 'UM_tblKSTestOut');
				 
--Output table 				 
SELECT * 
FROM UM_tblKSTestOut 
ORDER BY 1;

DROP TABLE UM_tblKSTestOut;


-- END: TEST(s)

-- END: TEST SCRIPT
\timing off

