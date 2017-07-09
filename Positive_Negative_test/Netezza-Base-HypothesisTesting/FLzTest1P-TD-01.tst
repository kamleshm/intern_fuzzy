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
--	Test Unit Number:	FLzTest1P-TD-01
--
--	Name(s):		FLzTest1P
--
-- 	Description:	    	ne-Sample Proportion z Test used to determine if the probability 
--				of event in the sample is significantly different from a given probability.
--
--	Applications:	    	FLzTest1P(StatType VARCHAR(10), TestVal DOUBLE PRECISION,
--				HypoMean DOUBLE PRECISION, NumTails BIGINT)
--
-- 	Signature:		
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
GROUP BY a.GroupID
WHERE   a.Num_Val IS NOT NULL
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

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

---- Validation of parameters
--	Caes 1a:
---------------------------------------------------------------------------------------
---- Try the test with invlaid values of first parameter like T_TEST, PROB, etc.
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1P('T_TEST', 0.45, a.Num_Val, 1)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 1b:
SELECT a.GroupID,
       FLzTest1P('PROB', 0.45, a.Num_Val, 1)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 2a:
---------------------------------------------------------------------------------------
---- Try the test with NULL value for second parameters
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1P('Z_STAT', NULL, a.Num_Val, 1)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 3a:
---------------------------------------------------------------------------------------
---- Try the test with fourth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, -1)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 3b:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 0)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 3c:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 3)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

--	Caes 4a:
---------------------------------------------------------------------------------------
---- Try the test with empty table
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return zero rows

--	Caes 5a:
---------------------------------------------------------------------------------------
---- Try the test with all NULL values
---------------------------------------------------------------------------------------
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       NULL
FROM   tblzTest a;

--	Caes 5b:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return NULL values

--	Case 6a:
---------------------------------------------------------------------------------------
---- Try the test with values which are not 0 or 1
---------------------------------------------------------------------------------------

DELETE FROM tblzTestNew;

--	Case 6b:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       2
FROM   tblzTest a;

--	Case 6c:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return NULL values
--      R: prop.test(25,25, p=.45, alternative="greater", correct=F) # GroupID=1

--	Case 6d:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 2),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return NULL values
--      R: prop.test(25,25, p=.45, alternative="two.sided", correct=F) # GroupID = 1

--	Case 6e:
DELETE FROM tblzTestNew;

--	Case 7a:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       -1
FROM   tblzTest a;

--	Case 7b:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return NULL values
--      R: prop.test(0,0, p=.45, alternative="greater", correct=F) # GroupID = 1

--	Case 7c:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 2),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: return NULL values
--      R: prop.test(0,0, p=.45, alternative="two.sided", correct=F) # GroupID = 1

--	Case 8a:
---------------------------------------------------------------------------------------
---- Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblzTestNew;

--	Case 8b:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       1
FROM   tblzTest a;

--	Case 8c:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: standard outputs (match R)
--      R: prop.test(25,25, p=.45, alternative="greater", correct=F) # GroupID = 1

--	Case 8d:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 2),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: standard outputs (match R)
--       R: prop.test(25,25, p=.45, alternative="two.sided", correct=F) # GroupID = 1

--	Case 8e:
DELETE FROM tblzTestNew;

--	Case 9a:
INSERT INTO tblzTestNew
SELECT a.GroupID,
       a.ObsID,
       0
FROM   tblzTest a;

--	Case 9b:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 1)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: standard outputs (match R)
--      R: prop.test(0,25, p=.45, alternative="greater", correct=F) # GroupID = 1

--	Case 9c:
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 2),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 2)
FROM   tblzTestNew a
GROUP BY a.GroupID;
-- Result: floating point exception: divide by zero
--       R: prop.test(0,25, p=.45, alternative="two.sided", correct=F) # GroupID = 1

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Case 1a::
SELECT a.GroupID,
       FLzTest1P('Z_STAT', 0.45, a.Num_Val, 1),
       FLzTest1P('P_VALUE', 0.45, a.Num_Val, 1)
FROM   tblzTest a
GROUP BY a.GroupID;
-- Result: standard outputs (match R)
--      R: prop.test(20,25, p=.45, alternative="greater", correct=F) # GroupID = 1
--         prop.test(12,22, p=.45, alternative="greater", correct=F) # GroupID = 2

-- END: POSITIVE TEST(s)
DROP TABLE tblzTestNew;
\time
-- 	END: TEST SCRIPT
