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
--	Test Unit Number:	FLMatrixInv-NZ-01
--
--	Name(s):		FLMatrixInv
--
-- 	Description:		Calculates the inverse of a square matrix
--
--	Applications:		 
--
-- 	Signature:		FLMatrixInv(Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		01-05-2015
--
--	Authors:			<Tammy Weng: Tammy.Weng@fuzzyl.com>, <Anurag Reddy: Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql


CREATE TABLE tblMatrixInvTest
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT)
DISTRIBUTE ON(row_id ,col_id);

CREATE TABLE tblMatrixInvOutput
     (OutputMatrixID BIGINT,
      OutputRowNum BIGINT,
      OutputColNum BIGINT,
      OutputVal FLOAT)
DISTRIBUTE ON( OutputMatrixID ,OutputRowNum ,OutputColNum );

-- BEGIN: POSITIVE TEST(s)
---- P1 Test with a 1 * 1 Matrix
---- Simulate X
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1
    AND    Col_id <= 1
    AND    MatrixID <= 1;
    
    ---- Calculate Inv(X)
    DELETE FROM tblMatrixInvOutput;
    INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a	
	ORDER BY 1, 2;
    
    ---- Inv(X) * X should return identity matrix
    SELECT a.MatrixID,
           CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01P1: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01P1: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 Sum(CASE WHEN FLAbs(NumVal) <= 1e-15 THEN 0 ELSE 1 END) AS SumVal
          FROM (SELECT a.MatrixID,
                        a.Row_ID,
                        a.Col_ID,
                        CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
                FROM (SELECT a.MatrixID,
                              a.Row_ID,
                              b.OutputColNum AS Col_ID,
                              FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                      FROM  tblMatrixInvTest AS a,
                            tblMatrixInvOutput AS b
                      WHERE b.OutputMatrixID = a.MatrixID
                      AND   b.OutputRowNum = a.Col_ID
                      GROUP BY 1, 2, 3
                      ) AS a
                ) AS a
          GROUP BY MatrixID
    ) AS a;
    
---- P2 Test with a small 50 * 50 Matrix
---- Simulate X
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 50
    AND    Col_id <= 50
    AND    MatrixID <= 1;
    
    ---- Calculate Inv(X)
    ---- Calculate Inv(X)
    DELETE FROM tblMatrixInvOutput;
    INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a	
	ORDER BY 1, 2;
    
    ---- Inv(X) * X should return identity matrix
    SELECT a.MatrixID,
           CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01P2: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01P2: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 Sum(CASE WHEN FLAbs(NumVal) <= 1e-7 THEN 0 ELSE 1 END) AS SumVal
          FROM (SELECT a.MatrixID,
                        a.Row_ID,
                        a.Col_ID,
                        CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
                FROM (SELECT a.MatrixID,
                              a.Row_ID,
                              b.OutputColNum AS Col_ID,
                              FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                      FROM  tblMatrixInvTest AS a,
                            tblMatrixInvOutput AS b
                      WHERE b.OutputMatrixID = a.MatrixID
                      AND   b.OutputRowNum = a.Col_ID
                      GROUP BY 1, 2, 3
                      ) AS a
                ) AS a
          GROUP BY MatrixID
         ) AS a;

/*
---- P3 Test with a 1000 * 1000 Matrix
---- Simulate X
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1000
    AND    Col_id <= 1000
    AND    MatrixID <= 1;
    
    ---- Calculate Inv(X)
    DELETE FROM tblMatrixInvOutput;
    INSERT INTO tblMatrixInvOutput	
	SELECT t.MatrixID, f.row, f.col, f.value  
	FROM (
		 SELECT *,
             NVL(LAG(0) OVER (PARTITION BY 1 ORDER BY row_id, col_id), 1) AS begin_flag, 
             NVL(LEAD(0) OVER (PARTITION BY 1 ORDER BY row_id, col_id), 1) AS end_flag
		 FROM tblMatrixInvTest
		 ) AS t
		 ,TABLE (FLMtxInvUdt(t.row_id, t.col_id, t.cell_val, t.begin_flag, t.end_flag)) AS f;
    
    ---- Inv(X) * X should return identity matrix
    SELECT a.MatrixID,
           CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01P3: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01P3: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                  Sum(CASE WHEN FLAbs(NumVal) <= 1e-4 THEN 0 ELSE 1 END) AS SumVal
          FROM (SELECT a.MatrixID,
                        a.Row_ID,
                        a.Col_ID,
                        CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
                FROM (SELECT a.MatrixID,
                              a.Row_ID,
                              b.OutputColNum AS Col_ID,
                              FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                      FROM  tblMatrixInvTest AS a,
                            tblMatrixInvOutput AS b
                      WHERE b.OutputMatrixID = a.MatrixID
                      AND   b.OutputRowNum = a.Col_ID
                      GROUP BY 1, 2, 3
                      ) AS a
                ) AS a
          GROUP BY MatrixID
          ) AS a;   

//*/
          
-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)

---- N1 Testing for Non-square Matrix

-------- N1.1 Number of rows greater than number of columns
	SELECT 	a.Matrix_ID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixMulti a
	WHERE  a.Matrix_ID = 5
	AND    a.Col_ID < 5
	ORDER BY 1, 2;

-------- N1.2 Number of rows less than number of columns
	SELECT 	a.Matrix_ID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixMulti a
	WHERE  a.Matrix_ID = 5
	AND    a.Row_ID < 5
	ORDER BY 1, 2;

---- N2 Testing for Singular Matrix
---- N2.1 Testing for a 1 * 1 Matrix with 0 as the Value
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 1, 0);
---- Calculate Inv(X), this calculation should return error messages
------Testing Results: Returns the value infinity.
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;

---- N2.2 Testing for a 1 * 1 Matrix with 0 as the Value
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 2, 0);
---- Calculate Inv(X), this calculation should return error messages
------Testing Results:ERROR [HY000] ERROR:  Matrix is not correctly formed, some elements in the matrix are missing (2 x 2 != 1).
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;

---- N2.3 Testing for a 1 * 1 Matrix with 0 as the Value
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 3, 0);
---- Calculate Inv(X), this calculation should return error messages
------Testing Results:ERROR [HY000] ERROR:  Number of rows and columns are not the same, matrix is not a square matrix.
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;

---- N2.4 Testing with a simulated 5 * 5 singular matrix
-------------- Testing Results: Cannot detect all singular matrices, some times return non-sense matrix with very large values as result

---- Simulate values for the first 4 columns of X
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest
SELECT c.SerialVal AS MatrixID,
       a.SerialVal AS Row_id,
       b.SerialVal AS Col_id,
       FLSimNormal(RANDOM(), 0, 10) AS Cell_Val
FROM   fzzlSerial AS a,
       fzzlSerial As b,
       fzzlSerial AS c
WHERE  Row_id <= 5
AND    Col_id <= 4
AND    MatrixID <= 1;

---- Calculate values for the last columns using the summation of values in the first 4 Columns Of X, this implies the matrix will be singular
INSERT INTO tblMatrixInvTest
SELECT a.MatrixID,
       a.Row_id,
       5,
       FLSum(Cell_Val)
FROM   tblMatrixInvTest AS a
GROUP BY 1, 2, 3;

---- Calculate Inv(X), this calculation should return error messages
DELETE FROM tblMatrixInvOutput;
INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;

---- Inv(X) * X should return identity matrix
SELECT a.MatrixID,
       CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N2.4: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N2.4: FAILED' END AS Msg
FROM (SELECT a.MatrixID,
             Sum(CASE WHEN FLAbs(NumVal) <= 1e-4 THEN 0 ELSE 1 END) AS SumVal
      FROM (SELECT a.MatrixID,
                    a.Row_ID,
                    a.Col_ID,
                    CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
            FROM (SELECT a.MatrixID,
                          a.Row_ID,
                          b.OutputColNum AS Col_ID,
                          FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                  FROM  tblMatrixInvTest AS a,
                        tblMatrixInvOutput AS b
                  WHERE b.OutputMatrixID = a.MatrixID
                  AND   b.OutputRowNum = a.Col_ID
                  GROUP BY 1, 2, 3
                  ) AS a
            ) AS a
      GROUP BY MatrixID
      ) AS a; 

---- N3 Testing for Matrix with Missing Cell
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest
SELECT c.SerialVal AS MatrixID,
       a.SerialVal AS Row_id,
       b.SerialVal AS Col_id,
       FLSimNormal(RANDOM(), 0, 10) AS Cell_Val
FROM   fzzlSerial AS a,
       fzzlSerial As b,
       fzzlSerial AS c
WHERE  Row_id <= 5
AND    Col_id <= 5
AND    MatrixID <= 1;

DELETE FROM tblMatrixInvTest WHERE Row_ID = 2 AND Col_ID = 2;
DELETE FROM tblMatrixInvTest WHERE Row_ID = 5 AND Col_ID = 2;

---- Calculate Inv(X)
--------Testing Results: ERROR [HY000] ERROR:  Matrix is not correctly formed, some elements in the matrix are missing (5 x 5 != 23).
DELETE FROM tblMatrixInvOutput;
INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;
             
---- Inv(X) * X should return identity matrix, the query below should return Err = 0 for all Matrices 
SELECT a.MatrixID,
       CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N3: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N3: FAILED' END AS Msg
FROM (SELECT a.MatrixID,
             Sum(CASE WHEN FLAbs(NumVal) <= 1e-6 THEN 0 ELSE 1 END) AS SumVal
      FROM (SELECT a.MatrixID,
                    a.Row_ID,
                    a.Col_ID,
                    CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
            FROM (SELECT a.MatrixID,
                          a.Row_ID,
                          b.OutputColNum AS Col_ID,
                          FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                  FROM  tblMatrixInvTest AS a,
                        tblMatrixInvOutput AS b
                  WHERE b.OutputMatrixID = a.MatrixID
                  AND   b.OutputRowNum = a.Col_ID
                  GROUP BY 1, 2, 3
                  ) AS a
            ) AS a
      GROUP BY MatrixID
      ) AS a;

---- N4 Testing for Matrix with Repeat Cell
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest
SELECT c.SerialVal AS MatrixID,
       a.SerialVal AS Row_id,
       b.SerialVal AS Col_id,
       FLSimNormal(RANDOM(), 0, 10) AS Cell_Val
FROM   fzzlSerial AS a,
       fzzlSerial As b,
       fzzlSerial AS c
WHERE  Row_id <= 5
AND    Col_id <= 5
AND    MatrixID <= 1;

INSERT INTO tblMatrixInvTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 4, 3.5);


---- Calculate Inv(X), this calculation should return error messages
--------Testing Results:ERROR [HY000] ERROR:  Matrix is not correctly formed, some elements in the matrix are missing (5 x 5 != 26)
DELETE FROM tblMatrixInvOutput;
INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;
             
---- Inv(X) * X should return identity matrix
SELECT a.MatrixID,
       CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N4: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N4: FAILED' END AS Msg
FROM (SELECT a.MatrixID,
             Sum(CASE WHEN FLAbs(NumVal) <= 1e-6 THEN 0 ELSE 1 END) AS SumVal
      FROM (SELECT a.MatrixID,
                    a.Row_ID,
                    a.Col_ID,
                    CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
            FROM (SELECT a.MatrixID,
                          a.Row_ID,
                          b.OutputColNum AS Col_ID,
                          FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                  FROM  tblMatrixInvTest AS a,
                        tblMatrixInvOutput AS b
                  WHERE b.OutputMatrixID = a.MatrixID
                  AND   b.OutputRowNum = a.Col_ID
                  GROUP BY 1, 2, 3
                  ) AS a
            ) AS a
      GROUP BY MatrixID
      ) AS a;


---- N5 Testing for Matrix with Repeat Cell and Missing Cell
DELETE FROM tblMatrixInvTest;
INSERT INTO tblMatrixInvTest
SELECT c.SerialVal AS MatrixID,
       a.SerialVal AS Row_id,
       b.SerialVal AS Col_id,
       FLSimNormal(RANDOM(), 0, 10) AS Cell_Val
FROM   fzzlSerial AS a,
       fzzlSerial As b,
       fzzlSerial AS c
WHERE  Row_id <= 5
AND    Col_id <= 5
AND    MatrixID <= 1;

DELETE FROM tblMatrixInvTest WHERE Row_ID = 2 AND Col_ID = 4;
INSERT INTO tblMatrixInvTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 2, 3, 3.5);


---- Calculate Inv(X), this calculation should return error messages
--------Testing Results: It calculates the matrix inverse and the result is wrong
DELETE FROM tblMatrixInvOutput;
INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;
             
---- Inv(X) * X should return identity matrix
SELECT a.MatrixID,
       CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N5: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N5: FAILED' END AS Msg
FROM (SELECT a.MatrixID,
              Sum(CASE WHEN FLAbs(NumVal) <= 1e-6 THEN 0 ELSE 1 END) AS SumVal
       FROM (SELECT a.MatrixID,
                     a.Row_ID,
                     a.Col_ID,
                     CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
             FROM (SELECT a.MatrixID,
                           a.Row_ID,
                           b.OutputColNum AS Col_ID,
                           FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                   FROM  tblMatrixInvTest AS a,
                         tblMatrixInvOutput AS b
                   WHERE b.OutputMatrixID = a.MatrixID
                   AND   b.OutputRowNum = a.Col_ID
                   GROUP BY 1, 2, 3
                   ) AS a
             ) AS a
       GROUP BY MatrixID
       ) AS a;

---- N6 Testing for Very Large Matrix (more than 1000 * 1000)
---- Simulate X
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1001
    AND    Col_id <= 1001
    AND    MatrixID <= 1;
    
---- Calculate Inv(X)
------Testing Results: 
/* The query returned more than 1000 rows. Extra rows were ignored. */
/* Start time 05-Jan-15 6:31:01 PM, end time 05-Jan-15 6:32:41 PM. */
/* Duration 100.1537285 sec. */
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;

---- N7 Testing for Matrix with RowID and ColID <= 0 
-------- N7.1 RowID <= 0
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal - 1 AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    ---- Calculate Inv(X)
	------Testing Results:ERROR [HY000] ERROR:  Matrix is not correctly formed, some elements in the matrix are missing (10 x 10 != 1100).
    DELETE FROM tblMatrixInvOutput;
    INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;
    
    ---- Inv(X) * X should return identity matrix
    SELECT a.MatrixID,
           CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N7.1: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N7.1: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 Sum(CASE WHEN FLAbs(NumVal) <= 1e-9 THEN 0 ELSE 1 END) AS SumVal
          FROM (SELECT a.MatrixID,
                        a.Row_ID,
                        a.Col_ID,
                        CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
                FROM (SELECT a.MatrixID,
                              a.Row_ID,
                              b.OutputColNum AS Col_ID,
                              FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                      FROM  tblMatrixInvTest AS a,
                            tblMatrixInvOutput AS b
                      WHERE b.OutputMatrixID = a.MatrixID
                      AND   b.OutputRowNum = a.Col_ID
                      GROUP BY 1, 2, 3
                      ) AS a
                ) AS a
          GROUP BY MatrixID
         ) AS a;
-------- N7.2 ColID <= 0                 
    DELETE FROM tblMatrixInvTest;
    INSERT INTO tblMatrixInvTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal - 1 AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 10;
    
    ---- Calculate Inv(X)
	------Testing Results:ERROR [HY000] ERROR:  Matrix is not correctly formed, some elements in the matrix are missing (10 x 10 != 1100).
    DELETE FROM tblMatrixInvOutput;
    INSERT INTO tblMatrixInvOutput
	SELECT 	a.MatrixID, a.Row_id, a.Col_id, FLMatrixInv(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Inverse 
	FROM   	tblMatrixInvTest a
	ORDER BY 1, 2;
    
    ---- Inv(X) * X should return identity matrix
    SELECT a.MatrixID,
           CASE WHEN SumVal = 0 THEN 'Matrix-FT-FLMatrixInv-NZ-01N7.2: PASSED' ELSE 'Matrix-FT-FLMatrixInv-NZ-01N7.2: FAILED' END AS Msg
    FROM (SELECT a.MatrixID,
                 Sum(CASE WHEN FLAbs(NumVal) <= 1e-9 THEN 0 ELSE 1 END) AS SumVal
          FROM (SELECT a.MatrixID,
                        a.Row_ID,
                        a.Col_ID,
                        CASE WHEN a.Row_ID = a.Col_ID THEN a.NumVal - 1 ELSE a.NumVal END AS NumVal
                FROM (SELECT a.MatrixID,
                              a.Row_ID,
                              b.OutputColNum AS Col_ID,
                              FLSumProd(a.Cell_Val, b.OutputVal) AS NumVal
                      FROM  tblMatrixInvTest AS a,
                            tblMatrixInvOutput AS b
                      WHERE b.OutputMatrixID = a.MatrixID
                      AND   b.OutputRowNum = a.Col_ID
                      GROUP BY 1, 2, 3
                      ) AS a
                ) AS a
          GROUP BY MatrixID
         ) AS a;                
                 
-- 	END: NEGATIVE TEST(s)
--	Drop schema/indexes by calling associated drop script(s) (OPTIONAL)
DROP TABLE tblMatrixInvTest;
DROP TABLE tblMatrixInvOutput;

-- 	END: TEST SCRIPT

