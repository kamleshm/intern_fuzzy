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
--	Test Unit Number:	SP_LogRegrFB-NZ-01
--
--	Name(s):		SP_LogRegrFB
--
-- 	Description:	    	Stored Procedure which performs Logistic Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		FLLogRegrFB(IN   TableName     VARCHAR(100), 
--                                        IN   pThreshold    DOUBLE PRECISION ,
--                                        IN   MaxIterations INTEGER,
--                                        IN   SpecID        VARCHAR(30),
--                                        IN   HighestpAllow1 DOUBLE PRECISION ,
--                                        IN   HighestpAllow2 DOUBLE PRECISION ,
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
--FROM    tblLogRegr a
--GROUP BY a.VarID
--ORDER BY 1;


CREATE TABLE tblLogRegrTest (
ObsID       BIGINT,
VarID       INTEGER,
Value      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case1---- Incorrect table name
CALL SP_LogRegrFB('tblLogRegrNotExist', 0.10, 25, '', 0.50, 0.10,'Test');

--Case 2 Incorrect column names and parameter values ---

---- Populate data in table
INSERT INTO tblLogRegrTest
SELECT a.*
FROM   tblLogRegr a;

--Case 2a ---- Incorrect column names
--Not applicable for Netezza

--Case 2b ---- Invalid parameter values
--arg1
CALL SP_LogRegrFB('', 0.10, 25, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB(NULL, 0.10, 25, '', 0.50, 0.10,'Test');
--arg5
CALL SP_LogRegrFB('tblLogRegrTest', -0.10, 25, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 1.10, 25, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0, 10, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 1, 10, '', 0.50, 0.10,'Test');
--arg6
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 0, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, -10, '', 0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, NULL, '', 0.50, 0.10,'Test');
--arg8
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', -0.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 10.50, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0, 0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 1, 0.10,'Test');
--arg9
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, -0.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 10.10,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0,'Test');
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 1,'Test');

--Case3 ---- No data in table
DELETE FROM tblLogRegrTest ;
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');

--Case 4 --Invalid Dependent variable--

--Case 4a : ---- No dependent variable in table
---- Insert data without the intercept and dependent variable
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > 0;

---- No dependent variable in table
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
--Case 4b ---- No dependent variable for all observations
---- Insert dependent variable only for some obs
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;

---- No dependent variable for all observations
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
--Case 9---- Number of observations <= number of variables

---- Cleanup the table
DELETE FROM tblLogRegrTest ;

---- Populate less rows than variables
INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
--Case 12--- small itearation

---- Cleanup the table and populate
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT *
FROM    tblLogRegr a
WHERE   a.VariD <=5;

---- small iteration
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 1, '', 0.50, 0.10,'Test');

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------
---Case 3 commented out as it stalls..Needs Code Review

--Case 1 ---- Perform regression with non-sparse data
---- Cleanup the data and populate again
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID <= 10;

INSERT INTO tblLogRegrTest
SELECT  a.ObsID,
        b.VarID,
        0
FROM    (
        SELECT  DISTINCT a.ObsID
        FROM    tblLogRegrTest a
        WHERE   a.VarID = -1
        ) AS a,
        (
        SELECT  DISTINCT a.VarID
        FROM    tblLogRegrTest a
        WHERE   a.VarID > 0
        ) AS b
WHERE   NOT EXISTS (SELECT  1
                    FROM    tblLogRegrTest x
                    WHERE   x.ObsID = a.ObsID
                    AND     x.VarID = b.VarID);

---- Perform regression with non-sparse data
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
ORDER BY 1,2,3,4;

--Case 2
---- Perform regression with sparse data
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLogRegrTest ;

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > 0
AND     a.VarID <= 10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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
ORDER BY 1,2,3,4;

--case 3
--Cross database access test case
---- Drop and recreate the test table in another database 
DROP TABLE tblLogRegrTest;

CREATE MULTISET TABLE tblLogRegrTest (
ObsID       BIGINT,
VarID      INTEGER,
Value      DOUBLE PRECISION)
PRIMARY INDEX (ObsID);

INSERT INTO tblLogRegrTest
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID > 0
AND     a.VarID <= 10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegr a
WHERE   a.VarID IN (-1, 0);

SELECT VarID,
                 COUNT(*)
 FROM  tblLogRegrTest
 GROUP BY 1 
 ORDER BY 1;

---- Perform regression with sparse data 
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, '', 0.50, 0.10,'Test');
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

--case 4
--run a test on sparse dataset with speciD 
DELETE FROM fzzllogregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');

INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,9, 'I') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,10, 'I') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,13 , 'I') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,185, 'I') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,100, 'I') ;

INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,19, 'X') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,110, 'X') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,18 , 'X') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,105, 'X') ;
INSERT INTO  fzzllogregrmodelvarspec VALUES ('GSENTEST' ,26, 'X') ;


--perform regression
CALL SP_LogRegrFB('tblLogRegrTest', 0.10, 25, 'GSENTEST', 0.50, 0.10,'Test');

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
ORDER BY 1, 2,3;

---DROP the test table
DELETE FROM fzzllogregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');
DROP TABLE tblLogRegrTest; 
DROP TABLE tblLogRegrTest;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
