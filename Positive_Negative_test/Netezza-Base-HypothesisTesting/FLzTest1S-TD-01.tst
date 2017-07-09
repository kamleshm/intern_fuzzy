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
--	Test Unit Number:	FLzTest1S-TD-01
--
--	Name(s):		FLzTest1S
--
-- 	Description:	    	One-Sample z Test is used to test if population mean of the sample 
--				is significantly different from a given reference value. One-Sample 
--				z Test is similar to One-Sample t test, normally, when the number of
--				observations in the samples is smaller than 30, t Test is used, 
--				otherwise z Test is used.
--	Applications:	    	
--
-- 	Signature:		FLzTest1S(StatType VARCHAR(10), TestVal DOUBLE PRECISION,
--				HypoMean DOUBLE PRECISION, NumTails BIGINT)
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
SELECT a.GroupID,
       FLzTest1S('T_TEST', 0.45, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

SELECT a.GroupID,
       FLzTest1S('PROB', 0.45, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

---------------------------------------------------------------------------------------
---- Case 1b: Try the test with NULL value for second parameters
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1S('Z_STAT', NULL, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

---------------------------------------------------------------------------------------
---- Case 1c: Try the test with fourth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, -1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 0)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 3)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message

---------------------------------------------------------------------------------------
---- Case 1d: Try the test with empty table
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: no rows are returned

---------------------------------------------------------------------------------------
---- Case 1e: Try the test with all NULL values
---------------------------------------------------------------------------------------
INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       NULL
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: floating point exception: Invalid arithmetic operation

---------------------------------------------------------------------------------------
---- Case 1f: Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblHypoTestNew;

INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       10
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: floating point exception: Invalid arithmetic operation

SELECT a.GroupID,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 2)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: floating point exception: Invalid arithmetic operation

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values
 
SELECT a.GroupID, 
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 1) AS Z_STAT1,
       FLzTest1S('P_VALUE', 0.45, a.Num_Val, 1) AS P_VALUE1,
       FLzTest1S('Z_STAT', 0.45, a.Num_Val, 2) AS Z_STAT2,
       FLzTest1S('P_VALUE', 0.45, a.Num_Val, 2) AS P_VALUE2
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID
ORDER BY 1;
-- Result: standard outputs

DROP TABLE tblHypoTestNew;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT
