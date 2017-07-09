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
--	Test Unit Number:	FLMatrixDet-NZ-01
--
--	Name(s):		FLMatrixDet
--
-- 	Description:		Calculates the Determinant of a square matrix
--
--	Applications:		 
--
-- 	Signature:		FLMatrixDet(Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		01-02-2015
--
--	Authors:			<Tammy Weng: Tammy.Weng@fuzzyl.com>, <Anurag Reddy: Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

CREATE TABLE tblMatrixDetTest
     (MatrixID INTEGER,
      row_id   INTEGER,
      col_id   INTEGER,
      cell_val FLOAT);

CREATE TABLE tblMatrixDetOutput
     (OutputMatrixID BIGINT,
      OutputDetVal FLOAT);

-- BEGIN: POSITIVE TEST(s)
---- P1 Test with a 1 * 1 Matrix
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 1
    AND    Col_id <= 1
    AND    MatrixID <= 10;
    
    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))
    ---- This function will throw error message (Value cannot be NULL) when det(x) = 0.	

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01P1: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01P1: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					a.Determinant - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (b.OutputDetVal) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;
			
---- P2 Test with a 50 * 50 Matrix
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
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
    
    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))
    ---- This function will throw error message (Value cannot be NULL) when det(x) = 0.	

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01P2: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01P2: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					ABS(a.Determinant) - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (ABS(b.OutputDetVal)**(CAST(1.00 AS DOUBLE PRECISION)/CAST(50.00 AS DOUBLE PRECISION))) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;
		  
---- P3 Test with a 100 * 100 Matrix
---- Simulate X
DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), 0, 3) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 100
    AND    Col_id <= 100
    AND    MatrixID <= 1;
    
    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))
    ---- This function will throw error message (Value cannot be NULL) when det(x) = 0.	

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01P3: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01P3: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					ABS(a.Determinant) - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (ABS(b.OutputDetVal)**(CAST(1.00 AS DOUBLE PRECISION)/CAST(100.00 AS DOUBLE PRECISION))) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;

---- P4 Test with a 500 * 500 Matrix
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), 0, 3) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 500
    AND    Col_id <= 500
    AND    MatrixID <= 1;
    
    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))
    ---- This function will throw error message (Value cannot be NULL) when det(x) = 0.
	---- Numeric overflow is reached here. The Random function needs to be adjusted.

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01P4: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01P4: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					ABS(a.Determinant) - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (ABS(b.OutputDetVal)**(CAST(1.00 AS DOUBLE PRECISION)/CAST(500.00 AS DOUBLE PRECISION))) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;
		
-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)
---- N1 Test with singular matrix
------- N1.1 Test with matrix with all Zeros
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           0
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 1;
	
	    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID <= 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
	
	    ---- Calculate the Det(X/Det(X)) = 1 

    SELECT a.OutputMatrixID,
           CASE WHEN FLABS(a.OutputDetVal) <= 1e-12 THEN  'Matrix-FT-FLMatrixDet-NZ-01N1.1: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N1.1: FAILED'  END AS NumVal
    FROM   tblMatrixDetOutput AS a;

------- N1.2 Test with singular matrix         
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 9
    AND    MatrixID <= 1;
   
    ---- Calculate the last col  
    INSERT INTO tblMatrixDetTest
    SELECT a.MatrixID AS MatrixID,
           a.Row_ID,
           10 AS Col_id,
           Cell_Val
    FROM   tblMatrixDetTest AS a
    WHERE  Col_ID = 1;
	
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID <= 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
	
	SELECT a.OutputMatrixID,
           CASE WHEN FLABS(a.OutputDetVal) <= 1e-12 THEN  'Matrix-FT-FLMatrixDet-NZ-01N1.2: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N1.2: FAILED'  END AS NumVal
    FROM   tblMatrixDetOutput AS a;  
	
---- N2 Test with none square matrix
-------- N2.1 Number of Rows > Number of Cols
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           0
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 9
    AND    MatrixID <= 1;
    
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID <= 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
    
    ---- Calculate the Det(X/Det(X)) = 1
	---- The error is thrown while calculating Det(X) itself.
	
    SELECT a.OutputMatrixID,
           COUNT(*) AS ErrCNT,
           CASE WHEN ERRCNT = 0 THEN  'Matrix-FT-FLMatrixDet-NZ-01N2.1: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N2.1: FAILED'  END AS NumVal
    FROM   tblMatrixDetOutput AS a
    WHERE OutputDetVal IS NOT NULL
    GROUP BY 1;	

-------- N2.2 Number of Rows < Number of Cols
---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           0
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 9
    AND    Col_id <= 10
    AND    MatrixID <= 1;
    
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID <= 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
                 ) AS a;
    
    ---- Calculate the Det(X/Det(X)) = 1 
	---- The error is thrown while calculating Det(X) itself.

    SELECT a.OutputMatrixID,
           COUNT(*) AS ErrCNT,
           CASE WHEN ERRCNT = 0 THEN  'Matrix-FT-FLMatrixDet-NZ-01N2.2: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N2.2: FAILED'  END AS NumVal
    FROM   tblMatrixDetOutput AS a
    WHERE OutputDetVal IS NOT NULL
    GROUP BY 1;
	
---- N3 Test with missing cells
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
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
    ---- Delete one cell
    DELETE FROM tblMatrixDetTest WHERE Row_ID = 1 AND Col_ID = 1;
    ---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01N3: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N3: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					ABS(a.Determinant) - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (ABS(b.OutputDetVal)**(CAST(1.00 AS DOUBLE PRECISION)/CAST(50.00 AS DOUBLE PRECISION))) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;  
	
---- N4 Test with repeated cells
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
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
    
    ---- Repeat one cell
    INSERT INTO tblMatrixDetTest (MatrixID, Row_ID, Col_ID, Cell_Val) VALUES (1, 1, 1, 2.0);	
	
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
		
	---- Calculate the Det(X/Det(X))

    SELECT 	a.OutputMatrixID AS MatrixID,
			CASE WHEN abs(a.NumVal) < 1e-12 THEN 'Matrix-FT-FLMatrixDet-NZ-01N4: PASSED' ELSE 'Matrix-FT-FLMatrixDet-NZ-01N4: FAILED' END AS Msg
    FROM   	(
			SELECT a.MatrixID AS OutputMatrixID,
					ABS(a.Determinant) - 1 AS NumVal
			FROM  	(	    
					WITH z (Matrix_ID, Row_ID, Col_ID, NumVal) AS
					(
					SELECT 	a.MatrixID,
							a.Row_ID,
							a.Col_ID,
							CASE WHEN b.OutputDetVal = 0 THEN NULL ELSE a.Cell_Val / (ABS(b.OutputDetVal)**(CAST(1.00 AS DOUBLE PRECISION)/CAST(50.00 AS DOUBLE PRECISION))) END AS NumVal
					FROM   	tblMatrixDetTest AS a,
							tblMatrixDetOutput AS b
					WHERE b.OutputMatrixID = a.MatrixID
					)
					SELECT 	z.Matrix_ID as MatrixID,
							FLMatrixDet(z.Row_id, z.Col_id, z.NumVal) OVER (PARTITION BY 1) AS Determinant
					FROM z
					) AS a
			WHERE  a.Determinant IS NOT NULL
			) AS a;  
			
---- N5 Test with NULL AS Cell_Val
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           NULL
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 50
    AND    Col_id <= 50
    AND    MatrixID <= 1;
	
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
	
---- N6 Test with NULL AS Row_ID
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 1;
    
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(NULL, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;

---- N7 Test with NULL AS Col_ID
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 1;
    
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	a.MatrixID as MatrixID,
					FLMatrixDet(a.Row_id, NULL, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;

---- N8 Test with NULL AS Matrix_ID
---- In Netezza, Matrix_ID is not taken as input.
    ---- Simulate X
    DELETE FROM tblMatrixDetTest;
    INSERT INTO tblMatrixDetTest
    SELECT c.SerialVal AS MatrixID,
           a.SerialVal AS Row_id,
           b.SerialVal AS Col_id,
           FLSimNormal(RANDOM(), RANDOM(), RANDOM()+1) AS Cell_Val
    FROM   fzzlSerial AS a,
           fzzlSerial As b,
           fzzlSerial AS c
    WHERE  Row_id <= 10
    AND    Col_id <= 10
    AND    MatrixID <= 1;
    
	---- Calculate Det(X)
    DELETE FROM tblMatrixDetOutput;
    INSERT INTO tblMatrixDetOutput
    SELECT 	p.MatrixID,
			p.Determinant
	FROM   	(
			SELECT 	NULL as MatrixID,
					FLMatrixDet(a.Row_id, a.Col_id, a.Cell_Val) OVER (PARTITION BY 1) AS Determinant
			FROM   tblMatrixDetTest AS a
			WHERE  a.MatrixID = 1
       		) AS p
	WHERE  p.Determinant IS NOT NULL;
-- 	END: NEGATIVE TEST(s)

--	Drop schema/indexes by calling associated drop script(s) (OPTIONAL)	
  DROP TABLE tblMatrixDetTest;
  DROP TABLE tblMatrixDetOutput;
  
-- 	END: TEST SCRIPT 