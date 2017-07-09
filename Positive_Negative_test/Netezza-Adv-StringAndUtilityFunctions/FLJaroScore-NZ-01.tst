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
--	Test Unit Number:		FLJaroScore-Netezza-01
--
--	Name(s):		    	FLJaroScore
--
-- 	Description:			The Jaro distance metric compares two strings and measures the similarity between them based on the number and order of the common characters between the two strings.
--
--	Applications:		 
--
-- 	Signature:		    	FLJaroScore(String1 VARCHAR(1000), String2 VARCHAR(1000))
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

--Case 1a
-- expected 0,0.4444
SELECT FLJaroScore('MARTHA','martha') AS JaroScore1,
       FLJaroScore('MARTHA','Marhta') AS JaroScore3;
		  
--Case 1b
-- expected 1
SELECT	FLJaroScore('1000','1000') AS FLJaroDist;

--Case 1c
-- expected 0, 1, 0, 0.5555, 0.916666
SELECT FLJaroScore('0','1') AS FLJaroDist;
SELECT FLJaroScore('1','1') AS FLJaroDist;
SELECT FLJaroScore('10','01') AS FLJaroDist;
SELECT FLJaroScore('100','010') AS FLJaroDist;
SELECT	FLJaroScore('1000','0100') AS FLJaroDist;

--Case 1d: 
---Should be 0.82222
SELECT	FLJaroScore('DwAyNE','DuANE') AS FLJaroDist; 

--Case 1e
---Should be 0.767
SELECT	FLJaroScore('DIXON','DICKSONX') AS FLJaroDist; 

--Case 1f
-- expected all 1's
SELECT	FLJaroScore(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3))) AS FLJaroDist
FROM
(
     SELECT *
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b
LIMIT 10;

--CASE 1g: TD-77
--SELECT  ColumnName (TITLE 'String Value'), 
--        FLJaroScore(ColumnName,ColumnName) 
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
SELECT	FLJaroScore('','Partha') AS FLJaroDist;

--Case 1b
--Check if the Arg 1 takes valid values
SELECT	FLJaroScore(NULL,'Partha') AS FLJaroDist;

--Case 1c
--Check if the Arg 1 takes valid values
SELECT	FLJaroScore(martha,'Partha') AS FLJaroDist;


--Case 2a
--Check if the 2nd argument takes valid values
SELECT	FLJaroScore('MARTHA','') AS FLJaroDist;

--Case 2b
--Check if the 2nd argument takes valid values
SELECT	FLJaroScore('MARTHA',NULL) AS FLJaroDist;

--Case 2c
--Check if the 2nd argument takes valid values
SELECT	FLJaroScore('MARTHA',martha) AS FLJaroDist;


--Case 3a
--Check if the 1st and 2nd argument takes valid values
SELECT	FLJaroScore('','') AS FLJaroDist;

--Case 4a
-- All Nulls
SELECT	FLJaroScore(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3))) AS FLJaroDist
FROM
(
     SELECT CASE WHEN a.serialval < 100 THEN NULL ELSE a.serialval END AS serialval
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
