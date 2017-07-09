----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLSVMLinearUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMLinSeparableDeep a) AS z,
TABLE(FLSVMLinearUdt(z.GroupID, 
                     z.ObsID, 
                     z.VarID, 
                     z.Num_Val, 
                     z.CValue, 
                     z.begin_flag, 
                     z.end_flag)) AS f;