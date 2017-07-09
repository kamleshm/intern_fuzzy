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
--	Test Unit Number:		FLConcatString-Netezza-01
--
--	Name(s):		    	FLConcatString
--
-- 	Description:			The concat string function is an aggregate that joins the values of a string column from a table into an output string using a user supplied delimiter to separate the fields
--
--	Applications:		 
--
-- 	Signature:		    	FLConcatString(String1 VARCHAR(1000), Delimiter VARCHAR (1))
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			04-26-2017
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--  Author:           <Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 8000

-- SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   tblString a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Return same results, Good
SELECT	FLConcatString(String1,'|') AS ConcatString 
FROM    tblString; 

--Positive test case 2 
--use the same one but try to get an order in concat string
SELECT	FLConcatString(a.String1,'|') AS ConcatString 
FROM (
                 SELECT TOP 10 String1 as String1
                  FROM    tblString
                 ORDER BY 1) as a; 

--Positive test case 3
--select  names and concat them  for a large number of data

SELECT	FLConcatString(a.companyname,'|') AS ConcatString 
FROM 
( SELECT  Top 30
  companyname as companyname 
  FROM       finPubco
  ORDER BY 1
) as a;

--Positive test case 4
--select the top names alphabetically and concat them  for a large number of data
SELECT	FLConcatString(a.companyname,'|') AS ConcatString 
FROM 
( SELECT  Top 30
  companyname as companyname 
  FROM       finPubco
  ORDER BY 1
) as a;

--Positive test case 5 
--(Resolution to JIRA TD-82) example similar to the test case listed there
SELECT SUBSTRING(String1 FROM 1 FOR 1) || ':' (TITLE ''),
FLConcatString(String1,'|') (TITLE 'FLConcatString')
FROM tblString
ORDER BY 1
GROUP BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input For Input String Column
--- Return expected results, Good
SELECT	FLConcatString('String1','|') AS ConcatString
FROM    tblString; 

SELECT	FLConcatString('','|') AS ConcatString 
FROM    tblString; 

SELECT	FLConcatString(NULL,'|') AS ConcatString
FROM    tblString; 


---- Negative Test 2: Invalid Input For Delimiter
--- Return expected results, Good
SELECT	FLConcatString(String1,'') AS ConcatString 
FROM    tblString; 

SELECT	FLConcatString(String1,NULL) AS ConcatString 
FROM    tblString; 

--Negative test case 3
--try  using  more than 1 character as delimiter 
--it should ignore the other characters after the 1st
SELECT	FLConcatString(a.companyname,'|pppp') AS ConcatString 
FROM 
( SELECT  Top 25
  companyname as companyname 
  FROM       finPubCo
  ORDER BY 1
) as a;

---Negative case 4
--When the input causes the concat string exceeds the max allowded value for the output 
SELECT FLConcatString(a.CustName, ',') AS ConcatString
FROM (
		SELECT 'abcdefghijklmnopqrstuvwxyz' AS CustName,
				a.SerialVal AS CustNo
		FROM 	fzzlserial a
	  ) AS a;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
