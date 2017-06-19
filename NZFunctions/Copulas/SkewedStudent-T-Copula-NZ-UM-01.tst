--INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata Aster
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC.
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade
-- secret or copyright law. Dissemination of this information or reproduction of this material is
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
--      Test Category:              Copulas – Multivariate Distributions
--
--      Last Updated:                   05-30-2017
--
--      Author:                         <kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST(s)

-----****************************************************************
---Skewed Student’s T Copula
-----****************************************************************
-----------------------------------------------------------------------------------
/******************************************************************/
/**************** First truncate all the tables *******************/
/******************************************************************/

TRUNCATE TABLE tblSimUncorr;

TRUNCATE TABLE tblCholesky;

TRUNCATE TABLE tblSimCorr;

TRUNCATE TABLE tblInvGamma;

/******************************************************************/
/******** Generate uncorrelated standard normal variates **********/
/******************************************************************/
INSERT INTO tblSimUncorr
SELECT a.SerialVal AS TrialID,
       b.SerialVal AS DrawID,
       c.SerialVal AS SeriesID,
       FLSimNormal(RANDOM(), 0, 1)
FROM   fzzlSerial a,
       fzzlSerial b,
       fzzlSerial c
WHERE  a.SerialVal <= 10000   ---- number of trials
AND    b.SerialVal <= 1000    ---- number of draws
AND    c.SerialVal <= 4       ---- number of variates
ORDER BY 1, 2, 3;

/******************************************************************/
/************** Generate Inverse Gamma Distribution ***************/
/******************************************************************/

INSERT INTO tblInvGamma
SELECT a.SerialVal AS TrialID,
       b.SerialVal AS DrawID,
       FLSimInvGamma(RANDOM(), 5.5, 5.5) ---- degrees of freedom is 11
FROM   fzzlSerial a,
       fzzlSerial b
WHERE  a.SerialVal <= 10000
AND    b.SerialVal <= 1000;


/******************************************************************/
/**************** Perform Cholesky decomposition ******************/
/******************************************************************/
INSERT INTO tblCholesky
SELECT FLMatrixRow(p.CholeskyStr) AS Row,
FLMatrixCol(p.CholeskyStr) AS Col,
FLMatrixVal(p.CholeskyStr) AS Value
FROM (
SELECT FLCholeskyStr(a.seriesid1, a.seriesid2, a.Correl)
OVER (PARTITION BY 1) AS CholeskyStr
FROM tbldistCorrel a
WHERE a.seriesid1 <= 4 ---- Limit rows and columns
AND a.seriesid2 <= 4 ---- to match the number of variates
) AS p
ORDER BY 1, 2;

/******************************************************************/
/***************Generate Skewed Student's T Copula ***************/
/******************************************************************/
INSERT INTO tblSimCorr
SELECT p.TrialID,
       p.DrawID,
       p.SeriesID,
       FLSimSkewTCopulaObs(q.Mean, q.StdDev, q.Skewness, 11, p.SimValue, r.SimValue)
FROM   (
       SELECT a.TrialID,
              a.DrawID,
              b.Row AS SeriesID,
              FLSumProd(b.Value, a.SimValue) AS SimValue
       FROM   tblSimUncorr a,
              tblCholesky b
       WHERE  b.Col    = a.SeriesID
       GROUP BY a.TrialID, a.DrawID, b.Row
       ) AS p,
       tblDistParams q,
       tblInvGamma r
WHERE  q.SeriesID = p.SeriesID
AND    r.TrialID  = p.TrialID
AND    r.DrawID   = p.DrawID;



SELECT  *
FROM    tblSimUncorr
LIMIT 20;

SELECT  *
FROM    tblCholesky
LIMIT 20;

SELECT  *
FROM    tblSimCorr
LIMIT 20;

SELECT  *
FROM    tblInvGamma
LIMIT 20;

