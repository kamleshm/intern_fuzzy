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
-- 	Test Category:			String Functions
--
--	Test Unit Number:		FLGetFlat-Netezza-01
--
--	Name(s):		    	FLGetFlat
--
-- 	Description:			String function which returns the value of argument identified by a number
--
--	Applications:		 
--
-- 	Signature:		    	FLGetFlat(int ParamID, String Param1, String Param2, String Param3, ….String Param12)
--
--	Parameters:		    	See Documentation
--
--	Return value:			String
--
--	Last Updated:			11-24-2014
--
--	Author:			    	Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

-- Positive test 1: Manual example
-- Expected result: good
SELECT FLGetFlat(2,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');

-- Positive test 2: Boundary conditions
-- Expected result: good
SELECT FLGetFlat(1,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');
SELECT FLGetFlat(12,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');

-- END: POSITIVE TEST(s)
-- BEGIN: NEGATIVE TEST(s)

-- Negative test 1: out of bounds
SELECT FLGetFlat(0,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');
SELECT FLGetFlat(13,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');

-- Negative test 2: invalid data types
SELECT FLGetFlat(1.2,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');
SELECT FLGetFlat(NULL,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');
SELECT FLGetFlat(2,'one'NULL,'three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');
SELECT FLGetFlat(2,'one','5','three','four','five','six',
'seven','eight','nine','ten','eleven','twelve');

-- Negative test 3: invalid number of arguments
SELECT FLGetFlat(2,'one','two','three','four','five','six',
'seven','eight','nine','ten','eleven');
SELECT FLGetFlat(2,'one','two');

-- END: Negative TEST(s)