-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
--  Test Unit Number:       FLMDEStudentsTUdt-TD-01.tst
--
--  Name(s):                FLMDEStudentsTUdt
--
--  Description:            Fit a StudentsT distribution
--
--  Applications:
--
--  Signature:              
--
--  Parameters:             See Documentation
--
--  Return value:           Table
--
--  Last Updated:           03-21-2014
--
--  Author:                 Positive test cases: <Zhi.Wang@fuzzyl.com>
--                          Negative test cases: <Joe.Fan@fuzzyl.com>
--                          Local order by changes:<Gandhari.Sen@fuzzyl.com>

--

-- BEGIN: TEST SCRIPT


.RUN file=../PulsarLogOn.sql
.SET WIDTH 1000
SET ROLE ALL;

-- BEGIN: NEGATIVE TEST(s)

---- Initialize Fit Distribution test 

-- Initialize tblSimDistMap
DROP TABLE tblSimDistMap;

CREATE TABLE tblSimDistMap
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID BIGINT
)
PRIMARY INDEX (NewGroupID);

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
DROP TABLE tblSimDistFloat;

CREATE MULTISET TABLE tblSimDistFloat
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID         BIGINT,
Num_Val         DOUBLE PRECISION
)
PRIMARY INDEX (NewGroupID);

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
DROP TABLE tblSimDistInt;

CREATE MULTISET TABLE tblSimDistInt
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID         BIGINT,
Num_Val         INTEGER
)
PRIMARY INDEX (NewGroupID);
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

-- Case 1a: Fit FLMDEStudentsTUdt onto Beta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Beta')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1b: Fit FLMDEStudentsTUdt onto Bradford distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Bradford')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1c: Fit FLMDEStudentsTUdt onto Burr distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Burr')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1d: Fit FLMDEStudentsTUdt onto Cauchy distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Cauchy')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1e: Fit FLMDEStudentsTUdt onto Chi distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Chi')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1f: Fit FLMDEStudentsTUdt onto ChiSq distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('ChiSq')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1g: Fit FLMDEStudentsTUdt onto Cosine distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Cosine')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1h: Fit FLMDEStudentsTUdt onto DoubleGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1i: Fit FLMDEStudentsTUdt onto DoubleWeibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1j: Fit FLMDEStudentsTUdt onto Erlang distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Erlang')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1k: Fit FLMDEStudentsTUdt onto Exponential distribution
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
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1l: Fit FLMDEStudentsTUdt onto ExtremeLB distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1m: Fit FLMDEStudentsTUdt onto Fisk distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Fisk')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1n: Fit FLMDEStudentsTUdt onto FoldedNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1o: Fit FLMDEStudentsTUdt onto Gamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Gamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1p: Fit FLMDEStudentsTUdt onto GenLogistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1q: Fit FLMDEStudentsTUdt onto Gumbel distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Gumbel')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1r: Fit FLMDEStudentsTUdt onto HalfNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1s: Fit FLMDEStudentsTUdt onto HypSecant distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('HypSecant')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1t: Fit FLMDEStudentsTUdt onto InvGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('InvGamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1u: Fit FLMDEStudentsTUdt onto InvNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('InvNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1v: Fit FLMDEStudentsTUdt onto Laplace distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Laplace')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1w: Fit FLMDEStudentsTUdt onto Logistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Logistic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1x: Fit FLMDEStudentsTUdt onto LogNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('LogNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1y: Fit FLMDEStudentsTUdt onto Maxwell distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Maxwell')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1z: Fit FLMDEStudentsTUdt onto Normal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Normal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aa: Fit FLMDEStudentsTUdt onto Pareto distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Pareto')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ab: Fit FLMDEStudentsTUdt onto Power distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Power')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ac: Fit FLMDEStudentsTUdt onto Rayleigh distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ad: Fit FLMDEStudentsTUdt onto Reciprocal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ae: Fit FLMDEStudentsTUdt onto Semicircular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Semicircular')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1af: Fit FLMDEStudentsTUdt onto StudentsT distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ag: Fit FLMDEStudentsTUdt onto TransBeta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('TransBeta')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ah: Fit FLMDEStudentsTUdt onto Triangular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Triangular')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ai: Fit FLMDEStudentsTUdt onto Uniform distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Uniform')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aj: Fit FLMDEStudentsTUdt onto Weibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Weibull')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ak: Fit FLMDEStudentsTUdt onto Binomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Binomial')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1al: Fit FLMDEStudentsTUdt onto Geometric distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Geometric')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1am: Fit FLMDEStudentsTUdt onto Logarithmic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1an: Fit FLMDEStudentsTUdt onto NegBinomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ao: Fit FLMDEStudentsTUdt onto Poisson distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Poisson')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 2: Stress test with different distributions (Num_Val is INTEGER)
/*
-- Case 2a: Fit FLMDEStudentsTUdt onto Beta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Beta')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2b: Fit FLMDEStudentsTUdt onto Bradford distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Bradford')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2c: Fit FLMDEStudentsTUdt onto Burr distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Burr')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2d: Fit FLMDEStudentsTUdt onto Cauchy distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Cauchy')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2e: Fit FLMDEStudentsTUdt onto Chi distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Chi')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2f: Fit FLMDEStudentsTUdt onto ChiSq distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('ChiSq')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2g: Fit FLMDEStudentsTUdt onto Cosine distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Cosine')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2h: Fit FLMDEStudentsTUdt onto DoubleGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2i: Fit FLMDEStudentsTUdt onto DoubleWeibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2j: Fit FLMDEStudentsTUdt onto Erlang distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Erlang')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2k: Fit FLMDEStudentsTUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2l: Fit FLMDEStudentsTUdt onto ExtremeLB distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2m: Fit FLMDEStudentsTUdt onto Fisk distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Fisk')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2n: Fit FLMDEStudentsTUdt onto FoldedNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2o: Fit FLMDEStudentsTUdt onto Gamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Gamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2p: Fit FLMDEStudentsTUdt onto GenLogistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2q: Fit FLMDEStudentsTUdt onto Gumbel distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Gumbel')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2r: Fit FLMDEStudentsTUdt onto HalfNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2s: Fit FLMDEStudentsTUdt onto HypSecant distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('HypSecant')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2t: Fit FLMDEStudentsTUdt onto InvGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('InvGamma')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2u: Fit FLMDEStudentsTUdt onto InvNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('InvNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2v: Fit FLMDEStudentsTUdt onto Laplace distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Laplace')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2w: Fit FLMDEStudentsTUdt onto Logistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Logistic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2x: Fit FLMDEStudentsTUdt onto LogNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('LogNormal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2y: Fit FLMDEStudentsTUdt onto Maxwell distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Maxwell')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2z: Fit FLMDEStudentsTUdt onto Normal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Normal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aa: Fit FLMDEStudentsTUdt onto Pareto distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Pareto')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ab: Fit FLMDEStudentsTUdt onto Power distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Power')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ac: Fit FLMDEStudentsTUdt onto Rayleigh distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ad: Fit FLMDEStudentsTUdt onto Reciprocal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ae: Fit FLMDEStudentsTUdt onto Semicircular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Semicircular')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2af: Fit FLMDEStudentsTUdt onto StudentsT distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ag: Fit FLMDEStudentsTUdt onto TransBeta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('TransBeta')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ah: Fit FLMDEStudentsTUdt onto Triangular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Triangular')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ai: Fit FLMDEStudentsTUdt onto Uniform distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Uniform')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aj: Fit FLMDEStudentsTUdt onto Weibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Weibull')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ak: Fit FLMDEStudentsTUdt onto Binomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Binomial')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2al: Fit FLMDEStudentsTUdt onto Geometric distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Geometric')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2am: Fit FLMDEStudentsTUdt onto Logarithmic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2an: Fit FLMDEStudentsTUdt onto NegBinomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ao: Fit FLMDEStudentsTUdt onto Poisson distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Poisson')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

*/

---- Case 3: Num_Val is constant (zero, one, 2^30)

-- Case 3a: Num_Val is constant (zero)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        0 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 3b: Num_Val is constant (one)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 3c: Num_Val is constant (2^30)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        2**30 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


---- Case 4: Num_Val is very large

-- Case 4a: Num_Val is very large (100% of array)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1000000 * a.Num_Val AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 4b: Num_Val is very large (50% of array)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN RANDOM(0,1) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



-- Case 4c: Num_Val is very large (10% of array)
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN RANDOM(0,10) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 5: Num_Val contains NULL

-- Case 5a: 10% of values are NULL
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        CASE WHEN RANDOM(1,10) = 1 THEN NULL ELSE a.Num_Val END AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 5b: 100% of values are NULL
REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        NULL AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'StudentsT';

WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
)
SELECT  b.Distribution (FORMAT 'XXXXXXXXXXXXXXX'),
        b.GroupID,
        a.*
FROM    TABLE (FLMDEStudentsTUdt(z.GroupID, z.Num_Val)
               HASH BY z.GroupID
               LOCAL ORDER BY z.GroupID, z.Num_Val) AS a,
        tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

--case 6
---Test case without local order by numval

WITH z (GroupID, NumVal,Distribution) AS
(
SELECT a.GroupID,
       a.Num_Val,
       a. Distribution
FROM  tblSimDistR a, tblSimDistRParams b
WHERE  a.Distribution = 'StudentT' AND b.Distribution = 'StudentT' AND a.GroupID = b.GroupID
)
SELECT a.GroupID AS GroupID, b.Nobs AS Nobs,  a.Location AS Est_Location, 0  AS Location,  a.Scale AS Est_Scale, 1 AS Scale, a.Shape AS Est_DF, b.Param1 AS DF
FROM TABLE(FLMDEStudentsTUdt(z.GroupID, z.NumVal)
		HASH BY z.GroupID
		LOCAL ORDER BY z.GroupID) AS a,
		tblSimDistRParams AS b
WHERE a.GroupID = b.GroupID AND b.Distribution='StudentT'
ORDER BY 4, 6, 8, 2;



---- Drop tables after Pulsar test for fit distribution function
DROP TABLE tblSimDistFloat;
DROP TABLE tblSimDistInt;
DROP TABLE tblSimDistMap;
DROP VIEW  vwSimDist;


-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1
--- All samples produce Null
WITH z (GroupID, NumVal,Distribution) AS
(
SELECT a.GroupID,
       a.Num_Val,
       a. Distribution
FROM  tblSimDistR a, tblSimDistRParams b
WHERE  a.Distribution = 'StudentT' AND b.Distribution = 'StudentT' AND a.GroupID = b.GroupID
)
SELECT a.GroupID AS GroupID, b.Nobs AS Nobs,  a.Location AS Est_Location, 0  AS Location,  a.Scale AS Est_Scale, 1 AS Scale, a.Shape AS Est_DF, b.Param1 AS DF
FROM TABLE(FLMDEStudentsTUdt(z.GroupID, z.NumVal)
		HASH BY z.GroupID
		LOCAL ORDER BY z.GroupID, z.NumVal) AS a,
		tblSimDistRParams AS b
WHERE a.GroupID = b.GroupID AND b.Distribution='StudentT'
ORDER BY 4, 6, 8, 2;

---- Positive Test 2
CREATE VIEW view_student_100 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimStudentsT(RANDOM(0,1000000000),0,1,35.6895) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100;

CREATE VIEW view_student_1000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimStudentsT(RANDOM(0,1000000000),0,1,35.6895) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1000;

CREATE VIEW view_student_10000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimStudentsT(RANDOM(0,1000000000),0,1,35.6895) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 10000;

---- Positive Test 2a
WITH z (GroupID, NumVal) AS
(
SELECT a.GroupID, a.NumVal FROM view_student_100 AS a
)
SELECT a.*
FROM TABLE (FLMDESTUDENTSTUDT(z.GroupID, z.NumVal)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID, z.NumVal) AS a;

---- Positive Test 2b
WITH z (GroupID, NumVal) AS
(
SELECT a.GroupID, a.NumVal FROM view_student_1000 AS a
)
SELECT a.*
FROM TABLE (FLMDESTUDENTSTUDT(z.GroupID, z.NumVal)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID, z.NumVal) AS a;

---- Positive Test 2c
WITH z (GroupID, NumVal) AS
(
SELECT a.GroupID, a.NumVal FROM view_student_10000 AS a
)
SELECT a.*
FROM TABLE (FLMDESTUDENTSTUDT(z.GroupID, z.NumVal)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID, z.NumVal) AS a;

DROP VIEW view_student_100;
DROP VIEW view_student_1000;
DROP VIEW view_student_10000;




-- END: POSITIVE TEST(s)

