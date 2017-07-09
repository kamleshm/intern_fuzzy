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
--	Test Unit Number:	FLKSTest1S-TD-02
--
--	Name(s):		FLKSTest1S
--
-- 	Description:	    	FLKSTest1S conducts One-Sample Kolmogorov-Smirnov (KS) Test. 
--				One-Sample Kolmogorov-Smirnov (KS) Test is normally used to 
--				determine if a given sample of data comes from a specified 
--				normal distribution.
--	Applications:	    
--
-- 	Signature:		FLKSTest1S(IN Testtype VARCHAR(10), IN TableName VARCHAR(256),
--				IN ValueCol VARCHAR(100), IN Mean DOUBLE PRECISION, 
--				IN StdDev DOUBLE PRECISION, IN SigLevel DOUBLE PRECISION,
--				IN WhereClause VARCHAR(512), IN GroupBy VARCHAR(256),
--				IN TableOutput BYEINT, OUT OutTable VARCHAR(256))
--
--	Parameters:		See Documentation
--
--	Return value:	    	Table
--
--	Last Updated:	    	03-24-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

---- Table used for regression
SELECT  a.GroupID,
        COUNT(*)
FROM    tblKSTest a
GROUP BY a.GroupID
ORDER BY 1;

---- Check if the test table exists
SHOW TABLE fuzzy. tblKSTestNew;

---- Drop and recreate the test table
DROP TABLE fuzzy.tblKSTestNew;

CREATE MULTISET TABLE fuzzy.tblKSTestNew (
GroupID     INTEGER,
ObsID       INTEGER,
NumVal      DOUBLE PRECISION)
PRIMARY INDEX (ObsID);

-- BEGIN: NEGATIVE TEST(s)

---- Case 1a: Incorrect table name
CALL FLKSTest1S('NORMAL', 'tblKSTestTemp', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);

--Case 1aa incorrect database name
CALL FLKSTest1S('NORMAL', 'xuz.tblKSTest', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

---- Populate data in table
INSERT INTO fuzzy.tblKSTestNew
SELECT a.*
FROM   tblKSTest a;

---- Case 1b: Incorrect first parameters
CALL FLKSTest1S(NULL, 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

CALL FLKSTest1S('EXPONETIAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

---- Case 1c: Incorrect column names
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumValue', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'Group', 0, ResultTable);
-- Result: syntax error

---- Case 1d: Absurd WHERE clause
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE Dog = Cat', 'Group', 0, ResultTable);
-- Result: syntax error

CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE Dog Is Not My Pet', 'Group', 0, ResultTable);
-- Result: syntax error

---- Case 1e: NULLs for all values
DELETE FROM fuzzy.tblKSTestNew;

INSERT INTO fuzzy.tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       NULL
FROM   tblKSTest a;

---- Case 1f: NULLs for all values
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specifc error message for FLCDFNormal 

---- Case 1g: All values are same
DELETE FROM fuzzy.tblKSTestNew;

INSERT INTO fuzzy.tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       10
FROM   tblKSTest a;

---- Case 1h: All values are same
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: produces result, but R says "ties should not be present for the Kolmogorov-Smirnov test"
--      R: ks.test(rep(10,20), "pnorm", alternative="two.sided")

---- Case 1i: Group ID column is NULL
DELETE FROM fuzzy.tblKSTestNew;

INSERT INTO fuzzy.tblKSTestNew
SELECT NULL,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Case 1j: NULLs for Group ID
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: cannot verify result
--      R: x <- c(1.26, 0.34, 0.7, 1.75, 50.57, 1.55, 0.08, 0.42, 0.5, 3.2, 0.15, 0.49, 0.95, 0.24, 1.37, 0.17, 6.98, 0.1, 0.94, 0.38)
--         y <- c(2.37, 2.16, 14.82, 1.73, 41.04, 0.23, 1.32, 2.91, 39.41, 0.11, 24.44, 4.51, 0.51, 4.5, 0.18, 14.68, 4.66, 1.3, 2.06, 1.19)
--         ks.test(c(x,y), "pnorm", 3.5, 11.5)

---- Populate valid data
DELETE FROM fuzzy.tblKSTestNew;

INSERT INTO fuzzy.tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Case 1i: Restrictive WHERE clause
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE ObsID < 0', 'GroupID', 0, ResultTable);
-- Result: no rows returned

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

---- Valid values
DELETE FROM fuzzy.tblKSTestNew;

INSERT INTO fuzzy.tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Valid values
CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: standard outputs
--      R: ks.test(x, "pnorm", 3.5, 11.5)
--         ks.test(y, "pnorm", 3.5, 11.5)

CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', 3.5, NULL, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message (INCORRECT)
--         "... Standard Deviation (arg #4) ..." should be "... Standard Deviation (arg #5) ..."

CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', NULL, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message (INCORRECT)
--         "... Standard Deviation (arg #4) ..." should be "... Standard Deviation (arg #5) ..."

CALL FLKSTest1S('NORMAL', 'fuzzy.tblKSTestNew', 'NumVal', NULL, NULL, NULL, 'GroupID', 0, ResultTable);
-- Result: standard outputs
--      R: ks.test(x, "pnorm", mean(x), sd(x))
--         ks.test(y, "pnorm", mean(y), sd(y))

-- END: POSITIVE TEST(s)

--DROP TEST TABLE
DROP TABLE fuzzy.tblKSTestNew;

-- 	END: TEST SCRIPT
