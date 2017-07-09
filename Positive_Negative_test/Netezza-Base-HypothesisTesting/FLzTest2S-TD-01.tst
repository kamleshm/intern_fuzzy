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
--	Test Unit Number:	FLzTest2S-TD-01
--
--	Name(s):		FLzTest2S
--
-- 	Description:	    	Two-Sample z Test is used to determine if the population means from 
--				the two samples are equal. This test is similar to Two-sample t test.
--	Applications:	    	
--
-- 	Signature:		FLzTest2S(StatType VARCHAR(10), GroupID BIGINT,
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
SELECT  a.TestType,
        a.GroupID,
        COUNT(*)
FROM    tblHypoTest a
GROUP BY a.TestType, GroupID
ORDER BY 1, 2;


---- Drop and recreate the test table
DROP TABLE tblHypoTestNew IF EXISTS;

CREATE TABLE tblHypoTestNew
(
TestType VARCHAR(30),
GroupID  INTEGER,
ObsID    INTEGER,
Num_Val  FLOAT)
DISTRIBUTE ON(OBSID);

-- BEGIN: NEGATIVE TEST(s)

---- Validation of parameters
---------------------------------------------------------------------------------------
---- Case 1a: Try the test with invlaid values of first parameter like T_TEST, PROB, etc.
---------------------------------------------------------------------------------------
SELECT  FLzTest2S('T_TEST', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

SELECT  FLzTest2S('PROB', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

---------------------------------------------------------------------------------------
---- Case 1b: Try the test with fourth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 0)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, -1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 3)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

---------------------------------------------------------------------------------------
---- Case 1c: Try the test with empty table
---------------------------------------------------------------------------------------
SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: 1 row returned as null value

---------------------------------------------------------------------------------------
---- Case 1d: Try the test with all NULL values
---------------------------------------------------------------------------------------
INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       NULL
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

SELECT a.GroupID,
       FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: floating point exception: Invalid arithmetic operation

---------------------------------------------------------------------------------------
---- Case 1e: Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblHypoTestNew;

INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       10
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: floating point exception: Invalid arithmetic operation

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: floating point exception: Invalid arithmetic operation

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs

SELECT  FLzTest2S('Z_STAT', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs

-- END: POSITIVE TEST(s)
DROP TABLE tblHypoTestNew;
\time
-- 	END: TEST SCRIPT
