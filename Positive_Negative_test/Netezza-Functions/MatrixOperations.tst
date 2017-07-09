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
-- 	Test Category:		    Matrix Operations
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----****************************************************************
---FLMatrixDet
-----****************************************************************
SELECT p.Matrix_ID,p.Determinant
FROM (
SELECT a.Matrix_ID AS Matrix_ID, FLMatrixDet(a.Row,
a.Col,
a.Value)
OVER (PARTITION BY 1) AS Determinant
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS p
WHERE p.Determinant IS NOT NULL;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixInv
-----****************************************************************
SELECT a.Row,
       a.Col,
       FLMatrixInv(a.Row, a.Col, a.Value)
OVER (PARTITION BY 1) AS Inverse
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixRREF
-----****************************************************************
SELECT a.Row,
       a.Col,
       FLMatrixRREF(a.Row, a.Col, a.Value, 2)
OVER (PARTITION BY Matrix_ID) AS RREF
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLMtxInvUdt
-----****************************************************************
SELECT f.*
FROM (
SELECT a.Row,
       a.Col,
       a.Value,
       NVL(LAG(0) OVER (PARTITION BY 1 ORDER BY a.Row, a.Col), 1) 
       AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY 1 ORDER BY a.Row, a.Col), 1) 
       AS end_flag
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS t,
TABLE ( FLMtxInvUdt(t.Row, 
                    t.Col, 
                    t.Value,
                    t.begin_flag, 
                    t.end_flag)
       ) AS f;





-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixInvStr
-----****************************************************************
SELECT FLMatrixInvStr(a.Row, a.Col, a.Value)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.Inverse) AS Row,
       FLMatrixCol(p.Inverse) AS Col,
       FLMatrixVal(p.Inverse) AS Inverse
FROM(
     SELECT FLMatrixInvStr(a.Row, a.Col, a.Value)
     OVER (PARTITION BY 1) AS Inverse
     FROM tblMatrixMulti a
     WHERE a.Matrix_ID = 5
     ) AS p;




-------------------------------------------------------------------------------------
-----****************************************************************
---Transpose of a Matrix
-----****************************************************************
SELECT a.Col AS Row,
       a.Row As Col,
       a.Value AS Transpose
FROM tblMatrix a
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---Product of Two Matrices
-----****************************************************************
SELECT a.Row,
 a.Col,
 FLMatrixInv(a.Row, a.Col, a.Value) 
 OVER (PARTITION BY 1) AS Inverse 
FROM  tblMatrix a
ORDER BY 1, 2;
SELECT a.Row,
 b.Col,
 FLSumProd(a.Value, b.Value) AS Product
FROM  tblMatrixResult a, 
      tblMatrix b
WHERE  a.Col = b.Row
GROUP BY a.Row, b.Col
ORDER BY 1, 2;



-------------------------------------------------------------------------------------
SELECT a.Row,
 b.Col,
 CASE
            WHEN ABS(FLSumProd(a.Value, b.Value)) < 1e-15 
            THEN 0
       ELSE FLSumProd(a.Value, b.Value)
 END
FROM  tblMatrixResult a,
tblMatrix b
WHERE  a.Col = b.Row
GROUP BY a.Row, b.Col
ORDER BY 1, 2;



-----****************************************************************
---FLEigenValue
-----****************************************************************
SELECT a.Row,
       a.Col,
       FLEigenValue(a.Row,
       a.Col,
       a.Value)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;



-------------------------------------------------------------------------------------
-- If we are interested in only the non-zero values in the Eigen Value matrix
SELECT p.*
FROM (
SELECT a.Row,
       a.Col,
       FLEigenValue(a.Row,
       a.Col,
       a.Value)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) as p
WHERE p.Row = p.Col
ORDER BY 1, 2;


-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenValueStr
-----****************************************************************
SELECT FLMatrixRow(p.EigenValue) AS Row,
        FLMatrixCol(p.EigenValue) AS Col,
       FLMatrixVal(p.EigenValue) AS EigenValue
FROM ( 
SELECT FLEigenValueStr(a.Row,
                       a.Col,
                       a.Value)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5 
) AS p
ORDER BY 1, 2;
-------------------------------------------------------------------------------------
SELECT FLEigenValueStr(a.Row,
a.Col,
a.Value)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.EigenValue) AS Row,
FLMatrixCol(p.EigenValue) AS Col,
FLMatrixVal(p.EigenValue) AS EigenValue
FROM (
SELECT FLEigenValueStr(a.Row,
a.Col,
a.Value)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS p;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenVector
-----****************************************************************
SELECT a.Row,
       a.Col,
       FLEigenVector(a.Row,
       a.Col,
       a.Value)
OVER (PARTITION BY 1) AS EigenVector
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenVectorStr
-----****************************************************************
SELECT FLMatrixRow(p.EigenVector) AS Row,
       FLMatrixCol(p.EigenVector) AS Col,
       FLMatrixVal(p.EigenVector) AS EigenVector
FROM( 
     SELECT FLEigenVectorStr(a.Row,
                             a.Col,
                             a.Value)
OVER (PARTITION BY 1) AS EigenVector
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5 
) AS p
ORDER BY 1, 2;

-------------------------------------------------------------------------------------
SELECT FLEigenVectorStr(a.Row,
a.Col,
a.Value)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenSystemUDT
-----****************************************************************
SELECT a.*
FROM
( SELECT a.Row_ID,
	a.Col_ID,
	a.Cell_Val,
	NVL(LAG(0) OVER(PARTITION BY a.Matrix_ID
					ORDER BY a.Row_ID, a.Col_ID),1) AS Begin_flag,
	NVL(LEAD(0) OVER(PARTITION BY a.Matrix_ID
					ORDER BY a.Row_ID, a.Col_ID),1) AS End_flag
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5 ) AS z,
TABLE (FLEigenSystemUDT(z.Row_ID,
						z.Col_ID,
						z.Cell_Val,
						z.Begin_Flag,
						z.End_Flag)
		) AS a
ORDER BY 1,2,3;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenSystemStr
-----****************************************************************
SELECT FLEigenSystemStr(a.Row,
						a.Col,
						a.Value)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.EigenSystem) AS Row,
       FLMatrixCol(p.EigenSystem) AS Col,
       FLEigenValue(Row,Col,FLMatrixVal(p.EigenSystem))
OVER (PARTITION BY 1) AS EigenValue,
      FLEigenVector(Row,Col,FLMatrixVal(p.EigenSystem))
OVER (PARTITION BY 1) AS EigenVector
FROM (
      SELECT FLEigenSystemStr(a.Row,
                              a.Col,
                              a.Value)
      OVER (PARTITION BY 1) AS EigenSystem
      FROM tblMatrixMulti a
      WHERE a.Matrix_ID = 5
      ) AS p
ORDER BY 1,2;
