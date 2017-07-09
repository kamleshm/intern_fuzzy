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
---FLARIMAUdt
-----*******************************************************************************************************************************
DROP TABLE tblTimeSeriesTest;
CREATE TABLE tblTimeSeriesTest
(
GroupID BIGINT,
Time BIGINT,
Value DOUBLE PRECISION
) DISTRIBUTE ON (GroupID);
INSERT INTO tblTimeSeriesTest
SELECT 1, ObsID, Num_Val FROM tblTimeSeriesW1
UNION
SELECT 2, ObsID, SQRT(Num_Val) FROM tblTimeSeriesW2
UNION
SELECT 3, ObsID, Num_Val FROM tblTimeSeriesW3
UNION
SELECT 4, ObsID, Num_Val FROM tblTimeSeriesW4
UNION
SELECT 5, ObsID, Num_Val FROM tblTimeSeriesW5
UNION
SELECT 6, ObsID, LN(Num_Val) FROM tblTimeSeriesW6
UNION
SELECT 7, ObsID, LN(Num_Val) FROM tblTimeSeriesW7;

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



-----*******************************************************************************************************************************
---FLARIMAFcstUdt
-----*******************************************************************************************************************************
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



-----*******************************************************************************************************************************
---FLAutoCorrelUdt
-----*******************************************************************************************************************************
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

-----*******************************************************************************************************************************
---FLGARCHpqUdt
-----*******************************************************************************************************************************
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
						 
						 
-----*******************************************************************************************************************************
---FLHoltWinter
-----*******************************************************************************************************************************						 
SELECT b.SerialVal,
       FLHoltWinter(a.PERIODID,
                    a.VAL,
                    7,
                    0.20,
                    0.20,
                    0.80,
                    b.SerialVal,
                    1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 28
GROUP BY b.SerialVal
ORDER BY 1;


-- END: TEST(s)

-- END: TEST SCRIPT
\timing off