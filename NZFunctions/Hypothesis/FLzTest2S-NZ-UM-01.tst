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
--timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---FLtTest2S
-----*******************************************************************************************************************************
--Input Table
SELECT *
FROM tblHypoTest
LIMIT 20;


--Output Table
SELECT FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID,a.Num_Val, 2) AS T_Stat,
       FLtTest2S('P_VALUE', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 2) AS P_Value
FROM tblHypoTest a;



-- END: TEST(s)

-- END: TEST SCRIPT
--timing off

