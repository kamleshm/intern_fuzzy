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
--     Test Category:    Hypothesis Testing Functions
--
--     Test Unit Number: SP_KaplanMeierHypoTest-NZ-01
--
--     Name(s):          SP_KaplanMeierHypoTest
--
--     Description:      SP_KaplanMeierHypoTest performs Kaplan-Meier Test on two data samples. 
--                       Kaplan-Meier Test is used to determine whether survival probabilities 
--                       between samples are significantly different.
--
--     Applications:            
--
--     Signature:        SP_KaplanMeierHypoTest(IN TableName 	VARCHAR(100),
--                                    			IN DataSetID1 	INTEGER,
--                                    			IN DataSetID2 	INTEGER,
--                                    			IN Note 		VARCHAR(256))
--                                      
--     Parameters:        See Documentation
--
--     Return value:            Table
--
--     Last Updated:            01-25-2015
--
--     Author:            <Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql


-- BEGIN: NEGATIVE TEST(s)

--- Initialization
DROP TABLE tblWHAS100_Pulsar;

CREATE TABLE tblWHAS100_Pulsar
(
ObsID       BIGINT,
TIME    	DOUBLE PRECISION,
STATUS      DOUBLE PRECISION,
Gender      DOUBLE PRECISION
)
DISTRIBUTE ON ( ObsID );



---- Case 1: Input validation

-- Case 1a: Empty input table
DELETE FROM tblWHAS100_Pulsar;

-- Need to change output table name to include random AnalysisID

CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: standard output


-- Case 1b: Bad InputTable string
-- Need to change output table name to include random AnalysisID
DROP TABLE KaplanMeier;
CALL SP_KaplanMeierHypoTest('dummy', 1, 2, 'HypoTest');
-- Result: standard error message


-- Case 1c: Bad TimeColName string
-- Case 1d: Bad StatusColName string
-- Case 1e: Bad SampleIDColName string
-- Case 1f: Bad Alpha number
-- Case 1g: Bad WHERE clause
--NA for NZ

/*
-- Need to change output table name to include random AnalysisID
-- Result: need to resolve TDFL-400
*/

-- Case 1h: Bad GROUP BY clause
--NA for NZ


-- Case 1i: Bad TableOutput string
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

-- Need to change output table name to include random AnalysisID
                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest');  
-- Result: no output and null ResultTable

-- Need to change output table name to include random AnalysisID
                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: no output and null ResultTable


-- Case 2: Input dataset contains only one covariate
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        0
FROM    tblWHAS100 a;

                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest');  
-- Result: standard output


-- Case 3: Strange Status indicator

-- Case 3a: Status is all 0
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        0 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: division by zero


-- Case 3b: Status is all 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        1 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: standard outputs


-- Case 3c: Status is not 0 or 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat * 10 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: division by zero (need to restrict to 0/1 and write that in user manual)


-- Case 4: Negative time
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate - 1000 AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

                      
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest'); 
-- Result: standard outputs


-- Case 5: Random ObsID sequence
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID * RANDOM(1,10) AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

DROP TABLE KaplanMeier;
CALL SP_KaplanMeierHypoTest('tblWHAS100_Pulsar', 1, 2, 'HypoTest');                       
-- Result: standard outputs


---- Wrapup
DROP TABLE tblWHAS100_Pulsar;


-- END: NEGATIVE TEST(s)


-- BEGIN: POSITIVE TEST(s)

---- Case 1
CREATE OR REPLACE VIEW vwWHAS100 AS
SELECT  1 AS DataSetID,
        a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a
UNION ALL
SELECT  2 AS DataSetID,
        a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeierHypoTest('vwWHAS100', 1, 2, 'HypoTest'); 
-- Result: Fails saying that Y Value must be positive

---- Case 2
CREATE OR REPLACE VIEW vwWHAS100_2 AS
SELECT  1 AS MultiplierID,
        a.*
FROM    vwWHAS100 a
UNION ALL
SELECT  2 AS MultiplierID,
        a.*
FROM    vwWHAS100 a;

CALL SP_KaplanMeierHypoTest('vwWHAS100_2', 1, 2, 'HypoTest');


---- Cleanup
DROP VIEW vwWHAS100;
DROP VIEW vwWHAS100_2;


-- END: POSITIVE TEST(s)

-- END: TEST SCRIPT
