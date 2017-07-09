-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC.
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade
-- secret or copyright law. Dissemination of this information or reproduction of this material is
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
--      Test Category:                  Data Mining
--
--      Test Unit Number:               SP_KMeans-NZ-01
--
--      Name(s):                        SP_KMeans
--
--      Description:                    K-means is one of the most popular unsupervised learning algorithms for grouping objects.
--					Each cluster is computed by averaging the feature vectors of all objects assigned to it
--
--      Applications:
--
--      Signature:                      SP_KMeans(TableName VARCHAR(100),
--					MaxNumOfClusters INTEGER,
--					MaxNumOfIterations INTEGER)
--
--      Parameters:                     See Documentation
--
--      Return value:                   Analysis ID of the output model.
--
--      Last Updated:                   07-03-2017
--
--      Author:                         Kamlesh Meena

----------------------------------------------------------------------------------------
-- BEGIN: TEST SCRIPT
\time

--.run file=../PulsarLogOn.sql

--.set width 2500

---- Table used for KMeans
CREATE TEMP TABLE tblKMeansDemo AS
SELECT Obsid, VarID as DimID, Num_Val as Value
FROM tblUSArrests;

----BEGIN: NEGATIVE TEST(s)

--  Case 1:
---- Incorrect Table Name
-- Expected Fuzzy Logix specific error,Good
EXEC SP_KMeans('Dummy',2,20);

--      Case 2:
---- No data in table
CREATE TABLE tblUSArrests_No_Data (
ObsID       BIGINT,
DimId       INTEGER,
Value      DOUBLE PRECISION)
DISTRIBUTE ON (ObsID);
EXEC SP_KMeans('tblUSArrests_No_Data',2,20);
DROP TABLE tblUSArrests_No_data;

--      Case 3:
---- Invalid parameters

--      Case 3(a):
---- Number of clusters = 0
-- Expected Fuzzy Logix specific error,Good
EXEC SP_KMeans('tblKMeansDemo',0,20);

--      Case 3(b):
---- Number of clusters = 0
-- Expected Fuzzy Logix specific error,Good
EXEC SP_KMeans('tblKMeansDemo',-2,20);

--      Case 3(c):
---- Number of iterations = 0
-- Expected Fuzzy Logix specific error,Good
EXEC SP_KMeans('tblKMeansDemo',2,0);

--      Case 3(d):
---- Number of iterations < 0
-- Expected Fuzzy Logix specific error,Good
EXEC SP_KMeans('tblKMeansDemo',2,-2);

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

--      Case 1(a):
---- Performs HKMeans with non-sparse data
EXEC SP_KMeans('tblKMeansDemo',2,20);

--      Case 1(b):
---- Drop and recreate the test table with column names different than that of usual FL deep table naming conventions
CREATE TABLE tblHKMeansTest (
ObsCol       BIGINT,
VarCol       INTEGER,
Val      DOUBLE PRECISION)
DISTRIBUTE ON(ObsCol);


INSERT INTO tblHKMeansTest
SELECT  a.*
FROM    tblUsArrests a;

EXEC SP_KMeans('tblHKMeansTest',2,20);

-- Case 1(c)
---- Perform KMeans with sparse data
CREATE  TABLE tblMDADemo AS
SELECT Obsid, VarID as DimID, Num_Val as Value
FROM tblMDA;
EXEC SP_KMeans('tblMDADemo',3,20);
DROP TABLE tblMDADemo;
-- END: POSITIIVE TEST(s)
\time
-- END TEST SCRIPT




----------------------------------------------------------------------------------------
CREATE TEMP TABLE tblKMeansDemo AS
SELECT Obsid, VarID as DimID, Num_Val as Value
FROM tblUSArrests;

SELECT '***** EXECUTING SP_KMeans *****';
SELECT SP_KMeans('tblKMeansDemo',5,10);

--SELECT * 
--FROM fzzlKMeansCentroid 
--WHERE Analysisid = 'MMEHTA_414317' 
--ORDER BY DimID, ClusterID;

-- SELECT ClusterID, COUNT(*) 
-- FROM fzzlKMeansClusterid 
-- WHERE AnalysisID = 'MMEHTA_414317' 
-- GROUP BY ClusterID
-- ORDER BY ClusterID;
