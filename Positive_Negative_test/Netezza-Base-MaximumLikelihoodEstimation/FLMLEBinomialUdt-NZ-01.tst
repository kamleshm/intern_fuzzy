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
--  Test Unit Number:       FLMLEBinomialUdt-NZ-01.tst
--
--  Name(s):                FLMLEBinomialUdt
--
--  Description:            Fit a Binomial distribution
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
--                          Local order by changes:<Gandhari.Sen@fuzzyl.com>
--			    Netezza Test cases:  <Anurag.Reddy@fuzzyl.com>
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
DISTRIBUTE ON(NewGroupID);

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

-- Case 1a: Fit FLMLEBinomialUdt onto Beta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
		MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Beta')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 1b: Fit FLMLEBinomialUdt onto Bradford distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Bradford')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1c: Fit FLMLEBinomialUdt onto Burr distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Burr')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1d: Fit FLMLEBinomialUdt onto Cauchy distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Cauchy')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1e: Fit FLMLEBinomialUdt onto Chi distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Chi')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1f: Fit FLMLEBinomialUdt onto ChiSq distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1g: Fit FLMLEBinomialUdt onto Cosine distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Cosine')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1h: Fit FLMLEBinomialUdt onto DoubleGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1i: Fit FLMLEBinomialUdt onto DoubleWeibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1j: Fit FLMLEBinomialUdt onto Erlang distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Erlang')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1k: Fit FLMLEBinomialUdt onto Exponential distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Exponential')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1l: Fit FLMLEBinomialUdt onto ExtremeLB distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1m: Fit FLMLEBinomialUdt onto Fisk distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Fisk')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1n: Fit FLMLEBinomialUdt onto FoldedNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1o: Fit FLMLEBinomialUdt onto Gamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Gamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1p: Fit FLMLEBinomialUdt onto GenLogistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1q: Fit FLMLEBinomialUdt onto Gumbel distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Gumbel')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1r: Fit FLMLEBinomialUdt onto HalfNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1s: Fit FLMLEBinomialUdt onto HypSecant distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('HypSecant')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1t: Fit FLMLEBinomialUdt onto InvGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('InvGamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1u: Fit FLMLEBinomialUdt onto InvNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('InvNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1v: Fit FLMLEBinomialUdt onto Laplace distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Laplace')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1w: Fit FLMLEBinomialUdt onto Logistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Logistic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1x: Fit FLMLEBinomialUdt onto LogNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('LogNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1y: Fit FLMLEBinomialUdt onto Maxwell distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Maxwell')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1z: Fit FLMLEBinomialUdt onto Normal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Normal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aa: Fit FLMLEBinomialUdt onto Pareto distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Pareto')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ab: Fit FLMLEBinomialUdt onto Power distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Power')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ac: Fit FLMLEBinomialUdt onto Rayleigh distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ad: Fit FLMLEBinomialUdt onto Reciprocal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ae: Fit FLMLEBinomialUdt onto Semicircular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('SemiCircular')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1af: Fit FLMLEBinomialUdt onto StudentsT distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('StudentsT')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ag: Fit FLMLEBinomialUdt onto TransBeta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('TransBeta')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ah: Fit FLMLEBinomialUdt onto Triangular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Triangular')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ai: Fit FLMLEBinomialUdt onto Uniform distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Uniform')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1aj: Fit FLMLEBinomialUdt onto Weibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Weibull')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ak: Fit FLMLEBinomialUdt onto Binomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1al: Fit FLMLEBinomialUdt onto Geometric distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Geometric')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1am: Fit FLMLEBinomialUdt onto Logarithmic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1an: Fit FLMLEBinomialUdt onto NegBinomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 1ao: Fit FLMLEBinomialUdt onto Poisson distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistFloat a
		WHERE   UPPER(a.Distribution) = UPPER('Poisson')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;



---- Case 2: Stress test with different distributions (Num_Val is INTEGER)

-- Case 2a: Fit FLMLEBinomialUdt onto Beta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Beta')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

-- Case 2b: Fit FLMLEBinomialUdt onto Bradford distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Bradford')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2c: Fit FLMLEBinomialUdt onto Burr distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Burr')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2d: Fit FLMLEBinomialUdt onto Cauchy distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Cauchy')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2e: Fit FLMLEBinomialUdt onto Chi distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Chi')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2f: Fit FLMLEBinomialUdt onto ChiSq distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('ChiSq')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2g: Fit FLMLEBinomialUdt onto Cosine distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Cosine')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2h: Fit FLMLEBinomialUdt onto DoubleGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleGamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2i: Fit FLMLEBinomialUdt onto DoubleWeibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('DoubleWeibull')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2j: Fit FLMLEBinomialUdt onto Erlang distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Erlang')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2k: Fit FLMLEBinomialUdt onto Exponential distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Exponential')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2l: Fit FLMLEBinomialUdt onto ExtremeLB distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('ExtremeLB')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2m: Fit FLMLEBinomialUdt onto Fisk distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Fisk')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2n: Fit FLMLEBinomialUdt onto FoldedNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('FoldedNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2o: Fit FLMLEBinomialUdt onto Gamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Gamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2p: Fit FLMLEBinomialUdt onto GenLogistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('GenLogistic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2q: Fit FLMLEBinomialUdt onto Gumbel distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Gumbel')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2r: Fit FLMLEBinomialUdt onto HalfNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('HalfNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2s: Fit FLMLEBinomialUdt onto HypSecant distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('HypSecant')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2t: Fit FLMLEBinomialUdt onto InvGamma distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('InvGamma')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2u: Fit FLMLEBinomialUdt onto InvNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('InvNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2v: Fit FLMLEBinomialUdt onto Laplace distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Laplace')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2w: Fit FLMLEBinomialUdt onto Logistic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Logistic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2x: Fit FLMLEBinomialUdt onto LogNormal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('LogNormal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2y: Fit FLMLEBinomialUdt onto Maxwell distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Maxwell')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2z: Fit FLMLEBinomialUdt onto Normal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Normal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aa: Fit FLMLEBinomialUdt onto Pareto distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Pareto')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ab: Fit FLMLEBinomialUdt onto Power distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Power')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ac: Fit FLMLEBinomialUdt onto Rayleigh distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Rayleigh')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ad: Fit FLMLEBinomialUdt onto Reciprocal distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Reciprocal')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ae: Fit FLMLEBinomialUdt onto Semicircular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('SemiCircular')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2af: Fit FLMLEBinomialUdt onto StudentsT distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('StudentsT')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ag: Fit FLMLEBinomialUdt onto TransBeta distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('TransBeta')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ah: Fit FLMLEBinomialUdt onto Triangular distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Triangular')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ai: Fit FLMLEBinomialUdt onto Uniform distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Uniform')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2aj: Fit FLMLEBinomialUdt onto Weibull distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Weibull')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ak: Fit FLMLEBinomialUdt onto Binomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2al: Fit FLMLEBinomialUdt onto Geometric distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Geometric')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2am: Fit FLMLEBinomialUdt onto Logarithmic distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Logarithmic')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2an: Fit FLMLEBinomialUdt onto NegBinomial distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('NegBinomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;


-- Case 2ao: Fit FLMLEBinomialUdt onto Poisson distribution
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistInt a
		WHERE   UPPER(a.Distribution) = UPPER('Poisson')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

 
SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
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
WHERE   a.Distribution = 'Binomial';

SELECT  b.Distribution,
        b.GroupID,
        a.*
FROM  ( SELECT  a.NewGroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    vwSimDist a
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')) AS z, 
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumOfTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a,
		tblSimDistMap b
WHERE a.GroupID = b.NewGroupID
ORDER BY 1,2;

--case 6
---Test case without local order by numval
--NA for NZ

---- Drop tables after Pulsar test for fit distribution function
DROP TABLE tblSimDistFloat IF EXISTS;
DROP TABLE tblSimDistInt IF EXISTS;
DROP TABLE tblSimDistMap IF EXISTS;
DROP VIEW  vwSimDist;


-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1
SELECT 	b.Nobs AS Nobs, 
		a.Prob AS Est_Prob, 
		b.Param2 AS Prob, 
		b.Param1 AS NTrials, 
		CASE WHEN ABS(a.Prob - b.Param2)/b.Param2 < 0.5 THEN 'Passed' ELSE 'Check' END AS Hint
FROM  ( SELECT  a.GroupID,
                a.Num_Val,
				MAX(a.Num_Val) OVER (PARTITION BY a.GroupID) As NumOfTrials,
				a.Distribution,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    tblSimDistR a,
				tblSimDistRParams b
		WHERE   UPPER(a.Distribution) = UPPER('Binomial')
		AND 	UPPER(b.Distribution) = UPPER('Binomial') 
		AND 	a.GroupID = b.GroupID) AS z,
		TABLE (FLMLEBinomialUdt(z.GroupID, CAST(z.NumofTrials AS INT), CAST(z.Num_Val AS INT), z.begin_flag, z.end_flag)) AS a,
		tblSimDistRParams AS b
WHERE 	a.GroupID = b.GroupID 
AND 	b.Distribution='Binomial'
ORDER BY 3, 1;


---- Positive Test 2
CREATE VIEW view_binom_100 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimBinomial(RANDOM()*10e9,0.76829,5) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100;

CREATE VIEW view_binom_1000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimBinomial(RANDOM()*10e9,0.76829,5) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1000;

CREATE VIEW view_binom_10000 AS
SELECT 1 AS GroupID,a.SerialVal AS ObsID, FLSimBinomial(RANDOM()*10e9,0.76829,5) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 10000;

---- Positive Test 2a
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
				5 AS NumofTrials,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_binom_100 a) AS z,
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumofTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

---- Positive Test 2b
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
				5 AS NumofTrials,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_binom_1000 a) AS z,
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumofTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

---- Positive Test 2c
SELECT  a.*
FROM  ( SELECT  a.GroupID AS NewGroupID,
				5 AS NumofTrials,
                a.NumVal AS Num_Val,
                NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS begin_flag, 
                NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.GroupID), 1) AS end_flag 
		FROM    view_binom_10000 a) AS z,
		TABLE (FLMLEBinomialUdt(z.NewGroupID, z.NumofTrials, z.Num_Val, z.begin_flag, z.end_flag)) AS a;

DROP VIEW view_binom_100;
DROP VIEW view_binom_1000;
DROP VIEW view_binom_10000;




-- END: POSITIVE TEST(s)
\time
-- END TEST SCRIPT
