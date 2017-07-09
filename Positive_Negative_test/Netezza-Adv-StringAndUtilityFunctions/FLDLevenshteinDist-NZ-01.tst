-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
--	Test Unit Number:		FLDLevenshteinDist-Netezza-01
--
--	Name(s):		    	FLDLevenshteinDist
--
-- 	Description:			Damerau–Levenshtein distance is a measure of the similarity between two strings, String1 and String2. The distance is the number of deletions, insertions, substitutions and transpositions required to transform String1 into String2.
--
--	Applications:		 
--
-- 	Signature:		    	FLDLevenshteinDist(String1 VARCHAR(1000), String2 VARCHAR(1000), CaseFlag INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			BIGINT
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
-- .run file=../PulsarLogOn.sql

-- .set width 8000

-- BEGIN: POSITIVE TEST(s)

--Case 1a
SELECT	FLDLevenshteinDist('MARTHA','Partha',1) AS DLevenshteinlDist1,
            FLDLevenshteinDist('MARTHA','Partha',0) AS DLevenshteinDist2,
            FLDLevenshteinDist('MARTHA','Parhta',1) AS DLevenshteinDist3,
	      FLDLevenshteinDist('MARTHA','Parhta',0) AS DLevenshteinlDist4;
		  
--Case 1b
SELECT	FLDLevenshteinDist('1000','1000',1) AS DLevenshteinDist1;
SELECT	FLDLevenshteinDist('1000','0100',1) AS DLevenshteinDist1;

--Case 1c
SELECT FLDLevenshteinDist('0','1',1) AS FLDLevenshteinDist;
SELECT FLDLevenshteinDist('1','1',1) AS FLDLevenshteinDist;
SELECT FLDLevenshteinDist('10','01',1) AS FLDLevenshteinDist;
SELECT FLDLevenshteinDist('100','010',1) AS FLDLevenshteinDist;
SELECT FLDLevenshteinDist('1000','0100',1) AS FLDLevenshteinDist;

--Case 1d
SELECT	FLDLevenshteinDist('1011101 ','1001001 ',1) AS DLevenshteinDist1;

--Case 1e
SELECT	FLDLevenshteinDist('-10 11','100- ',1) AS DLevenshteinDist1;

--Case 1f
SELECT	FLDLevenshteinDist(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3)),1) AS FLDLevenshteinDist
FROM
(
     SELECT *
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b
LIMIT 20;

--CASE TD-79
-- SELECT FLLevenshteinDist('teusday','tuesday',1) (FORMAT 'ZZZZ9',  TITLE  'LDScore: tuesday'),
--       FLLevenshteinDist('teusday','thursday',1) (FORMAT 'ZZZZ9',   TITLE  'LDScore: thursday'),
--	   FLDLevenshteinDist('teusday','tuesday',1) (FORMAT 'ZZZZ9',  TITLE  'DLDScore: tuesday'),
--       FLDLevenshteinDist('teusday','thursday',1) (FORMAT 'ZZZZ9',   TITLE  'DLDScore: thursday'),
--	   FLDLevenshteinDist('tuesday','something',1) (FORMAT 'ZZZZ9',  TITLE  'DLDScore: something'),
--       FLDLevenshteinDist('Helton','Helton',1) (FORMAT 'ZZZZ9', TITLE  'DLDScore: Helton'),
--	   FLDLevenshteinDist('Helton','HELTON',0) (FORMAT 'ZZZZ9', TITLE  'DLDScore: HELTON');
	   
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)		

--Case 1a
--Check if the flag takes valid values
SELECT	FLDLevenshteinDist('MARTHA','Partha',-1) AS DLevenshteinDist1;

--Case 1b
--Check if the flag takes valid values
SELECT	FLDLevenshteinDist('MARTHA','Partha',10) AS DLevenshteinDist1;

--Case 1c
--Check if the flag takes valid values
SELECT	FLDLevenshteinDist('MARTHA','Partha',NULL) AS DLevenshteinDist1;


--Case 2a
--Check if the Arg 1 takes valid values
SELECT	FLDLevenshteinDist('','Partha',1) AS DLevenshteinDist1;

--Case 2b
--Check if the Arg 1 takes valid values
SELECT	FLDLevenshteinDist(NULL,'Partha',1) AS DLevenshteinDist1;

--Case 2c
--Check if the Arg 1 takes valid values
SELECT	FLDLevenshteinDist(martha,'Partha',1) AS DLevenshteinDist1;


--Case 3a
--Check if the 2nd argument takes valid values
SELECT	FLDLevenshteinDist('MARTHA','',1) AS DLevenshteinDist1;

--Case 3b
--Check if the 2nd argument takes valid values
SELECT	FLDLevenshteinDist('MARTHA',NULL,1) AS DLevenshteinDist1;

--Case 3c
--Check if the 2nd argument takes valid values
SELECT	FLDLevenshteinDist('MARTHA',martha,1) AS DLevenshteinDist1;


--Case 4a
--Check if the 1st and 2nd argument takes valid values
SELECT	FLDLevenshteinDist('','',1) AS DLevenshteinDist1;

--Case 5a
-- All Nulls
SELECT	FLDLevenshteinDist(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3)),1) AS FLDLevenshteinDist
FROM
(
     SELECT CASE WHEN a.serialval < 100 THEN NULL ELSE a.serialval END AS serialval
     FROM  fzzlserial a 
     WHERE a.serialval<100
 ) AS b;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
