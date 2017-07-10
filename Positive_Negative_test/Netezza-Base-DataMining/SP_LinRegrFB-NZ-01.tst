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
--	Test Unit Number:	SP_LinRegrFB-NZ-01
--
--	Name(s):		SP_LinRegrFB
--
-- 	Description:	    	Stored Procedure which performs  FastBackward Linear Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		SP_LinRegrFB(IN   TableName VARCHAR(100), 
--                            IN   SpecID        VARCHAR(30),
--                            IN   HighestpAllow1 DOUBLE PRECISION ,
--                            IN   HighestpAllow2 DOUBLE PRECISION ,
--                            IN   Note      VARCHAR(255)) 
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(64)
--
--	Last Updated:	    	07-10-2017
--
--	Author:			<gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,<kamlesh.meena@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

------ Table used for regression
--SELECT  a.VarID,
--        COUNT(*)
--FROM    tblLinRegr a
--GROUP BY a.VarID
--ORDER BY 1;

CREATE TABLE tblLinRegrTest (
ObsID       BIGINT,
VarID       INTEGER,
Value       DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

---Case 1a
--- Incorrect table name
EXEC SP_LinRegrFB('tblLinRegr_NotExist','', 0.50, 0.10, 'HelloWorld' );
---Case 1b
--- NULL table name
EXEC SP_LinRegrFB(NULL,'', 0.50, 0.10, 'HelloWorld' );
---Case 1c
--- Empty string as  table name
EXEC SP_LinRegrFB('','', 0.50, 0.10, 'HelloWorld' );

---Case 2a
---- No data in table
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

---Case 3
---- Populate data in table
INSERT INTO tblLinRegrTest
SELECT a.*
FROM   tblLinRegr a;

---- Incorrect column names
---Case 3a
--Not Applicable for Netezza.

--Case4a 
---Incorrect Values for Highest Prob1 allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', -0.50, 0.10, 'HelloWorld' );

--Case4b 
---Incorrect Values for Highest Prob1 allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 1.50, 0.10, 'HelloWorld' );

--Case4c 
---Incorrect Values for Highest Prob allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 0, 0.10, 'HelloWorld' );
--Case4d 
---Incorrect Values for Highest Prob allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 1.0, 0.10, 'HelloWorld' );

--Case5a 
---Incorrect Values for Highest Prob2 allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, -0.10, 'HelloWorld' );

--Case5b 
---Incorrect Values for Highest Prob2 allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 10.10, 'HelloWorld' );

--Case5c 
---Incorrect Values for Highest Prob2 allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0, 'HelloWorld' );

--Case5d 
---Incorrect Values for Highest Prob allowed
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 1.0, 'HelloWorld' );

--Case 6a
---- Insert data without the intercept and dependent variable
DELETE FROM tblLinRegrTest ALL;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0;

---- No dependent variable in table
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

---Case 7a
---- Insert dependent variable only for some obs
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;


---- No dependent variable for all observations
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 8a
---- Insert intercept variable only for some obs
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> 0;

INSERT INTO tblLinRegrTest
SELECT  *
FROM    tblLinRegr a
WHERE   a.VarID = 0
AND     a.ObsID <= 10000;

---- No intercept variable for all observations
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 9a
---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLinRegrTest
WHERE VarCol= 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        2
FROM    tblLinRegr a
WHERE   a.VarID = 0;

---- Intercept not 0 or 1
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 9aa
---- Cleanup the intercept and insert  1 and 0  for intercept
DELETE FROM tblLinRegrTest
WHERE VarCol= 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 500 THEN 0 ELSE 1 END
FROM    tblLinRegr a
WHERE   a.VarID = 0;

---- Intercept  value not unique
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 10a
---- Cleanup the table
DELETE FROM tblLinRegrTest ;

---- Populate less rows than variables
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

---Case 11 a
---- Cleanup the table and populate the data
DELETE FROM tblLinRegrTest ;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a;

--- Repeat a row in the table
INSERT INTO tblLinRegrTest
SELECT  a.ObsCol,
        a.VarCol,
        a.NumVal
FROM    tblLinRegrTest a
WHERE   a.VarCol = 10
AND     a.ObsCol = 26;

---- Repeated data in table
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 12a
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest ;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID * 2,
        a.Num_Val
FROM    tblLinRegr a
WHERE   a.VarID > 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);


---- Non consecutive variable IDs 
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.10, 'HelloWorld' );

--Case 13 a
--Insert  in fzzllinregrmodelvarspec all varids that are in the intable
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE VARID <= 10;

DELETE FROM fzzllinregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');

INSERT INTO  fzzllinregrmodelvarspec 
SELECT  'GSENTEST' , a.VarID, 'I' 
FROM ( SELECT DISTINCT VarID
                  FROM tblLinRegrTest ) a; 
                

--All varids included
EXEC SP_LinRegrFB('tblLinRegrTest','GSENTEST', 0.50, 0.10, 'HelloWorld' );

--Case 14a
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE VARID <= 10;

DELETE FROM fzzllinregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');

INSERT INTO  fzzllinregrmodelvarspec 
SELECT  'GSENTEST' , a.VarID, 'X' 
FROM ( SELECT DISTINCT VarID
                  FROM tblLinRegrTest ) a; 
                
--All varids  excluded 
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--CASE 1  PROGRAM STALLS FOR LARGE DATA...JOIN PERFORMANCE NEEDS REVIEW...for now max allowable VarID is set it to varid < =100  for dense dataset
--Case 1
---- Cleanup the data and populate again
DELETE FROM tblLinRegrTest ;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE VarID <=10;

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tblLinRegrTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with non-sparse data
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1,2,3;

--case 2
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tblLinRegrTest AS a
GROUP BY 1
ORDER BY 1;
        
---- Perform regression with sparse data
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--case 3
---Case 3a
--- Cleanup the data and populate again with intercept value as 0
---JIRA TDFL-464 raised 
--gives error in matrix inversion 

DELETE FROM tblLinRegrTest ;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE  VarID  <> 0 ;

INSERT INTO tblLinRegrTest
SELECT  a. ObsID,
                  a.VarID,
               0
FROM    tblLinRegr a 
WHERE  VarID  = 0 ;

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tblLinRegrTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with intercept all 0s
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );
--error Inverting matrix
---JIRA TDFL -464 ..it's a RFC

---Case 3b
--- Cleanup the data and populate again with intercept value as 1
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE  VarID  <> 0 
AND VarID <= 20 ;

INSERT INTO tblLinRegrTest
SELECT  a. ObsID,
                  a.VarID,
                 1
FROM    tblLinRegr a 
WHERE  VarID  = 0 ;

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tblLinRegrTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with intercept value all 1s
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--Case 4 
--Cross database access test case
---- Drop and recreate the test table in another database 
DROP TABLE tblLinRegrTest;

CREATE TABLE tblLinRegrTest (
ObsID       BIGINT,
VarID       INTEGER,
Value       DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0
AND VarID <=20
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
EXEC SP_LinRegrFB('tblLinRegrTest','', 0.50, 0.1, 'HelloWorld' );

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

--case 5
--run a test on sparse dataset with speciD 
DELETE FROM fzzllinregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');

INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,9, 'I') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,10, 'I') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,13 , 'I') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,185, 'I') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,100, 'I') ;

INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,19, 'X') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,110, 'X') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,18 , 'X') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,105, 'X') ;
INSERT INTO  fzzllinregrmodelvarspec VALUES ('GSENTEST' ,26, 'X') ;

DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

--Test with SpecID
EXEC SP_LinRegrFB('tblLinRegrTest','GSENTEST', 0.50, 0.1, 'HelloWorld' );

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

--Delete the specid used for testing
DELETE FROM fzzllinregrmodelvarspec WHERE UPPER(SpecID) = UPPER('GSENTEST');

---DROP the test table
DROP TABLE tblLinRegrTest; 
DROP TABLE tblLinRegrTest;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
