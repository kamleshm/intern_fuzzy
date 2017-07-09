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
--     Test Category:    Sampling Techniques
--
--     Test Unit Number: SP_SurveySelectStratPerc-NZ-01
--
--     Name(s):          SP_SurveySelectStratPerc
--
--     Description:      SP_SurveySelectStratPerc selects samples independently within the 
--                       specified strata by selecting a specified percentage of records 
--                       for each stratum.
--                       
--     Applications:            
--
--     Signature:        SP_SurveySelectStratPerc ( Population Table Name			VARCHAR(100), 
--                                                  RecID/ObsID Name 				VARCHAR(100), 
--												  	StratumID Name					VARCHAR(100),
--													Sample Table Name 				VARCHAR(100),
--													Stratum Information TableName 	VARCHAR(100),
--													Number of Samples 				INTEGER, 
--													Notes							VARCHAR(256)) 
--
--     Parameters:        See Documentation
--
--     Return value:            Table
--
--     Last Updated:            25-01-2015
--
--     Author:            <Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: NEGATIVE TEST(s)

Drop Table OutTable;

---- Case 1: input validation

---- Case 1a: invalid InputTable
CALL SP_SurveySelectStratPerc('Dummy', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message


CALL SP_SurveySelectStratPerc( NULL, 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message


---- Case 1b: invalid RecIDCol
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'Dummy', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message


CALL SP_SurveySelectStratPerc('tblPopulation', 
                               NULL, 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message


---- Case 1c: invalid StratumIDCol
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'Dummy', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message

CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                               NULL, 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message


---- Case 1d: invalid StratumTable
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'Dummy',
                               2,
                              'StratPerc Test');
-- Result: standard error message


CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                               NULL,
                               2,
                              'StratPerc Test');
-- Result: standard error message


---- Case 1e: invalid NumOfSamples
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               0,
                              'StratPerc Test');
-- Result: standard error message


---- Case 1f: invalid WithReplacement
--NA for NZ

---- Case 1g: invalid TableOutput
--NA for NZ

---- Case 1h: invalid OutTable
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							   NULL,
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard error message

---- Case 2: WithReplacement = 1 and small fzzlSerial

-- Artificially reduce size of fzzlSerial
DROP TABLE fzzlSerial_Test;

CREATE TABLE fzzlSerial_Test
(
SerialVal       BIGINT,
RandVal         DOUBLE PRECISION
)
DISTRIBUTE ON(SerialVal);

INSERT INTO fzzlSerial_Test
SELECT  *
FROM    fzzlSerial;

DELETE FROM fzzlSerial
WHERE   SerialVal > 2**2;

---- Case 2a: Length of fzzlSerial is smaller than InputTable
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: dubious results
--         insufficient sampling of ObsID and excess SampleNum (why 3 and 4?)
--         Function should check if length of fzzlSerial > length of InputTable 
--                           and if length of fzzlSerial > NumOfSamples


---- Case 2a:length of fzzlSerial is smaller than InputTable AND NumOfSamples
Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               6,
                              'StratPerc Test');
-- Result: dubious results
--         insufficient sampling of ObsID and insufficient number of SampleNum


-- Restore fzzlSerial and drop test table
DELETE FROM fzzlSerial;

INSERT INTO fzzlSerial
SELECT  *
FROM    fzzlSerial_Test;

DROP TABLE fzzlSerial_Test;


---- Case 3: mess with contents of tblStratumSize

-- Initialization
DROP TABLE tblStratumSize_Test;

CREATE TABLE tblStratumSize_Test
(
StratumID       BIGINT,
StratumPerc     DOUBLE PRECISION,
StratumSize     BIGINT
);

---- Case 3a: Extraneous StratumID
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a
UNION ALL
SELECT  a.StratumID + 5,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs


---- Case 3b: Missing StratumID
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a
WHERE   a.StratumID <= 3;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs (only StratumID's 1, 2, 3 are returned)


---- Case 3c: Artificially increase tblStratumSize.StratumSize
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize + 5
FROM    tblStratumSize a;

---- Case 3c1: WithReplacement = 0
Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs (tblStratumSize.StratumSize is not used in this function)


---- Case 3d: Artificially decrease tblStratumSize.StratumSize
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize - 5
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs (tblStratumSize.StratumSize is not used in this function)


---- Case 3e: Artificially increase tblStratumSize.StratumPerc
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc * 5,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs (stratum size of the output is limited to stratum size of tblPopulation)


---- Case 3f: Artificially decrease tblStratumSize.StratumPerc
DELETE FROM tblStratumSize_Test;

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc * 0.5,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard output (stratum size of the output is limited to tblStratumSize.StratumPerc * count of stratum size in tblPopulation)


-- Cleanup Case 3
DROP TABLE tblStratumSize_Test;


---- Case 4: mess with schema of tblStratumSize

---- Case 4a: mismatch the column name of tblStratumSize.StratumID vs. tblPopulation.StratumID
-- Initialization
DROP TABLE tblStratumSize_Test;

CREATE TABLE tblStratumSize_Test
(
StratumID_Test      BIGINT,
StratumPerc         DOUBLE PRECISION,
StratumSize         BIGINT
);

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: syntax error

-- Cleanup Case 4a
DROP TABLE tblStratumSize_Test;



---- Case 4b: mismatch the column name of tblStratumSize.StratumSize <> "StratumSize"
-- Initialization
DROP TABLE tblStratumSize_Test;

CREATE TABLE tblStratumSize_Test
(
StratumID           BIGINT,
StratumPerc         DOUBLE PRECISION,
StratumSize_Test    BIGINT
);

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: standard outputs (tblStratumSize.StratumSize is not used in this function)

-- Cleanup Case 4b
DROP TABLE tblStratumSize_Test;


---- Case 4c: mismatch the column name of tblStratumSize.StratumPerc <> "StratumPerc"
-- Initialization
DROP TABLE tblStratumSize_Test;

CREATE TABLE tblStratumSize_Test
(
StratumID           BIGINT,
StratumPerc_Test    DOUBLE PRECISION,
StratumSize         BIGINT
);

INSERT INTO tblStratumSize_Test
SELECT  a.StratumID,
        a.StratumPerc,
        a.StratumSize
FROM    tblStratumSize a;

Drop Table OutTable;
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize_Test',
                               2,
                              'StratPerc Test');
-- Result: syntax error

-- Cleanup Case 4c
DROP TABLE tblStratumSize_Test;


-- END: NEGATIVE TEST(s)


-- BEGIN: POSITIVE TEST(s)

---- Case 1: without replacement
CALL SP_SurveySelectStratPerc('tblPopulation', 
                              'ObsID', 
                              'StratumID', 
							  'OutTable',
                              'tblStratumSize',
                               2,
                              'StratPerc Test');
-- Result: standard outputs

-- END: POSITIVE TEST(s)

-- END: TEST SCRIPT
