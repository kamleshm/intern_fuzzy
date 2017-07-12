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
--	Test Unit Number:	SP_LinRegrMultiDataSet-NZ-01
--
--	Name(s):		SP_LinRegrMultiDataSet
--
-- 	Description:	    	Stored Procedure which performs Linear Regression on multidataset and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		SP_LinRegrMultiDataSet(IN TableName VARCHAR(256),
--							IN Note VARCHAR(255))
--
--	Parameters:		See Documentation
--
--	Return value:	    	Table
--
--	Last Updated:	    	07-10-2017
--
--	Author:			<kamlesh.meena@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time
DROP TABLE tblLinRegrMDTest IF EXISTS;
CREATE TABLE tblLinRegrMDTest (
DataSetID   BIGINT,
ObsID       BIGINT,
VarID       INTEGER,
Value      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

---- BEGIN: NEGATIVE TEST(s)
-- Case1
---- Incorrect table name
CALL SP_LinRegrMultiDataSet('Dummy', 'vmy2in1kzc1');
CALL SP_LinRegrMultiDataSet('', 'vmy2in1kzc2');
CALL SP_LinRegrMultiDataSet(NULL, 'vmy2in1kzc3');

---- Populate data in table
DROP VIEW vw_LinRegrMultiTest ;

CREATE OR REPLACE VIEW vw_LinRegrMultiTest AS 
SELECT 1 AS DataSetID, a.*
FROM   tblLinRegr a
WHERE  a.VarID <= 50  AND a.ObsID <= 2000
UNION
SELECT 2 AS DataSetID, a.*
FROM   tblLinRegr  a
WHERE  a.VarID <= 50 AND a.ObsID <= 3000
UNION
SELECT 3 AS DataSetID, a.*
FROM   tblLinRegr a
WHERE  a.VarID <= 50 AND a.ObsID <= 4000
UNION
SELECT 4 AS DataSetID, a.*
FROM   tblLinRegr a
WHERE  a.VarID <= 100  AND a.ObsID <= 10000;


INSERT INTO tblLinRegrMDTest
SELECT a.*
FROM   vw_LinRegrMultiTest a;

--Case 2a ---- Incorrect column names
-- Not applicable in Netezza

--Case3 ---- No data in table
DELETE FROM tblLinRegrMDTest;
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc4');

--Case 4 --Invalid Dependent variable--
--Case 4a ---- No dependent variable for  every datasetID 
---- Insert dependent variable only for some DatasetID
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID<> -1 ;

INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID = -1
AND DatasetID <>2;

---- No dependent variable for all  DatasetIDs
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc5');

--Case 4b ---- No dependent variable for all observations in each dataset 
---- Insert dependent variable only for some obs in each dataset
DELETE FROM tblLinRegrMDTest 
WHERE VarID  = -1;

INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID = -1
AND     a.ObsID <= 3500;

---- No dependent variable for all observations
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc6');

--Case 5 Invalid Intercept values---
--Case 5a ---- No intercept variable for all observations
DELETE FROM tblLinRegrMDTest;
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID <> 0;
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID = 0
AND DatasetID <>2;

---- No intercept for  some datasets 
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc7');

--Case 5b ---- No distinct intercept values  fobservations in each dataset
DELETE FROM tblLinRegrMDTest
WHERE VarID = 0;

INSERT INTO tblLinRegrMDTest
SELECT  a.DatasetID,
        a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 3500 THEN 0 ELSE 1 END
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID = 0;

---- Non distinct values for intercept
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc8');

--Case5c: Intercept not 0 or 1
---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLinRegrMDTest
WHERE VarID = 0;
INSERT INTO tblLinRegrMDTest
SELECT   a.DatasetID,
        a.ObsID,
        a.VarID,
        CASE WHEN a.DatasetID <> 2  THEN Num_Val  ELSE 4 END
FROM   vw_LinRegrMultiTest a
WHERE   a.VarID = 0;

---- Intercept of 0 or 1
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc9');

--Case 6
---- Number of observations <= number of variables
---- Cleanup the table
DELETE FROM tblLinRegrMDTest;

---- Populate less rows than variables
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.ObsID <= 2;

---- Number of observations <= number of variables
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc10');

--Case7
---- Repeated data in table
---- Cleanup the table and populate the data
DELETE FROM tblLinRegrMDTest;
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a;

--- Repeat a row in the table
INSERT INTO tblLinRegrMDTest
SELECT a.GroupID,
         a.ObsCol,
        a.VarCol,
        a.NumVal
FROM    tblLinRegrMDTest a
WHERE  a.VarID = 10
AND a.ObsID = 26;

---- Repeated data in table
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc11');

--Case 11---- Non consecutive variable IDs 
---- Cleanup the table and populate
DELETE FROM tblLinRegrMDTest;
INSERT INTO  tblLinRegrMDTest
SELECT * 
FROM    vw_LinRegrMultiTest a
WHERE   a.DatasetId <> 2;

INSERT INTO tblLinRegrMDTest
SELECT  a.datasetid,
        a.ObsID,
        a.VarID * 2,
        a.Num_Val
FROM    vw_LinRegrMultiTest a
WHERE   a.VariD > 0
AND a.DatasetID = 2
UNION ALL 
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID IN (-1, 0)
AND a.DatasetID = 2;

---- Non consecutive variable IDs
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc12');


-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------
--Case 1
---- Perform regression with non-sparse data
---- Cleanup the data and populate again
DELETE FROM tblLinRegrMDTest;
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a;

---- Perform regression with non-sparse data
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc13');

-- Display result

FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc13'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc13'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--Case 2
---- Perform regression with sparse data
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLinRegrMDTest;

INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID > 0
AND     a.VarID <= 10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with non-sparse data
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc14');

-- Display result

FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc14'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc14'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--Case 3
---- Perform regression with sparse data and large number of variables
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values
---- for all variables except dependent and intercept
DELETE FROM tblLinRegrMDTest;

INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    vw_LinRegrMultiTest a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data and large number of variables
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc15');

-- Display result

FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc15'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc15'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--case 4
--Cross database run
---- Drop and recreate the test table
DROP TABLE tblLinRegrMDTest;

CREATE TABLE tblLinRegrMDTest (
DataSetID     BIGINT,
ObsID       BIGINT,
VarID       INTEGER,
Value      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

--Insert data 
INSERT INTO tblLinRegrMDTest
SELECT  a.*
FROM    vw_LinRegrMultiTest a;

---- Perform regression 
CALL SP_LinRegrMultiDataSet('tblLinRegrMDTest', 'vmy2in1kzc16');

-- Display result

FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc16'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='vmy2in1kzc16'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

---DROP the test table
DROP VIEW vw_LinRegrMultiTest;
DROP TABLE tblLinRegrMDTest;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
