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




-------------------------------------------------------------------------------------
EXEC SP_ANCOVA('tblAncovaTest', 
               'GroupID', 
               'XVAL', 
               'YVAL', 
               0.05);
--SELECT a.*
--FROM fzzlANCOVAStats a
--WHERE AnalysisID='ADMIN_137601';



-------------------------------------------------------------------------------------
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




-------------------------------------------------------------------------------------
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





-------------------------------------------------------------------------------------
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


-------------------------------------------------------------------------------------
SELECT GROUPID, 
       COUNT(*) AS GRP_COUNT,
       FLtTest1S('T_STAT', 0.0, a.Value, 2) As T_STAT,
       FLtTest1S ('P_VALUE', 0.0, a.Value, 2) as P_VALUE
FROM tblHypoTest a
WHERE TestType = 'tTest'
GROUP BY GROUPID
ORDER BY 1;




SELECT FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID,a.Value, 2),
       FLtTest2S('P_VALUE', 'UNEQUAL_VAR', a.GroupID, a.Value, 2)
FROM tblHypoTest a;




-------------------------------------------------------------------------------------
SELECT FLMWTest('T_STAT' , x.GroupID, y.FracRank) AS T_STAT, 
       FLMWTest('P_VALUE' , x.GroupID, y.FracRank) AS P_VALUE
FROM (
    SELECT  a.GroupID,
            RANK() OVER (PARTITION BY 1 ORDER BY a.Value ASC) AS Rank
    FROM tblHypoTest a
) AS x,
(
    SELECT  p.Rank,
            FLFracRank(p.Rank, COUNT(*)) AS FracRank
    FROM
    (
        SELECT  a.GroupID,
                a.ObsID,
                RANK() OVER (PARTITION BY 1 ORDER BY a.Value ASC)
        FROM tblHypoTest a
    ) AS p
    GROUP BY p.Rank
) AS y
WHERE y.Rank = x.Rank;





-------------------------------------------------------------------------------------
SELECT  GROUPID, COUNT(*) AS GRP_COUNT,
        FLzTest1P('Z_STAT',  0.45, a.Num_Val, 2) AS Z_STAT,
        FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2) AS P_VALUE
FROM    tblzTest a
GROUP BY GROUPID
ORDER BY 1;




SELECT  GROUPID, COUNT(*) AS GRP_COUNT, 
        FLzTest1S('Z_STAT',  0.45, a.Value, 2) AS Z_STAT,
        FLzTest1S('P_VALUE', 0.45, a.Value, 2) AS P_VALUE
FROM    tblHypoTest a
WHERE   TestType = 'tTest'
GROUP BY GROUPID
ORDER BY 1;




SELECT  FLzTest2P('Z_STAT',  a.GroupID, a.Num_Val, 2) AS Z_STAT,
        FLzTest2P('P_VALUE', a.GroupID, a.Num_Val, 2) AS P_VALUE
FROM    tblzTest a;




SELECT  FLzTest2S('Z_STAT',  a.GroupID, a.Value, 2) AS Z_STAT,
        FLzTest2S('P_VALUE', a.GroupID, a.Value, 2) AS P_VALUE
FROM    tblHypoTest a
WHERE   TestType = 'tTest';
