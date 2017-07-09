INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
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
-- 	Test Category:		    Math Functions
--
--	Last Updated:			05-15-2017
--
--	Author:			    	<@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----****************************************************************
---FLSimBeta
-----****************************************************************
SELECT a.SerialVal,
       FLSimBeta(RANDOM(), 0.0, 1.0, 1.0, 2.0) AS SimBeta
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimBradford
-----****************************************************************
SELECT a.SerialVal,
       FLSimBradford(RANDOM(), 0.0, 1.0, 5.0) AS SimBradford
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimBurr
-----****************************************************************
SELECT a.SerialVal,
       FLSimBurr(RANDOM(), 0.0, 1.0, 2.0, 1.0) AS SimBurr
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimCauchy
-----****************************************************************
SELECT a.SerialVal,
       FLSimCauchy(RANDOM(), 0.0, 1.0) AS SimCauchy
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimChi
-----****************************************************************
SELECT a.SerialVal,
       FLSimChi(RANDOM(), 0, 1, 2) AS SimChi
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimChiSq
-----****************************************************************
SELECT a.SerialVal,
       FLSimChiSq(RANDOM(), 3) AS SimChiSq
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimCosine
-----****************************************************************
SELECT a.SerialVal,
       FLSimCosine(RANDOM(), 0.0, 1.0) AS SimCosine
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimErlang
-----****************************************************************
SELECT a.SerialVal,
       FLSimErlang(RANDOM(), 0.0, 1.0, 2) AS SimErlang
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimExp
-----****************************************************************
SELECT a.SerialVal,
       FLSimExp(RANDOM(), 0.0, 1.0) AS SimExp
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimExtremeLB
-----****************************************************************
SELECT a.SerialVal,
       FLSimExtremeLB(RANDOM(), 1.0, 1.0, 2.0) AS SimExtremeLB
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimFisk
-----****************************************************************
SELECT a.SerialVal,
       FLSimFisk(RANDOM(), 1.0, 1.0, 2.0) AS SimFisk
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimFoldedNormal
-----****************************************************************
SELECT a.SerialVal,
       FLSimFoldedNormal(RANDOM(), 1.0, 1.0) AS SimFoldedNormal
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimGamma
-----****************************************************************
SELECT a.SerialVal,
       FLSimGamma(RANDOM(), 0.0, 1.0, 2.0) AS SimGamma
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimGumbel
-----****************************************************************
SELECT a.SerialVal,
       FLSimGumbel(RANDOM(), 0.0, 1.0) AS SimGumbel
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimHypSecant
-----****************************************************************
SELECT a.SerialVal,
       FLSimHypSecant(RANDOM(), 0.0, 1.0) AS SimHypSecant
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimInvNormal
-----****************************************************************
SELECT a.SerialVal,
       FLSimInvNormal(RANDOM(), 1.0, 1.0) AS SimInvNormal
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimLaplace
-----****************************************************************
SELECT a.SerialVal,
       FLSimLaplace(RANDOM(), 0.0, 1.0) AS SimLaplace
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimLogistic
-----****************************************************************
SELECT a.SerialVal,
       FLSimLogistic(RANDOM(), 0.0, 1.0) AS SimLogistic
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimLogNormal
-----****************************************************************
SELECT a.SerialVal,
       FLSimLogNormal(RANDOM(), 0.0, 1.0) AS SimLogNormal
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimMaxwell
-----****************************************************************
SELECT a.SerialVal,
       FLSimMaxwell(RANDOM(), 1.0) AS SimMaxwell
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimNormal
-----****************************************************************
SELECT a.SerialVal,
       FLSimNormal(RANDOM(), 0.0, 1.0) AS SimNormal
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimPareto
-----****************************************************************
SELECT a.SerialVal,
       FLSimPareto(RANDOM(), 1.0, 1.0) AS SimPareto
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimPower
-----****************************************************************
SELECT a.SerialVal,
       FLSimPower(RANDOM(), 2.0) AS SimPower
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimRayleigh
-----****************************************************************
SELECT a.SerialVal,
       FLSimRayleigh(RANDOM(), 1.0) AS SimRayleigh
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimReciprocal
-----****************************************************************
SELECT a.SerialVal,
       FLSimReciprocal(RANDOM(), 1.0, 100.0) AS SimReciprocal
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimSemicircular
-----****************************************************************
SELECT a.SerialVal,
       FLSimSemicircular(RANDOM(), 0.0, 1.0) AS SimSemicircular
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimStudentsT
-----****************************************************************
SELECT a.SerialVal,
       FLSimStudentsT(RANDOM(), 0.0, 1.0, 2.0) AS SimStudentsT
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimTriangular
-----****************************************************************
SELECT a.SerialVal,
       FLSimTriangular(RANDOM(), -4.0, 4.0, 2.0) AS SimTriangular
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimUniform
-----****************************************************************
SELECT a.SerialVal,
       FLSimUniform(RANDOM(), 0.0, 1.0) AS SimUniform
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimWeibull
-----****************************************************************
SELECT a.SerialVal,
       FLSimWeibull(RANDOM(), 1.0, 2.0, 3.0) AS SimWeibull
FROM   fzzlSerial a
WHERE  a.SerialVal <= 5
ORDER BY 1;
