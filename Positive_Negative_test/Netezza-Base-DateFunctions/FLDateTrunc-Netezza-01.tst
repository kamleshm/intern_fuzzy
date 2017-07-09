-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    Date Functions
--
--	Test Unit Number:		FLDateTrunc-Netezza-01
--
--	Name(s):		    	FLDateTrunc
--
-- 	Description:			Scalar function which truncates a DATE variable to a specified precision
--
--	Applications:		 
--
-- 	Signature:		    	FLDateTrunc(pFormat VARCHAR, pDate DATE)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Date
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


---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('yy', a.DateIN1) AS TruncYear,
        FLDateTrunc('mm', a.DateIN1) AS TruncMonth,
        FLDateTrunc('dd', a.DateIN1) AS TruncDay
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 2: Test for alternative inputs for DatePartInd
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('yyyy', a.DateIN1) AS TruncYear,
        FLDateTrunc('m', a.DateIN1) AS TruncMonth,
        FLDateTrunc('d', a.DateIN1) AS TruncDay
FROM    tblTestDate a
ORDER BY 1;

---- Positive Test 3: Test for lower bound of Date input
SELECT  Date '0001-01-01' AS DateIN1,
        FLDateTrunc('yy', DateIN1) AS TruncYear,
        FLDateTrunc('mm', DateIN1) AS TruncMonth,
        FLDateTrunc('dd', DateIN1) AS TruncDay;

---- Positive Test 4: Test for upper bound of Date input
SELECT  Date '9999-12-31' AS DateIN1,
        FLDateTrunc('yy', DateIN1) AS TruncYear,
        FLDateTrunc('mm', DateIN1) AS TruncMonth,
        FLDateTrunc('dd', DateIN1) AS TruncDay;

        
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Input for Date Part
--- Return expected error msg, Good
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('gg', a.DateIN1) AS TruncYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc(NULL, a.DateIN1) AS TruncYear
FROM    tblTestDate a
ORDER BY 1;

---- Negative Test 2: Invalid Input for Date
--- Return expected error msg, Good
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('yy', a.DateTS1) AS TruncYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('yy', NULL) AS TruncYear
FROM    tblTestDate a
ORDER BY 1;

SELECT  FLDateTrunc('yy', '2010-10-32 10:56:16') AS TruncYear;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
