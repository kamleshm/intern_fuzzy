-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
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
--	Test Unit Number:		FLConcatStr-Netezza-01
--
--	Name(s):		    	FLConcatStr
--
-- 	Description:			Concatenates into one string.
--
--	Applications:		 
--
-- 	Signature:		    	FLConcatStr(String STRING,
--												Position INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns Concated string.
SELECT FLConcatStr(a.String1,'|') AS ConcatString FROM tblString a;

--Positive test case 2 
--use the same one but try to get an order in concat string
SELECT FLConcatStr(a.String1,'|') AS ConcatString 
FROM (
SELECT String1 as String1
FROM    tblString
ORDER BY 1
LIMIT 10) 
AS a;

--Positive test case 3
--select  names and concat them  for a large number of data
SELECT FLConcatStr(a.companyname,'|') AS ConcatString 
FROM (
SELECT  
companyname as companyname 
FROM       finPubco
LIMIT 30)
AS a;

--Positive test case 4
--select the top names alphabetically and concat them  for a large number of data
SELECT FLConcatStr(a.companyname,'|') AS ConcatString 
FROM ( 
SELECT 
companyname as companyname 
FROM       finPubco
ORDER BY 1
LIMIT 30)
AS a;

--Positive test case 5 
--(Resolution to JIRA TD-82) example similar to the test case listed there
--SELECT SUBSTRING(DatabaseNameI FROM 1 FOR 1) || ':' (TITLE ''),
--FLConcatStr(DatabaseNameI,'|') (TITLE 'Databases')
--FROM DBC.DBase
--ORDER BY 1
--GROUP BY 1

SELECT SUBSTRING(string1 from 1 for 1),
	FLConcatStr(string1,'|') 
FROM tblstring 
GROUP BY 1  
ORDER BY 1;

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:More parameter given

SELECT FLConcatStr(a.String1,'|','A') AS ConcatString
FROM tblString a;

---- Negative Test 2: Invalid Input For Input String Column

---- Negative Test 2a
--- Return expected results, Good
SELECT FLConcatStr('String1','|') AS ConcatString
FROM    tblString;

---- Negative Test 2b
--- Return expected results, Good
SELECT FLConcatStr('','|') AS ConcatString 
FROM    tblString;

---- Negative Test 2c
--- Return expected results, Good
SELECT FLConcatStr(NULL,'|') AS ConcatString
FROM    tblString;


---- Negative Test 3: Invalid Input For Delimiter
--- Return expected results, Good
--- To be investigated
SELECT FLConcatStr(String1,'') AS ConcatString 
FROM    tblString;

SELECT FLConcatString(String1,NULL) AS ConcatString 
FROM    tblString;


--Negative test case 4 :try  using  more than 1 character as delimiter 
--it should ignore the other characters after the 1st
SELECT FLConcatStr(a.companyname,'|pppp') AS ConcatString 
FROM 
( SELECT
  companyname as companyname 
  FROM       finPubCo
  ORDER BY 1
  LIMIT 25
) 
AS a;

---Negative case 5
--When the input causes the concat string exceeds the max allowded value for the output 
SELECT FLConcatStr(a.CustName, ',') AS ConcatString
FROM (
SELECT 'abcdefghijklmnopqrstuvwxyz' AS CustName,
a.SerialVal AS CustNo
FROM  fzzlserial a
)
AS a;

-- END: NEGATIVE TEST(s)
\time
--      END: TEST SCRIPT

