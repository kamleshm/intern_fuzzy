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
---FLMWTest
-----*******************************************************************************************************************************
--Input Table
SELECT * 
FROM tblHypoTest
LIMIT 20;

--Output Table
SELECT FLMWTest('T_STAT' , x.GroupID, y.FracRank) AS T_STAT, 
       FLMWTest('P_VALUE' , x.GroupID, y.FracRank) AS P_VALUE
FROM (
    SELECT  a.GroupID,
            RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
    FROM tblHypoTest a
) AS x,
(
    SELECT  p.Rank,
            FLFracRank(p.Rank, COUNT(*)) AS FracRank
    FROM
    (
        SELECT  a.GroupID,
                a.ObsID,
                RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC)
        FROM tblHypoTest a
    ) AS p
    GROUP BY p.Rank
) AS y
WHERE y.Rank = x.Rank;



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off

