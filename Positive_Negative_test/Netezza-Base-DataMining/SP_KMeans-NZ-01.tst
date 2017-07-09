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
--     Test Category:     	   Data Mining Functions
--
--    Test Unit Number:  	   SP_KMeans-NZ-01
--
--    Name(s):     		   SP_KMeans
--
--     Description:           	   K-Means clusters the training data. The relationship of 
--                		   observations to clusters has hard edges.
--    Applications:            
--
--     Signature:        	   SP_KMeans (IN TableName VARCHAR(100),
--                  		   IN Clusters INT, IN Iterations INT)
--
--    Parameters:        	   See Documentation
--
--    Return value:  	           Table
--
--    Last Updated:                10-07-2017
--
--    Author:            	   <partha.sen@fuzzyl.com, joe.fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>, <kamlesh.meena@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- Table used for KMeans
SELECT  a.VarID,
        COUNT(*)
FROM    tblUSArrests a
GROUP BY a.VarID
ORDER BY 1;

--Creating a table similar to tblUSArrests but with appropriate column names
CREATE TABLE tblKMeansTest (
ObsID        BIGINT,
DimID        INTEGER,
Value        DOUBLE PRECISION)
DISTRIBUTE ON(ObsID, DimID);

---- BEGIN: NEGATIVE TEST(s)

--    Case 1a:
---- Incorrect table name
CALL SP_KMeans('Dummy', 3, 25);
-- Result: Fuzzy Logix specific error message

--    Case 2a:
---- Incorrect column names
--Not applicable for Netezza

--    Case 3a:
---- No data in table
DELETE FROM tblKMeansTest;

CALL SP_KMeans('tblKMeansTest', 3, 25);
-- Result: Fuzzy Logix specific error message

--Populate the table
INSERT INTO tblKMeansTest
SELECT *
FROM   tblUSArrests;

--    Case 4a:
---- Invalid parameters
---- Number of clusters <= 0
CALL SP_KMeans('tblKMeansTest', -1, 25);
CALL SP_KMeans('tblKMeansTest', 0, 25);
-- Result: Fuzzy Logix specific error message

--    Case 4b:
---- Number of iterations <= 0
CALL SP_KMeans('tblKMeansTest', 3, -1);
CALL SP_KMeans('tblKMeansTest', 3, 0);
-- Result: Fuzzy Logix specific error message

--    Case 4c:
---- Hypothesis <= 0
--Not Applicable for Netezza

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme values


--    Case 1a:
---- Perform KMeans with non-sparse data
DELETE FROM fzzlKMeansCentroid;
DELETE FROM fzzlKMeansClusterID;

DELETE FROM tblKMeansTest;
--Populate the table
INSERT INTO tblKMeansTest
SELECT *
FROM         tblUSArrests a;

CALL SP_KMeans('tblKMeansTest', 3, 25);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlKMeansCentroid a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlKMeansClusterID a
ORDER BY a.AnalysisID DESC;

--    Case 1b:
---- Perform KMeans with non-sparse data
DELETE FROM fzzlKMeansCentroid;
DELETE FROM fzzlKMeansClusterID;

DELETE FROM tblKMeansTest;
--Populate the table
INSERT INTO tblKMeansTest
SELECT *
FROM         tblUSArrests a
WHERE a.Num_Val <> 0;

CALL SP_KMeans('tblKMeansTest', 3, 25);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlKMeansCentroid a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlKMeansClusterID a
ORDER BY a.AnalysisID DESC;

--Case 1c:
---- Drop and recreate the test table with column names different than that of usual FL deep table naming conventions
----Negative test on Netezza
DELETE FROM fzzlKMeansCentroid;
DELETE FROM fzzlKMeansClusterID;

DROP TABLE tblKMeansTest;

CREATE TABLE tblKMeansTest (
ObsCol       BIGINT,
VarCol       INTEGER,
Val      DOUBLE PRECISION)
DISTRIBUTE ON (ObsCol);

INSERT INTO tblKMeansTest
SELECT  a.*
FROM    tblUsArrests a
WHERE a.Val <> 0;

---- Perform KMeans with non-sparse data
CALL SP_KMeans('tblKMeansTest', 3, 25);
-- Result: standard outputs

-- Display result
SELECT  a.*
FROM    fzzlKMeansCentroid a
ORDER BY a.AnalysisID DESC;

SELECT  a.*
FROM    fzzlKMeansClusterID a
ORDER BY a.AnalysisID DESC;

---DROP the test table
DROP TABLE tblKMeansTest; 


-- END: POSITIIVE TEST(s)
\time
--     END: TEST SCRIPT
