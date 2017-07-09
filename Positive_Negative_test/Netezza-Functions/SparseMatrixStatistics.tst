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
--	Author:			    	<anurag.reddy@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----****************************************************************
---FLSparseCorrel
-----****************************************************************
WITH tblHomeSurveyStats (MediaOutletID, VarSum, VarSqSum) AS
(
SELECT a.MediaOutletID,
       SUM(a.Num_Val) AS VarSum,
       SUM(a.Num_Val * a.Num_Val) AS VarSqSum
FROM   tblHomeSurveySparse a
GROUP BY a.MediaOutletID
)
SELECT a.MediaOutletID1,
       a.MediaOutletID2,
       FLSparseCorrel(a.VarSumXY,
                      x1.VarSum,
                      x2.VarSum,
                      x1.VarSqSum,
                      x2.VarSqSum, 9605) AS FLSparseCorrel
FROM   (
       SELECT a.MediaOutletID AS MediaOutletID1,
              b.MediaOutletID AS MediaOutletID2,
              SUM(a.Num_Val * b.Num_Val) AS VarSumXY
       FROM   tblHomeSurveySparse a,
              tblHomeSurveySparse b
       WHERE  b.ValueID = a.ValueID
       GROUP BY a.MediaOutletID, b.MediaOutletID
       ) AS a,
       tblHomeSurveyStats x1,
       tblHomeSurveyStats x2
WHERE  x1.MediaOutletID = a.MediaOutletID1
AND    x2.MediaOutletID = a.MediaOutletID2
AND    x1.MediaOutletID <= 10
AND    x2.MediaOutletID <= 10
AND    x1.MediaOutletID < x2.MediaOutletID
ORDER BY 1, 2
LIMIT 20;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseCovar
-----****************************************************************
WITH tblHomeSurveyStats (MediaOutletID, VarSum, VarSqSum) AS
(
SELECT a.MediaOutletID,
       SUM(a.Num_Val) AS VarSum,
       SUM(a.Num_Val * a.Num_Val) AS VarSqSum
FROM   tblHomeSurveySparse a
GROUP BY a.MediaOutletID
)
SELECT a.MediaOutletID1,
       a.MediaOutletID2,
       FLSparseCovar(a.VarSumXY,
                     x1.VarSum,
                     x2.VarSum,
                     x1.VarSqSum,
                     x2.VarSqSum,
                     9605) AS FLSparseCovar
FROM
       (
       SELECT a.MediaOutletID AS MediaOutletID1,
              b.MediaOutletID AS MediaOutletID2,
              SUM(a.Num_Val * b.Num_Val) AS VarSumXY
       FROM   tblHomeSurveySparse a,
              tblHomeSurveySparse b
       WHERE   b.ValueID = a.ValueID
       GROUP BY a.MediaOutletID, b.MediaOutletID
       ) AS a,
       tblHomeSurveyStats x1,
       tblHomeSurveyStats x2
WHERE  x1.MediaOutletID = a.MediaOutletID1
AND    x2.MediaOutletID = a.MediaOutletID2
AND    x1.MediaOutletID <= 10
AND    x2.MediaOutletID <= 10
AND    x1.MediaOutletID <= x2.MediaOutletID
ORDER BY 1, 2;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseKurtosis
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseKurtosis(a.VarSum,
                        a.VarSqSum,
                        a.VarCuSum,
                        a.VarQdSum,
                        a.VarCount) AS FLSparseKurtosis
FROM( 
     SELECT MediaOutletID,
            SUM(Num_Val) AS VarSum,
            SUM(Num_Val * Num_Val) AS VarSqSum,
            SUM(Num_Val * Num_Val * Num_Val) AS VarCuSum,
            SUM(Num_Val * Num_Val * Num_Val * Num_Val) AS VarQdSum,
            9605 AS VarCount
     FROM   tblHomeSurveySparse
     GROUP BY MediaOutletID
     ) AS a
WHERE MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseMean
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseMean(a.VarSum,
                    a.VarCount) AS FLSparseMean
FROM( 
     SELECT MediaOutletID,
            SUM(Num_Val) AS VarSum,
            9605 AS VarCount
     FROM  tblHomeSurveySparse
     GROUP BY MediaOutletID
     ) AS a
WHERE a.MediaOutletID <= 10
ORDER BY 1;


-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseSkewness
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseSkewness(a.VarSum,
                        a.VarSqSum,
                        a.VarCuSum,
                        a.VarCount) AS FLSparseSkewness
FROM( 
     SELECT MediaOutletID,
            SUM(Num_Val) AS VarSum,
            SUM(Num_Val * Num_Val) AS VarSqSum,
            SUM(Num_Val * Num_Val * Num_Val) AS VarCuSum,
            9605 AS VarCount
     FROM   tblHomeSurveySparse
     GROUP BY MediaOutletID
     ) AS a
WHERE MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseStdDev
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseStdDev(a.VarSum,
                      a.VarSqSum,
                      a.VarCount) AS FLSparseStdDev
FROM( 
     SELECT MediaOutletID,
            SUM(Num_Val) AS VarSum,
            SUM(Num_Val * Num_Val) AS VarSqSum,
            9605 AS VarCount
     FROM   tblHomeSurveySparse
     GROUP BY MediaOutletID
     ) AS a
WHERE MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseVar
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseVar(a.VarSum,
                   a.VarSqSum,
                   a.VarCount) AS FLSparseVar
FROM( 
     SELECT MediaOutletID,
          SUM(Num_Val) AS VarSum,
          SUM(Num_Val * Num_Val) AS VarSqSum,
          9605 AS VarCount
     FROM tblHomeSurveySparse
     GROUP BY MediaOutletID
    ) AS a
WHERE  MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLSparseVarP
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseVarP(a.VarSum,
                    a.VarSqSum,
                    a.VarCount) AS FLSparseVarP
FROM( 
     SELECT MediaOutletID,
          SUM(Num_Val) AS VarSum,
          SUM(Num_Val * Num_Val) AS VarSqSum,
          9605 AS VarCount
     FROM tblHomeSurveySparse
     GROUP BY MediaOutletID
    ) AS a
WHERE  MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLEuclideanDist
-----****************************************************************
SELECT a.Country,
       b.Country,
       FLEuclideanDist(a.Consumption, b.Consumption) AS FLEuclideanDist
FROM tblProteinConsump a,
     tblProteinConsump b
WHERE b.ProteinCode = a.ProteinCode
AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country
ORDER BY 1,2
LIMIT 20;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLManhattanDist
-----****************************************************************
SELECT a.Country,
       b.Country,
       FLManhattanDist(a.Consumption, b.Consumption) AS FLManhattanDist
FROM tblProteinConsump a,
     tblProteinConsump b
WHERE b.ProteinCode = a.ProteinCode
AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country
ORDER BY 1,2
LIMIT 20;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLShuffleCorrelWin
-----****************************************************************
SELECT p.*
FROM(SELECT a.TickerSymbol,
            FLShuffleCorrelWin(a.closeprice, a.Volume) 
     OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
     FROM FINSTOCKPRICE a) AS p
WHERE p.ShuffleCorrel IS NOT NULL
ORDER BY 1
LIMIT 20;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLShuffleCorrelWinStr
-----****************************************************************
SELECT p.*
FROM (  SELECT a.TickerSymbol,
        FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
        OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrelStr
        FROM finstockprice a) AS p
WHERE p.ShuffleCorrelStr IS NOT NULL
ORDER BY 1
LIMIT 20;

-------------------------------------------------------------------------------------
SELECT p.TickerSymbol,
       q.SerialVal,
       SUBSTR(p.ShuffleCorrel, (q.SerialVal -1) * 21 + 1, 20)::DOUBLE 
       AS Correl
FROM(
      SELECT a.TickerSymbol,
             FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
      OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
      FROM finstockprice a
     ) AS p,
     fzzlSerial q
WHERE q.SerialVal <= 100
AND p.ShuffleCorrel IS NOT NULL
ORDER BY 1,2
LIMIT 20;




-------------------------------------------------------------------------------------
-----****************************************************************
---SP_Perc
-----****************************************************************
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice',
             'CLOSEPRICE',
             'TICKERSYMBOL',
             '0.1,0.3,0.5,0.7,0.9',
             'FinStockPricePerc');
 
SELECT	* 
FROM	FinStockPricePerc
LIMIT 20; 

