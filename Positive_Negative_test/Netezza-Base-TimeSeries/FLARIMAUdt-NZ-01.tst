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
--	Test Unit Number:	FLARIMAUdt-TD-01
--
--	Name(s):		FLARIMAUdt
--
-- 	Description:		Calculates the coefficients of the autoregressive integrated moving average (ARIMA) model.
--
--	Applications:		 
--
-- 	Signature:		FLARIMAUdt (Group_ID  BIGINT, 
--                              Obs_ID    BIGINT,
--                              Num_Val   DOUBLE PRECISION,
--                              P         INTEGER,
--                              D         INTEGER,
--                              Q         INTEGER)
--
--	Parameters:		See Documentation
--
--	Return value:	Table
--
--	Last Updated:	04-26-2017
--
--	Author:			<Shuai.Yang@fuzzyl.com>
--	Author:			<Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

---- Table used for ARIMAUdt

DROP TABLE tblTimeSeriesAll;
DROP TABLE tblTimeSeriesTest;
DROP TABLE tblARIMATest;

CREATE TABLE tblARIMATest
AS
(
SELECT * 
FROM   tblARIMA
);

CREATE TABLE tblTimeSeriesAll (
GroupID    BIGINT,
ObsID      BIGINT,
NumVal     DOUBLE PRECISION,
P          INTEGER,
D          INTEGER,
Q          INTEGER)
DISTRIBUTE ON (GroupID);

CREATE TABLE tblTimeSeriesTest(
GroupID    BIGINT,
ObsID      BIGINT,
NumVal     DOUBLE PRECISION,
P          INTEGER,
D          INTEGER,
Q          INTEGER)
DISTRIBUTE ON (GroupID);

INSERT INTO tblTimeSeriesAll
SELECT 1, ObsID, Num_Val, 1, 0, 0 FROM tblTimeSeriesW1
UNION
SELECT 2, ObsID, SQRT(Num_Val), 2, 0, 0 FROM tblTimeSeriesW2
UNION
SELECT 3, ObsID, Num_Val, 1, 0, 0 FROM tblTimeSeriesW3
UNION
SELECT 4, ObsID, Num_Val, 0, 1, 2 FROM tblTimeSeriesW4
UNION
SELECT 5, ObsID, Num_Val, 1, 1, 0 FROM tblTimeSeriesW5
UNION
SELECT 6, ObsID, LN(Num_Val), 0, 1, 1 FROM tblTimeSeriesW6
UNION
SELECT 7, ObsID, LN(Num_Val), 2, 0, 1 FROM tblTimeSeriesW7;

SELECT  a.GroupID,
        COUNT(*)
FROM    tblTimeSeriesAll a
GROUP BY a.GroupID 
ORDER BY 1;

---- BEGIN: NEGATIVE TEST(s)

--	Case 1 Invalid parameters
---- Case 1a Arg#3 < 0 
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1 as GroupID, ObsID, Num_Val, -1, 0, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 1b Arg#4 < 0
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1 as GroupID,ObsID,Num_Val, 0, -1, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;


---- Case 1c Arg#5 < 0
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1 as GroupID, ObsID, Num_Val, 1, 0, -1 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

--	Case 2 Extreme parameter values
---- Case 2a Arg#3 >= Num Of Observations
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT GroupID, ObsID, Num_Val, COUNT(ObsID) OVER (PARTITION BY groupid), 0, 0
FROM( SELECT 1 AS groupid, ObsID, Num_Val 
      FROM tblTimeSeriesW1 ) AS a )
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 2b Arg#4 >= Num Of Observations
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT GroupID, ObsID, Num_Val, 1, COUNT(ObsID) OVER (PARTITION BY groupid), 0
FROM( SELECT 1 AS groupid, ObsID, Num_Val 
      FROM tblTimeSeriesW1 ) AS a )
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 2c Arg#5 >= Num Of Observations
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT GroupID, ObsID, Num_Val, 1, 0, COUNT(ObsID) OVER (PARTITION BY groupid)
FROM( SELECT 1 AS groupid, ObsID, Num_Val 
      FROM tblTimeSeriesW1 ) AS a )
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;


/*
---- Case 2d Arg#3 + Arg#4 + Arg#5 >= Num Of Observations
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT GroupID, ObsID, Num_Val, COUNT(ObsID) OVER (PARTITION BY groupid)/3 + 1, COUNT(ObsID) OVER (PARTITION BY groupid)/3, COUNT(ObsID) OVER (PARTITION BY groupid)/3
FROM( SELECT 1 AS groupid, ObsID, Num_Val 
      FROM tblTimeSeriesW1 ) AS a )
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;
*/

--	Case 3 NULL checks
---- Case 3a Mixed NULL Arg#2
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1, ObsID, CASE WHEN OBSID mod 2 = 0 THEN NULL ELSE NUM_VAL END, 1, 0, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 3b NULL Arg#2
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1, ObsID, NULL, 1, 0, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 3c NULL Arg#1
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT NULL, ObsID, NUM_VAL, 1, 0, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 3d NULL Arg#3
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1, ObsID, NUM_VAL, NULL, 0, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 3e NULL Arg#4
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1, ObsID, NUM_VAL, 1, NULL, 0 FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---- Case 3f NULL Arg#5
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT 1, ObsID, NUM_VAL, 1, 0, NULL FROM tblTimeSeriesW1)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;


---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme values

-- Case 1 Query example in user manual
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Case 2
-- Test AR(1)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 1 AS P, 0 AS D, 0 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Test MA(1)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 0 AS P, 0 AS D, 1 AS Q 
--FROM tblARIMA a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Test ARIMA(1,0,1)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 1 AS P, 0 AS D, 1 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Test ARIMA(1,1,1)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 1 AS P, 1 AS D, 1 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Test ARIMA(2,0,0)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 2 AS P, 0 AS D, 0 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;
-- Test ARIMA(0,0,2)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 0 AS P, 0 AS D, 2 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

-- Test ARIMA(1,0,2)
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 1 AS P, 0 AS D, 2 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

--	Case 3 Empty table
DELETE FROM tblARIMATest;
--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT 1 AS GroupID, a.ObsID, a.Num_Val, 1 AS P, 0 AS D, 2 AS Q 
--FROM tblARIMATest a)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

--	Case 4 Constant Arg#2
DELETE FROM tblTimeSeriesTest;

INSERT INTO tblTimeSeriesTest
SELECT 1, ObsID, 1.0, 1, 0, 0 FROM tblTimeSeriesW1;

--WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
--SELECT * FROM tblTimeSeriesTest)
--SELECT a.*
WITH z (GroupID, ObsID, NumVal, P, D, Q) AS (
SELECT * FROM tblTimeSeriesAll)
SELECT a.*
FROM   (SELECT z.GroupID,z.ObsId,z.NumVal,z.P,z.D,z.Q,
	NVL(LAG(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.GroupId ORDER BY z.ObsId),1) AS end_flag 
		FROM z) as zz,TABLE (FLARIMAUdt(zz.GroupId,zz.NumVal,zz.P,zz.D,zz.Q,zz.begin_flag,zz.end_flag)) AS a;

---DROP the test table
DROP TABLE tblTimeSeriesAll;
DROP TABLE tblTimeSeriesTest;
DROP TABLE tblARIMATest;
-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT
