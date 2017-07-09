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
--	Test Unit Number:	FLtTest1S-NZ-01
--
--	Name(s):		FLtTest1S
--
-- 	Description:	    	Performs One-sample Students-t test. It is used to determine if the 
--				population mean of the sample is significantly different from a given reference value.
--	Applications:	    
--
-- 	Signature:		FLtTest1S(StatType VARCHAR(10), TestVal DOUBLE PRECISION,
--				InVal DOUBLE PRECISION, NumTails BIGINT)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	01-14-2015
--
--	Author:			<Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--				Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- Table used for testing
SELECT  a.TestType,
        a.GroupID,
        COUNT(*)
FROM    tblHypoTest a
GROUP BY a.TestType, GroupID
ORDER BY 1, 2;

CREATE TABLE tblHypoTestNew
(
TestType VARCHAR(30), --CHARACTER SET LATIN NOT CASESPECIFIC, --implement this on Netezza.
GroupID  INTEGER,
ObsID    INTEGER,
Num_Val  FLOAT)
DISTRIBUTE ON(OBSID);

-- BEGIN: NEGATIVE TEST(s)

---- Validation of parameters
-- Case 1a:
---------------------------------------------------------------------------------------
---- Try the test with invlaid values of first parameter like T_TEST, PROB, etc.
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLtTest1S('T_TEST', 1.0, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The first argument should be either the T_STAT or P_VALUE.
 */

-- Case 1b:
SELECT a.GroupID,
       FLtTest1S('PROB', 1.0, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The first argument should be either the T_STAT or P_VALUE.
 */

-- Case 2a:
---------------------------------------------------------------------------------------
---- Try the test with NULL value for second parameters
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLtTest1S('T_STAT', NULL, a.Num_Val, 1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The second argument should be the value for which t-Test is to be performed.
 */

-- Case 3a:
---------------------------------------------------------------------------------------
---- Try the test with fourth parameter i.e., number of tails not 1 or 2. Values like -1, 0, 3 should be tried
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, -1)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The number of tails should be either 1 or 2.
 */

-- Case 3b:
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 0)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The number of tails should be either 1 or 2.
 */

-- Case 3c:
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 3)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: Fuzzy Logix specific error message
/*
ERROR [HY000] ERROR:  The number of tails should be either 1 or 2.
 */

-- Case 4a:
---------------------------------------------------------------------------------------
---- Try the test with empty table
---------------------------------------------------------------------------------------
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: no rows are returned

-- Case 4b:
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

SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: returns value 5.7399657661151e-206, 5.4272742252909e-206

-- Case 5a:
---------------------------------------------------------------------------------------
---- Try the test with all values same for the third parameters i.e., standard deviation as 0
---------------------------------------------------------------------------------------

DELETE FROM tblHypoTestNew;

-- Case 5b:
INSERT INTO tblHypoTestNew
SELECT a.TestType,
       a.GroupID,
       a.ObsID,
       10
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest';

-- Case 5c:
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 1)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: FLtTest1S return values 5.7399657661151e-206, 5.4272742252909e-206

-- Case 5d:
SELECT a.GroupID,
       FLtTest1S('T_STAT', 1.0, a.Num_Val, 2)
FROM   tblHypoTestNew a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: FLtTest1S returns 5.7399657661151e-206, 5.4272742252909e-206
 
-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

SELECT  a.GroupID,
        FLtTest1S('T_STAT', 1.0, a.Num_Val, 1),
        FLtTest1S('P_VALUE', 1.0, a.Num_Val, 1),
        FLtTest1S('T_STAT', 1.0, a.Num_Val, 2),
        FLtTest1S('P_VALUE', 1.0, a.Num_Val, 2)
FROM   tblHypoTest a
WHERE  a.TestType = 'tTest'
GROUP BY a.GroupID;
-- Result: standard outputs

-- END: POSITIVE TEST(s)
DROP TABLE tblHypoTestNew;
\time
-- 	END: TEST SCRIPT
