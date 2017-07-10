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
--	Test Unit Number:	FLLinRegrUdt-NZ-01
--
--	Name(s):		FLLinRegrUdt	
--
-- 	Description:	    	Stored Procedure which performs Linear Regression and stores the results in predefined tables.
--
--	Applications:	    	Linear regressions can be used in business to evaluate trends and make estimates or forecasts.
--
-- 	Signature:		FLLinRegrUdt(pGroupID INTEGER,
--					pObsID INTEGER,
--					pVarID INTEGER,
--					pValue DOUBLE PRECISION,
--					pReduceVars BYTEINT,
--					pThresholdStdDev DOUBLE PRECISION,
--					pThresholdCorrel DOUBLE PRECISION,
--					pBeginFlag INTEGER,
--					pEndFlag INTEGER)
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(64)
--
--	Last Updated:	    	07-10-2017
--
--	Author:			<kamlesh.meena@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time

DROP TABLE tbllinregrdatadeepTest IF EXISTS;
CREATE TABLE tbllinregrdatadeepTest (
GroupID BIGINT,
ObsID       BIGINT,
VarID       INTEGER,
Num_Val      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

---- BEGIN: NEGATIVE TEST(s)

---- Incorrect table name
--    Case 1a:
--Not applicable for Netezza

---- Populate data in table
INSERT INTO tbllinregrdatadeepTest
SELECT a.*
FROM   tbllinregrdatadeep a;

---- Incorrect column names
--    Case 2a:
 
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.Obs,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

--    Case 2b:
 
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.Var,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

--    Case 2c:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- No data in table
--    Case 3a:
DELETE FROM tbllinregrdatadeepTest;
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert data without the intercept and dependent variable
--    Case 4a:
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0;

---- No dependent variable in table
--    Case 4b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert dependent variable only for some obs
--    Case 5a:
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;

---- No dependent variable for all observations
--    Case 5b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert intercept variable only for some obs
--    Case 6a:
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
--    Case 6b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the intercept and insert the value 2 for intercept
--    Case 6a:
DELETE FROM tbllinregrdatadeepTest
WHERE VarID = 0;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,
		a.ObsID,
        a.VarID,
        2
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 0;

---- Intercept not 0 or 1
--    Case 6b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table
--    Case 7a:
DELETE FROM tbllinregrdatadeepTest;

---- Populate less rows than variables
--    Case 7b:
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
--    Case 7c:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table and populate the data
--    Case 8a:
DELETE FROM tbllinregrdatadeepTest;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a;

--- Repeat a row in the table
--    Case 8b:
INSERT INTO tbllinregrdatadeep
SELECT  a.GroupID,
		a.ObsID,
        a.VarID,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 10
AND     a.ObsID = 26;

---- Repeated data in table
--    Case 8b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table and populate
--    Case 9a:
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,
		a.ObsID,
        a.VarID * 2,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0
UNION ALL
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID IN (-1, 0);

---- Non consecutive variable IDs 
--    Case 9b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)

---- Cleanup the data and populate again
--    Case 1a:
DELETE FROM tblLinRegrTest;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a;

---- Perform regression with non-sparse data
--    Case 1b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: standard outputs

---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
--    Case 2a:
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
--    Case 2b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsID,z.VarID,z.Num_Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: standard outputs

------ Drop and recreate the test table with column names different than that of usual FL deep table naming conventions
--    Case 3a:
DROP TABLE tbllinregrdatadeepTest;
CREATE TABLE tbllinregrdatadeepTest (
GroupID 	BIGINT,
ObsCol       BIGINT,
VarCol       INTEGER,
Val      DOUBLE PRECISION)
DISTRIBUTE ON(ObsCol);

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID IN (-1, 0);

---- Perform regression with sparse data
--    Case 3b:
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsCol,
       a.VarCol,
       a.Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsCol), 1)
        AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsCol), 1)
        AS end_flag
FROM tbllinregrdatadeepTest a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID,z.ObsCol,z.VarCol,z.Val,1,0.05,0.95,z.begin_flag,z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: standard outputs

---DROP the test table
DROP TABLE tbllinregrdatadeepTest;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
