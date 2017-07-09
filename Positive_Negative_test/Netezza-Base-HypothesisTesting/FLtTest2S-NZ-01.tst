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
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLtTest2S-NZ-01
--
--	Name(s):		FLtTest2S
--
-- 	Description:	    	Performs Students-t test for two samples. Students-t test on two samples 
--				is used to determine if the population means from the two samples are equal. 
--				Two-sample t-test is used for unpaired data. For paired data, you could 
--				use FLtTest1S.
--
--	Applications:	    
--
-- 	Signature:		FLtTest2S(StatType VARCHAR(10), VarType VARCHAR(20), SampleNo BIGINT,
--				InValue DOUBLE PRECISION, NumTails BIGINT)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	01-14-2015
--
--	Author:			<Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- Table used for testing
DROP TABLE tblHypoTestNew IF EXISTS;

SELECT  a.TestType,
        a.GroupID,
        COUNT(*)
FROM    tblHypoTest a
GROUP BY a.TestType, GroupID
ORDER BY 1, 2;

CREATE TABLE tblHypoTestNew
(
TestType VARCHAR(30),
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
SELECT  FLtTest2S('T_TEST', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 1b:
SELECT  FLtTest2S('PROB', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 2a:
---------------------------------------------------------------------------------------
---- Try the test with invlaid values of second parameter like 'VARIANCE', 'EQ_VAR' etc.
---------------------------------------------------------------------------------------
SELECT  FLtTest2S('T_STAT', 'VARIANCE', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 2b:
SELECT  FLtTest2S('T_STAT', 'EQ_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 3a:
---------------------------------------------------------------------------------------
---- Try the test with fifth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 0)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 3b:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, -1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 3c:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 3)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: Fuzzy Logix specific error message

--	Case 4a:
---------------------------------------------------------------------------------------
---- Try the test with empty table
---------------------------------------------------------------------------------------
SELECT FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest';
-- Result: 1 row returned as null value

--	Case 4b:
---------------------------------------------------------------------------------------
---- Try the test with all NULL values
---------------------------------------------------------------------------------------
INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       NULL
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

--	Case 4c:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: return NULL value

--	Case 5a:
---------------------------------------------------------------------------------------
---- Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblHypoTestNew;

--	Case 5b:
---------------------------------------------------------------------------------------
INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       10
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

--	Case 5c:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: return NULL value

--	Case 5d:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: return NULL value

--	Case 5e:
SELECT  FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: return NULL value

--	Case 5f:
SELECT  FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTestNew a
WHERE   a.TestType = 'tTest';
-- Result: return NULL value

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

-- Case 1a:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs

-- Case 1b:
SELECT  FLtTest2S('T_STAT', 'EQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs

-- Case 1c:
SELECT  FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 1)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs

-- Case 1d:
SELECT  FLtTest2S('T_STAT', 'UNEQUAL_VAR', a.GroupID, a.Num_Val, 2)
FROM    tblHypoTest a
WHERE   a.TestType = 'tTest';
-- Result: standard outputs 

-- END: POSITIVE TEST(s)

DROP TABLE tblHypoTestNew;
\time
-- 	END: TEST SCRIPT
