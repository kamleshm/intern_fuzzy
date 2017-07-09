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
-- 	Test Category:		Data Mining Functions
--
--	Test Unit Number:	FLLogRegrWt-TD-01
--
--	Name(s):		FLLogRegrWt
--
-- 	Description:	    	Stored Procedure which performs Logistic Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		FLCoxPH(IN   TableName     VARCHAR(100), 
--                                        IN   ObsIDCol      VARCHAR(100),
--                                        IN   VarIDCol      VARCHAR(100),
--                                        IN   ValueCol      VARCHAR(100), 
--                                        IN   MaxIterations INTEGER,
--                                        IN   Note          VARCHAR(255), 
--                                        OUT  AnalysisID    VARCHAR(30)) 
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(30)
--
--	Last Updated:	    	03-18-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

---- Drop and recreate the wide table
DROP TABLE tblCoxPHWide;

CREATE TABLE tblCoxPHWide 
AS
(SELECT  ID AS ObsID,
        time_AIDS_d AS TIME_VAL,
        censor AS STATUS,
        sex,
        ivdrug,
        tx
FROM    tblCoxPH) WITH DATA
PRIMARY INDEX (OBSID);

DROP TABLE tblCoxPHdeep;
CALL FLRegrDataPrep('tblCoxPHWide',-- wide tables
                    'ObsID',-- Name of the observation id Column
                    'TIME_VAL',-- Name of the dependent variable
                    'tblCoxPHdeep',-- Name of the Output Deep Table.
                    'ObsCol',
                    'VarCol',
                    'NumVal',
                    0,-- Transform Categorical to Dummy (t/f)
                    0,-- Perform Normalization
                    0,-- Perform Variable Reduction
                    0,-- Make data Sparse
                    0,-- Minimum acceptable Standard Deviation
                    1,-- Maximum Acceptable correlation
                    0, -- 0=>Training dataset, 1=>Test dataset
                    'Status',-- Columns to exclude from conversion
                    NULL,-- Class Specification
                    NULL,-- Where clause
                    NULL,-- Provided in case of a re-run, else NULL
                    AnalysisID);

INSERT INTO tblCoxPHdeep
SELECT ObsID, 
       -2 AS VarID, 
       Status AS Num_Val
FROM tblCoxPHWide;
                    
 ---- Drop and recreate the test table
DROP TABLE tblCoxPHTest;

CREATE MULTISET TABLE tblCoxPHTest (
ObsCol       BIGINT,
VarCol       INTEGER,
NumVal      DOUBLE PRECISION)
PRIMARY INDEX (ObsCol);



---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case1---- Incorrect table name

CALL FLCoxPH('tblCoxPHTestNotExist', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH('', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH(NULL, 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

--Case 2 Incorrect column names and parameter values ---

---- Populate data in table
INSERT INTO tblCoxPHTest
SELECT a.*
FROM   tblCoxPHDeep a;

--Case 2a ---- Incorrect column names
--Param2
CALL FLCoxPH('tblCoxPHTest', 'Obs', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', '', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', NULL, 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
--Param3
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'Var', 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', NULL, 'NumVal', 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', '', 'NumVal', 15, 'Test', AnalysisID);

--Param4
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumValue', 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol',NULL, 15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', '', 15, 'Test', AnalysisID);

--Case 2b ---- Invalid parameter values
--Param5
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', -15, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal',0, 'Test', AnalysisID);
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', NULL, 'Test', AnalysisID);

--Case3 ---- No data in table
DELETE FROM tblCoxPHTest ALL;
CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

----Case 4
--Test with no Dependent variable 
DELETE FROM  tblCoxPHTest ALL;

INSERT INTO tblCoxPHTest
SELECT ObsCol, VarCol, NumVal
FROM   tblCoxPHDeep
WHERE VarCol <> -1; 

CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

--case 5
---- Test with Censoring status not equal to 0 or 1
DELETE FROM tblCoxPHTest WHERE VarCol = -2;

INSERT INTO tblCoxPHTest
SELECT *
FROM   tblCoxPHDeep
WHERE VarCol <> -2; 

INSERT INTO tblCoxPHTest
SELECT ObsID,
        -2,
        STATUS + 1
FROM tblCoxPHWide;

CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

--case 6
---- Test with all censoring status are equal
------  all censoring status equals to 0

DELETE FROM tblCoxPHTest WHERE VarCol = -2;

INSERT INTO tblCoxPHTest
SELECT ObsID,
        -2,
        0
FROM tblCoxPHWide;

CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

--case 7
--all censoring status equals to 1
DELETE FROM tblCoxPHTest WHERE VarCol = -2;

INSERT INTO tblCoxPHTest
SELECT ObsID,
        -2,
        1
FROM tblCoxPHWide;

CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);

--case 8
---- Test with number of observations less than number of variables
REPLACE VIEW vwCoxPHTest AS
SELECT ObsCol, 
       VarCol, 
       NumVal
FROM   tblCoxPHDeep
WHERE ObsCol < 3
AND VarCol <> -2
UNION ALL
SELECT ObsCol, 
       VarCol, 
       CASE WHEN ObsCol = 1 THEN 1 ELSE 0 END AS NumVal
FROM   tblCoxPHDeep
WHERE ObsCol < 3
AND VarCol = -2;

CALL FLCoxPH('vwCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);


-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case 1 . with intercept
CALL FLCoxPH('tblCoxPHDeep', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);
-- expected  result :it should go through
--Goes through 
--check the results

SELECT  a.*
FROM     fzzlCoxPHStats a,
        (
        SELECT  TOP 1 a.AnalysisID
        FROM     fzzlCoxPHInfo a
        ORDER BY a.RunStartTime DESC
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM     fzzlCoxPHCoeffs a,
        (
        SELECT  TOP 1 a.AnalysisID
        FROM     fzzlCoxPHInfo a
        ORDER BY a.RunStartTime DESC
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

--Case 2
--Cross database access test case
---- Drop and recreate the test table in another database 
DROP TABLE tblCoxPHTest;

CREATE MULTISET TABLE  tblCoxPHTest (
ObsCol       BIGINT,
VarCol       INTEGER,
NumVal      DOUBLE PRECISION)
PRIMARY INDEX (ObsCol);

INSERT INTO  tblCoxPHTest
SELECT * 
FROM tblCoxPHDeep;

CALL FLCoxPH('tblCoxPHTest', 'ObsCol', 'VarCol', 'NumVal', 15, 'Test', AnalysisID);


---DROP the test table
DROP VIEW vwCoxPHTest;
DROP TABLE tblCoxPHDeep;
DROP TABLE tblCoxPHTest; 
DROP TABLE tblCoxPHWide;
-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
