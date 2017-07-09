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
--	Test Unit Number:	SP_LogRegrSW-NZ-01
--
--	Name(s):		SP_LogRegrSW
--
-- 	Description:	    	Stored Procedure which performs Stepwise Logistic Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		SP_LogRegrSW(IN   TableName     VARCHAR(100),
--                                        IN   FalsePosNegThreshold DOUBLE PRECISION,
--                                        IN   MaxIterations        INTEGER, 
--                                        IN   SpecID               VARCHAR(25),
--                                        IN   TopN                 INTEGER,
--                                        IN   MaxpValueAllowed     DOUBLE PRECISION ,
--                                        IN   Note          VARCHAR(255)) 
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(30)
--
--	Last Updated:	    	01-20-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

----(OPTIONAL) Check Table used for regression
--SELECT  a.VarID,
--        COUNT(*)
--FROM    tblLogRegr a
--GROUP BY a.VarID
--ORDER BY 1;

CREATE TABLE tblLogRegrTest (
ObsID       BIGINT,
VarID       INTEGER,
Value       DOUBLE PRECISION)
DISTRIBUTE ON (ObsID);


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case1---- Incorrect table name
CALL SP_LogRegrSW('tblLogRegrNotExist', 0.10, 25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW('', 0.10, 25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW(NULL, 0.10, 25,3, '', 0.1,'Test');

--Case 2 Incorrect column names and parameter values ---

---- Populate data in table
INSERT INTO tblLogRegrTest
SELECT a.*
FROM   tblLogRegr a;

--Case 2a ---- Incorrect column names
--Param2
--Not Applicable for Netezza

--Case 2b ---- Invalid parameter values
--Param 5
CALL SP_LogRegrSW('tblLogRegrTest', -0.10, 25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 10.10, 25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0, 25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 1, 25, '', 3, 0.1,'Test');
--param 6
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, -25, '', 3, 0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 0, '', 3, 0.1,'Test');
--param8
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', -3, 0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 13, 0.1,'Test');
--param 9
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, -0.1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 1,'Test');
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 10.1,'Test');

--Case3 ---- No data in table
DELETE FROM tblLogRegrTest;
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');

--Case 4 --Invalid Dependent variable--

--Case 4a : ---- No dependent variable in table
---- Insert data without the intercept and dependent variable
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > 0;

---- No dependent variable in table
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 4b ---- No dependent variable for all observations
---- Insert dependent variable only for some obs
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;

---- No dependent variable for all observations
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 5 Invalid Intercept values---

--Case 5a ---- No intercept variable for all observations
DELETE FROM tblLogRegrTest;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID <> 0;

INSERT INTO tblLogRegrTest
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 500 THEN 0 ELSE 1 END
FROM    tblLogRegr a
WHERE   a.VarID = 0
AND     a.ObsID <= 10000;

---- Non distinct values for intercept
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case5b: Intercept not 0 or 1

---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLogRegrTest
WHERE VarID = 0;

INSERT INTO tblLogRegrTest
SELECT  a.ObsID,
        a.VarID,
        2
FROM    tblLogRegr a
WHERE   a.VarID = 0;

---- Intercept not 0 or 1
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 6 ---- Dependent variable not 0 or 1
---- Cleanup the table
DELETE FROM tblLogRegrTest ;

---- Populate the table with dependent variable other than 0 and 1
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > -1
UNION ALL
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 10000 THEN a.Num_Val ELSE 2 END
FROM    tblLogRegr a
WHERE   a.VarID = -1;

---- Dependent variable not 0 or 1
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 7--Dependent variable all 0's
---- Delete the dependent variable
DELETE FROM tblLogRegrTest
WHERE VarID = -1;

---- Populate all 0's for the dependent variable
INSERT INTO tblLogRegrTest
SELECT a.ObsID,
       a.VarID,
       0
FROM   tblLogRegr a
WHERE  a.VarID = -1;

---- Dependent variable all 0's
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
---Case 8 ---- Dependent variable all 1's

---- Delete the dependent variable
DELETE FROM tblLogRegrTest
WHERE VarID = -1;

---- Populate all 0's for the dependent variable
INSERT INTO tblLogRegrTest
SELECT a.ObsID,
       a.VarID,
       1
FROM   tblLogRegr a
WHERE  a.VarID = -1;

---- Dependent variable all 1's
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 9---- Number of observations <= number of variables

---- Cleanup the table
DELETE FROM tblLogRegrTest ;

---- Populate less rows than variables
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case10 ---- Repeated data in table

---- Cleanup the table and populate the data
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a;

--- Repeat a row in the table
INSERT INTO tblLogRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLogRegrTest a
WHERE  a.VarID = 27
 AND a.ObsID = 26;

---- Repeated data in table
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 11---- Non consecutive variable IDs 

---- Cleanup the table and populate
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.ObsID,
        a.VarID * 2,
        a.Num_Val
FROM    tblLogRegr a
WHERE   a.VariD > 0
UNION ALL
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID IN (-1, 0);

---- Non consecutive variable IDs 
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
--Case 12
---- Cleanup the table and populate
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a 
WHERE VARID <= 5;

--small itearation
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 1, '', 3, 0.1,'Test');

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case 1 ---- Perform regression 
---- Cleanup the data and populate again
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID <= 5;

---- Perform regression 
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
-- Display result
SELECT  a.*
FROM    fzzlLogRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1,2,3;


--Case 2:---- Perform regression with sparse data

---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > 0
AND     a.VarID <= 5
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
CALL SP_LogRegrSW('tblLogRegrTest', 0.10, 25, '', 3, 0.1,'Test');
-- Display result
SELECT  a.*
FROM    fzzlLogRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1,2,3;


---DROP the test table
DROP TABLE tblLogRegrTest;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
