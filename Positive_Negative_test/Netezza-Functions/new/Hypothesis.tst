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
DROP VIEW view_ANOVA1Way;
CREATE VIEW view_ANOVA1Way AS
SELECT s.serialval AS GroupID, 
       t.City, 
       t.SalesPerVisit
FROM   tblCustData t, 
       fzzlserial s
WHERE  City <> 'Boston'
AND    serialval <= 1;
SELECT a.*
FROM(SELECT a.GroupID,
            a.City,
            a.SalesPerVisit,
            NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.City), 1)
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.City), 1)
            AS end_flag 
     FROM view_ANOVA1Way a) AS z,
TABLE(FLANOVA1WAYUdt(z.GroupID, 
                     z.City, 
                     z.SalesPerVisit, 
                     z.begin_flag, 
                     z.end_flag)) AS a;
DROP VIEW view_ANOVA1Way;




-----*******************************************************************************************************************************
---SP_Ancova
-----*******************************************************************************************************************************
EXEC SP_ANCOVA('tblAncovaTest', 
               'GroupID', 
               'XVAL', 
               'YVAL', 
               0.05);
--SELECT a.*
--FROM fzzlANCOVAStats a
--WHERE AnalysisID='ADMIN_137601';



-----*******************************************************************************************************************************
---FLCrossTabUdt
-----*******************************************************************************************************************************
SELECT  a.*
FROM(
SELECT 1 AS groupid,
       a.tabrowid,
       a.tabcolid,
              NVL(LAG(0) OVER (PARTITION BY groupid ORDER BY a.tabrowid), 1)   
       AS begin_flag, 
       NVL(LEAD(0) OVER (PARTITION BY groupid ORDER BY a.tabrowid), 1)  
       AS end_flag
FROM tblCrossTab a) AS z,
TABLE(FLCrossTabUdt(z.groupid, 
                    z.tabrowid, 
                    z.tabcolid, 
                    z.begin_flag, 
                    z.end_flag)) AS a;




-----*******************************************************************************************************************************
---FLCrossTabUdt with Large Contingency Tables
-----*******************************************************************************************************************************
SELECT  a.HardwareID,
        b.MajorID,
        FLChiSq('EXP_VAL', a.HardwareID, b.MajorID, c.HardwareID,
c.MajorID, 1) AS Exp_Val,
        FLChiSq('CHI_SQ', a.HardwareID, b.MajorID, c.HardwareID, c.MajorID,
1) AS Chi_SQ
FROM   tblHardware a,
        tblMajor b,
       tblStudentCrossRef c
GROUP BY a.HardwareID,b.MajorID
ORDER BY 1, 3;





-----*******************************************************************************************************************************
---SP_KSTest1S
-----*******************************************************************************************************************************
-- Case 1: Both mean and standard deviation are known.
DROP TABLE tblKSTestOut;
CALL SP_KSTest1S('NORMAL', 
                 'tblKSTest', 
                 'Num_Val', 
                  3.5, 
                  11.5, 
                  NULL, 
                 'GROUPID', 
                 'tblKSTestOut');
SELECT * 
FROM tblKSTestOut 
ORDER BY 1;



-- Case 2: Both mean and standard deviation are unknown.
DROP TABLE tblKSTestOut;
CALL SP_KSTest1S('NORMAL', 
                 'tblKSTest', 
                 'Num_Val', 
                  NULL, 
                  NULL, 
                  NULL, 
                 'GROUPID', 
                 'tblKSTestOut');
SELECT * 
FROM tblKSTestOut 
ORDER BY 1;

DROP TABLE tblKSTestOut;


-----*******************************************************************************************************************************
---FLtTest1S
-----*******************************************************************************************************************************
SELECT GROUPID, 
       COUNT(*) AS GRP_COUNT,
       FLtTest1S('T_STAT', 0.0, a.Num_Val, 2) As T_STAT,
       FLtTest1S ('P_VALUE', 0.0, a.Num_Val, 2) as P_VALUE
FROM tblHypoTest a
WHERE TestType = 'tTest'
GROUP BY GROUPID
ORDER BY 1;



-----*******************************************************************************************************************************
---FLtTest2S
-----*******************************************************************************************************************************
SELECT FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID,a.Num_Val, 2) AS T_Stat,
       FLtTest2S('P_VALUE', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 2) AS P_Value
FROM tblHypoTest a;




-----*******************************************************************************************************************************
---FLMWTest
-----*******************************************************************************************************************************
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





-----*******************************************************************************************************************************
---FLzTest1P
-----*******************************************************************************************************************************
SELECT  GROUPID, COUNT(*) AS GRP_COUNT,
        FLzTest1P('Z_STAT',  0.45, a.Num_Val, 2) AS Z_STAT,
        FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2) AS P_VALUE
FROM    tblzTest a
GROUP BY GROUPID
ORDER BY 1;



-----*******************************************************************************************************************************
---FLzTest1S
-----*******************************************************************************************************************************
SELECT  GROUPID, COUNT(*) AS GRP_COUNT, 
        FLzTest1S('Z_STAT',  0.45, a.Num_Val, 2) AS Z_STAT,
        FLzTest1S('P_VALUE', 0.45, a.Num_Val, 2) AS P_VALUE
FROM    tblHypoTest a
WHERE   TestType = 'tTest'
GROUP BY GROUPID
ORDER BY 1;



-----*******************************************************************************************************************************
---FLzTest2P
-----*******************************************************************************************************************************
SELECT  FLzTest2P('Z_STAT',  a.GroupID, a.Num_Val, 2) AS Z_STAT,
        FLzTest2P('P_VALUE', a.GroupID, a.Num_Val, 2) AS P_VALUE
FROM    tblzTest a;



-----*******************************************************************************************************************************
---FLzTest2S
-----*******************************************************************************************************************************
SELECT  FLzTest2S('Z_STAT',  a.GroupID, a.Num_Val, 2) AS Z_STAT,
        FLzTest2S('P_VALUE', a.GroupID, a.Num_Val, 2) AS P_VALUE
FROM    tblHypoTest a
WHERE   TestType = 'tTest';



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off
