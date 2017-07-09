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
--	Test Unit Number:	FLEigenValueStr-NZ-01
--
--	Name(s):		FLEigenValueStr
--
-- 	Description:    	Calculates the eigenvalues, eigenvectors of a square matrix (n x n)
--
--	Applications:		 
--
-- 	Signature:		FLEigenValueStr (Row_ID, Col_ID, Cell_Val)
--				FLEigenVectorStr (Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		01-26-2014
--
--	Author:			<Tammy Weng: Tammy.Weng@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--
--	CAUTION: This test is the same as FLEigenVectorStr - they are computed simultaneously
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

CREATE TABLE tblEigenTest
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

    DELETE FROM tblEigenTest ;
    INSERT INTO tblEigenTest
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
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenValue) AS Row_id,
			FLMatrixCol(p.EigenValue) AS Col_id,
			FLMatrixVal(p.EigenValue) AS EigenValue 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenValueStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenValue
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput	
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenVector) AS Row_id,
			FLMatrixCol(p.EigenVector) AS Col_id,
			FLMatrixVal(p.EigenVector) AS EigenVector 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenVectorStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenVector
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;
	
                  
    ---- Check if Eigenvalues match with simulated eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenValueStr-NZ-01P1a: PASSED' ELSE 'Matrix-FT-FLEigenValueStr-NZ-01P1a: FAILED' END AS Msg
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
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenVectorStr-NZ-01P1b: PASSED' ELSE 'Matrix-FT-FLEigenVectorStr-NZ-01P1b: FAILED' END AS Msg
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
                        tblEigenTest AS b
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

    DELETE FROM tblEigenTest ;
    INSERT INTO tblEigenTest
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
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenValue) AS Row_id,
			FLMatrixCol(p.EigenValue) AS Col_id,
			FLMatrixVal(p.EigenValue) AS EigenValue 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenValueStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenValue
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;
        
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenVector) AS Row_id,
			FLMatrixCol(p.EigenVector) AS Col_id,
			FLMatrixVal(p.EigenVector) AS EigenVector 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenVectorStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenVector
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

    ---- Check Eigen Vectors and Eigenvalues
    SELECT a.MatrixID,
           CASE WHEN SUM(a.Num_Val) = 0 THEN 'Matrix-FT-FLEigenValueStrUdt-NZ-01P2: PASSED' ELSE 'Matrix-FT-FLEigenValueStrUdt-NZ-01P2: FAILED' END AS Msg
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
                        tblEigenTest AS b
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
    
-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)
 
---- N1 Test with non-square matrix

---- N1.1 Test Number of Rows > Number of Cols
    DELETE FROM tblEigenTest ;
    INSERT INTO tblEigenTest
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
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenValue) AS Row_id,
			FLMatrixCol(p.EigenValue) AS Col_id,
			FLMatrixVal(p.EigenValue) AS EigenValue 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenValueStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenValue
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput	
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenVector) AS Row_id,
			FLMatrixCol(p.EigenVector) AS Col_id,
			FLMatrixVal(p.EigenVector) AS EigenVector 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenVectorStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenVector
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

---- N1.2 Test Number of Rows > Number of Cols
    DELETE FROM tblEigenTest ;
    INSERT INTO tblEigenTest
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
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenValue) AS Row_id,
			FLMatrixCol(p.EigenValue) AS Col_id,
			FLMatrixVal(p.EigenValue) AS EigenValue 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenValueStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenValue
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput	
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenVector) AS Row_id,
			FLMatrixCol(p.EigenVector) AS Col_id,
			FLMatrixVal(p.EigenVector) AS EigenVector 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenVectorStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenVector
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;
                 
---- N2 Test with complex eigenvalues
---- No error message is thrown. The results have to be checked.
    DELETE FROM tblEigenTest ;
    INSERT INTO tblEigenTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 1, 3);
    INSERT INTO tblEigenTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 2, -2);
    INSERT INTO tblEigenTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 1, 4);
    INSERT INTO tblEigenTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 2 , -1);
    
---- Calculate Eigenvalues
    DELETE FROM tblEigenValueOutput ;
    INSERT INTO tblEigenValueOutput
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenValue) AS Row_id,
			FLMatrixCol(p.EigenValue) AS Col_id,
			FLMatrixVal(p.EigenValue) AS EigenValue 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenValueStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenValue
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;

    ---- Calculate Eigen Vectors            
    DELETE FROM tblEigenVectorOutput ;
    INSERT INTO tblEigenVectorOutput	
	SELECT  p.MatrixID,
			FLMatrixRow(p.EigenVector) AS Row_id,
			FLMatrixCol(p.EigenVector) AS Col_id,
			FLMatrixVal(p.EigenVector) AS EigenVector 
	FROM    (
			SELECT  a.MatrixID,
					FLEigenVectorStr(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS EigenVector
			FROM    tblEigenTest a
			WHERE 	a.MatrixID = 1
			) AS p
	ORDER BY Row_id,Col_id;
                  
-- 	END: NEGATIVE TEST(s)

--	Drop schema/indexes by calling associated drop script(s) (OPTIONAL)
  DROP TABLE tblEigenValues;
  DROP TABLE tblEigenVectors;
  DROP TABLE tblEigenTest;
  DROP TABLE tblEigenValueOutput;
  DROP TABLE tblEigenVectorOutput;

-- 	END: TEST SCRIPT
