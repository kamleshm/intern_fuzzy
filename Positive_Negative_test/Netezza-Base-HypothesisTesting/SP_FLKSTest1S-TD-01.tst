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
--	Test Unit Number:	FLKSTest1S-TD-01
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
--	Last Updated:	    	07-07-2017
--
--	Author:			Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
.run file=../PulsarLogOn.sql

---- Table used for regression
SELECT  a.GroupID,
        COUNT(*)
FROM    tblKSTest a
GROUP BY a.GroupID
ORDER BY 1;

---- Drop and recreate the test table
DROP TABLE tblKSTestNew IF EXISTS;

CREATE TABLE tblKSTestNew (
GroupID     INTEGER,
ObsID       INTEGER,
NumVal      DOUBLE PRECISION)
DISTRIBUTE ON(OBSID);

-- BEGIN: NEGATIVE TEST(s)

---- Case 1a: Incorrect table name
CALL FLKSTest1S('NORMAL', 'tblKSTestTemp', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

---- Populate data in table
INSERT INTO tblKSTestNew
SELECT a.*
FROM   tblKSTest a;

---- Case 1b: Incorrect first parameters
CALL SP_KSTest1S(NULL, 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: Fuzzy Logix specific error message

CALL SP_KSTest1S('EXPONETIAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: Fuzzy Logix specific error message

---- Case 1c: Incorrect column names
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumValue', 3.5, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: Fuzzy Logix specific error message

CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'Group','ResultTable');
-- Result: syntax error

---- Case 1d: Absurd WHERE clause
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE Dog = Cat', 'Group','ResultTable');
-- Result: syntax error

CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE Dog Is Not My Pet', 'Group','ResultTable');
-- Result: syntax error

---- Case 1e: NULLs for all values
DELETE FROM tblKSTestNew;

INSERT INTO tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       NULL
FROM   tblKSTest a;

---- Case 1f: NULLs for all values
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID','ResultTable');
-- Result: Fuzzy Logix specifc error message for FLCDFNormal 

---- Case 1g: All values are same
DELETE FROM tblKSTestNew;

INSERT INTO tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       10
FROM   tblKSTest a;

---- Case 1h: All values are same
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: produces result, but R says "ties should not be present for the Kolmogorov-Smirnov test"
--      R: ks.test(rep(10,20), "pnorm", alternative="two.sided")

---- Case 1i: Group ID column is NULL
DROP TABLE ResultTable IF EXISTS;
DELETE FROM tblKSTestNew;

INSERT INTO tblKSTestNew
SELECT NULL,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Case 1j: NULLs for Group ID
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID','ResultTable');
-- Result: cannot verify result
--      R: x <- c(1.26, 0.34, 0.7, 1.75, 50.57, 1.55, 0.08, 0.42, 0.5, 3.2, 0.15, 0.49, 0.95, 0.24, 1.37, 0.17, 6.98, 0.1, 0.94, 0.38)
--         y <- c(2.37, 2.16, 14.82, 1.73, 41.04, 0.23, 1.32, 2.91, 39.41, 0.11, 24.44, 4.51, 0.51, 4.5, 0.18, 14.68, 4.66, 1.3, 2.06, 1.19)
--         ks.test(c(x,y), "pnorm", 3.5, 11.5)

---- Populate valid data
DELETE FROM tblKSTestNew;

INSERT INTO tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Case 1i: Restrictive WHERE clause
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, 'WHERE ObsID < 0', 'GroupID','ResultTable');
-- Result: no rows returned

---- Case 1j: Violating the condition that Mean (Arg #4) and Standard Deviation (Arg #5) being both known and unknown
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, NULL, NULL, 'GroupID','ResultTable');
-- Result: Fuzzy Logix specific error message (INCORRECT)
--         "... Standard Deviation (arg #4) ..." should be "... Standard Deviation (arg #5) ..."


---- Case 1k: Violating the condition that Mean (Arg #4) and Standard Deviation (Arg #5) being both known and unknown
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', NULL, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: Fuzzy Logix specific error message (INCORRECT)
--         "... Standard Deviation (arg #4) ..." should be "... Standard Deviation (arg #5) ..."

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

---- Valid values
DELETE FROM tblKSTestNew;

INSERT INTO tblKSTestNew
SELECT a.GroupID,
       a.ObsID,
       a.Num_Val
FROM   tblKSTest a;

---- Valid values
DROP TABLE ResultTable IF EXISTS;
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', 3.5, 11.5, NULL, 'GroupID', 'ResultTable');
-- Result: standard outputs
--      R: ks.test(x, "pnorm", 3.5, 11.5)
--         ks.test(y, "pnorm", 3.5, 11.5)

DROP TABLE ResultTable IF EXISTS;
CALL SP_KSTest1S('NORMAL', 'tblKSTestNew', 'NumVal', NULL, NULL, NULL, 'GroupID','ResultTable');
-- Result: standard outputs
--      R: ks.test(x, "pnorm", mean(x), sd(x))
--         ks.test(y, "pnorm", mean(y), sd(y))

-- END: POSITIVE TEST(s)
DROP TABLE tblKSTestNew;
DROP TABLE ResultTable IF EXISTS;
\time
-- 	END: TEST SCRIPT
