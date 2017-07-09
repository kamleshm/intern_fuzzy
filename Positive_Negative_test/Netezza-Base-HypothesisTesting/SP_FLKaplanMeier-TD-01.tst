-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
--     Test Unit Number: FLKaplanMeier-TD-01
--
--     Name(s):          FLKaplanMeier
--
--     Description:      Kaplan-Meier estimate is widely applied to estimate the survival function
--                       from lifetime data. For example, it is often used to measure the fraction 
--                       of patients living for a certain amount of time after treatment 
--                       in medical research.
--
--     Applications:            
--
--     Signature:        FLKaplanMeier (IN  TableName       VARCHAR(100),  
--                                      IN  TimeColName     VARCHAR(100),
--                                      IN  StatusColName   VARCHAR(100),  
--                                      IN  Alpha           DOUBLE PRECISION,
--                                      IN  Note            VARCHAR(100),
--                                      IN  WhereClause     VARCHAR(512),
--                                      IN  GroupBy         VARCHAR(256),
--                                      IN  TableOutput     BYTEINT,
--                                      OUT ResultTable     VARCHAR(256))
--                                      
--     Parameters:        See Documentation
--
--     Return value:            Table
--
--     Last Updated:            03-28-2014
--
--     Author:            <Joe.Fan@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql


-- BEGIN: NEGATIVE TEST(s)

--- Initialization
DROP TABLE tblWHAS100_Pulsar;

CREATE TABLE tblWHAS100_Pulsar
(
ObsID       BIGINT,
TIME_VAL    DOUBLE PRECISION,
STATUS      DOUBLE PRECISION,
Gender      DOUBLE PRECISION
)
PRIMARY INDEX ( ObsID );



---- Case 1: Input validation

-- Case 1a: Empty input table
DELETE FROM tblWHAS100_Pulsar;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard output


-- Case 1b: Bad TableName string
CALL FLKaplanMeier('dummy', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard error message


-- Case 1c: Bad TimeColName string
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'dummy', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard error message


-- Case 1d: Bad StatusColName string
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'dummy', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard error message


-- Case 1e: Bad Alpha number
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.00, NULL, 'Gender', 0, oTable);
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 1.00, NULL, 'Gender', 0, oTable);
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', -0.05, NULL, 'Gender', 0, oTable);
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 1.05, NULL, 'Gender', 0, oTable);
-- Result: incorrect error message (arg #). Also, the condition is not in user manual


-- Case 1f: Bad WHERE clause
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, '', 'Gender', 0, oTable);
-- Result: standard output
/*
CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, 'dummy', 'Gender', 0, oTable);
-- Result: need to resolve TDFL-400
*/

-- Case 1g: Bad GROUP BY clause
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'dummy', 0, oTable);
-- Result: standard error message


-- Case 1h: Bad TableOutput string
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;


-- Need to change output table name to include random AnalysisID
DROP TABLE KaplanMeier; 
CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', -1, oTable);
-- Result: no output and null ResultTable


-- Need to change output table name to include random AnalysisID
DROP TABLE KaplanMeier; 
CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 2, oTable);
-- Result: no output and null ResultTable


-- Case 2: Input dataset contains only one covariate
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        0
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard output


-- Case 3: Strange Status indicator

-- Case 3a: Status is all 0
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        0 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard outputs


-- Case 3b: Status is all 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        1 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard outputs


-- Case 3c: Status is not 0 or 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat * 10 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: strange outputs (need to restrict to 0/1 and write that in user manual)


-- Case 4: Negative time
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate - 1000 AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard outputs


-- Case 5: Random ObsID sequence
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID * RANDOM(1,10) AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL FLKaplanMeier('tblWHAS100_Pulsar', 'TIME_VAL', 'STATUS', 0.05, NULL, 'Gender', 0, oTable);
-- Result: standard outputs



---- Wrapup
DROP TABLE tblWHAS100_Pulsar;


-- END: NEGATIVE TEST(s)


-- BEGIN: POSITIVE TEST(s)

---- Case 1
REPLACE VIEW vwWHAS100 AS
SELECT  1 AS DataSetID,
        a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a
UNION ALL
SELECT  2 AS DataSetID,
        a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME_VAL,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

-- Case 1a
CALL FLKaplanMeier('vwWHAS100', 'TIME_VAL', 'STATUS', 0.05, NULL, 'DATASETID, Gender', 0, oTable);
-- Result: standard output

-- Case 1b
-- Need to change output table name to include random AnalysisID
DROP TABLE KaplanMeier;
CALL FLKaplanMeier('vwWHAS100', 'TIME_VAL', 'STATUS', 0.05, NULL, 'DATASETID, Gender', 1, oTable);
-- Result: standard output


---- Case 2
REPLACE VIEW vwWHAS100_2 AS
SELECT  1 AS MultiplierID,
        a.*
FROM    vwWHAS100 a
UNION ALL
SELECT  2 AS MultiplierID,
        a.*
FROM    vwWHAS100 a;

CALL FLKaplanMeier('vwWHAS100_2', 'TIME_VAL', 'STATUS', 0.05, NULL, 'DATASETID, Gender', 0, oTable);


---- Cleanup
DROP VIEW vwWHAS100;
DROP VIEW vwWHAS100_2;


-- END: POSITIVE TEST(s)

-- END: TEST SCRIPT
