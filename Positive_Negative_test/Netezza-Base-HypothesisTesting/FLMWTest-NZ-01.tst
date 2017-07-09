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
--     Test Category:    Hypothesis Testing Functions
--
--     Test Unit Number: FLMWTest-NZ-01
--
--     Name(s):          FLMWTest
--
--     Description:      Returns the Mann-Whitney test statistic and associated probability to test whether two
--						 independent samples come from the same population.   
--
--     Applications:            
--
--     Signature:        FLMWTest(IN  STATISTC	      VARCHAR(100),
--                                IN  GroupID    	  INTEGER,  
--                                IN  FracRank    	  DOUBLE PRECISION)
--
--     Parameters:        See Documentation
--
--     Return value:            Table
--
--     Last Updated:            07-07-2017
--
--     Author:            <Joe.Fan@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql


-- BEGIN: NEGATIVE TEST(s)

---- Initialization

DROP TABLE tblHypoTest_Test IF EXISTS;

CREATE TABLE tblHypoTest_Test
(
GroupID     INTEGER,
ObsID       INTEGER,
Num_Val     DOUBLE PRECISION
)
DISTRIBUTE ON (ObsID);


---- Case 1: input validation

---- Case 1a: invalid table name
SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest_Dummy a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest_Dummy a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;
-- Result: standard error message

---- Case 1b: empty table
DELETE FROM tblHypoTest_Test;

SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest_Test a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest_Test a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;
-- Result: FLCDFNormal Argument 1 cannot be NULL


---- Case 2: SampleID is not 1 or 2
DELETE FROM tblHypoTest_Test;

INSERT INTO tblHypoTest_Test
SELECT  a.GroupID * 10,
        a.ObsID,
        a.Num_Val
FROM    tblHypoTest a;

SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest_Test a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest_Test a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;
-- Result: divide by zero


---- Case 3: Num_Val is a constant value
DELETE FROM tblHypoTest_Test;

INSERT INTO tblHypoTest_Test
SELECT  a.GroupID,
        a.ObsID,
        1
FROM    tblHypoTest a;

SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest_Test a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest_Test a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;
-- Result: divide by zero


---- Case 4: Table contains data for only one GroupID
DELETE FROM tblHypoTest_Test;

INSERT INTO tblHypoTest_Test
SELECT  a.GroupID,
        a.ObsID,
        a.Num_Val
FROM    tblHypoTest a
WHERE   a.GroupID = 1;

SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest_Test a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest_Test a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;
-- Result: divide by zero


---- Wrapup
DROP TABLE tblHypoTest_Test;


-- END: NEGATIVE TEST(s)


-- BEGIN: POSITIVE TEST(s)

SELECT FLMWTest('P_VALUE', x.GroupID, y.FracRank)
FROM   (
       SELECT a.GroupID,
              RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) AS Rank
       FROM   tblHypoTest a
       ) AS x,
       (
       SELECT p.Rank,
              FLFracRank(p.Rank, COUNT(*)) AS FracRank
       FROM   (
              SELECT a.GroupID,
                     a.ObsID,
                     RANK() OVER (PARTITION BY 1 ORDER BY a.Num_Val ASC) 
			  FROM   tblHypoTest a
              ) AS p
       GROUP BY p.Rank
       ) AS y
WHERE  y.Rank = x.Rank;

-- Result:
-- Standard Netezza Output

-- END: POSITIVE TEST(s)

DROP TABLE tblHypoTest_Test;
\time
-- END: TEST SCRIPT
