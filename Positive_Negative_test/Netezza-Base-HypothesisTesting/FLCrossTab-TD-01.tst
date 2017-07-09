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
--	Test Unit Number:	FLCrossTab-TD-01
--
--	Name(s):		FLCrossTab
--
-- 	Description:	    	Cross tabulation, or cross tab, also called pivot table in Microsoft excel, display the joint distribution of two variables. 
--
--	Applications:	    	
--
-- 	Signature:		FLCrossTab(IN  TableName   VARCHAR(256),
--                             IN  RowColName  VARCHAR(100),
--                             IN  ColColName  VARCHAR(100),
--                             IN  WhereClause VARCHAR(512),
--                             IN  GroupBy     VARCHAR(256),
--                             IN  TableOutput byteint,
--                             OUT ResultTable VARCHAR(256))
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(256)
--
--	Last Updated:	    	07-07-2017
--
--	Author:			<gandhari.sen@fuzzyl.com>

-- BEGIN: TEST SCRIPT
\time
.run file=../PulsarLogOn.sql


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
--------------------------------------------------------------------------------------

---- Negative tests ----
-- Validate with input TableName as NULL
CALL FLCrossTab(NULL, 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate with input RowColName as NULL
CALL FLCrossTab('tblCrossTab', NULL, 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate with input ColColName as NULL
CALL FLCrossTab('tblCrossTab', 'tabrowid', NULL, NULL, NULL, 0, ResultTable);


-- Test with TableOutput indicator as NULL
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, NULL, ResultTable);

-- Validate input table exists
CALL FLCrossTab('tblCrossTab_Notexist', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input table is not empty
--PASSED on new run
DROP TABLE tblCrossTab_empty;
CREATE MULTISET TABLE tblCrossTab_empty
     (
      TABROWID INTEGER,
      TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );
CALL FLCrossTab('tblCrossTab_empty', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input RowColName exists
CALL FLCrossTab('tblCrossTab', 'tabrowid_Notexist', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input ColColName exists
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid_Notexist', NULL, NULL, 0, ResultTable);

----------------------------
-- Test with 'where' clause that excludes all the rows
--Passed on retest
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', 'WHERE tabRowID < 0', NULL, 0, ResultTable);

-- Test with GroupBy using a column that does not exist
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', NULL, 'GroupNotexist', 0, ResultTable);

-- Test with TableOutput indicator other than 1 or 0
--Passed on retest.
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 10, ResultTable);

-- END: NEGATIVE TEST(s)


--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

---- Positive tests ----

-- Run the function without where and groupBy clause and table output set to 0
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Run the function without where and groupBy clause and with table output set to 1
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 1, ResultTable);

-- Run the function with a Where clause
CALL FLCrossTab('tblCrossTab', 'tabrowid', 'tabcolid', 'WHERE tabrowID <=2', NULL, 0, ResultTable);

-- Run the function with a GroupBy clause
DROP TABLE tblCrossTabGroups;
CREATE MULTISET TABLE tblCrossTabGroups
     (
      GroupID  INTEGER,
      TABROWID INTEGER,
      TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );

INSERT INTO tblCrossTabGroups
SELECT 1,
       a.*
FROM   tblCrossTab a;

CALL FLCrossTab('tblCrossTabGroups', 'tabrowid', 'tabcolid', NULL, 'GroupID', 0, ResultTable);


---- Case 2 Run the function with more things in GroupBy clause
REPLACE VIEW vwCrossTabGroups AS
SELECT  1 AS MultiplierID,
       a.*
FROM   tblCrossTabGroups a
UNION ALL
SELECT  2 AS MultiplierID,
       a.*
FROM   tblCrossTabGroups a;

CALL FLCrossTab('vwCrossTabGroups', 'tabrowid', 'tabcolid', NULL, 'MultiplierID, GroupID', 0, ResultTable);



-- END: POSITIVE TEST(s)
DROP TABLE tblCrossTab_empty;
DROP TABLE tblCrossTabGroups;
DROP VIEW  vwCrossTabGroups;

-- 	END: TEST SCRIPT

\time
-- END SCRIPT
