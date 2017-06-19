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
-- 	Test Category:	    Time Series Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---FLGARCHpqUdt
-----*******************************************************************************************************************************

--Input Table
SELECT *
FROM tblbac_return
LIMIT 20;

--Output Table
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off