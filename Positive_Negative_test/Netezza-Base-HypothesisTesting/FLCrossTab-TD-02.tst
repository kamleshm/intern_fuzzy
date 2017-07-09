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
--	Test Unit Number:	FLCrossTab-TD-02
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
--case 1
-- Validate with input TableName as NULL
CALL FLCrossTab(NULL, 'tabrowid', 'tabcolid', NULL, NULL, 0, 'ResultTable');

-- Validate with input RowColName as NULL
--case 2
CALL FLCrossTab('fuzzy.tblCrossTab', NULL, 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate with input ColColName as NULL
--case 3
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', NULL, NULL, NULL, 0, ResultTable);


-- Test with TableOutput indicator as NULL
--case 4
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, NULL, ResultTable);

-- Validate input table exists
--case 5
CALL FLCrossTab('tblCrossTab_Notexist', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input database exists
--case 6
CALL FLCrossTab('fuz.tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);


-- Validate input table is not empty
--case 7
DROP TABLE fuzzy.tblCrossTab_empty;
CREATE MULTISET TABLE fuzzy. tblCrossTab_empty
     (
      TABROWID INTEGER,
      TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );
CALL FLCrossTab('fuzzy.tblCrossTab_empty', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input RowColName exists
--case 8
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid_Notexist', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Validate input ColColName exists
--case 9
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid_Notexist', NULL, NULL, 0, ResultTable);

----------------------------
-- Test with 'where' clause that excludes all the rows
--case 10
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', 'WHERE tabRowID < 0', NULL, 0, ResultTable);

-- Test with GroupBy using a column that does not exist
--case 11
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', NULL, 'GroupNotexist', 0, ResultTable);

-- Test with TableOutput indicator other than 1 or 0
--case 12
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 10, ResultTable);

-- END: NEGATIVE TEST(s)


--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

---- Positive tests ----

-- Run the function without where and groupBy clause and table output set to 0
--case 13
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 0, ResultTable);

-- Run the function without where and groupBy clause and with table output set to 1
--case 14
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', NULL, NULL, 1, ResultTable);

-- Run the function with a Where clause
--case 15
CALL FLCrossTab('fuzzy.tblCrossTab', 'tabrowid', 'tabcolid', 'WHERE tabrowID <=2', NULL, 0, ResultTable);

-- Run the function with a GroupBy clause
DROP TABLE fuzzy.tblCrossTabGroups;
CREATE MULTISET TABLE fuzzy.tblCrossTabGroups
     (
      GroupID  INTEGER,
      TABROWID INTEGER,
      TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );

INSERT INTO fuzzy. tblCrossTabGroups
SELECT 1,
       a.*
FROM   tblCrossTab a;

CALL FLCrossTab('fuzzy.tblCrossTabGroups', 'tabrowid', 'tabcolid', NULL, 'GroupID', 0, ResultTable);
-- END: POSITIVE TEST(s)

--DROP TEST TABLES
DROP TABLE fuzzy.tblCrossTab_empty;
DROP TABLE fuzzy.tblCrossTabGroups;


-- 	END: TEST SCRIPT
\time
-- END SCRIPT
