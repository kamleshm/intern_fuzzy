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
--	Test Unit Number:	SP_GLM-NZ-01
--
--	Name(s):		SP_GLM
--
-- 	Description:	    	Stored Procedure that transforms Generalized Linear modeling
--
--	Applications:	    	
--
-- 	Signature:		SP_GLM(IN TableName VARCHAR(256), 
--                        IN RecIdCol VARCHAR(30), 
--                        IN DepVarCol VARCHAR(30),
--                        IN COLSPECID VARCHAR(30),
--                        IN IntSPECID VARCHAR(30),
--                        IN LSMeansCol VARCHAR(30),
--                        IN Note VARCHAR(255))
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(30)
--
--	Last Updated:	    	01-19-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--Create the test table 
CREATE TABLE tblTestGLMWide
     (
      OBSID INTEGER,
      DRUG INTEGER,
      DISEASE INTEGER,
      TRIAL INTEGER,
      EFFECT FLOAT)
DISTRIBUTE ON ( OBSID );


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative  test cases --------------------------------------------
---------------------------------------------------------------------------------------
--param1
--CASE 1a
----Input table does not 
CALL SP_GLM('tblTestGLMNotExist', 'ObsID', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

--CASE 1b
----NULL
CALL SP_GLM(NULL, 'ObsID', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2'); 
--CASE 1c
----empty 
CALL SP_GLM('', 'ObsID', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

--Case 2
--empty input table 
DELETE FROM  tblTestGLMWide ALL;
CALL SP_GLM('tblTestGLMWide', 'ObsID', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

--Populate the test table
INSERT INTO tblTestGLMWide
SELECT * FROM tblDrugWide;

--Param2
--CASE 3a
CALL SP_GLM('tblTestGLMWide', 'Obs', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');
 --ERROR 7559:  Memory (via malloc call) not freed before exiting  UDF/XSP/UDM fuzzylogix.FLGLM. 
 --JIRA RAISED 517
CALL SP_GLM('tblTestGLMWide', '', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');
CALL SP_GLM('tblTestGLMWide', NULL, 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

--Param3
--CASE 3b
CALL SP_GLM('tblTestGLMWide', 'ObsID', NULL, 'GLM2', 'Int1', 'Drug', 'GLM Test2');
CALL SP_GLM('tblTestGLMWide', 'ObsID', 'NonEffect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');
--7559:  Memory (via malloc call) not freed before exiting  UDF/XSP/UDM fuzzylogix.FLGLM. 
--JIRA 517
CALL SP_GLM('tblTestGLMWide', 'ObsID', '', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

--Param6
--case 3c
CALL SP_GLM('tblTestGLMWide', 'ObsID', 'Effect', 'GLM2', 'Int1', 'DrugNotExist', 'GLM Test2');

-- END:  NEGATIVE  TEST(s)

--BEGIN:POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- POSITIVE  test cases --------------------------------------------
---------------------------------------------------------------------------------------
--Populate the test table
--case 1a
DELETE  FROM tblTestGLMWide;

INSERT INTO tblTestGLMWide
SELECT * FROM tblDrugWide;

--Insert into table for ColSpecID
DELETE FROM fzzlGLMColumns WHERE SPECID IN ('GLM1', 'GLM2');
INSERT INTO fzzlGLMColumns
VALUES ('GLM1', 1 ,'ObsID');
INSERT INTO fzzlGLMColumns
VALUES ('GLM1', 1 ,'Drug');
INSERT INTO fzzlGLMColumns
VALUES ('GLM2', 2 ,'Disease');

-----Insert into table for  IntSpecID
DELETE FROM  fzzlGLMIntColumns WHERE SPECID IN ( 'Int1', 'Int2') ;
 INSERT INTO fzzlGLMIntColumns
VALUES ('Int1', 1 ,'DRUG','Disease');
 INSERT INTO fzzlGLMIntColumns
VALUES ('Int2', 1 ,'DISEASE','Trial');


CALL SP_GLM('tblTestGLMWide', 'ObsID', 'Effect', 'GLM2', 'Int1', 'Drug', 'GLM Test2');

SELECT  a.*
FROM     fzzlGLMRegrStats a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2;

SELECT a.*
FROM   fzzlGLMRegrCoeffs a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2, 3;

SELECT a.*
FROM   fzzlGLMLSMeans a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2, 3;


--case  2a
-----Insert into table for  IntSpecID
CALL SP_GLM('tblTestGLMWide', 'ObsID', 'Effect', 'GLM1', 'Int2', 'Drug', 'GLM Test2');

SELECT  a.*
FROM     fzzlGLMRegrStats a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2;

SELECT a.*
FROM   fzzlGLMRegrCoeffs a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2, 3;

SELECT a.*
FROM   fzzlGLMLSMeans a,
        (
        SELECT   a.AnalysisID
        FROM     FZZLGLMINFO a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 2, 3;


--- END:  POSITIVE  TEST(s)
--Drop the Test tables
DELETE FROM fzzlGLMColumns WHERE SPECID IN ('GLM1', 'GLM2');
DELETE FROM  fzzlGLMIntColumns WHERE SPECID IN ( 'Int1', 'Int2') ;
DROP TABLE tblTestGLMWide;
-- 	END: TEST SCRIPT
