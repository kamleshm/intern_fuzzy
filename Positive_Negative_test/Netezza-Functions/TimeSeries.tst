SELECT q.*
FROM(
SELECT a.GroupID,
       a.Time,
       a.Value,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)     
       AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)    
       AS end_flag
       FROM  tblTimeSeriesTest a
) AS p,
TABLE(FLARIMAUdt(p.GroupID, 
                 p.Value, 
                 1, 
                 0, 
                 1, 
                 p.begin_flag, 
                 p.end_flag)
      ) AS q
ORDER BY 1, 2, 3
LIMIT 20;



-------------------------------------------------------------------------------------
SELECT q.*
FROM(
SELECT a.GroupID,
       a.Time,
       a.Value,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)     
       AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)    
       AS end_flag
FROM tblTimeSeriesTest a
) AS p,
TABLE(FLARIMAFcstUdt(p.GroupID, 
                     p.Value, 
                     1,
                     0, 
                     1, 
                     p.begin_flag,
                     p.end_flag)
       ) AS q
ORDER BY 1, 2
LIMIT 20;



-------------------------------------------------------------------------------------
SELECT q.*
FROM(
SELECT a.GroupID,
       a.Time,
       a.Value,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,
a.Time), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,
a.Time), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID, 
                       p.Value, 
                       10, 
                       p.begin_flag, 
                       p.end_flag) 
      ) AS q
ORDER BY 1, 2
LIMIT 20;

-------------------------------------------------------------------------------------
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
