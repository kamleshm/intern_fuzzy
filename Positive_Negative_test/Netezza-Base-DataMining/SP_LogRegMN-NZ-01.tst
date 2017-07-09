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
--	Test Unit Number:	SP_LogRegrMN-NZ-01
--
--	Name(s):		SP_LogRegrMN
--
-- 	Description:	    	Stored Procedure which performs Multinomial Logistic Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		SP_LogRegrMN(IN   TableName     VARCHAR(100), 
--                                        IN   RefLevel      INTEGER , 
--                                        IN   MaxIterations INTEGER,
--                                        IN   Note          VARCHAR(255)) 
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(30)
--
--	Last Updated:	    	01-20-2015
--
--	Author:			<gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

----(OPTIONAL) Check Table used for regression
--SELECT  a.VarID,
--        COUNT(*)
--FROM    tblLogRegrMN10000 a
--GROUP BY a.VarID
--ORDER BY 1;

CREATE TABLE tblLogRegrMNTest (
ObsID        BIGINT,
VarID        INTEGER,
Value        DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case1---- Incorrect table name
CALL SP_LogRegrMN('tblLogRegrNotExist', 3, 25,'Test');
CALL SP_LogRegrMN('', 3, 25,'Test');
CALL SP_LogRegrMN(NULL, 3, 25,'Test');

--Case 2 Incorrect column names and parameter values ---

---- Populate data in table
INSERT INTO tblLogRegrMNTest
SELECT a.*
FROM   tblLogRegrMN10000 a;

--Case 2a ---- Incorrect column names
--Not applicable for Netezza

--Case 2b ---- Invalid parameter values
--Param5
CALL SP_LogRegrMN('tblLogRegrMNTest', NULL, 25,'Test');
CALL SP_LogRegrMN('tblLogRegrMNTest', -13, 25,'Test');
CALL SP_LogRegrMN('tblLogRegrMNTest', 0, 25,'Test');
CALL SP_LogRegrMN('tblLogRegrMNTest', 5, 25,'Test');

--2bb
--Check whether there are other values for the dependent variable other than that of Reference level
DELETE FROM  tblLogRegrMNTest 
WHERE VARID = -1;

INSERT INTO tblLogRegrMNTest
SELECT  a.ObsID,
        a.VarID,
        3
FROM    tblLogRegrMN10000 a
WHERE   a.VarID = -1;

CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 2c
DELETE FROM  tblLogRegrMNTest;

INSERT INTO tblLogRegrMNTest
SELECT a.*
FROM   tblLogRegrMN10000 a;

--Param 6
--MaxIter < 0
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, -25,'Test');
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 0,'Test');
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, NULL,'Test');

--Case3 
---- No data in table
DELETE FROM tblLogRegrMNTest ;
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 4 
--Invalid Dependent variable--

--Case 4a :
---- No dependent variable in table
---- Insert data without the intercept and dependent variable
INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID > 0;

---- No dependent variable in table
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 4b 
---- No dependent variable for all observations
---- Insert dependent variable only for some obs
INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID = -1
AND     a.ObsID <= 1000;

---- No dependent variable for all observations
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 5 
---Invalid Intercept values

--Case 5a 
---- No intercept variable for all observations
DELETE FROM tblLogRegrMNTest;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID <> 0;

INSERT INTO tblLogRegrMNTest
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 500 THEN 0 ELSE 1 END
FROM    tblLogRegrMN10000 a
WHERE   a.VarID = 0
AND     a.ObsID <= 1000;

---- Non distinct values for intercept
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case5b: Intercept not 0 or 1

---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLogRegrMNTest
WHERE VarID = 0;

INSERT INTO tblLogRegrMNTest
SELECT  a.ObsID,
        a.VarID,
        2
FROM    tblLogRegrMN10000 a
WHERE   a.VarID = 0;

---- Intercept not 0 or 1
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 6
--- Number of observations <= number of variables
---- Cleanup the table
DELETE FROM tblLogRegrMNTest ;

---- Populate less rows than variables
INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.ObsID <= 10;

---- Number of observations <= number of variables
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case10 
---- Repeated data in table
---- Cleanup the table and populate the data
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a;

--- Repeat a row in the table
INSERT INTO tblLogRegrMNTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLogRegrMNTest a
WHERE  a.VarID = 9
AND a.ObsID =10;

---- Repeated data in table
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 11
---- Non consecutive variable IDs 
---- Cleanup the table and populate
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.ObsID,
        a.VarID * 2,
        a.Num_Val
FROM    tblLogRegrMN10000 a
WHERE   a.VariD > 0
UNION ALL
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID IN (-1, 0);

---- Non consecutive variable IDs 
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

--Case 12 
--- small num of iteration
---- Cleanup the table and populate
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a;

----really small num of iteration 
CALL SP_LogRegrMN('tblLogRegrMNTest',3,1,'Test');

--Case  14 
---- Cleanup the table and populate
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT a.*
FROM tblLogRegrMN10000 a ;

INSERT INTO tblLogRegrMNTest
SELECT a.*
FROM tblLogRegrMN10000 AS a
WHERE a.ObsID IN (SELECT ObsID 
                                     FROM tblLogRegrMN10000 
                                     WHERE VarID = -1
                                     AND Num_Val < 3);

----repeated Observation 
CALL SP_LogRegrMN('tblLogRegrMNTest', 1, 25,'Test');

--- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case 1 
---- Perform regression with non-sparse data
---- Cleanup the data and populate again
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a;

---- Perform regression with non-sparse data
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

-- Display result
SELECT  a.*
FROM    fzzlLogRegrMNStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrMNCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY  1, 2,3,4;

--Case 2:
---- Perform regression with sparse data
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID > 0
AND    a.VarID  <= 10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

-- Display result
SELECT  a.*
FROM    fzzlLogRegrMNStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrMNCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY  1, 2,3,4;

--Case 3 
--Perform regression with sparse data and large number of variables

---- Cleanup the data and populate again, make the data sparse i.e., non-zero values
---- for all variables except dependent and intercept
DELETE FROM tblLogRegrMNTest ;

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data and large number of variables
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');


-- Display result
SELECT  a.*
FROM    fzzlLogRegrMNStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrMNCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY  1, 2,3,4;

--case 4
--Cross database access test case
---- Drop and recreate the test table in another database 
DROP TABLE tblLogRegrMNTest;

CREATE TABLE tblLogRegrMNTest (
ObsID       BIGINT,
VarID      INTEGER,
Value      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

INSERT INTO tblLogRegrMNTest
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegrMN10000 a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with non-sparse data
CALL SP_LogRegrMN('tblLogRegrMNTest', 3, 25,'Test');

-- Display result
SELECT  a.*
FROM    fzzlLogRegrMNStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLogRegrMNCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLogRegrMNInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3,4 ;

---DROP the test table
DROP TABLE tblLogRegrMNTest; 
DROP TABLE tblLogRegrMNTest;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
