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
--     Test Unit Number: SP_KaplanMeier-NZ-01
--
--     Name(s):          SP_KaplanMeier
--
--     Description:      Kaplan-Meier estimate is widely applied to estimate the survival function
--                       from lifetime data. For example, it is often used to measure the fraction 
--                       of patients living for a certain amount of time after treatment 
--                       in medical research.
--
--     Applications:            
--
--     Signature:        FLKaplanMeier (IN  TableName       VARCHAR(100), 
--                                      IN  Alpha           DOUBLE PRECISION,
--                                      IN  Note            VARCHAR(256))
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
TIME    DOUBLE PRECISION,
STATUS      DOUBLE PRECISION,
Gender      DOUBLE PRECISION
)
DISTRIBUTE ON( ObsID );

---- Case 1: Input validation

-- Case 1a: Empty input table
DELETE FROM tblWHAS100_Pulsar;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
-- Result: standard output


-- Case 1b: Bad TableName string
CALL SP_KaplanMeier('Dummy', 0.05,'KaplanMeier Test');
-- Result: standard error message


-- Case 1e: Bad Alpha number
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.00,'KaplanMeier Test');
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 1.00,'KaplanMeier Test');
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL SP_KaplanMeier('tblWHAS100_Pulsar', -0.05,'KaplanMeier Test');
-- Result: incorrect error message (arg #). Also, the condition is not in user manual

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 1.05,'KaplanMeier Test');
-- Result: incorrect error message (arg #). Also, the condition is not in user manual


-- Case 2: Input dataset contains only one covariate
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        0
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
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

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
-- Result: standard outputs


-- Case 3b: Status is all 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        1 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
-- Result: standard outputs


-- Case 3c: Status is not 0 or 1
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat * 10 AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
-- Result: strange outputs (need to restrict to 0/1 and write that in user manual)


-- Case 4: Negative time
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID AS ObsID, 
        a.FolDate - a.AdmitDate - 1000 AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
-- Result: standard outputs


-- Case 5: Random ObsID sequence
DELETE FROM tblWHAS100_Pulsar;

INSERT INTO tblWHAS100_Pulsar
SELECT  a.ID * RANDOM(1,10) AS ObsID, 
        a.FolDate - a.AdmitDate AS TIME,
        a.FStat AS STATUS,
        a.Gender
FROM    tblWHAS100 a;

CALL SP_KaplanMeier('tblWHAS100_Pulsar', 0.05,'KaplanMeier Test');
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

-- Case 1a
CALL SP_KaplanMeier('vwWHAS100', 0.05,'KaplanMeier Test');
-- Result: standard output


---- Case 2
CREATE OR REPLACE VIEW vwWHAS100_2 AS
SELECT  1 AS MultiplierID,
        a.*
FROM    vwWHAS100 a
UNION ALL
SELECT  2 AS MultiplierID,
        a.*
FROM    vwWHAS100 a;

CALL SP_KaplanMeier('vwWHAS100_2', 0.05,'KaplanMeier Test');


---- Cleanup
DROP VIEW vwWHAS100;
DROP VIEW vwWHAS100_2;


-- END: POSITIVE TEST(s)

-- END: TEST SCRIPT
