-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
--
--
-- Functional Test Specifications:
--
-- 	Test Category:		Matrix Operation Functions
--
--	Test Unit Number:	FLEigenSystemUdt-TD-01
--
--	Name(s):		FLEigenSystemUdt
--
-- 	Description:		Calculates the tridiagonal/upper Hessenberg matrix, eigenvalues, and 
--				eigenvectors of a square matrix (n x n). If the input matrix is symmetric 
--				then the function returns a tridiagonal matrix, else it returns the upper Hessenberg matrix.
--
--	Applications:		 
--
-- 	Signature:		FLEigenSystemUdt (Matrix_ID, Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:	Double Precision
--
--	Last Updated:	01-26-2014
--
--	Author:			<Tammy Weng: Tammy.Weng@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

CREATE MULTISET TABLE tblEigenValues ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
PRIMARY INDEX ( row_id ,col_id );

CREATE MULTISET TABLE tblEigenVectors ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
PRIMARY INDEX ( row_id ,col_id );


CREATE MULTISET TABLE tblEigenSystemTest ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
PRIMARY INDEX ( row_id ,col_id );

CREATE MULTISET TABLE tblEigenSystemOutput ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      OutputMatrixID BIGINT,
      OutputRowNum BIGINT,
      OutputColNum BIGINT,
      OutputTriDiag   DOUBLE PRECISION,
      OutputEigenVal  DOUBLE PRECISION,
      OutputEigenVec  DOUBLE PRECISION)
PRIMARY INDEX (OutputMatrixID, OutputRowNum, OutputColNum);

-- BEGIN: POSITIVE TEST(s)
---- P1 Test with a 10 * 10 Non-Symmetric Matrix
---- Simulate X

    DELETE FROM tblEigenValues ALL;
    INSERT INTO tblEigenValues
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID = Col_ID THEN FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenVectors ALL;
    INSERT INTO tblEigenVectors
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenVectors AS a
    )
    SELECT b.MatrixID AS MatrixID,
           b.Row_ID,
           a.OutputColNum AS Col_ID,
           FLSumProd(a.OutputVal, b.Num_Val) as Cell_Val
    FROM (SELECT a.*
          FROM   TABLE (FLMatrixInvUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                         HASH BY z.Matrix_ID
                         LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                         ) AS a 
          ) AS a,
          (SELECT b.MatrixID,
                  b.Row_ID,
                  a.Col_ID,
                  FLSumProd(a.Cell_Val, b.Cell_Val) AS Num_Val
           FROM  tblEigenValues AS a,
                 tblEigenVectors AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Col_ID = a.Row_ID
           GROUP BY 1, 2, 3
           ) AS b
    WHERE b.MatrixID = a.OutputMatrixID
    AND   b.Col_ID = a.OutputRowNum
    GROUP BY 1, 2, 3;
    
    ---- Calculate Eigenvalues and Eigen Vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;
                 
    ---- Check if Eigenvalues match with simulated eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P1a: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P1a: FAILED' END AS Msg
    FROM  (SELECT b.MatrixID,
                   CASE WHEN ABS(a.Cell_Val - b.Cell_Val)/(ABS(b.Cell_Val) + 1) < 1e-3 THEN 0 ELSE 1 END AS Num_Val
           FROM   (SELECT a.OutputMatrixID AS MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY OutputMatrixID ORDER BY OutputEigenVal) AS ROW_ID,
                           OutputEigenVal AS Cell_Val
                   FROM tblEigenSystemOutput AS a
                   WHERE a.OutputRowNum = a.OutputColNum
                   ) AS a,
                   (SELECT a.MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY MatrixID ORDER BY Cell_Val) AS ROW_ID,
                           a.Cell_Val 
                   FROM tblEigenValues AS a
                   WHERE a.Row_ID = a.Col_ID
                   ) AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Row_ID = a.Row_ID
           ) AS a
    GROUP BY 1
    ORDER BY 1;   

    ---- Check Eigen Vectors
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P1b: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P1b: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val)/(ABS(b.Num_Val) + 1) <= 1e-3 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1;
    
---- P2 Test with a 10 * 10 Symmetric Matrix
---- Simulate X

    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           FLSumProd(a.Cell_Val, b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;  

    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P2: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P2: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-8 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1; 
    
---- P3 Test with a 10 * 10 Non-Symmetric Singular Matrix
---- Simulate X

    DELETE FROM tblEigenValues ALL;
    INSERT INTO tblEigenValues
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID = Col_ID AND ROW_ID < 10 THEN FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenVectors ALL;
    INSERT INTO tblEigenVectors
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenVectors AS a
    )
    SELECT b.MatrixID AS MatrixID,
           b.Row_ID,
           a.OutputColNum AS Col_ID,
           FLSumProd(a.OutputVal, b.Num_Val) as Cell_Val
           
    FROM (SELECT a.*
          FROM   TABLE (FLMatrixInvUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                         HASH BY z.Matrix_ID
                         LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                         ) AS a 
          ) AS a,
          (SELECT b.MatrixID,
                  b.Row_ID,
                  a.Col_ID,
                  FLSumProd(a.Cell_Val, b.Cell_Val) AS Num_Val
           FROM  tblEigenValues AS a,
                 tblEigenVectors AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Col_ID = a.Row_ID
           GROUP BY 1, 2, 3
           ) AS b
    WHERE b.MatrixID = a.OutputMatrixID
    AND   b.Col_ID = a.OutputRowNum
    GROUP BY 1, 2, 3;
    
    ---- Calculate Eigenvalues and Eigen Vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;
                 
    ---- Check if Eigenvalues match with simulated eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P3a: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P3a: FAILED' END AS Msg
    FROM  (SELECT b.MatrixID,
                   CASE WHEN ABS(a.Cell_Val - b.Cell_Val)/(ABS(b.Cell_Val) + 1) < 1e-3 THEN 0 ELSE 1 END AS Num_Val
           FROM   (SELECT a.OutputMatrixID AS MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY OutputMatrixID ORDER BY OutputEigenVal) AS ROW_ID,
                           OutputEigenVal AS Cell_Val
                   FROM tblEigenSystemOutput AS a
                   WHERE a.OutputRowNum = a.OutputColNum
                   ) AS a,
                   (SELECT a.MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY MatrixID ORDER BY Cell_Val) AS ROW_ID,
                           a.Cell_Val 
                   FROM tblEigenValues AS a
                   WHERE a.Row_ID = a.Col_ID
                   ) AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Row_ID = a.Row_ID
           ) AS a
    GROUP BY 1
    ORDER BY 1;   

    ---- Check Eigen Vectors
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P3b: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P3b: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val)/(ABS(b.Num_Val) + 1) <= 1e-3 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1;

---- P4 Test with a 10 * 10 Symmetric Singular Matrix
---- Simulate X

    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID < 10 THEN FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           FLSumProd(a.Cell_Val, b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;  

    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P4: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P4: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-8 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1; 

---- P5 Test with a 100 * 100 Non-Symmetric Matrix
---- Simulate X
/*
    DELETE FROM tblEigenValues ALL;
    INSERT INTO tblEigenValues
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID = Col_ID THEN FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 100
    AND    Col_id <= 100
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenVectors ALL;
    INSERT INTO tblEigenVectors
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 100
    AND    Col_id <= 100
    AND    MatrixID <= 2;
    
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenVectors AS a
    )
    SELECT b.MatrixID AS MatrixID,
           b.Row_ID,
           a.OutputColNum AS Col_ID,
           FLSumProd(a.OutputVal, b.Num_Val) as Cell_Val
           
    FROM (SELECT a.*
          FROM   TABLE (FLMatrixInvUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                         HASH BY z.Matrix_ID
                         LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                         ) AS a 
          ) AS a,
          (SELECT b.MatrixID,
                  b.Row_ID,
                  a.Col_ID,
                  FLSumProd(a.Cell_Val, b.Cell_Val) AS Num_Val
           FROM  tblEigenValues AS a,
                 tblEigenVectors AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Col_ID = a.Row_ID
           GROUP BY 1, 2, 3
           ) AS b
    WHERE b.MatrixID = a.OutputMatrixID
    AND   b.Col_ID = a.OutputRowNum
    GROUP BY 1, 2, 3;
    
    ---- Calculate Eigenvalues and Eigen Vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;
                 
    ---- Check if Eigenvalues match with simulated eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P5a: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P5a: FAILED' END AS Msg
    FROM  (SELECT b.MatrixID,
                   CASE WHEN ABS(a.Cell_Val - b.Cell_Val) < 1e-8 THEN 0 ELSE 1 END AS Num_Val
           FROM   (SELECT a.OutputMatrixID AS MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY OutputMatrixID ORDER BY OutputEigenVal) AS ROW_ID,
                           OutputEigenVal AS Cell_Val
                   FROM tblEigenSystemOutput AS a
                   WHERE a.OutputRowNum = a.OutputColNum
                   ) AS a,
                   (SELECT a.MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY MatrixID ORDER BY Cell_Val) AS ROW_ID,
                           a.Cell_Val 
                   FROM tblEigenValues AS a
                   WHERE a.Row_ID = a.Col_ID
                   ) AS b
           WHERE b.MatrixID = a.MatrixID
           AND   b.Row_ID = a.Row_ID
           ) AS a
    GROUP BY 1
    ORDER BY 1;   

    ---- Check Eigen Vectors
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P5b: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P5b: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-8 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1;
//*/

---- P6 Test with a 100 * 100 Symmetric Matrix
---- Simulate X

    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 100
    AND    Col_id <= 100
    AND    MatrixID <= 2
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           FLSumProd(a.Cell_Val, b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a;  

    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01P6: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01P6: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-6 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1;  
   
-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)
 
---- N1 Test with non-square matrix

---- N1.1 Test Number of Rows > Number of Cols
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 9
    AND    MatrixID <= 2;
    
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                  FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                  HASH BY z.Matrix_ID
                  LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                  ) AS a;  
                  
---- N1.2 Test Number of Rows > Number of Cols
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,1000)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 9
    AND    Col_id <= 10
    AND    MatrixID <= 2;
    
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                  FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                  HASH BY z.Matrix_ID
                  LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                  ) AS a; 
                 
---- N2 Test with complex eigenvalues
    DELETE FROM tblEigenSystemTest ALL;
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 1, 3);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 2, -2);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 1, 4);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 2 , -1);
    ---- Calculate eigenvalues and eigen vectors
    DELETE FROM tblEigenSystemOutput ALL;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                  FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                  HASH BY z.Matrix_ID
                  LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                  ) AS a; 
    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenSystemUdt-TD-01N2: PASSED' ELSE 'Matrix-FT-FLEigenSystemUdt-TD-01N2: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-6 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenSystemOutput AS a,
                        tblEigenSystemOutput AS b
                 WHERE b.OutputMatrixID = a.OutputMatrixID
                 AND   b.OutputColNum = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS b
          WHERE b.MatrixID = a.MatrixID
          AND   b.Row_ID = a.Row_ID
          AND   b.Col_ID = a.Col_ID) AS a
    GROUP BY 1
    ORDER BY 1;  
-- 	END: NEGATIVE TEST(s)

--	Drop schema/indexes by calling associated drop script(s) (OPTIONAL)
  DROP TABLE tblEigenValues;
  DROP TABLE tblEigenVectors;
  DROP TABLE tblEigenSystemTest;
  DROP TABLE tblEigenSystemOutput;

-- 	END: TEST SCRIPT
