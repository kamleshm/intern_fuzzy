-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    String Functions
--
--	Test Unit Number:		FLExtractStr-Netezza-01
--
--	Name(s):		    	FLExtractStr
--
-- 	Description:			The extract string function is a scaler that extracts a segment from a string concatenated with delimiter
--
--	Applications:		 
--
-- 	Signature:		    	FLExtractStr(String1 VARCHAR(1000), Delimiter VARCHAR(1), StringPos BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			04-26-2017
--
--	Author:			    	<gandhari.sen@fuzzyl.com>
--  Author:					<Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 8000

-- SELECT COUNT(*) AS CNT,
--        CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   tblString a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same outputs, Good
SELECT FLExtractStr('一二三一二一一二三四二三四三四四|WAL-MART|DUANE|MARTHA|你好你好你好| DWAYNE|MARHTA|','|',5) AS ExtractPos5,
       FLExtractStr('Home Depot|你|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|',2) AS ExtractPos2,
       FLExtractStr('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|',';',5) AS WrongDelimiter,
       FLExtractStr('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|一二三一二一一二三四二三四三四四','|',7) AS ExtractLastWithNoDelim;

	   
---- Positive Test 2: Duplicate Delimiter
--- Return expected results, Good
SELECT FLExtractStr('Home Depot|||WAL-MART|DUANE|MARTHA|一二三一二一一二三四二三四三四四| DWAYNE|MARHTA|','|',5) AS ExtractPos5,
       FLExtractStr('Home Depot||你好你好你好|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|',2) AS ExtractPos2;

---- Positive Test 3: Mix Delimiters
--- Return expected results, Good
SELECT FLExtractStr('Home Depot,WAL-MART,DUANE,MARTHA,WALMART, DWAYNE,MARHTA,',',',5) AS ExtractDel1,
       FLExtractStr('Home Depot,|WAL-MART,|DUANE,|MARTHA,|你好你好你好,| DWAYNE,|MARHTA,|','|',5) AS ExtractDel2,
       FLExtractStr('Home Depot,|WAL-MART,|你好你好你好,|MARTHA,|WALMART,| DWAYNE,|MARHTA,|',',',5) AS ExtractDel3;

-- END: POSITIVE TEST(s)


-- END: NEGATIVE TEST(s)

