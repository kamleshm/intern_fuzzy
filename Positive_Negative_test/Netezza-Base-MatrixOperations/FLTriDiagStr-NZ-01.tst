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
--	Test Unit Number:	FLTriDiagStr-NZ-01
--
--	Name(s):		FLTriDiagstr
--
-- 	Description:    Calculates the tridiagonal /upper Hessenberg of a  square matrix (n x n). If the input matrix is symmetric then the function returns a tridiagonal matrix, else it returns the upper Hessenberg matrix.
--
--	Applications:		 
--
-- 	Signature:		FLTriDiagstr (Matrix_ID, Row_ID, Col_ID, Cell_Val)
--
--	Parameters:		See Documentation
--
--	Return value:		String
--
--	Last Updated:		07-11-2017
--
--	Author:			<Kamlesh.Meena@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
-- BEGIN: POSITIVE TEST(s)
DROP TABLE tblTriDiagStrTest IF EXISTS;
CREATE TABLE tblTriDiagStrTest
( MatrixID INTEGER,
row_id   INTEGER,
col_id   INTEGER,
cell_val DOUBLE PRECISION);

-- BEGIN: POSITIVE TEST(s)
---- P1 Test with a 10 * 10 Symmetric Matrix
---- Simulate Symmetrix X

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 10
AND    Col_id <= 10
AND    Row_ID >= Col_ID
AND    MatrixID <= 10;

INSERT INTO tblTriDiagStrTest
SELECT a.MatrixID,
a.Col_ID ,
a.Row_ID,
a.Cell_Val
FROM   tblTriDiagStrTest AS a
WHERE  Row_ID > Col_ID;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

---- P2 Test with a 100 * 100 Symmetric Matrix
---- Simulate Symmetrix X
DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 100
AND    Col_id <= 100
AND    Row_ID >= Col_ID
AND    MatrixID <= 4;

INSERT INTO tblTriDiagStrTest
SELECT a.MatrixID,
a.Col_ID ,
a.Row_ID,
a.Cell_Val
FROM   tblTriDiagStrTest AS a
WHERE  Row_ID > Col_ID;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;


---- P3 Test with a 10 * 10 Non-Symmetric Matrix
---- Simulate Non-Symmetrix X

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 10
AND    Col_id <= 10 
AND    MatrixID <= 10;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

---- P4 Test with a 100 * 100 Non-Symmetric Matrix
---- Simulate Non-Symmetrix X

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 100
AND    Col_id <= 100
AND    MatrixID <= 4;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

---- P5 Test with a 1000 * 1000 Non-Symmetric Matrix
---- Simulate Non-Symmetrix X

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 1000
AND    Col_id <= 1000
AND    MatrixID <= 4;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

-- 	END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)
---- N1 Test with a large matrix (More than 1000 * 1000)
---- Simulate Matrix 

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 1001
AND    Col_id <= 1001
AND    MatrixID <= 1;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

---- N2 Test with non-square matrix
-------- N2.1 Number of Rows > Number of Cols
---- Simulate Matrix

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 10
AND    Col_id <= 9
AND    MatrixID <= 1;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

-------- N2.2 Number of Rows < Number of Cols
---- Simulate Matrix

DELETE FROM tblTriDiagStrTest;
INSERT INTO tblTriDiagStrTest
SELECT c.SerialVal AS MatrixID,
a.SerialVal AS Row_id,
b.SerialVal AS Col_id,
FLSimNormal(RANDOM(),0.0,1.0) AS Cell_Val
FROM   fzzlSerial AS a,
fzzlSerial As b,           
fzzlSerial AS c
WHERE  Row_id <= 9
AND    Col_id <= 10
AND    MatrixID <= 1;

SELECT a.MatrixID,
FLTriDiagStr(a.Col_ID,a.Row_ID,a.Cell_Val) OVER(PARTITION BY a.MatrixID) 
FROM tblTriDiagStrTest a
ORDER BY 1 
LIMIT 100;

-- 	END: NEGATIVE TEST(s)
DROP TABLE tblTriDiagStrTest;
\time
-- 	END: TEST SCRIPT
