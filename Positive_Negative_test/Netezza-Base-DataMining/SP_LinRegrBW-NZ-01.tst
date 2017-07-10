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
--	Test Unit Number:	SP_LinRegrBW-NZ-01
--
--	Name(s):		SP_LinRegrBW
--
-- 	Description:	    	Stored Procedure which performs  Backward Linear Regression and stores the results in predefined tables.
--
--	Applications:	    	
--
-- 	Signature:		SP_LinRegrBW(IN   TableName VARCHAR(100), 
--                            IN   SpecID        VARCHAR(30),
--                            IN   HighestpAllow DOUBLE PRECISION ,
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
--       COUNT(*)
--FROM    tblLinRegr a
--GROUP BY a.VarID
--ORDER BY 1;

DROP TABLE tblLinRegrTest IF EXISTS;
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
EXEC SP_LinRegrBW('tblLinRegr_NotExist','',0.1,'HelloWorld');

--Case 1b
--- NULL table name
EXEC SP_LinRegrBW(NULL,'',0.1,'HelloWorld');

--Case 1c
--- Empty string as  table name
EXEC SP_LinRegrBW('','',0.1,'HelloWorld');

---Case 2a
---- No data in table
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

---Case 3
---- Populate data in table
INSERT INTO tblLinRegrTest
SELECT a.*
FROM   tblLinRegr a;

---- Incorrect column names
---Case 3
--Not applicable for Netezza

--Case4
--Param 6
---Incorrect Values for Highest Prob allowed
EXEC SP_LinRegrBW('tblLinRegrTest','',-0.10,'HelloWorld');
EXEC SP_LinRegrBW('tblLinRegrTest','',1.1,'HelloWorld');
EXEC SP_LinRegrBW('tblLinRegrTest','',0,'HelloWorld');
EXEC SP_LinRegrBW('tblLinRegrTest','',NULL,'HelloWorld');

--Case 5a
---- Insert data without the intercept and dependent variable
DELETE FROM tblLinRegrTest; 

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> -1;

---- No dependent variable in table
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

---Case 6a
---- Insert dependent variable only for some obs
INSERT INTO tblLinRegrTest
SELECT a. ObsID -1,
                 a.VarID,
                 a.Value
FROM tblLinRegr a
WHERE   a.VarID = -1;

--- No dependent variable for all observations
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 7a
---- Insert intercept variable only for some obs
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> 0;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID = 0
AND     a.ObsID <= 10000;

---- No intercept variable for all observations
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 8a
---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLinRegrTest
WHERE VarID = 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        2
FROM    tblLinRegr a
WHERE   a.VarID = 0;

---- Intercept not 0 or 1
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--8 a (i)
---- Cleanup the intercept and insert values 1 and 0 for the intercept value
DELETE FROM tblLinRegrTest
WHERE VarID= 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN ObsID <= 100 THEN 1 ELSE 0 END
FROM    tblLinRegr a
WHERE   a.VarID = 0;

---- Intercept  value not  unique
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 9a
---- Cleanup the table
DELETE FROM tblLinRegrTest;

---- Populate less rows than variables
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

---Case 10 a
---- Cleanup the table and populate the data
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a;

--- Repeat a row in the table
INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLinRegrTest a
WHERE   a.VarID = 10
AND     a.ObsID = 26;

---- Repeated data in table
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 11a
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID * 2,
        a.Value
FROM    tblLinRegr a
WHERE   a.VarID > 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

---- Non consecutive variable IDs 
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 12
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLinRegr a
WHERE   a.VarID >= 0
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Value END
FROM    tblLinRegr a
WHERE   a.VarID = -1
AND VarID < 10
AND ObsID < 200 ;

---dependent variables have NULLS
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 13
---- Cleanup the table and populate(
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> -1;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
       2
FROM    tblLinRegr a
WHERE   a.VarID = -1;

--dependednt variable has same value 
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 14
---- Cleanup the table and populate
--collinearity
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE VarID <= 5;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
                 b.VarCol + 1,
                 a.Value
FROM    tblLinRegr a,
              (SELECT Max(VarID) AS VarCol
               FROM tblLinRegrTest
               ) AS b
WHERE VarID = 1;

select VarID, count( *) from tblLinRegrTest group by 1 order by 1;

---singular matrix
EXEC SP_LinRegrBW('tblLinRegrTest',NULL,0.1,'HelloWorld');
--ERROR: TDSQLException:007504:in UDF/XSP/UDM fuzzylogix.FLMatrixInvUdt: SQLSTATE U0009: Error Inverting Matrix.
--RFC..will be handled after the GA

--Case 15
---- Cleanup the table and populate 
DELETE FROM tblLinRegrTest ;

INSERT INTO tblLinRegrTest
SELECT a.* 
FROM    tblLinRegr a
WHERE   a.VarID  <> -1; 
INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        NULL
FROM    tblLinRegr a
WHERE   a.VarID  = -1;

--Dependent variables all NULLS 
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 16
---- Cleanup the table and populate 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT a.* 
FROM    tblLinRegr a
WHERE   a.VarID  <> 0; 
INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        NULL
FROM    tblLinRegr a
WHERE   a.VarID  = 0;

--intercept variables all NULLS 
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 17
---- Cleanup the table and populate 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT a.* 
FROM    tblLinRegr a
WHERE   a.VarID  < 1; 

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        NULL
FROM    tblLinRegr a
WHERE   a.VarID  > 0;

--InDependent variable values all NULLS 
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

---Case 18
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLinRegr a
WHERE   a.VarID <> 0
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Value END
FROM    tblLinRegr a
WHERE   a.VarID = 0
AND VarID < 10
AND ObsID < 200;

---some intercept value as NULL
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 19
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.Value
FROM    tblLinRegr a
WHERE   a.VarID <> 1
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Value END
FROM    tblLinRegr a
WHERE   a.VarID = 1
AND VarID < 10
AND ObsID < 200;

--one variable has NULLS
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 20 
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> -1;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        CASE WHEN ObsID < 100 THEN NULL ELSE VarID END,
        Value
FROM    tblLinRegr a
WHERE   a.VarID = -1;

--some dependent variables are NULLs
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');


--Case 21
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        CASE WHEN ObsID < 100 THEN NULL ELSE VarID END,
        Value
FROM    tblLinRegr a
WHERE   a.VarID = 0;

--some intercept as NULLS
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 22
---- Cleanup the table and populate(DOUBT) 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID < 1 ;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        CASE WHEN ObsID = 61 AND VarID = 1 THEN NULL ELSE VarID END,
        Value
FROM    tblLinRegr a
WHERE   a.VarID > 0;

--independent varid as NULL
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 23
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> -1;

INSERT INTO tblLinRegrTest
SELECT  CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
                  Value
FROM    tblLinRegr a
WHERE   a.VarID = -1;

---ObsID as NULL for dependent variable
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 24
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID < 1 ;

INSERT INTO tblLinRegrTest
SELECT  CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
        Value
FROM    tblLinRegr a
WHERE   a.VarID > 0;

--ObsID NULL for independent variableID
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

--Case 25
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
EXEC SP_LinRegrBW('tblLinRegrTest','GSENTEST',0.1,'HelloWorld');
--get Double() :  NULL field

--Case 26
--Insert  in fzzllinregrmodelvarspec all varids that are in the intable
---- Cleanup the table and populate
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
EXEC SP_LinRegrBW('tblLinRegrTest','GSENTEST',0.1,'HelloWorld');
--get Double() :  NULL field

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------


--CASE 1  PROGRAM STALLS FOR LARGE DATA...JOIN PERFORMANCE NEEDS REVIEW...for now max allowable VarID is set it to varid < =100  for dense dataset
--Case 1
---- Cleanup the data and populate again
DELETE FROM tblLinRegrTest;

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
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;


--Case 2
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0
AND a.VarID <= 10
AND     a.Value <> 0
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
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

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

---Case 3
--- Cleanup the data and populate again with intercept value as 0
---JIRA TDFL-464 raised 
--gives error in matrix inversion 
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE  VarID  <> 0 
AND VarID <= 10;

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

---- Perform regression with intercept value all 0s
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');
--error Inverting matrix
---JIRA TDFL -464 ..it's a RFC

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
        SELECT a.AnalysisID
        FROM    fzzlLinRegrInfo a
        WHERE Note='HelloWorld'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;


---Case 4
--- Cleanup the data and populate again with intercept value as 1
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a 
WHERE  VarID  <> 0 
AND VarID <= 10 ;

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
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

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

-----Case  5
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
AND a.VarID <=10
AND     a.Value <> 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tblLinRegrTest  AS a
GROUP BY 1
ORDER BY 1;


---- Perform regression with sparse data with a SpecID
EXEC SP_LinRegrBW('tblLinRegrTest','',0.1,'HelloWorld');

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

---case 6
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
AND a.VarID <=10
AND     a.Value <> 0
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
EXEC SP_LinRegrBW('tblLinRegrTest','GSENTEST',0.1,'HelloWorld');

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

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
