-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
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
--	Test Unit Number:	FLEigenValue-NZ-01
--
--	Name(s):		FLEigenValue
--
-- 	Description:    	Calculates the eigenvalues, eigenvectors of a square matrix (n x n)
--
--	Applications:		 
--
-- 	Signature:		FLEigenValue (Row_ID, Col_ID, Cell_Val)
--				FLEigenVector (Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		01-26-2014
--
--	Author:			<Tammy Weng: Tammy.Weng@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--
--	CAUTION: This test is the same as FLEigenVector - they are computed simultaneously
--	Depending on future test scenarios, eventually, the two files may be merged.
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql


CREATE TABLE tblEigenValues
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
DISTRIBUTE ON(row_id ,col_id);

CREATE TABLE tblEigenVectors
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
DISTRIBUTE ON(row_id ,col_id);

CREATE TABLE tblEigenSystemTest
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
DISTRIBUTE ON(row_id ,col_id);

CREATE TABLE tblEigenValueOutput
     (
      OutputMatrixID BIGINT,
      OutputRowNum BIGINT,
      OutputColNum BIGINT,
      OutputEigenVal  DOUBLE PRECISION)
DISTRIBUTE ON(OutputMatrixID, OutputRowNum, OutputColNum);

CREATE TABLE tblEigenVectorOutput
     (
      OutputMatrixID BIGINT,
      OutputRowNum BIGINT,
      OutputColNum BIGINT,
      OutputEigenVec  DOUBLE PRECISION)
DISTRIBUTE ON(OutputMatrixID, OutputRowNum, OutputColNum);


-- BEGIN: POSITIVE TEST(s)
---- P1 Test with a 10 * 10 Non-Symmetric Matrix
---- Simulate X

    DELETE FROM tblEigenValues ;
    INSERT INTO tblEigenValues
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID = Col_ID THEN FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenVectors ;
    INSERT INTO tblEigenVectors
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;

    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest
    SELECT b.MatrixID AS MatrixID,
           b.Row_ID,
           a.Col AS Col_ID,
           FLSumProd(a.Value, b.Num_Val) as Cell_Val
    FROM (SELECT *,
             NVL(LAG(0) OVER (PARTITION BY 1 ORDER BY row_id, col_id), 1) AS begin_flag, 
             NVL(LEAD(0) OVER (PARTITION BY 1 ORDER BY row_id, col_id), 1) AS end_flag
		 FROM tblEigenVectors
		 WHERE MatrixID = 1
		  ) AS t,
		 TABLE (FLMtxInvUdt(t.row_id, t.col_id, t.cell_val, t.begin_flag, t.end_flag)) AS a,
          (SELECT b.MatrixID,
                  b.Row_ID,
                  a.Col_ID,
                  FLSumProd(a.Cell_Val, b.Cell_Val) AS Num_Val
           FROM  tblEigenValues AS a,
                 tblEigenVectors AS b
           WHERE b.MatrixID = a.MatrixID
		   AND 	 a.MatrixID = 1
           AND   b.Col_ID = a.Row_ID
           GROUP BY 1, 2, 3
           ) AS b
    WHERE b.MatrixID = t.MatrixID
    AND   b.Col_ID = a.Row
    GROUP BY 1, 2, 3;
    
    ---- Calculate Eigenvalues
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenValue(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenValue
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenVector(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenVector
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;
	
                  
    ---- Check if Eigenvalues match with simulated eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenValue-NZ-01P1a: PASSED' ELSE 'Matrix-FT-FLEigenValue-NZ-01P1a: FAILED' END AS Msg
    FROM  (SELECT b.MatrixID,
                   CASE WHEN ABS(a.Cell_Val - b.Cell_Val)/(ABS(b.Cell_Val) + 1) < 1e-3 THEN 0 ELSE 1 END AS Num_Val
           FROM   (SELECT a.OutputMatrixID AS MatrixID,
                           ROW_NUMBER() OVER (PARTITION BY OutputMatrixID ORDER BY OutputEigenVal) AS ROW_ID,
                           OutputEigenVal AS Cell_Val
                   FROM tblEigenValueOutput AS a
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
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenVector-NZ-01P1b: PASSED' ELSE 'Matrix-FT-FLEigenVector-NZ-01P1b: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val)/(ABS(b.Num_Val) + 1) <= 1e-3 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenVectorOutput AS a,
                        tblEigenSystemTest AS b
                 WHERE b.MatrixID = a.OutputMatrixID
                 AND   b.Col_ID = a.OutputRowNum
                 GROUP BY 1, 2, 3
                 ) AS a,
                 (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.OutputRowNum AS Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumProd(b.OutputEigenVec, a.OutputEigenVal) AS Num_Val
                 FROM   tblEigenValueOutput AS a,
                        tblEigenVectorOutput AS b
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

    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest
    WITH tblX (MatrixID, Row_ID, Col_ID, Cell_Val) AS 
    (
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(a.SerialVal,b.SerialVal, 3) AS Cell_Val
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
    
    ---- Calculate eigenvalues and eigenvectors
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenValue(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenValue
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;
        
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenVector(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenVector
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenValueUdt-NZ-01P2: PASSED' ELSE 'Matrix-FT-FLEigenValueUdt-NZ-01P2: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 a.Row_ID,
                 a.Col_ID,
                 CASE WHEN ABS(a.Num_Val - b.Num_Val) <= 1e-8 THEN 0 ELSE 1 END AS Num_Val
          FROM  (
                 SELECT a.OutputMatrixID AS MatrixID,
                        b.Row_ID,
                        a.OutputColNum AS Col_ID,
                        FLSumprod(a.OutputEigenVec, b.Cell_Val) AS Num_Val
                 FROM   tblEigenVectorOutput AS a,
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
                 FROM   tblEigenValueOutput AS a,
                        tblEigenVectorOutput AS b
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

    DELETE FROM tblEigenValues ;
    INSERT INTO tblEigenValues
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           CASE WHEN Row_ID = Col_ID AND ROW_ID < 10 THEN FLSimNormal(RANDOM()* 100000, RANDOM()*10, RANDOM()*1000) ELSE 0 END AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    DELETE FROM tblEigenVectors ;
    INSERT INTO tblEigenVectors
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM()*100000, RANDOM()*10, RANDOM()*1000) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
	-- some trivial problem where z doesnt exist.
    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest
    WITH z (MatrixID, Row_ID, Col_ID, Cell_Val) AS
    (
    SELECT a.*
    FROM   tblEigenVectors AS a
    )
    SELECT b.MatrixID AS MatrixID,
           b.Row_ID,
           a.OutputColNum AS Col_ID,
           FLSumProd(a.OutputVal, b.Num_Val) as Cell_Val
           
    FROM (SELECT a.*
          FROM   TABLE (FLMatrixInv(z.Row_ID, z.Col_ID, z.Cell_Val)
							OVER (PARTITION BY z.MatrixID)
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
    DELETE FROM tblEigenSystemOutput ;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal, Begin_flag, End_flag)
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

    DELETE FROM tblEigenSystemTest ;
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
    DELETE FROM tblEigenSystemOutput ;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 PARTITION BY z.Matrix_ID
                 ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
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
    DELETE FROM tblEigenValues ;
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
    
    DELETE FROM tblEigenVectors ;
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
    
    DELETE FROM tblEigenSystemTest ;
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
                         PARTITION BY z.Matrix_ID
                         ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
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
    DELETE FROM tblEigenSystemOutput ;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 PARTITION BY z.Matrix_ID
                 ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
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

    DELETE FROM tblEigenSystemTest ;
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
    DELETE FROM tblEigenSystemOutput ;
    INSERT INTO tblEigenSystemOutput
    WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
    (
    SELECT *
    FROM   tblEigenSystemTest AS a
    )
    SELECT a.*
    FROM   TABLE (
                 FLEigenSystemUdt(z.Matrix_ID, z.Row_ID, z.Col_ID, z.NumVal)
                 PARTITION BY z.Matrix_ID
                 ORDER BY z.Matrix_ID, z.Row_ID, z.Col_ID
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
    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 9
    AND    MatrixID <= 2;
    
	---- Calculate Eigenvalues
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenValue(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenValue
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenVector(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenVector
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

---- N1.2 Test Number of Rows > Number of Cols
    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 9
    AND    Col_id <= 10
    AND    MatrixID <= 2;
    
    ---- Calculate Eigenvalues
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenValue(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenValue
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenVector(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenVector
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;
                 
---- N2 Test with complex eigenvalues
---- No error message is thrown. The results have to be checked.
    DELETE FROM tblEigenSystemTest ;
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 1, 3);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 2, -2);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 1, 4);
    INSERT INTO tblEigenSystemTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 2 , -1);
    
    ---- Calculate Eigenvalues
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenValue(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenValue
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT 	t.MatrixID,
			t.row_id,
			t.col_id,
			FLEigenVector(t.row_id, t.col_id, t.cell_val) OVER (PARTITION BY 1) AS EigenVector
	FROM tblEigenSystemTest AS t
	WHERE t.MatrixID = 1
	ORDER BY t.Row_ID, t.Col_ID;
                  
-- 	END: NEGATIVE TEST(s)

--	Drop schema/indexes by cing associated drop script(s) (OPTIONAL)
  DROP TABLE tblEigenValues;
  DROP TABLE tblEigenVectors;
  DROP TABLE tblEigenSystemTest;
  DROP TABLE tblEigenValueOutput;
  DROP TABLE tblEigenVectorOutput;

-- 	END: TEST SCRIPT
