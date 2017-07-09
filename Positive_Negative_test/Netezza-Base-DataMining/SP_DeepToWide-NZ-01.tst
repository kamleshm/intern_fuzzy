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
-- 	Test Category:		Data Mining Functions
--
--	Test Unit Number:	SP_DeepToWide-NZ-01
--
--	Name(s):		SP_DeepToWide
--
-- 	Description:	    	Stored Procedure that transforms the data in a deep table format to that of a wide table format.
--
--	Applications:	    	
--
-- 	Signature:				SP_DeepToWide	(IN  DeepTable  	VARCHAR(100),
--                                           IN  FieldMapTable  VARCHAR(100),
--                                           IN  MapName  		VARCHAR(100),
--                                           OUT  WideTable  	VARCHAR(100))
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(100)
--
--	Last Updated:	    	07-07-2017
--
--	Author:			<Raman.Rajasekhar@fuzzyl.com, gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,<kamlesh.meena@fuzzl.com>

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-----------------------------------------------------------------------------------------------------------------------------------
----------Creating deep tables and the corresponding mapping tables ------------------------------
-------------------------------------------------------------------------------------------------------------------------

SELECT a.*
FROM tblAutoMpgMap a
ORDER BY a.VarID, a.ColumnName;

---- Create mapping table with multiple table names
DROP TABLE tblAutoMpgMapMulti;
CREATE TABLE tblAutoMpgMapMulti
     (
      VarID 		BIGINT,
      ColumnName 	VARCHAR(100), --CHARACTER SET LATIN NOT CASESPECIFIC,
      MapName 		VARCHAR(100)) --CHARACTER SET LATIN NOT CASESPECIFIC)
DISTRIBUTE ON( VarID );

---- Insert data into tblAutoMpgMapMulti
INSERT INTO tblAutoMpgMapMulti SELECT * FROM tblAutoMpgMap;
INSERT INTO tblAutoMpgMapMulti VALUES ( -1, 'MPG',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  1, 'Acceleration',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  2, 'Cylinders',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  3, 'Displacement',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  4, 'HorsePower',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  5, 'ModelYear',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  6, 'Origin',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  7, 'Weight',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES ( -1, 'MPG1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  1, 'Acceleration1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  2, 'Cylinders1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  3, 'Displacement1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  4, 'HorsePower1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  5, 'ModelYear1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  6, 'Origin1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES (  7, 'Weight1',  'tblAutoMpgDupli');
INSERT INTO tblAutoMpgMapMulti VALUES ( -1, 'MPG',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  1, 'Acceleration',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  2, 'Cylinders',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  3, 'Displacement',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  4, 'HorsePower',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  5, 'ModelYear',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  6, 'Origin',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  7, 'Weight',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  8, 'Extra1',  'tblAutoMpgExtra');
INSERT INTO tblAutoMpgMapMulti VALUES (  9, 'Extra2',  'tblAutoMpgExtra');

--- Check the table
SELECT a.* 
FROM tblAutoMpgMapMulti a
ORDER BY a.MapName, a.VarID, a.ColumnName;

---- Create deep table with column names 'ObsIDCol', 'VarIDCol', and 'ValueCol'
DROP TABLE tblAutoMPGDeep1 IF EXISTS;
CREATE TABLE tblAutoMPGDeep1
     (
      OBSIDCol BIGINT,
      VarIDCol BIGINT,
      ValueCol FLOAT)
DISTRIBUTE ON ( OBSIDCol ,VarIDCol );

---- Insert values into tblAutoMpgDeep1
DELETE FROM tblAutoMPGDeep1;

INSERT INTO tblAutoMPGDeep1
SELECT *
FROM tblAutoMpgDeepDemo;

---- Create empty input deep table for negative testing
DROP TABLE tblAutoMPGDeep_empty IF EXISTS;
CREATE TABLE tblAutoMPGDeep_empty
     (
      OBSIDCol BIGINT,
      VarIDCol BIGINT,
      ValueCol FLOAT)
DISTRIBUTE ON ( OBSIDCol ,VarIDCol );

---- Create the empty mapping table
DROP TABLE tblAutoMpgMap_empty IF EXISTS;
CREATE TABLE tblAutoMpgMap_empty
( 
 VarID			BIGINT,
 ColumnName		VARCHAR(100),
 MapName		VARCHAR(100))
DISTRIBUTE ON (VarID);


---- BEGIN: POSTIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--CASE 1
---- w/o mapping table and w/o map name
---- Expected result: Should Work fine
DROP TABLE tblAutoMpgWideDemo IF EXISTS;
CALL SP_DeepToWide('tblAutoMpgDeep1',NULL,NULL,'tblAutoMpgWideDemo');

---- Check the wide table and then compare with the original input table
SELECT 	*
FROM 	tblAutoMpgWideDemo
LIMIT 1;
--Check if empty
SELECT Count(*)
FROM tblAutoMpgWideDemo a;

SELECT VarIdCol, Count(*)
FROM tblAutoMPGDeep1  a
WHERE VarIdCol <> 0
GROUP BY VarIdCol
ORDER BY 1;

--CASE 2
---- w/ mapping table (contains only one map name) but w/o map name
---- Expected result: Should Work fine
DROP TABLE tblAutoMpgWideDemo IF EXISTS;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMap',NULL,'tblAutoMpgWideDemo');

SELECT 	*
FROM 	tblAutoMpgWideDemo
LIMIT 1;
--Check if empty
SELECT Count(*)
FROM tblAutoMpgWideDemo a;


--CASE 3
 ---- w/ mapping table (contains only one map name) but w/o map name
---- Expected result: Should Work fine
DROP TABLE tblAutoMpgWideDemo IF EXISTS;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMap',NULL,'tblAutoMpgWideDemo');

SELECT 	*
FROM 	tblAutoMpgWideDemo
LIMIT 1;
--Check if empty
SELECT Count(*)
FROM tblAutoMpgWideDemo a;


--CASE 4
---- w/ mapping table (with single map name) and w/ map name
---- Expected result: Should Work fine
DROP TABLE tblAutoMpgWideDemo IF EXISTS;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMap','tblAutoMpg','tblAutoMpgWideDemo');

SELECT 	*
FROM 	tblAutoMpgWideDemo
LIMIT 1;
--Check if empty
SELECT Count(*)
FROM tblAutoMpgWideDemo a;

--CASE 5
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Should Work fine
---- PASSED
DROP TABLE tblAutoMpgWideDemo IF EXISTS;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWideDemo');

SELECT 	*
FROM 	tblAutoMpgWideDemo
LIMIT 1;
--Check if empty
SELECT Count(*)
FROM tblAutoMpgWideDemo a;

--CASE 5a
--Using database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Should Work fine
---- PASSED
--DROP TABLE tblAutoMpgWide IF EXISTS;
--CALL SP_DeepToWide('fuzzylogix.tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWide', Message);

--SHOW TABLE tblAutoMpgWide;
--Check if empty
--SELECT Count(*)
--FROM tblAutoMpgWide a;

---CASE 5b
--Using database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Should Work fine
---- PASSED
--DROP TABLE tblAutoMpgWide IF EXISTS;
--CALL SP_DeepToWide('fuzzylogix.tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','fuzzylogix.tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWide', Message);

--SHOW TABLE tblAutoMpgWide;
--Check if empty
--SELECT Count(*)
--FROM tblAutoMpgWide a;

---CASE 5c
--Using database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Should Work fine
---- PASSED
--DROP TABLE tblAutoMpgWide IF EXISTS;
--CALL SP_DeepToWide('fuzzylogix.tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','fuzzylogix.tblAutoMpgMapMulti','tblAutoMpg','fuzzylogix.tblAutoMpgWide', Message);

--SHOW TABLE tblAutoMpgWide;
--Check if empty
--SELECT Count(*)
--FROM tblAutoMpgWide a;



-- END: POSITIVE TEST(s)

--BEGIN: NEGATIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Negative  test cases --------------------------------------------
---------------------------------------------------------------------------------------

SELECT Count(*)
FROM tblAutoMpgWideDemo;

--CASE 7a
---- ouput table exist
---- Expected result: Throw error : Output Table 'tblAutoMpgWide' already exists, use another table name.
CALL SP_DeepToWide('tblAutoMpgDeepDemo','tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWideDemo');

--CASE 6a
----  input deep table does not exist
---- Expected result: Throw error - Input table does not exist
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('ABCD','tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWideDemo');

--CASE 6b
----  input deep table is empty
---- Expected result: Throw error : Input Table cannot be empty
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep_empty','tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWideDemo');

SELECT *
FROM tblAutoMpgWideDemo;

--CASE 7
---- w/ empty mapping table and a Map Name
---- Expected result: Throw error - Mapping table is empty
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMap_empty','BogusMapName','tblAutoMpgWideDemo');

--CASE 8 
---- w/o input deep table
---- Expected result: Throw error - Input table parameter cannot be null
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide(NULL,'tblAutoMpgMapMulti','tblAutoMpg','tblAutoMpgWideDemo');

--CASE 9
---- w/o output table name
---- Expected result: Throw error - Output table parameter cannot be null
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMap','tblAutoMpg',NULL);

--CASE 10
---- w/o Mapping table & w/ mapping name
---- Expected result: Throw error - Map table parameter cannot be null if nap name is specified
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep1',NULL,'tblAutoMpg','tblAutoMpgWideDemo');

--CASE 11
---- W/ Mapping table & w/o mapping name  
---- Expected result: Throw error - Multiple map names exist in mapping table
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMapMulti',NULL,'tblAutoMpgWideDemo');

--CASE 12
---- w/ Mapping table & mapping name, but mapping has duplicate VarIDs
---- Expected result: Throw error - VarID must be unique
DROP TABLE tblAutoMpgWideDemo;
CALL SP_DeepToWide('tblAutoMpgDeep1','tblAutoMpgMapMulti','tblAutoMpgDupli','tblAutoMpgWideDemo');

---CASE 13
--Using wrong database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Throw error 
---- PASSED
--DROP TABLE tblAutoMpgWide;
--CALL SP_DeepToWide('fuzzx.tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','fuzzylogix.tblAutoMpgMapMulti','tblAutoMpg','fuzzylogix.tblAutoMpgWide', Message);

---CASE 14
--Using wrong database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Throw error
---- PASSED
--DROP TABLE tblAutoMpgWide;
--CALL SP_DeepToWide('tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','fzylogix.tblAutoMpgMapMulti','tblAutoMpg','fuzzylogix.tblAutoMpgWide', Message);


---CASE 15
--Using wrong database qualifier
---- w/ mapping table (with multiple map name) and w/ map name
---- Expected result: Throw error
---- PASSED
--DROP TABLE tblAutoMpgWide;
--CALL SP_DeepToWide('tblAutoMpgDeep1','ObsIDCol', 'VarIDCol', 'ValueCol','tblAutoMpgMapMulti','tblAutoMpg','fugix.tblAutoMpgWide', Message);


-- END: NEGATIVE TEST(s)

--Drop the Test tables
DROP TABLE tblAutoMpgDeep1;
DROP TABLE tblAutoMpgWideDemo;
\time
-- 	END: TEST SCRIPT
