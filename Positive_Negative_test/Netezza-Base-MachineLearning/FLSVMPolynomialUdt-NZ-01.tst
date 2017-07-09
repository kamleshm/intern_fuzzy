----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLSVMPolynomialUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            2 As Degree,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMnonLinearSeparated a) AS z,
TABLE(FLSVMPolynomialUdt(z.GroupID, 
                         z.ObsID, 
                         z.VarID, 
                         z.Num_Val, 
                         z.CValue, 
                         z.Degree, 
                         z.begin_flag, 
                         z.end_flag)) AS f
                         ORDER BY 1, 2, 3;