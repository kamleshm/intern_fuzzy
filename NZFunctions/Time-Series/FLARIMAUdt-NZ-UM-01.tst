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

DROP TABLE UM_tblTimeSeriesTest;

CREATE TABLE UM_tblTimeSeriesTest
(
GroupID BIGINT,
Time BIGINT,
Value DOUBLE PRECISION
) DISTRIBUTE ON (GroupID);

INSERT INTO UM_tblTimeSeriesTest
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

--UM_tblTimeSeriesTest
SELECT *
FROM UM_tblTimeSeriesTest
LIMIT 20;

--Output Table
SELECT q.*
FROM(
SELECT a.GroupID,
       a.Time,
       a.Value,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)
       AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.Time), 1)
       AS end_flag
       FROM UM_tblTimeSeriesTest a
) AS p,
TABLE(FLARIMAUdt(p.GroupID,
                 p.Value,
                 1,
                 0,
                 1,
                 p.begin_flag,
                 p.end_flag)
     ) AS q
ORDER BY 1, 2, 3;




-- END: TEST(s)

-- END: TEST SCRIPT
\timing off