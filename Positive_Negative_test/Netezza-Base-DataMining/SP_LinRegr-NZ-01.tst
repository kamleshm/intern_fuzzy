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
--	Test Unit Number:	SP_LinRegr-NZ-01
--
--	Name(s):		SP_LinRegr
--
-- 	Description:	    	Stored Procedure which performs Linear Regression and stores the results in predefined tables.
--
--	Applications:	    	Linear regressions can be used in business to evaluate trends and make estimates or forecasts.
--
-- 	Signature:		SP_LinRegr(IN   TableName VARCHAR(100), 
--                            IN   SpecID  	 VARCHAR(30),
--                            IN   Note      VARCHAR(255)) 
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(64)
--
--	Last Updated:	    	01-19-2015
--
--	Author:			<gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,<kamlesh.meena@fuzzl.com>

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

---- Incorrect table name
EXEC SP_LinRegr('tblLinRegrTemp','','HelloWorld');
--Result:ERROR [42S02] ERROR:  relation does not exist RESEARCH_FENG.FBAI.TBLLINREGRTEMP

---- Populate data in table
INSERT INTO tblLinRegrTest
SELECT a.*
FROM   tblLinRegr a;

---- Incorrect column names
---- Not Applicable for Netezza

---- No data in table
DELETE FROM tblLinRegrTest;
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');
--Result:ERROR [HY000] ERROR:  record VREC is unassigned yet


---- Insert data without the intercept and dependent variable
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID > 0;

---- No dependent variable in table
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');


---- Insert dependent variable only for some obs
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;


---- No dependent variable for all observations
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

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
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

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
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

---- Cleanup the table
DELETE FROM tblLinRegrTest;

---- Populate less rows than variables
INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

---- Cleanup the table and populate the data
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a;

--- Repeat a row in the table
INSERT INTO tblLinRegrTest
SELECT  a.ObsID,
        a.VarID,
        a.NumVal
FROM    tblLinRegrTest a
WHERE   a.VarID = 10
AND     a.ObsID = 26;

---- Repeated data in table
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

---- Cleanup the table and populate
DELETE FROM tblLinRegrTest;

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
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------


---- Cleanup the data and populate again
DELETE FROM tblLinRegrTest;

INSERT INTO tblLinRegrTest
SELECT  a.*
FROM    tblLinRegr a;


---- Perform regression with non-sparse data
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');
--Note JIRA TDFL-116 raised as the SP stalls during execution at random.

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
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 3, 1, 2;

------ Drop and recreate the test table with column names different than that of usual FL deep table naming conventions
---- This test is a negative test case on Netezza
DROP TABLE tblLinRegrTest;

CREATE TABLE tblLinRegrTest (
ObsCol       BIGINT,
VarCol       INTEGER,
Val      DOUBLE PRECISION)
DISTRIBUTE ON(ObsCol);

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
EXEC SP_LinRegr('tblLinRegrTest','','HelloWorld');
--Result: ERROR [42S22] ERROR:  Attribute 'A.VARID' not found 

-- Display result
SELECT  a.*
FROM    fzzlLinRegrStats a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 1, 2, 3;

SELECT  a.*
FROM    fzzlLinRegrCoeffs a,
        (
        SELECT  a.AnalysisID
        FROM    fzzlLinRegrInfo a
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        ) b
WHERE   a.AnalysisID = b.AnalysisID
ORDER BY 3, 1, 2;

---DROP the test table
DROP TABLE tblLinRegrTest; 

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
