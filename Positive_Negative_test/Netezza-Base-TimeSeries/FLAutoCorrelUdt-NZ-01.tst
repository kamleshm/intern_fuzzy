-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
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
-- 	Test Category:		Time Series Functions
--
--	Test Unit Number:	FLAutoCorrelUdt-Netezza-01
--
--	Name(s):		FLAutoCorrelUdt
--
-- 	Description:		Calculates the coefficients of the autoregressive integrated moving average (ARIMA) model.
--
--	Applications:		 
--
-- 	Signature:		FLAutoCorrelUdt(pGroupID INTEGER,
--                                pValue DOUBLE PRECISION,
--                                pLag INTEGER,
--                                pBeginFlag INTEGER
--                                pEndFlag INTEGER)
--
--	Parameters:		See Documentation
--
--	Return value:	Table
--
--	Last Updated:	04-27-2017
--
--	Author:			<Diptesh.Nath@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

---- Table used for FlAutoCorrelUdt

DROP TABLE tblTimeSeriesTest;
CREATE TABLE tblTimeSeriesTest
(GroupID BIGINT,ObsID BIGINT,Value DOUBLE PRECISION
) DISTRIBUTE ON (GroupID);
INSERT INTO tblTimeSeriesTest
SELECT 1, ObsID, Num_Val FROM tblTimeSeriesW1
UNION
SELECT 2, ObsID, Num_Val FROM tblTimeSeriesW2
UNION
SELECT 3, ObsID, Num_Val FROM tblTimeSeriesW3
UNION
SELECT 4, ObsID, Num_Val FROM tblTimeSeriesW4
UNION
SELECT 5, ObsID, Num_Val FROM tblTimeSeriesW5
UNION
SELECT 6, ObsID, Num_Val FROM tblTimeSeriesW6
UNION
SELECT 7, ObsID, Num_Val FROM tblTimeSeriesW7;


---- BEGIN: NEGATIVE TEST(s)

--	Case 1 Invalid parameters
SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.Time), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.Time), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID,p.Value,10,p.begin_flag,p.end_flag)
) AS q
ORDER BY 1, 2;

--	Case 2 Parameter 1 cannot be NULL

SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(null,p.Value,10,p.begin_flag,p.end_flag)
) AS q
ORDER BY 1, 2;

---- Case 3 Parameter 3 cannot be negative

SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID,p.Value,-10,p.begin_flag,p.end_flag)
) AS q
ORDER BY 1, 2;

---- Case 4 Parameter 4 cannot be NULL

SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID,p.Value,10,null,p.end_flag)
) AS q
ORDER BY 1, 2;

---- Case 5 Parameter 4 cannot be NULL

SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID,p.Value,10,p.begin_flag,null)
) AS q
ORDER BY 1,2;

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- CASE 1 Test with normal and extreme values

SELECT q.*
FROM(
SELECT a.GroupID,a.ObsID,a.Value,
NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS begin_flag,
NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID,a.ObsID), 1) AS end_flag
FROM tblTimeSeriesTest AS a
) AS p,
TABLE (FLAutoCorrelUdt(p.GroupID,p.Value,10,p.begin_flag,p.end_flag)
) AS q
ORDER BY 1, 2;

-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT
