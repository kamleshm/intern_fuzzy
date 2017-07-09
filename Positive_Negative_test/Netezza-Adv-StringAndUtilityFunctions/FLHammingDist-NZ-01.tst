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
--	Test Unit Number:		FLHammingDist-Netezza-01
--
--	Name(s):		    	FLHammingDist
--
-- 	Description:			The Hamming distance between two strings of equal length is the number of positions at which the corresponding symbols are different.
--
--	Applications:		 
--
-- 	Signature:		    	FLHammingDist(String1 VARCHAR(1000), String2 VARCHAR(1000), CaseFlag INTEGER, Length BIGINT)
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
SELECT	FLHammingDist('MARTHA','Partha',1,3) AS HammingDist1,
	FLHammingDist('MARTHA','Partha',0,3) AS HammingDist2,
	FLHammingDist('MARTHA','MARTHA',0,3) AS HammingDist3,
	FLHammingDist('Prof. John Doe','Dr. John Doe',1,5) AS HammingDist4;
		  
--Case 1b
SELECT	FLHammingDist('toned','ROSES',1,3) AS HammingDist1;

--Case 1c
SELECT	FLHammingDist('toned','ROSES',0,3) AS HammingDist1;

--Case 1d
SELECT	FLHammingDist('1011101 ','1001001 ',1,7) AS HammingDist1;

--Case 1e
SELECT	FLHammingDist('-1011','100- ',1,4) AS HammingDist1;

--Case 1f
SELECT	FLHammingDist(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3)),1,1) AS HammingDist1
FROM
(
SELECT *
FROM  fzzlserial a 
WHERE a.serialval<100
 ) AS b
LIMIT 10;
 
--Case 1g: TD-80
-- SELECT FLHammingDist(LOWER(TableName), UPPER(TableName),0,CHARACTER_LENGTH( TRIM( TRAILING FROM TableName ) )) AS HDScore
-- FROM DBC.Tables AS a
-- WHERE HDScore <> 0;

-- Case 1g
SELECT FLHammingDist('0','1',1,1) AS FLHammingDist;
SELECT FLHammingDist('1','1',1,1) AS FLHammingDist;
SELECT FLHammingDist('10','01',1,2) AS FLHammingDist;
SELECT FLHammingDist('100','010',1,3) AS FLHammingDist;
SELECT FLHammingDist('1000','0100',1,4) AS FLHammingDist;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)		

--Case 1a
--Check if the flag takes valid values
SELECT	FLHammingDist('MARTHA','Partha',-1,3) AS HammingDist1;

--Case 1b
--Check if the flag takes valid values
SELECT	FLHammingDist('MARTHA','Partha',10,3) AS HammingDist1;

--Case 1c
--Check if the flag takes valid values
SELECT	FLHammingDist('MARTHA','Partha',NULL,3) AS HammingDist1;


--Case 2a
--Check if the Arg 1 takes valid values
SELECT	FLHammingDist('','Partha',1,3) AS HammingDist1;

--Case 2b
--Check if the Arg 1 takes valid values
SELECT	FLHammingDist(NULL,'Partha',1,3) AS HammingDist1;

--Case 2c
--Check if the Arg 1 takes valid values
SELECT	FLHammingDist(martha,'Partha',1,3) AS HammingDist1;


--Case 3a
--Check if the 2nd argument takes valid values
SELECT	FLHammingDist('MARTHA','',1,3) AS HammingDist1;

--Case 3b
--Check if the 2nd argument takes valid values
SELECT	FLHammingDist('MARTHA',NULL,1,3) AS HammingDist1;

--Case 3c
--Check if the 2nd argument takes valid values
SELECT	FLHammingDist('MARTHA',martha,1,3) AS HammingDist1;


--Case 4a
--Check if the 4th argument takes valid values
SELECT	FLHammingDist('MARTHA','Partha',1,NULL) AS HammingDist1;
--JIRA: the 4th argument takes negative valus for string length

--Case 4b
--Check if the 4th argument takes valid values
SELECT	FLHammingDist('MARTHA','Partha',1,-2) AS HammingDist1;

--Case 4c
--Check if the 4th argument takes valid values
--should return -1 as length of 'MARTHA'  < 7
SELECT	FLHammingDist('MARTHA','Parthas',1,7) AS HammingDist1;

--Case 4e
--Check if the 4th argument takes valid values
SELECT	FLHammingDist('MARTHA','Parthas',1,0) AS HammingDist1;

--Case 4f
--Check if the 4th argument takes valid values
--should return -1 as length of 'Parthas'  < 8
SELECT	FLHammingDist('MARTHA Andrews','Parthas',1,8) AS HammingDist1;

--Case 4g
--Check if the 4th argument takes valid values
SELECT	FLHammingDist('MARTHA Andrews','Parthas',1,CAST( 2**63-1 AS BIGINT)) AS HammingDist1;

--Case 5a
-- All Nulls
SELECT	FLHammingDist(CAST(b.serialval AS VARCHAR(3)),CAST(b.serialval AS VARCHAR(3)),1,1) AS HammingDist1
FROM
(
SELECT CASE WHEN a.serialval < 100 THEN NULL ELSE a.serialval END AS serialval
FROM  fzzlserial a 
WHERE a.serialval<100
 ) AS b;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
