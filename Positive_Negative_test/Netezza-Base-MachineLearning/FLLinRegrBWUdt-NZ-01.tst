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
--      Test Category:          Data Mining Functions
--
--      Test Unit Number:       FLLinRegrBWUdt-NZ-01
--
--      Name(s):                FLLinRegrBWUdt
--
--      Description:            This is a user defined table function which performs linear regression using backward substitution of variables (backward linear regression). In backward linear regression, variables are eliminated one at a time till all the p-Values are lower than threshold p-Value specified by the user.
--
--      Applications:
--
--      Signature:            FLLinRegrBWUdt(pGroupID BIGINT,
--				pObsID BIGINT,
--				pVarID BIGINT,
--				pValue DOUBLE PRECISION,
--				pReduceVars BYTEINT,
--				pThresholdStdDev DOUBLE PRECISION,
--				pThresholdCorrel DOUBLE PRECISION,
--				pThresholdPValue DOUBLE PRECISION
--				pBeginFlag INTEGER,
--				pEndFlag INTEGER)
--
--      Parameters:             See Documentation
--
--      Return value:           TABLE
--
--      Last Updated:           07-10-2017

--
--      Author:                 <kamlesh.meena@fuzzylogix.com>

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

SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.Obs, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

--    Case 2b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.Var, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

--    Case 2c:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- No data in table
--    Case 3a:
DELETE FROM tbllinregrdatadeepTest;
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert data without the intercept and dependent variable
--    Case 4a:
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> -1;

---- No dependent variable in table
--    Case 4b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert dependent variable only for some obs
--    Case 5a:
INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID-1 as ObsID,a.VarID,a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID = -1
AND     a.ObsID <= 10000;

---- No dependent variable for all observations
--    Case 5b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Insert intercept variable only for some obs
--    Case 6a:
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> 0;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 0
AND     a.ObsID <= 10000;

---- No intercept variable for all observations
--    Case 6b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the intercept and insert the value 2 for intercept
--    Case 7a:
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
--    Case 7b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the intercept and insert values 1 and 0 for the intercept value
--    Case 8a:
DELETE FROM tbllinregrdatadeepTest
WHERE VarID = 0;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,
		a.ObsID,
        a.VarID,
        CASE WHEN ObsID <= 100 THEN 1 ELSE 0 END
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 0;

---- Intercept  value not  unique
--    Case 8b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table
--    Case 9a:
DELETE FROM tbllinregrdatadeepTest;

---- Populate less rows than variables
--    Case 9b:
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.ObsID <= 100;

---- Number of observations <= number of variables
--    Case 9c:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table and populate the data
--    Case 10a:
DELETE FROM tbllinregrdatadeepTest;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a;

--- Repeat a row in the table
--    Case 10b:
INSERT INTO tbllinregrdatadeep
SELECT  a.GroupID,
                a.ObsID,
        a.VarID,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 10
AND     a.ObsID = 26;

---- Repeated data in table
--    Case 10c:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table and populate
--    Case 11a:
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
--    Case 11b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;
-- Result: Fuzzy Logix specific error message

---- Cleanup the table and populate(DOUBT) 
--Case 12a:
DELETE FROM tbllinregrdatadeepTest;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.ObsID,
        a.VarID,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID >= 0
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Num_Val END
FROM    tbllinregrdatadeep a
WHERE   a.VarID = -1
AND VarID < 10
AND ObsID < 200 ;

---dependent variables have NULLS
--Case 12b:
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate
--Case 13a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> -1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.ObsID,
        a.VarID,
       2
FROM    tbllinregrdatadeep a
WHERE   a.VarID = -1;

--dependednt variable has same value 
--Case 13b
SELECT f.*
FROM(
SELECT a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate collinearity
--Case 14a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE VarID <= 5;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
                 b.VarID + 1,
                 a.Num_Val
FROM    tbllinregrdatadeep a,
              (SELECT Max(VarID) AS VarID
               FROM tbllinregrdatadeepTest
               ) AS b
WHERE a.VarID = 1;

select varID, count( *) from tbllinregrdatadeepTest group by 1 order by 1;

---singular matrix
--Case 14b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;


---- Cleanup the table and populate 
--Case 15a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT a.* 
FROM    tbllinregrdatadeep a
WHERE   a.VarID  <> -1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        NULL
FROM    tbllinregrdatadeep a
WHERE   a.VarID  = -1;

--Dependent variables all NULLS 
--Case 15b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 16a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT a.* 
FROM    tbllinregrdatadeep a
WHERE   a.VarID  <> 0;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,
		a.ObsID,
        a.VarID,
        NULL
FROM    tbllinregrdatadeep a
WHERE   a.VarID  = 0;

--intercept variables all NULLS 
--Case 16b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 17a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT a.* 
FROM    tbllinregrdatadeep a
WHERE   a.VarID  <1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,
		a.ObsID,
        a.VarID,
        NULL
FROM    tbllinregrdatadeep a
WHERE   a.VarID  > 0;

--InDependent variable values all NULLS 
--Case 17b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 18a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> 0
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Num_Val END
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 0
AND VarID < 10
AND ObsID < 200;

---some intercept value as NULL
--Case 18b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 19a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        a.Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> 1
AND VarID < 10
AND ObsID < 200
UNION ALL
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        CASE WHEN ObsID < 100 THEN NULL ELSE Num_Val END
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 1
AND VarID < 10
AND ObsID < 200;

--one variable has NULLS
--Case 19b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 20a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> -1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        CASE WHEN ObsID < 100 THEN NULL ELSE VarID END,
        Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID = -1;

--some dependent variables are NULLs
--Case 20b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 21a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <> 0;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        CASE WHEN ObsID < 100 THEN NULL ELSE VarID END,
        Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID = 0;

--some intercept as NULLS
--Case 21b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 22a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        CASE WHEN ObsID = 61 AND VarID = 1 THEN NULL ELSE VarID END,
        Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0;

--independent varid as NULL
--Case 22b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 23a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <>-1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
                  Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0;

--independent varid as NULL
--Case 23b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 24a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <>-1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
                  Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID =-1;

--independent varid as NULL
--Case 24b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 25a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <1;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
                  Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID >0;

--independent varid as NULL
--Case 25b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---- Cleanup the table and populate 
--Case 26a
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID <=10;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,CASE WHEN ObsID = 61  THEN NULL ELSE a.ObsID END,
                  a.VarID,
                  Num_Val
FROM    tbllinregrdatadeep a
WHERE   a.VarID >0;

--independent varid as NULL
--Case 26b
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
--CASE 1  PROGRAM STALLS FOR LARGE DATA...JOIN PERFORMANCE NEEDS REVIEW...for now max allowable VarID is set it to varid < =100  for dense dataset
--Case 1
---- Cleanup the data and populate again
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM   tbllinregrdatadeep a 
WHERE VarID <=10;

SELECT a.VarID,
               COUNT(*) AS cnt
FROM tbllinregrdatadeepTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with non-sparse data
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

--Case 2
---- Cleanup the data and populate again, make the data sparse i.e., non-zero values 
---- for all variables except dependent and intercept
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0
AND 	a.VarID <= 10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID IN (-1, 0);

SELECT a.VarID,
       COUNT(*) AS cnt
FROM tbllinregrdatadeepTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with sparse data
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---Case 3
--- Cleanup the data and populate again with intercept value as 0
---JIRA TDFL-464 raised 
--gives error in matrix inversion 
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a 
WHERE  VarID  <> 0 
AND VarID <= 10;

INSERT INTO tbllinregrdatadeepTest
SELECT  a.GroupID,a.ObsID,
        a.VarID,
        0
FROM    tbllinregrdatadeep a 
WHERE  VarID  = 0 ;

SELECT a.VarID,
       COUNT(*) AS cnt
FROM tbllinregrdatadeepTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with intercept value all 0s
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---Case 4
--- Cleanup the data and populate again with intercept value as 1
DELETE FROM tbllinregrdatadeepTest;
INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a 
WHERE  VarID  <> 0 
AND VarID <= 10 ;

INSERT INTO  tbllinregrdatadeepTest
SELECT  a.GroupID,a. ObsID,
        a.VarID,
        1
FROM     tbllinregrdatadeep a 
WHERE  VarID  = 0 ;

SELECT a.VarID,
       COUNT(*) AS cnt
FROM tbllinregrdatadeepTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with intercept value all 1s
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

-----Case  5
--Cross database access test case
---- Drop and recreate the test table in another database 
DROP TABLE tbllinregrdatadeepTest;
CREATE TABLE tbllinregrdatadeepTest (
GroupID 	BIGINT,
ObsID       BIGINT,
VarID      INTEGER,
Num_Val      DOUBLE PRECISION)
DISTRIBUTE ON(ObsID);

INSERT INTO tbllinregrdatadeepTest
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID > 0
AND a.VarID <=10
AND     a.Num_Val <> 0
UNION ALL
SELECT  a.*
FROM    tbllinregrdatadeep a
WHERE   a.VarID IN (-1, 0);

SELECT a.VarID,
       COUNT(*) AS cnt
FROM tbllinregrdatadeepTest AS a
GROUP BY 1
ORDER BY 1;

---- Perform regression with sparse data with a SpecID
SELECT f.*
FROM(
SELECT  a.GroupID,a.ObsID,a.VarID,a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS begin_flag,
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1) AS end_flag
FROM tbllinregrdatadeepTest a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, z.ObsID, z.VarID, z.Num_Val, 1, 0.01, 0.95, 0.10, z.begin_flag, z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;

---DROP the test table
DROP TABLE tbllinregrdatadeepTest;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
 
