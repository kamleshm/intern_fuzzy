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
---FLzTest1S
-----*******************************************************************************************************************************
--Input table
SELECT *
FROM tblHypoTest
LIMIT 20;

--Output Table
SELECT  GROUPID, COUNT(*) AS GRP_COUNT, 
        FLzTest1S('Z_STAT',  0.45, a.Num_Val, 2) AS Z_STAT,
        FLzTest1S('P_VALUE', 0.45, a.Num_Val, 2) AS P_VALUE
FROM    tblHypoTest a
WHERE   TestType = 'tTest'
GROUP BY GROUPID
ORDER BY 1;



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off

