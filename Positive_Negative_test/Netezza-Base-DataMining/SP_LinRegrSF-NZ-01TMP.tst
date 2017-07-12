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
--	Test Unit Number:	SP_LinRegrSF-NZ-01
--
--	Name(s):		SP_LinRegrSF
--
-- 	Description:	    	Stored Procedure which performs Linear Regression and stores the results in predefined tables.
--
--	Applications:	    	Linear regressions can be used in business to evaluate trends and make estimates or forecasts.
--
-- 	Signature:		SP_LinRegrSF(IN   TableName VARCHAR(100), 
--                            IN   SpecID  VARCHAR(30),
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

--Case 1a
---- Incorrect table name
EXEC SP_LinRegrSF('tblLinRegrNotExist','','3gz6cpj81s1');
EXEC SP_LinRegrSF('','','3gz6cpj81s2');
EXEC SP_LinRegrSF(NULL,'','3gz6cpj81s3');

---- Populate data in table
INSERT INTO tblLinRegrTest
SELECT a.*
FROM   tblLinRegr a;

--Case2
---- Incorrect column names
--Not Applicable for Netezza

--Case 3
---- No data in table
DELETE FROM tblLinRegrTest ALL;
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s4');

---Case 4
--- Insert data without the intercept and dependent variable
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID> 0;

---- No dependent variable in table
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s5');

--Case 4
---- Insert dependent variable only for some obs
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;

---- No dependent variable for all observations
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s6');

--case 5
---- Insert intercept variable only for some obs
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID <> 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN a.ObsID <= 500 THEN 0 ELSE 1 END
FROM    tblLinRegr a
WHERE   a.VarID = 0
AND     a.ObsID <= 10000;

---- No intercept variable for all observations
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s7');

--Case 6
---- Cleanup the intercept and insert the value 2 for intercept
DELETE FROM tblLinRegrTest
WHERE VarCol = 0;

INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        2
FROM    tblLinRegr a
WHERE   a.VarID= 0;

---- Intercept not 0 or 1
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s8');

--Case 7
---- Cleanup the table
DELETE FROM tblLinRegrTest;

---- Populate less rows than variables
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s9');

---Case 8
---- Cleanup the table and populate the data
DELETE FROM tblLinRegrTest;

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
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s10');

--case 9
---- Cleanup the table and populate
DELETE FROM tblLinRegrTest ALL;

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

--case 10
---- Non consecutive variable IDs 
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s11');

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

--Case 1
---- Cleanup the data and populate again
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a;

---- Perform regression with non-sparse data
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s12');

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s12'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s12'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2,3;

--Case 2
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
        
---- Perform regression with sparse data
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s13');

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s13'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s13'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY  1, 2,3;

--case 3
--Cross database test case
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
AND a.VarID <=20
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
EXEC SP_LinRegrSF('tblLinRegrTest','','3gz6cpj81s14');

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s14'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
	WHERE Note='3gz6cpj81s14'
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

---DROP the test table
DROP TABLE tblLinRegrTest; 

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
