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
--	Test Unit Number:	FLADTest-TD-03
--
--	Name(s):		FLADTest
--
-- 	Description:	    	FLADTest performs Anderson Darling Test. Anderson Darling Test is 
--				used to test if a given sample of data is drawn from a specified 
--				normal distribution.
--	Applications:	    	
--
-- 	Signature:		FLADTest(IN TableName VARCHAR(256), IN ValCol VARCHAR(31),
--				IN Mean DOUBLE PRECISION, IN StdDev DOUBLE PRECISION,
--				IN WhereClause VARCHAR(200), IN GroupBy VARCHAR(200),
--				IN TableOutput BYTEINT, OUT OutTable VARCHAR(256))
--
--	Parameters:		See Documentation
--
--	Return value:	    	Table
--
--	Last Updated:	    	08-28-2014
--
--	Author:			<zhi.wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql


-- TD-206
-- BEGIN: POSITIVE TEST(s)
Drop table tblFLADTestdata;

CREATE MULTISET TABLE tblFLADTestdata 
     (baby_id INTEGER,
	  birth_weight FLOAT)
PRIMARY INDEX ( baby_id );

 INSERT INTO tblFLADTestdata VALUES (01, 3334)
;INSERT INTO tblFLADTestdata VALUES (02, 3554)
;INSERT INTO tblFLADTestdata VALUES (03, 3625)
;INSERT INTO tblFLADTestdata VALUES (04, 3837)
;INSERT INTO tblFLADTestdata VALUES (05, 3838);


CALL FLADTest('tblFLADTestdata',
                 'birth_weight',
                 3.27595454545455E 003,
                 5.28032458240593E 002,
                 '',
                 null,
                 0,
                 OutTable);

Drop table tblFLADTestdata;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
