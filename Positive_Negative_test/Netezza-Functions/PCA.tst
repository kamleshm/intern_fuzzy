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
