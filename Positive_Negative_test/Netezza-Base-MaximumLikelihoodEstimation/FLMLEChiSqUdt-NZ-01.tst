-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC.
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade
-- secret or copyright law. Dissemination of this information or reproduction of this material is
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
--  Test Category:          Basic Statistics
--
--  Test Unit Number:       FLMLEChiSqUdt-NZ-01.tst
--
--  Name(s):                FLMLEChiSqUdt
--
--  Description:            Fit a ChiSq distribution
--
--  Applications:
--
--  Signature:              
--
--  Parameters:             See Documentation
--
--  Return value:           Table
--
--  Last Updated:           07-06-2017
--
--  Author:                 Positive test cases: <Zhi.Wang@fuzzyl.com>
--                          Negative test cases: <Joe.Fan@fuzzyl.com>
--				Netezza test cases:  <Anurag.Reddy@fuzzyl.com>
--			    Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time

--.RUN file=../PulsarLogOn.sql
--.SET WIDTH 1000
--SET ROLE ALL;

-- BEGIN: NEGATIVE TEST(s)

---- Initialize Fit Distribution test 

-- Initialize tblSimDistMap
DROP TABLE tblSimDistMap IF EXISTS;

CREATE TABLE tblSimDistMap
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID BIGINT
)
DISTRIBUTE ON(NewGroupID);

INSERT INTO tblSimDistMap
(Distribution, GroupID, NewGroupID)
SELECT  a.Distribution,
        a.GroupID,
        ROW_NUMBER() OVER (ORDER BY a.tbl, a.Distribution, a.GroupID) AS NewGroupID
FROM    (
        SELECT  DISTINCT 1 AS tbl, a.Distribution, GroupID
        FROM    tblMLETest1 a
        Union ALL
        SELECT  DISTINCT 2 AS tbl, a.Distribution, GroupID
        FROM    tblMLETest2 a
        ) a;

-- Initialize tblSimDistFloat
DROP TABLE tblSimDistFloat IF EXISTS;

CREATE TABLE tblSimDistFloat
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID         BIGINT,
Num_Val         DOUBLE PRECISION
)
DISTRIBUTE ON (NewGroupID);

INSERT INTO tblSimDistFloat
(NewGroupID, Distribution, GroupID, Num_Val)
SELECT  b.NewGroupID,
        a.Distribution,
        a.GroupID,
        a.Num_Val
FROM    tblMLETest1 a,
        tblSimDistMap b
WHERE a.Distribution = b.Distribution And a.GroupID = b.GroupID
Union ALL
SELECT  b.NewGroupID,
        a.Distribution,
        a.GroupID,
        CAST(a.Num_Val AS DOUBLE PRECISION)
FROM    tblMLETest2 a,
        tblSimDistMap b
WHERE   a.Distribution = b.Distribution AND a.GroupID = b.GroupID;

-- Initialize tblSimDistInt
DROP TABLE tblSimDistInt IF EXISTS;

CREATE TABLE tblSimDistInt
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID         BIGINT,
Num_Val         INTEGER
)
DISTRIBUTE ON(NewGroupID);

INSERT INTO tblSimDistInt
(NewGroupID, Distribution, GroupID, Num_Val)
SELECT  b.NewGroupID,
        a.Distribution,
        a.GroupID,
        CAST(a.Num_Val AS INTEGER)
FROM    tblMLETest1 a,
        tblSimDistMap b
WHERE a.Distribution = b.Distribution And a.GroupID = b.GroupID
Union ALL
SELECT  b.NewGroupID,
        a.Distribution,
        a.GroupID,
        a.Num_Val
FROM    tblMLETest2 a,
        tblSimDistMap b
WHERE   a.Distribution = b.Distribution AND a.GroupID = b.GroupID;



---- Case 1: Stress test with different distributions (Num_Val is DOUBLE PRECISION)

-- Case 1a: Fit FLMLEChiSqUdt onto Beta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Beta')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 1b: Fit FLMLEChiSqUdt onto Bradford distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Bradford')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1c: Fit FLMLEChiSqUdt onto Burr distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Burr')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1d: Fit FLMLEChiSqUdt onto Cauchy distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Cauchy')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1e: Fit FLMLEChiSqUdt onto Chi distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Chi')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1f: Fit FLMLEChiSqUdt onto ChiSq distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1g: Fit FLMLEChiSqUdt onto Cosine distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Cosine')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1h: Fit FLMLEChiSqUdt onto DoubleGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1i: Fit FLMLEChiSqUdt onto DoubleWeibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1j: Fit FLMLEChiSqUdt onto Erlang distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Erlang')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1k: Fit FLMLEChiSqUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMLEChiSqUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID,z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1l: Fit FLMLEChiSqUdt onto ExtremeLB distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1m: Fit FLMLEChiSqUdt onto Fisk distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Fisk')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1n: Fit FLMLEChiSqUdt onto FoldedNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1o: Fit FLMLEChiSqUdt onto Gamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Gamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1p: Fit FLMLEChiSqUdt onto GenLogistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1q: Fit FLMLEChiSqUdt onto Gumbel distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Gumbel')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1r: Fit FLMLEChiSqUdt onto HalfNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1s: Fit FLMLEChiSqUdt onto HypSecant distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('HypSecant')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1t: Fit FLMLEChiSqUdt onto InvGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('InvGamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 1u: Fit FLMLEChiSqUdt onto InvNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('InvNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1v: Fit FLMLEChiSqUdt onto Laplace distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Laplace')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1w: Fit FLMLEChiSqUdt onto Logistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Logistic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1x: Fit FLMLEChiSqUdt onto LogNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('LogNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1y: Fit FLMLEChiSqUdt onto Maxwell distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Maxwell')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1z: Fit FLMLEChiSqUdt onto Normal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Normal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aa: Fit FLMLEChiSqUdt onto Pareto distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Pareto')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ab: Fit FLMLEChiSqUdt onto Power distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Power')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ac: Fit FLMLEChiSqUdt onto Rayleigh distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ad: Fit FLMLEChiSqUdt onto Reciprocal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ae: Fit FLMLEChiSqUdt onto Semicircular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Semicircular')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1af: Fit FLMLEChiSqUdt onto StudentsT distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('StudentsT')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ag: Fit FLMLEChiSqUdt onto TransBeta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('TransBeta')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ah: Fit FLMLEChiSqUdt onto Triangular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Triangular')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 1ai: Fit FLMLEChiSqUdt onto Uniform distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Uniform')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aj: Fit FLMLEChiSqUdt onto Weibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Weibull')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ak: Fit FLMLEChiSqUdt onto Binomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1al: Fit FLMLEChiSqUdt onto Geometric distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Geometric')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1am: Fit FLMLEChiSqUdt onto Logarithmic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1an: Fit FLMLEChiSqUdt onto NegBinomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ao: Fit FLMLEChiSqUdt onto Poisson distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Poisson')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 2: Stress test with different distributions (Num_Val is INTEGER)

-- Case 2a: Fit FLMLEChiSqUdt onto Beta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Beta')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2b: Fit FLMLEChiSqUdt onto Bradford distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Bradford')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 2c: Fit FLMLEChiSqUdt onto Burr distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Burr')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2d: Fit FLMLEChiSqUdt onto Cauchy distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Cauchy')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2e: Fit FLMLEChiSqUdt onto Chi distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Chi')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2f: Fit FLMLEChiSqUdt onto ChiSq distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2g: Fit FLMLEChiSqUdt onto Cosine distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Cosine')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2h: Fit FLMLEChiSqUdt onto DoubleGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2i: Fit FLMLEChiSqUdt onto DoubleWeibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2j: Fit FLMLEChiSqUdt onto Erlang distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Erlang')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2k: Fit FLMLEChiSqUdt onto Exponential distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Exponential')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 2l: Fit FLMLEChiSqUdt onto ExtremeLB distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2m: Fit FLMLEChiSqUdt onto Fisk distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Fisk')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2n: Fit FLMLEChiSqUdt onto FoldedNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2o: Fit FLMLEChiSqUdt onto Gamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Gamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 2p: Fit FLMLEChiSqUdt onto GenLogistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2q: Fit FLMLEChiSqUdt onto Gumbel distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Gumbel')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2r: Fit FLMLEChiSqUdt onto HalfNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2s: Fit FLMLEChiSqUdt onto HypSecant distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('HypSecant')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2t: Fit FLMLEChiSqUdt onto InvGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('InvGamma')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2u: Fit FLMLEChiSqUdt onto InvNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('InvNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2v: Fit FLMLEChiSqUdt onto Laplace distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Laplace')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2w: Fit FLMLEChiSqUdt onto Logistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Logistic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2x: Fit FLMLEChiSqUdt onto LogNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('LogNormal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2y: Fit FLMLEChiSqUdt onto Maxwell distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Maxwell')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2z: Fit FLMLEChiSqUdt onto Normal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Normal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aa: Fit FLMLEChiSqUdt onto Pareto distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Pareto')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ab: Fit FLMLEChiSqUdt onto Power distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Power')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ac: Fit FLMLEChiSqUdt onto Rayleigh distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ad: Fit FLMLEChiSqUdt onto Reciprocal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ae: Fit FLMLEChiSqUdt onto Semicircular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('SemiCircular')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2af: Fit FLMLEChiSqUdt onto StudentsT distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('StudentsT')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ag: Fit FLMLEChiSqUdt onto TransBeta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('TransBeta')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ah: Fit FLMLEChiSqUdt onto Triangular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Triangular')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ai: Fit FLMLEChiSqUdt onto Uniform distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Uniform')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aj: Fit FLMLEChiSqUdt onto Weibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Weibull')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ak: Fit FLMLEChiSqUdt onto Binomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2al: Fit FLMLEChiSqUdt onto Geometric distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Geometric')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2am: Fit FLMLEChiSqUdt onto Logarithmic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2an: Fit FLMLEChiSqUdt onto NegBinomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ao: Fit FLMLEChiSqUdt onto Poisson distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Poisson')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 3: Num_Val is constant (zero, one, 2^30)

-- Case 3a: Num_Val is constant (zero)

CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        0 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 3b: Num_Val is constant (one)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 3c: Num_Val is constant (2^30)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        2**30 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


---- Case 4: Num_Val is very large

-- Case 4a: Num_Val is very large (100% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1000000 * a.Num_Val AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 4b: Num_Val is very large (50% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN CAST(RANDOM() AS INT) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 4c: Num_Val is very large (10% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN CAST((RANDOM()*9 + 1) AS INT) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 5: Num_Val contains NULL

-- Case 5a: 10% of values are NULL
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN CAST((RANDOM()*9 + 1) AS INT) = 1 THEN NULL ELSE a.Num_Val END AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 5b: 100% of values are NULL
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        NULL AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'ChiSq';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z,
		TABLE (FLMLEChiSqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


--case 6
---Test case without local order by numval
--NA for NZ

---- Drop tables after Pulsar test for fit distribution function
DROP TABLE tblSimDistFloat;
DROP TABLE tblSimDistInt;
DROP TABLE tblSimDistMap;
DROP VIEW  vwSimDist;


-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1
SELECT 	b.Nobs AS Nobs,
		a.DegreeOfFreedom AS Est_Df,
		b.Param1 AS Df,
		CASE WHEN ABS(a.DegreeOfFreedom - b.Param1)/b.Param1 < 0.5 THEN 'Passed' ELSE  'Check' END AS Hint
FROM  ( SELECT  a.GroupID,
                a.Num_Val,
				a.Distribution,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistR a,
				tblSimDistRParams b
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')
		AND 	UPPER(b.Distribution) = UPPER('ChiSq') 
		AND 	a.GroupID = b.GroupID) AS z,
		TABLE (FLMLEChiSqUdt(z.GroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistRParams AS b
WHERE 	a.GroupID = b.GroupID 
AND 	b.Distribution='ChiSq'
ORDER BY 3, 1;


---- Positive Test 2 TD-85 Teradata mistake
CREATE VIEW view_chisq_100 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimChiSq(RANDOM()*10e9,6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100;

CREATE VIEW view_chisq_1000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimChiSq(RANDOM()*10e9,6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1000;

CREATE VIEW view_chisq_10000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimChiSq(RANDOM()*10e9,6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 10000;

---- Positive Test 2a
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_chisq_100 a) AS z,
		TABLE (FLMLEchisqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

---- Positive Test 2b
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_chisq_1000 a) AS z,
		TABLE (FLMLEchisqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

---- Positive Test 2c
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_chisq_10000 a) AS z,
		TABLE (FLMLEchisqUdt(z.NewGroupID, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

DROP VIEW view_chisq_100;
DROP VIEW view_chisq_1000;
DROP VIEW view_chisq_10000;




-- END: POSITIVE TEST(s)
\time
--END SCRIPT
