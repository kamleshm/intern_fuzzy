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
-- 	Test Category:		    Date Functions
--
--	Test Unit Number:		FLDateConvert-Netezza-01
--
--	Name(s):		    	FLDateConvert
--
-- 	Description:			Scalar function which converts a DATE variable into a specified format
--
--	Applications:		 
--
-- 	Signature:		    	FLDateConvert(pDate DATE, pFormat INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			11-24-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500
--set session dateform = ANSIDATE;

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   tblTestDate a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Comprehensive Test using tblTestDate 
SELECT COUNT(*)
FROM  (SELECT a.DateIN1,
              FLDateConvert(a.DateIN1, 101) AS FLDateConvert101,
              FLDateConvert(a.DateIN1, 102) AS FLDateConvert102,
              FLDateConvert(a.DateIN1, 103) AS FLDateConvert103,
              FLDateConvert(a.DateIN1, 104) AS FLDateConvert104,
              FLDateConvert(a.DateIN1, 105) AS FLDateConvert105,
              FLDateConvert(a.DateIN1, 106) AS FLDateConvert106,
              FLDateConvert(a.DateIN1, 107) AS FLDateConvert107,
              FLDateConvert(a.DateIN1, 110) AS FLDateConvert110,
              FLDateConvert(a.DateIN1, 111) AS FLDateConvert111,
              FLDateConvert(a.DateIN1, 112) AS FLDateConvert112
       FROM   tblTestDate a
       ) AS a;

---- Positive Test 1: Comprehensive Test using tblTestDate 
SELECT COUNT(*)
FROM  (SELECT a.DateIN1,
              FLDateConvert(a.DateIN1, 101) AS FLDateConvert101,
              FLDateConvert(a.DateIN1, 102) AS FLDateConvert102,
              FLDateConvert(a.DateIN1, 103) AS FLDateConvert103,
              FLDateConvert(a.DateIN1, 104) AS FLDateConvert104,
              FLDateConvert(a.DateIN1, 105) AS FLDateConvert105,
              FLDateConvert(a.DateIN1, 106) AS FLDateConvert106,
              FLDateConvert(a.DateIN1, 107) AS FLDateConvert107,
              FLDateConvert(a.DateIN1, 110) AS FLDateConvert110,
              FLDateConvert(a.DateIN1, 111) AS FLDateConvert111,
              FLDateConvert(a.DateIN1, 112) AS FLDateConvert112
       FROM   tblTestDate a
       ) AS a;


---- Positive Test 2: Manual Example
--- Same Output, Good
SELECT a.ObsID, a.DateIN1,
       FLDateConvert(a.DateIN1, 101) AS FLDateConvert101,
       FLDateConvert(a.DateIN1, 102) AS FLDateConvert102,
       FLDateConvert(a.DateIN1, 103) AS FLDateConvert103,
       FLDateConvert(a.DateIN1, 104) AS FLDateConvert104,
       FLDateConvert(a.DateIN1, 105) AS FLDateConvert105,
       FLDateConvert(a.DateIN1, 106) AS FLDateConvert106,
       FLDateConvert(a.DateIN1, 107) AS FLDateConvert107,
       FLDateConvert(a.DateIN1, 110) AS FLDateConvert110,
       FLDateConvert(a.DateIN1, 111) AS FLDateConvert111,
       FLDateConvert(a.DateIN1, 112) AS FLDateConvert112
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 3: Test for lower bound of input date
SELECT  DATE '0001-01-01' AS DateIN1,
       FLDateConvert(DateIN1, 101) AS FLDateConvert101,
       FLDateConvert(DateIN1, 102) AS FLDateConvert102,
       FLDateConvert(DateIN1, 103) AS FLDateConvert103,
       FLDateConvert(DateIN1, 104) AS FLDateConvert104,
       FLDateConvert(DateIN1, 105) AS FLDateConvert105,
       FLDateConvert(DateIN1, 106) AS FLDateConvert106,
       FLDateConvert(DateIN1, 107) AS FLDateConvert107,
       FLDateConvert(DateIN1, 110) AS FLDateConvert110,
       FLDateConvert(DateIN1, 111) AS FLDateConvert111,
       FLDateConvert(DateIN1, 112) AS FLDateConvert112;
       
---- Positive Test 4: Test for upper bound of input date
SELECT  DATE '9999-12-31' AS DateIN1,
       FLDateConvert(DateIN1, 101) AS FLDateConvert101,
       FLDateConvert(DateIN1, 102) AS FLDateConvert102,
       FLDateConvert(DateIN1, 103) AS FLDateConvert103,
       FLDateConvert(DateIN1, 104) AS FLDateConvert104,
       FLDateConvert(DateIN1, 105) AS FLDateConvert105,
       FLDateConvert(DateIN1, 106) AS FLDateConvert106,
       FLDateConvert(DateIN1, 107) AS FLDateConvert107,
       FLDateConvert(DateIN1, 110) AS FLDateConvert110,
       FLDateConvert(DateIN1, 111) AS FLDateConvert111,
       FLDateConvert(DateIN1, 112) AS FLDateConvert112;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input For Format Indicator
--- Return expected error msg, Good
SELECT a.ObsID, a.DateIN1,
       FLDateConvert(a.DateIN1, 200) AS FLDateConvert101
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateConvert(a.DateIN1, 101.0) AS FLDateConvert101
FROM tblTestDate a
ORDER BY 1;

SELECT a.ObsID, a.DateIN1,
       FLDateConvert(a.DateIN1, NULL) AS FLDateConvert101
FROM tblTestDate a
ORDER BY 1;

---- Negative Test 2: Invalid Date Input
--- Return expected error msg, Good
SELECT a.ObsID, a.DateIN1,
       FLDateConvert(NULL, 101) AS FLDateConvert101
FROM tblTestDate a
ORDER BY 1;

SELECT FLDateConvert('2010', 101);

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
