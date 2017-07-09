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
--	Test Unit Number:	FLCholeskyDecompUdt-TD-01
--
--	Name(s):		FLCholeskyDecompUdt
--
-- 	Description:		Calculates the Cholesky Decomposition of a Hermitian, positive definite square matrix. 
--                      The Cholesky decomposition is a decomposition of a positive definite matrix into the 
--                      product of a lower triangular matrix and its conjugate transpose. This function outputs 
--                      the lower triangular matrix generated by Cholesky decomposition.
--
--	Applications:		 
--
-- 	Signature:		FLCholeskyDecompUdt (Matrix_ID, Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:	Double Precision
--
--	Last Updated:	02-20-2014
--
--	Author:			<Tammy Weng: Tammy.Weng@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

CREATE MULTISET TABLE tblCholeskyDecompTest ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
PRIMARY INDEX ( row_id ,col_id );

CREATE MULTISET TABLE tblCholeskyDecompOutput ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      OutputMatrixID BIGINT,
      OutputRowNum   BIGINT,
      OutputColNum   BIGINT,
      OutputVal      DOUBLE PRECISION)
PRIMARY INDEX (OutputMatrixID, OutputRowNum, OutputColNum);

-- BEGIN: POSITIVE TEST(s)
---- P1 Test with 10 * 10 Symmetric and Positive-definite Matrices
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
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
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
    ---- Test if L * L' = A 
    SELECT a.MatrixID,
           CASE WHEN FLSum(a.Err) = 0 THEN 'Matrix-FT-FLCholeskyDecompUdt-TD-01P1: PASSED' ELSE 'Matrix-FT-FLCholeskyDecompUdt-TD-01P1: FAILED' END AS Msg
    FROM   (SELECT a.MatrixID,
                   a.Row_ID,
                   a.Col_ID,
                   CASE WHEN FLAbs(a.Num_Val - b.Cell_Val) < 1e-12 THEN 0 ELSE 1 END AS Err
            FROM  (SELECT a.OutputMatrixID AS MatrixID,
                          a.OutputRowNum AS Row_ID,
                          b.OutputRowNum As Col_ID,
                          FLSumProd(a.OutputVal, b.OutputVal) AS Num_Val
                   FROM   tblCholeskyDecompOutput AS a,
                          tblCholeskyDecompOutput AS b
                   WHERE  b.OutputMatrixID = a.OutputMatrixID
                   AND    b.OutputColNum = a.OutputColNum
                   GROUP BY 1, 2, 3
                   ) AS a,
                   tblCholeskyDecompTest AS b
            WHERE  b.MatrixID = a.MatrixID
            AND    b.Row_ID = a.Row_ID
            AND    b.Col_ID = a.Col_ID
            ) AS a
    GROUP BY 1;
     
---- P2 Test with a 100 * 100 Symmetric and Positive-definite Matrix  
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
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
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
    ---- Test if L * L' = A 
    SELECT a.MatrixID,
           CASE WHEN FLSum(a.Err) = 0 THEN 'Matrix-FT-FLCholeskyDecompUdt-TD-01P2: PASSED' ELSE 'Matrix-FT-FLCholeskyDecompUdt-TD-01P2: FAILED' END AS Msg
    FROM   (SELECT a.MatrixID,
                   a.Row_ID,
                   a.Col_ID,
                   CASE WHEN FLAbs(a.Num_Val - b.Cell_Val) < 1e-10 THEN 0 ELSE 1 END AS Err
            FROM  (SELECT a.OutputMatrixID AS MatrixID,
                          a.OutputRowNum AS Row_ID,
                          b.OutputRowNum As Col_ID,
                          FLSumProd(a.OutputVal, b.OutputVal) AS Num_Val
                   FROM   tblCholeskyDecompOutput AS a,
                          tblCholeskyDecompOutput AS b
                   WHERE  b.OutputMatrixID = a.OutputMatrixID
                   AND    b.OutputColNum = a.OutputColNum
                   GROUP BY 1, 2, 3
                   ) AS a,
                   tblCholeskyDecompTest AS b
            WHERE  b.MatrixID = a.MatrixID
            AND    b.Row_ID = a.Row_ID
            AND    b.Col_ID = a.Col_ID
            ) AS a
    GROUP BY 1;

/*    
---- P3 Test with a 1000 * 1000 Symmetric and Positive-definite Matrix
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1000
    AND    Col_id <= 1000
    AND    MatrixID <= 1
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           Sum(a.Cell_Val * b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
    ---- Test if L * L' = A 
    SELECT a.MatrixID,
           CASE WHEN FLSum(a.Err) = 0 THEN 'Matrix-FT-FLCholeskyDecompUdt-TD-01P3: PASSED' ELSE 'Matrix-FT-FLCholeskyDecompUdt-TD-01P3: FAILED' END AS Msg
    FROM   (SELECT a.MatrixID,
                   a.Row_ID,
                   a.Col_ID,
                   CASE WHEN FLAbs(a.Num_Val - b.Cell_Val) < 1e-8 THEN 0 ELSE 1 END AS Err
            FROM  (SELECT a.OutputMatrixID AS MatrixID,
                          a.OutputRowNum AS Row_ID,
                          b.OutputRowNum As Col_ID,
                          Sum(a.OutputVal * b.OutputVal) AS Num_Val
                   FROM   tblCholeskyDecompOutput AS a,
                          tblCholeskyDecompOutput AS b
                   WHERE  b.OutputMatrixID = a.OutputMatrixID
                   AND    b.OutputColNum = a.OutputColNum
                   GROUP BY 1, 2, 3
                   ) AS a,
                   tblCholeskyDecompTest AS b
            WHERE  b.MatrixID = a.MatrixID
            AND    b.Row_ID = a.Row_ID
            AND    b.Col_ID = a.Col_ID
            ) AS a
    GROUP BY 1;
  */    
---- P4 Test with 10 * 10 symmetric and Positive-semi-definite Matrices
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (SELECT c.SerialVal AS MatrixID,
            a.SerialVal AS Row_id,
            b.SerialVal AS Col_id,
            FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
     FROM   fzzlSerial AS a,
            fzzlSerial As b,
            fzzlSerial AS c
     WHERE  Row_id <= 9
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
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
    ---- Test if L * L' = A 
    SELECT a.MatrixID,
           CASE WHEN FLSum(a.Err) = 0 THEN 'Matrix-FT-FLCholeskyDecompUdt-TD-01P4: PASSED' ELSE 'Matrix-FT-FLCholeskyDecompUdt-TD-01P4: FAILED' END AS Msg
    FROM   (SELECT a.MatrixID,
                   a.Row_ID,
                   a.Col_ID,
                   CASE WHEN FLAbs(a.Num_Val - b.Cell_Val) < 1e-9 THEN 0 ELSE 1 END AS Err
            FROM  (SELECT a.OutputMatrixID AS MatrixID,
                          a.OutputRowNum AS Row_ID,
                          b.OutputRowNum As Col_ID,
                          FLSumProd(a.OutputVal, b.OutputVal) AS Num_Val
                   FROM   tblCholeskyDecompOutput AS a,
                          tblCholeskyDecompOutput AS b
                   WHERE  b.OutputMatrixID = a.OutputMatrixID
                   AND    b.OutputColNum = a.OutputColNum
                   GROUP BY 1, 2, 3
                   ) AS a,
                   tblCholeskyDecompTest AS b
            WHERE  b.MatrixID = a.MatrixID
            AND    b.Row_ID = a.Row_ID
            AND    b.Col_ID = a.Col_ID
            ) AS a
    GROUP BY 1;
  
-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)
 
---- N1 Test with a non-square matrix
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
    SELECT c.SerialVal AS MatrixID,
            a.SerialVal AS Row_id,
            b.SerialVal AS Col_id,
            FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
     FROM   fzzlSerial AS a,
            fzzlSerial As b,
            fzzlSerial AS c
     WHERE  Row_id <= 10
     AND    Col_id <= 9
     AND    MatrixID <= 1;
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
---- N2 Test with a non-symmetric matrix
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
    SELECT c.SerialVal AS MatrixID,
            a.SerialVal AS Row_id,
            b.SerialVal AS Col_id,
            FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
     FROM   fzzlSerial AS a,
            fzzlSerial As b,
            fzzlSerial AS c
     WHERE  Row_id <= 10
     AND    Col_id <= 10
     AND    MatrixID <= 1;
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
---- N3 Test with a symmetric but non-positive-definite matrix
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
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
    AND    MatrixID <= 1
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           - FLSumProd(a.Cell_Val, b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
---- N4 Test with a 1001 * 1001 Matrix
    ---- Simulate input Matrix A
    DELETE FROM tblCholeskyDecompTest ALL;
    INSERT INTO tblCholeskyDecompTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(0, 100000), RANDOM(0,10), RANDOM(1,10)) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1001
    AND    Col_id <= 1001
    AND    MatrixID <= 1
    ) 
    SELECT a.MatrixID,
           a.Col_ID AS Row_ID,
           b.Col_ID,
           Sum(a.Cell_Val * b.Cell_Val) AS Cell_Val
    FROM   tblX AS a,
           tblX AS b
    WHERE b.MatrixID = a.MatrixID
    AND   b.Row_ID = a.Row_ID
    GROUP BY 1, 2, 3;
    
    ---- Perform Cholesky Decomposition and output L
    DELETE FROM tblCholeskyDecompOutput ALL;
    INSERT INTO tblCholeskyDecompOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblCholeskyDecompTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLCholeskyDecompUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 HASH BY z.Matrix_ID
                 LOCAL ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
                 ) AS a; 
                 
-- 	END: NEGATIVE TEST(s)

--	Drop schema/indexes by calling associated drop script(s) (OPTIONAL)
  DROP TABLE tblCholeskyDecompTest;
  DROP TABLE tblCholeskyDecompOutput;

-- 	END: TEST SCRIPT
