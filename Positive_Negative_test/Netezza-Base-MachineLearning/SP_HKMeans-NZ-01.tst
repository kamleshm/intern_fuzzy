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
--     Test Category:              Data Mining Functions
--
--    Test Unit Number:            SP_HKMeans-NZ-01
--
--    Name(s):                     SP_HKMeans
--
--     Description:                Hierarchical K-Means clusters the training data. 
--								   The relationship of observations to clusters has hard edges. It re-clusters 
--								   the training data in each cluster until the desired hierarchical level is reached.
--    Applications:
--
--      Signature:                 SP_HKMeans(TableName VARCHAR(100),
--                                           NumOfLevels INTEGER,
--                                           MaxNumOfClusters INTEGER,
--                                           MaxNumOfIterations INTEGER)
--
--    Parameters:                  See Documentation
--
--    Return value:                Table
--
--    Last Updated:                01-22-2015
--
--    Author:                      <kamlesh.meena@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- Table used for HKMeans
SELECT  a.VarID,
        COUNT(*)
FROM    tblUSArrests a
GROUP BY a.VarID
ORDER BY 1;

--Creating a table similar to tblUSArrests but with appropriate column names
CREATE TABLE tblHKMeansTest (
ObsID        BIGINT,
DimID        INTEGER,
Value        DOUBLE PRECISION)
DISTRIBUTE ON(ObsID, DimID);

----BEGIN: NEGATIVE TEST(s)
--    Case 1a:
---- Incorrect table name
CALL SP_HKMeans('Dummy',2, 2, 20);
-- Result: Fuzzy Logix specific error message
 
--    Case 2a:
---- Incorrect column names
--Not applicable for Netezza

--    Case 3a:
---- No data in table
DELETE FROM tblHKMeansTest;

CALL SP_HKMeans('tblHKMeansTest',2, 2, 20);
-- Result: Fuzzy Logix specific error message

--Populate the table
INSERT INTO tblHKMeansTest
SELECT *
FROM   tblUSArrests;

--    Case 4a:
---- Number of levels <= 0
EXEC SP_HKMeans('tblHKMeansTest',0,2,20);
EXEC SP_HKMeans('tblHKMeansTest',-2,2,20);
-- Result: Fuzzy Logix specific error message

--    Case 4b:
---- Invalid parameters
---- Number of clusters <= 0
EXEC SP_HKMeans('tblHKMeansTest',2,0,20);
EXEC SP_HKMeans('tblHKMeansTest',2,-2,20);
-- Result: Fuzzy Logix specific error message

--    Case 4c:
---- Number of iterations <= 0
EXEC SP_HKMeans('tblHKMeansTest',2,2,0);
EXEC SP_HKMeans('tblHKMeansTest',2,2,-20);
-- Result: Fuzzy Logix specific error message

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme values
--    Case 1a:
---- Perform KMeans with non-sparse data
DELETE FROM fzzlHKMeansDendrogram;
DELETE FROM fzzlHKMeansHierClusterID;

DELETE FROM tblHKMeansTest;
--Populate the table
INSERT INTO tblHKMeansTest
SELECT *
FROM         tblUSArrests a;

CALL SP_HKMeans('tblHKMeansTest',2, 2, 20);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlHKMeansDendrogram a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlHKMeansHierClusterID a
ORDER BY a.AnalysisID DESC;

--    Case 1b:
---- Perform KMeans with non-sparse data
DELETE FROM fzzlHKMeansDendrogram;
DELETE FROM fzzlHKMeansHierClusterID;

DELETE FROM tblHKMeansTest;
--Populate the table
INSERT INTO tblHKMeansTest
SELECT *
FROM         tblUSArrests a
WHERE a.Num_Val <> 0;

CALL SP_HKMeans('tblHKMeansTest',2, 2, 20);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlHKMeansDendrogram a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlHKMeansHierClusterID a
ORDER BY a.AnalysisID DESC;

--Case 1c:
---- Drop and recreate the test table with column names different than that of usual FL deep table naming conventions
----Negative test on Netezza
DELETE FROM fzzlHKMeansDendrogram;
DELETE FROM fzzlHKMeansHierClusterID;

DROP TABLE tblHKMeansTest;

CREATE TABLE tblHKMeansTest (
ObsCol       BIGINT,
VarCol       INTEGER,
Val      DOUBLE PRECISION)
DISTRIBUTE ON (ObsCol);

INSERT INTO tblHKMeansTest
SELECT  a.*
FROM    tblUsArrests a
WHERE a.Val <> 0;

---- Perform KMeans with non-sparse data
CALL SP_HKMeans('tblHKMeansTest',2,2,20);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlHKMeansDendrogram a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlHKMeansHierClusterID a
ORDER BY a.AnalysisID DESC;

---DROP the test table
DROP TABLE tblHKMeansTest;

 
-- END: POSITIIVE TEST(s)
\time
-- END TEST SCRIPT

