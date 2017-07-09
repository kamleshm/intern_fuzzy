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
--	Test Unit Number:	FLCrossTab-TD-04
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
--	Last Updated:	    	08-28-2014
--
--	Author:			<zhi.wang@fuzzyl.com>
--                  <gandhari.sen@fuzzyl.com> (changed the table name to avoid conflict)

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- JIRA TD-220
Drop table tblcrosstab_test;
CREATE MULTISET TABLE tblcrosstab_test 
(
TABROWID INTEGER,
TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );
DELETE FROM tblcrosstab_test
;ins into tblcrosstab_test values(	1	,	1	)
;ins into tblcrosstab_test values(	2	,	1	)
;ins into tblcrosstab_test values(	3	,	1	)
;ins into tblcrosstab_test values(	4	,	1	);

call FLCrossTab('tblcrosstab_test', 'tabrowid', 'tabcolid', NULL, NULL, 0,OutTable);

-- END: POSITIVE TEST(s)
Drop table tblcrosstab_test;

-- 	END: TEST SCRIPT