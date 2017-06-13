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
-- 	Test Category:		    Matrix Operations
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-----****************************************************************
---FLMatrixDet
-----****************************************************************
SELECT p.Matrix_ID,p.Determinant
FROM (
SELECT a.Matrix_ID AS Matrix_ID, FLMatrixDet(a.Row_ID,
											a.Col_ID,
											a.Cell_Val)
OVER (PARTITION BY 1) AS Determinant
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS p
WHERE p.Determinant IS NOT NULL;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixInv
-----****************************************************************
SELECT a.Row_ID,
       a.Col_ID,
       FLMatrixInv(a.Row_ID, a.Col_ID, a.Cell_Val)
OVER (PARTITION BY 1) AS Inverse
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixRREF
-----****************************************************************
SELECT a.Row_ID,
       a.Col_ID,
       FLMatrixRREF(a.Row_ID, a.Col_ID, a.Cell_Val, 2)
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
SELECT a.Row_ID,
       a.Col_ID,
       a.Cell_Val,
       NVL(LAG(0) OVER (PARTITION BY 1 ORDER BY a.Row_ID, a.Col_ID), 1) 
       AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY 1 ORDER BY a.Row_ID, a.Col_ID), 1) 
       AS end_flag
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS t,
TABLE ( FLMtxInvUdt(t.Row_ID, 
                    t.Col_ID, 
                    t.Cell_Val,
                    t.begin_flag, 
                    t.end_flag)
       ) AS f;





-------------------------------------------------------------------------------------
-----****************************************************************
---FLMatrixInvStr
-----****************************************************************
SELECT FLMatrixInvStr(a.Row_ID, a.Col_ID, a.Cell_Val)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.Inverse) AS Row,
       FLMatrixCol(p.Inverse) AS Col,
       FLMatrixVal(p.Inverse) AS Inverse
FROM(
     SELECT FLMatrixInvStr(a.Row_ID, a.Col_ID, a.Cell_Val)
     OVER (PARTITION BY 1) AS Inverse
     FROM tblMatrixMulti a
     WHERE a.Matrix_ID = 5
     ) AS p;




-------------------------------------------------------------------------------------
-----****************************************************************
---Transpose of a Matrix
-----****************************************************************
SELECT a.Col_ID AS Row,
	a.Row_ID As Col,
	a.Cell_Val AS Transpose
FROM tblMatrixMulti a
WHERE a.Matrix_ID=5
ORDER BY 1, 2;



-------------------------------------------------------------------------------------
-----****************************************************************
---Product of Two Matrices
-----****************************************************************
TRUNCATE TABLE tblMatrixResult;
INSERT INTO tblMatrixResult
	SELECT a.Row_ID,
		a.Col_ID,
		FLMatrixInv(a.Row_ID, a.Col_ID, a.CELL_VAL)
		OVER (PARTITION BY 1) AS Inverse
	FROM tblMatrixMulti a
	WHERE a.Matrix_ID=5
	ORDER BY 1, 2;
SELECT a.Row_ID,
	b.Col_ID,
	FLSumProd(a.CELL_VAL, b.CELL_VAL) AS Product
FROM tblMatrixResult a,
	tblMatrixMulti b 
WHERE a.Col_ID = b.Row_ID
AND b.Matrix_ID=5
GROUP BY a.Row_ID, b.Col_ID
ORDER BY 1, 2;


-------------------------------------------------------------------------------------
SELECT a.Row_ID,
 b.Col_ID,
 CASE
       WHEN ABS(FLSumProd(a.Cell_Val, b.Cell_Val)) < 1e-15 
            THEN 0
       ELSE FLSumProd(a.Cell_Val, b.Cell_Val)
 END
FROM  tblMatrixResult a,
	tblMatrixMulti b
WHERE  a.Col_ID = b.Row_ID
AND b.Matrix_ID=5
GROUP BY a.Row_ID, b.Col_ID
ORDER BY 1, 2;


-----****************************************************************
---FLEigenValue
-----****************************************************************
SELECT a.Row_ID,
       a.Col_ID,
       FLEigenValue(a.Row_ID,
       a.Col_ID,
       a.Cell_Val)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;



-------------------------------------------------------------------------------------
-- If we are interested in only the non-zero values in the Eigen Value matrix
SELECT p.*
FROM (
SELECT a.Row_ID,
       a.Col_ID,
       FLEigenValue(a.Row_ID,
       a.Col_ID,
       a.Cell_Val)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) as p
WHERE p.Row_ID = p.Col_ID
ORDER BY 1, 2;


-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenValueStr
-----****************************************************************
SELECT FLMatrixRow(p.EigenValue) AS Row,
        FLMatrixCol(p.EigenValue) AS Col,
       FLMatrixVal(p.EigenValue) AS EigenValue
FROM ( 
SELECT FLEigenValueStr(a.Row_ID,
                       a.Col_ID,
                       a.Cell_Val)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5 
) AS p
ORDER BY 1, 2;
-------------------------------------------------------------------------------------
SELECT FLEigenValueStr(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.EigenValue) AS Row,
		FLMatrixCol(p.EigenValue) AS Col,
		FLMatrixVal(p.EigenValue) AS EigenValue
FROM (
SELECT FLEigenValueStr(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
OVER (PARTITION BY 1) AS EigenValue
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
) AS p;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenVector
-----****************************************************************
SELECT a.Row_ID,
       a.Col_ID,
       FLEigenVector(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
OVER (PARTITION BY 1) AS EigenVector
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5
ORDER BY 1, 2;




-------------------------------------------------------------------------------------
-----****************************************************************
---FLEigenVectorStr
-----****************************************************************

SELECT FLEigenVectorStr(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
OVER (PARTITION BY 1)
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5;

-------------------------------------------------------------------------------------
SELECT FLMatrixRow(p.EigenVector) AS Row,
       FLMatrixCol(p.EigenVector) AS Col,
       FLMatrixVal(p.EigenVector) AS EigenVector
FROM( 
     SELECT FLEigenVectorStr(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
OVER (PARTITION BY 1) AS EigenVector
FROM tblMatrixMulti a
WHERE a.Matrix_ID = 5 
) AS p
ORDER BY 1, 2;

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
SELECT FLEigenSystemStr(a.Row_ID,
					a.Col_ID,
					a.Cell_Val)
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
      SELECT FLEigenSystemStr(a.Row_ID,
							a.Col_ID,
							a.Cell_Val)
      OVER (PARTITION BY 1) AS EigenSystem
      FROM tblMatrixMulti a
      WHERE a.Matrix_ID = 5
      ) AS p
ORDER BY 1,2;
