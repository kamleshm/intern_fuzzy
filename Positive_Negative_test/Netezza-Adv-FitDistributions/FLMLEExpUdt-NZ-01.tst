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
--  Test Unit Number:       FLMLEExpUdt-Netezza-01.tst
--
--  Name(s):                FLMLEExpUdt
--
--  Description:            Fit an Exponential distribution.
--
--  Applications:
--
--  Signature:              
--
--  Parameters:             See Documentation
--
--  Return value:           Table
--
--  Last Updated:           04-10-2017
--
--  Author:                 Positive test cases: <Zhi.Wang@fuzzyl.com>
--                          Negative test cases: <Joe.Fan@fuzzyl.com>
--                          Netezza changes	   : <Sam.Sharma@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT


-- .RUN file=../PulsarLogOn.sql
-- .SET WIDTH 1000
-- SET ROLE ALL;

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
DISTRIBUTE ON (NewGroupID);

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
DROP TABLE tblSimDistInt;

CREATE TABLE tblSimDistInt
(
NewGroupID      BIGINT,
Distribution    VARCHAR(100),
GroupID         BIGINT,
Num_Val         INTEGER
)
DISTRIBUTE ON (NewGroupID);

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

-- Case 1a: Fit FLMLEExpUdt onto Beta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Beta')
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1b: Fit FLMLEExpUdt onto Bradford distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Bradford')
AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1c: Fit FLMLEExpUdt onto Burr distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Burr')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1d: Fit FLMLEExpUdt onto Cauchy distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Cauchy')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1e: Fit FLMLEExpUdt onto Chi distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Chi')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1f: Fit FLMLEExpUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1g: Fit FLMLEExpUdt onto Cosine distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Cosine')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1h: Fit FLMLEExpUdt onto DoubleGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1i: Fit FLMLEExpUdt onto DoubleWeibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1j: Fit FLMLEExpUdt onto Erlang distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Erlang')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1k: Fit FLMLEExpUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1l: Fit FLMLEExpUdt onto ExtremeLB distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1m: Fit FLMLEExpUdt onto Fisk distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Fisk')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1n: Fit FLMLEExpUdt onto FoldedNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1o: Fit FLMLEExpUdt onto Gamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Gamma')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1p: Fit FLMLEExpUdt onto GenLogistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1q: Fit FLMLEExpUdt onto Gumbel distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Gumbel')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1r: Fit FLMLEExpUdt onto HalfNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1s: Fit FLMLEExpUdt onto HypSecant distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('HypSecant')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1t: Fit FLMLEExpUdt onto InvGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('InvGamma')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1u: Fit FLMLEExpUdt onto InvNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('InvNormal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1v: Fit FLMLEExpUdt onto Laplace distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Laplace')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1w: Fit FLMLEExpUdt onto Logistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Logistic')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1x: Fit FLMLEExpUdt onto LogNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('LogNormal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1y: Fit FLMLEExpUdt onto Maxwell distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Maxwell')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1z: Fit FLMLEExpUdt onto Normal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Normal')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1aa: Fit FLMLEExpUdt onto Pareto distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Pareto')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ab: Fit FLMLEExpUdt onto Power distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Power')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ac: Fit FLMLEExpUdt onto Rayleigh distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ad: Fit FLMLEExpUdt onto Reciprocal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ae: Fit FLMLEExpUdt onto Semicircular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Semicircular')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1af: Fit FLMLEExpUdt onto StudentsT distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ag: Fit FLMLEExpUdt onto TransBeta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('TransBeta')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ah: Fit FLMLEExpUdt onto Triangular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Triangular')

AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ai: Fit FLMLEExpUdt onto Uniform distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Uniform')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1aj: Fit FLMLEExpUdt onto Weibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Weibull')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ak: Fit FLMLEExpUdt onto Binomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Binomial')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1al: Fit FLMLEExpUdt onto Geometric distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Geometric')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1am: Fit FLMLEExpUdt onto Logarithmic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1an: Fit FLMLEExpUdt onto NegBinomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 1ao: Fit FLMLEExpUdt onto Poisson distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistFloat a
WHERE   UPPER(a.Distribution) = UPPER('Poisson')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



---- Case 2: Stress test with different distributions (Num_Val is INTEGER)

-- Case 2a: Fit FLMLEExpUdt onto Beta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Beta')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2b: Fit FLMLEExpUdt onto Bradford distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Bradford')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2c: Fit FLMLEExpUdt onto Burr distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Burr')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2d: Fit FLMLEExpUdt onto Cauchy distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Cauchy')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2e: Fit FLMLEExpUdt onto Chi distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Chi')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2f: Fit FLMLEExpUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2g: Fit FLMLEExpUdt onto Cosine distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Cosine')

AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2h: Fit FLMLEExpUdt onto DoubleGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')

AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2i: Fit FLMLEExpUdt onto DoubleWeibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')

AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2j: Fit FLMLEExpUdt onto Erlang distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Erlang')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2k: Fit FLMLEExpUdt onto Exponential distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2l: Fit FLMLEExpUdt onto ExtremeLB distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')
-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2m: Fit FLMLEExpUdt onto Fisk distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Fisk')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2n: Fit FLMLEExpUdt onto FoldedNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2o: Fit FLMLEExpUdt onto Gamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Gamma')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2p: Fit FLMLEExpUdt onto GenLogistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2q: Fit FLMLEExpUdt onto Gumbel distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Gumbel')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2r: Fit FLMLEExpUdt onto HalfNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2s: Fit FLMLEExpUdt onto HypSecant distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('HypSecant')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2t: Fit FLMLEExpUdt onto InvGamma distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('InvGamma')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2u: Fit FLMLEExpUdt onto InvNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('InvNormal')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2v: Fit FLMLEExpUdt onto Laplace distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Laplace')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2w: Fit FLMLEExpUdt onto Logistic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Logistic')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2x: Fit FLMLEExpUdt onto LogNormal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('LogNormal')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2y: Fit FLMLEExpUdt onto Maxwell distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Maxwell')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2z: Fit FLMLEExpUdt onto Normal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Normal')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2aa: Fit FLMLEExpUdt onto Pareto distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Pareto')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ab: Fit FLMLEExpUdt onto Power distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Power')
-- AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ac: Fit FLMLEExpUdt onto Rayleigh distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ad: Fit FLMLEExpUdt onto Reciprocal distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ae: Fit FLMLEExpUdt onto Semicircular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Semicircular')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2af: Fit FLMLEExpUdt onto StudentsT distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('StudentsT')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ag: Fit FLMLEExpUdt onto TransBeta distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('TransBeta')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ah: Fit FLMLEExpUdt onto Triangular distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Triangular')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ai: Fit FLMLEExpUdt onto Uniform distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Uniform')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2aj: Fit FLMLEExpUdt onto Weibull distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Weibull')
AND 	a.Num_Val > 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ak: Fit FLMLEExpUdt onto Binomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Binomial')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2al: Fit FLMLEExpUdt onto Geometric distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Geometric')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2am: Fit FLMLEExpUdt onto Logarithmic distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2an: Fit FLMLEExpUdt onto NegBinomial distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 2ao: Fit FLMLEExpUdt onto Poisson distribution
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    tblSimDistInt a
WHERE   UPPER(a.Distribution) = UPPER('Poisson')

-- AND 	a.Num_Val >= 0
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



---- Case 3: Num_Val is constant (zero, one, 2^30)

-- Case 3a: Num_Val is constant (zero)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        0 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';


WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
AND 	a.Num_Val > 0 
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



-- Case 3b: Num_Val is constant (one)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';


WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



-- Case 3c: Num_Val is constant (2^30)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        2**30 AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';


WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')
)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


---- Case 4: Num_Val is very large

-- Case 4a: Num_Val is very large (100% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        1000000 * a.Num_Val AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



-- Case 4b: Num_Val is very large (50% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        -- CASE WHEN RANDOM(0,1) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
		CASE WHEN RANDOM() > 0.5 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



-- Case 4c: Num_Val is very large (10% of array)
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        -- CASE WHEN RANDOM(0,10) = 1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
		CASE WHEN RANDOM() <= 0.1 THEN 1000000 ELSE 1 END * a.Num_Val  AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';

 
WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;



---- Case 5: Num_Val contains NULL

-- Case 5a: 10% of values are NULL
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        -- CASE WHEN RANDOM(1,10) = 1 THEN NULL ELSE a.Num_Val END AS Num_Val
		CASE WHEN RANDOM() <= 0.1 THEN NULL ELSE a.Num_Val END AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';

WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


-- Case 5b: 100% of values are NULL
CREATE OR REPLACE VIEW vwSimDist AS
SELECT  a.NewGroupID, 
        a.Distribution,
        a.GroupID,
        NULL AS Num_Val
FROM    tblSimDistFloat a 
WHERE   a.Distribution = 'Exponential';

WITH z (GroupID, Num_Val) AS 
(
SELECT  a.NewGroupID,
        a.Num_Val
FROM    vwSimDist a
WHERE   UPPER(a.Distribution) = UPPER('Exponential')

)
SELECT  b.Distribution,
        b.GroupID,
        aa.*
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, a.Num_Val, a.begin_flag, a.end_flag)) AS aa,
        tblSimDistMap b
WHERE aa.GroupID = b.NewGroupID
ORDER BY 1,2 ;


--case 6
---Test case without local order by numval

WITH z (GroupID, Num_Val, Distribution) AS 
(
SELECT  a.GroupID,
        a.Num_Val, 
		a.Distribution
FROM    tblSimDistR a, tblSimDistRParams b
WHERE  a.Distribution = 'Exponential' AND b.Distribution = 'Exponential' AND a.GroupID = b.GroupID
AND 	a.Num_Val > 0
)
SELECT b.Nobs AS Nobs, aa.DegreeOfFreedom AS Est_Df, b.Param1 AS Df, CASE WHEN ABS(aa.DegreeOfFreedom - b.Param1)/b.Param1 < 0.5 THEN 'Passed' ELSE  'Check' END AS Hint
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, CAST(a.Num_Val AS INT), a.begin_flag, a.end_flag)) AS aa,
        tblSimDistRParams AS b
WHERE aa.GroupID = b.GroupID AND b.Distribution='Exponential'
ORDER BY 3, 1;


---- Drop tables after Pulsar test for fit distribution function
DROP TABLE tblSimDistFloat;
DROP TABLE tblSimDistInt;
DROP TABLE tblSimDistMap;
DROP VIEW  vwSimDist;


-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1
WITH z (GroupID, Num_Val, Distribution) AS 
(
SELECT  a.GroupID,
        a.Num_Val, 
		a.Distribution
FROM    tblSimDistR a, tblSimDistRParams b
WHERE  a.Distribution = 'Exponential' AND b.Distribution = 'Exponential' AND a.GroupID = b.GroupID
AND 	a.Num_Val > 0
)
SELECT b.Nobs AS Nobs, aa.DegreeOfFreedom AS Est_Df, b.Param1 AS Df, CASE WHEN ABS(aa.DegreeOfFreedom - b.Param1)/b.Param1 < 0.5 THEN 'Passed' ELSE  'Check' END AS Hint
FROM    (SELECT vw.*,
				NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as begin_flag,
                NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.Num_Val), 1) as end_flag
		 FROM z vw) AS a,
		TABLE (FLMLEExpUdt(a.GroupID, CAST(a.Num_Val AS INT), a.begin_flag, a.end_flag)) AS aa,
        tblSimDistRParams AS b
WHERE aa.GroupID = b.GroupID AND b.Distribution='Exponential'
ORDER BY 3, 1;

---- Positive Test 2
CREATE OR REPLACE VIEW view_Exp_100 AS
-- SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(RANDOM(0,1000000000),0.76829,5) AS NumVal
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(CAST(random() * (1000000000) as INT),6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100;

CREATE OR REPLACE VIEW view_Exp_1000 AS
-- SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(RANDOM(0,1000000000),0.76829,5) AS NumVal
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(CAST(random() * (1000000000) as INT),6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1000;

CREATE OR REPLACE VIEW view_Exp_10000 AS
-- SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(RANDOM(0,1000000000),0.76829,5) AS NumVal
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimExp(CAST(random() * (1000000000) as INT),6) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 10000;

---- Positive Test 2a
WITH z (GroupID, ObsID, NumVal) AS
(
SELECT GroupID, a.ObsID, a.NumVal FROM view_Exp_100 AS a
)
SELECT b.*
FROM (SELECT vw.*,
			 NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as begin_flag,
             NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as end_flag
	  FROM z vw) AS a,
	  TABLE (FLMLEExpUdt(a.GroupID, a.NumVal, a.begin_flag, a.end_flag)) AS b ;


---- Positive Test 2b
WITH z (GroupID, ObsID, NumVal) AS
(
SELECT GroupID, ObsID, a.NumVal FROM view_Exp_1000 AS a
)
SELECT b.*
FROM (SELECT vw.*,
			 NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as begin_flag,
             NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as end_flag
	  FROM z vw) AS a,
	  TABLE (FLMLEExpUdt(a.GroupID, a.NumVal, a.begin_flag, a.end_flag)) AS b ;

	  
---- Positive Test 2c
WITH z (GroupID, ObsID, NumVal) AS
(
SELECT GroupID, ObsID, a.NumVal FROM view_Exp_10000 AS a
)
SELECT b.*
FROM (SELECT vw.*,
			 NVL(LAG(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as begin_flag,
             NVL(LEAD(0) over (partition by vw.GroupID order by vw.GroupID, vw.NumVal), 1) as end_flag
	  FROM z vw) AS a,
	  TABLE (FLMLEExpUdt(a.GroupID, a.NumVal, a.begin_flag, a.end_flag)) AS b ;

	  
DROP VIEW view_Exp_100;
DROP VIEW view_Exp_1000;
DROP VIEW view_Exp_10000;



-- END: POSITIVE TEST(s)

