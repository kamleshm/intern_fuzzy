-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    String Functions
--
--	Test Unit Number:		FLJaroWinklerScore-Netezza-01
--
--	Name(s):		    	FLJaroWinklerScore
--
-- 	Description:			The Jaro Winkler distance is a measure of similarity between two strings. It is a variant of the Jaro distance metric.
--
--	Applications:		 
--
-- 	Signature:		    	FLJaroWinklerScore(String1 VARCHAR(1000), String2 VARCHAR(1000))
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			07-05-2017
--
--      Author:                         Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 8000

-- BEGIN: POSITIVE TEST(s)

--Case 1a
-- expected 0, 0.5
SELECT FLJaroWinklerScore('MARTHA','martha') AS JaroWinklDist1,
       FLJaroWinklerScore('MARTHA','Marhta') AS JaroWinklDist3;
		  
--Case 1b
-- expected 1
SELECT	FLJaroWinklerScore('1000','1000') AS FLJaroWinklerDist;

--Case 1c
-- expected 0, 1, 0, 0.5555, 0.91666
SELECT FLJaroWinklerScore('0','1') AS FLJaroWinklerDist;
SELECT FLJaroWinklerScore('1','1') AS FLJaroWinklerDist;
SELECT FLJaroWinklerScore('10','01') AS FLJaroWinklerDist;
SELECT FLJaroWinklerScore('100','010') AS FLJaroWinklerDist, FLJaroScore('100','010') AS FLJaroDist;
SELECT	FLJaroWinklerScore('1000','0100') AS FLJaroWinklerDist, FLJaroScore('1000','0100') AS FLJaroDist;

--Case 1d: 
---Should be 0.84
SELECT	FLJaroWinklerScore('DwAyNE','DuANE') AS FLJaroWinklerDist; 

---Should be 0.813
SELECT	FLJaroWinklerScore('DIXON','DICKSONX') AS FLJaroWinklerDist; 

--Case 1e
SELECT	FLJaroWinklerScore(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3))) AS FLJaroWinklerDist
FROM
(
     SELECT *
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b
LIMIT 10;

--CASE 1f: TD-77
--SELECT  ColumnName (TITLE 'String Value'), 
--        FLJaroWinklerScore(ColumnName,ColumnName) 
--		 (FORMAT 'Z9.999', TITLE 'JaroScore: Calculation Error (NE 1)')
--		  AS FLJaroValue
--FROM DBC.Columns
--WHERE DatabaseName='DBC'
--  AND FLJaroValue <> 1
--ORDER BY 1;
	   
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)		


--Case 1a
--Check if the Arg 1 takes valid values
SELECT	FLJaroWinklerScore('','Partha') AS FLJaroWinklerDist;

--Case 1b
--Check if the Arg 1 takes valid values
SELECT	FLJaroWinklerScore(NULL,'Partha') AS FLJaroWinklerDist;
 
--Case 1c
--Check if the Arg 1 takes valid values
SELECT	FLJaroWinklerScore(martha,'Partha') AS FLJaroWinklerDist;


--Case 2a
--Check if the 2nd argument takes valid values
SELECT	FLJaroWinklerScore('MARTHA','') AS FLJaroWinklerDist;

--Case 2b
--Check if the 2nd argument takes valid values
SELECT	FLJaroWinklerScore('MARTHA',NULL) AS FLJaroWinklerDist;

--Case 2c
--Check if the 2nd argument takes valid values
SELECT	FLJaroWinklerScore('MARTHA',martha) AS FLJaroWinklerDist;


--Case 3a
--Check if the 1st and 2nd argument takes valid values
SELECT	FLJaroWinklerScore('','') AS FLJaroWinklerDist;

--Case 4a
-- All Nulls
 SELECT	FLJaroWinklerScore(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3))) AS FLJaroWinklerDist
FROM
(
     SELECT CASE WHEN a.serialval < 100 THEN NULL ELSE a.serialval END AS serialval
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
