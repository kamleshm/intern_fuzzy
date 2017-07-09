----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLLinRegrUDT *****';
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)    
        AS begin_flag, 
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)   
        AS end_flag
FROM tbllinregrdatadeep a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID, 
                   z.ObsID, 
                   z.VarID, 
                   z.Num_Val,
                   1,
                   0.05,
                   0.95,                    
                   z.begin_flag, 
                   z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20; 