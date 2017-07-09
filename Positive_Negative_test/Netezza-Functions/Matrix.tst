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
