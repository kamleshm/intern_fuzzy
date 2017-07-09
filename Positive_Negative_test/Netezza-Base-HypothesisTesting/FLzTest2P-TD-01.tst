-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLzTest2P-TD-01
--
--	Name(s):		FLzTest2P
--
-- 	Description:	    	Two-sample Proportion z Test is used to determine if the probabilities 
--				of event for the two samples are significantly different from each other.
--	Applications:	    	
--
-- 	Signature:		FLzTest2P(StatType VARCHAR(10), GroupID BIGINT,
--				InValue DOUBLE PRECISION, NumTails BIGINT)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	07-07-2017
--
--	Author:			<Joe.Fan@fuzzyl.com>,Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
.run file=../PulsarLogOn.sql

---- Table used for testing
SELECT  a.GroupID,
        SUM(CASE WHEN a.Num_Val = 1.0 THEN 1 ELSE 0 END) AS x,
        COUNT(*) AS n
FROM    tblzTest a
WHERE   a.Num_Val IS NOT NULL
GROUP BY a.GroupID
ORDER BY 1;

---- Drop and recreate the test table
DROP TABLE tblzTestNew IF EXISTS; 

CREATE TABLE tblzTestNew
(
GroupID  INTEGER,
ObsID    INTEGER,
Num_Val  FLOAT)
DISTRIBUTE ON(OBSID);

-- BEGIN: NEGATIVE TEST(s)

---- Validation of parameters
--	Case 1a:
---------------------------------------------------------------------------------------
---- Try the test with invlaid values of first parameter like T_TEST, PROB, etc.
---------------------------------------------------------------------------------------
SELECT FLzTest2P('T_TEST', a.GroupID, a.Num_Val, 1)
FROM   tblzTest a;
-- Result: Fuzzy Logix specific error message

--	Case 1b:
SELECT FLzTest2P('PROB', a.GroupID, a.Num_Val, 1)
FROM   tblzTest a;
-- Result: Fuzzy Logix specific error message

--	Case 2a:
---------------------------------------------------------------------------------------
---- Try the test with fourth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 0)
FROM   tblzTest a;
-- Result: Fuzzy Logix specific error message

--	Case 2b:
SELECT FLzTest2P('z_STAT', a.GroupID, a.Num_Val, -1)
FROM   tblzTest a;
-- Result: Fuzzy Logix specific error message

--	Case 2c:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 3)
FROM   tblzTest a;
-- Result: Fuzzy Logix specific error message

--	Case 3a:
---------------------------------------------------------------------------------------
---- Try the test with empty table
---------------------------------------------------------------------------------------
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: 1 row returned with NULL value

--	Case 4a:
---------------------------------------------------------------------------------------
---- Try the test with all NULL values
---------------------------------------------------------------------------------------
DELETE FROM tblzTestNew;

INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       NULL
FROM   tblzTest a;

--	Case 4b:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: returns NULL value

--	Case 5a:
---------------------------------------------------------------------------------------
---- Try the test with values which are not 0 or 1
---------------------------------------------------------------------------------------

DELETE FROM tblzTestNew;

--	Case 5b:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       2
FROM   tblzTest a;

--	Case 5c:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM   tblzTestNew a;
-- Result: Fuzzy Logix specific error message

--	Case 5d:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: Fuzzy Logix specific error message

--	Case 5e:
DELETE FROM tblzTestNew;

--	Case 6a:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       -1
FROM   tblzTest a;

--	Case 6b:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM   tblzTestNew a;
-- Result: Fuzzy Logix specific error message

--	Case 6c:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: Fuzzy Logix specific error message

--	Case 7a:
---------------------------------------------------------------------------------------
---- Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblzTestNew;

--	Case 7b:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       1
FROM   tblzTest a;

--	Case 7c:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM   tblzTestNew a;
-- Result: returns NULL value

--	Case 7d:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: returns NULL value

--	Case 7e:
DELETE FROM tblzTestNew;

--	Case 8a:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       0
FROM   tblzTest a;

--	Case 8b:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM   tblzTestNew a;
-- Result: returns NULL value

--	Case 8c:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblzTestNew a;
-- Result: returns NULL value

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 1),
       FLzTest2P('P_VALUE', a.GroupID, a.Num_Val, 1)
FROM   tblzTest a;
-- Result: standard outputs
--      R: prop.test(c(20,12), c(25,22), alternative="greater", correct=F)

--	Case 1b:
SELECT FLzTest2P('Z_STAT', a.GroupID, a.Num_Val, 2),
       FLzTest2P('P_VALUE', a.GroupID, a.Num_Val, 2)
FROM   tblzTest a;
-- Result: standard outputs
--      R: prop.test(c(20,12), c(25,22), alternative="two.sided", correct=F)
 
-- END: POSITIVE TEST(s)

DROP TABLE tblzTestNew;
\time
-- 	END: TEST SCRIPT
