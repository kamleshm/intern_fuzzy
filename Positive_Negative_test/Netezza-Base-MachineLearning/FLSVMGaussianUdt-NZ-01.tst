SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            0.1 As SigmaSqr,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMnonLinearSeparated a) AS z,
TABLE(FLSVMGaussianUdt(z.GroupID, 
                       z.ObsID, 
                       z.VarID, 
                       z.Num_Val, 
                       z.CValue, 
                       z.SigmaSqr, 
                       z.begin_flag, 
                       z.end_flag)) AS f
                       ORDER BY 1, 2, 3;