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
---FLAnova1WayUdt
-----*******************************************************************************************************************************

DROP VIEW UM_view_ANOVA1Way;

CREATE VIEW UM_view_ANOVA1Way AS
SELECT s.serialval AS GroupID, 
       t.City, 
       t.SalesPerVisit
FROM   tblCustData t, 
       fzzlserial s
WHERE  City <> 'Boston'
AND    serialval <= 1;

--Created VIEW
SELECT * 
FROM UM_view_ANOVA1Way
LIMIT 20;

--Output Table
SELECT a.*
FROM(SELECT a.GroupID,
            a.City,
            a.SalesPerVisit,
            NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.City), 1)
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.City), 1)
            AS end_flag 
     FROM UM_view_ANOVA1Way a) AS z,
TABLE(FLANOVA1WAYUdt(z.GroupID, 
                     z.City, 
                     z.SalesPerVisit, 
                     z.begin_flag, 
                     z.end_flag)) AS a;
					 
DROP VIEW UM_view_ANOVA1Way;




-- END: TEST(s)

-- END: TEST SCRIPT
\timing off

