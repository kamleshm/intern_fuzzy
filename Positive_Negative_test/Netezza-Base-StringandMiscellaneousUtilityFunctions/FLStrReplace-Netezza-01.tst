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
--	Test Unit Number:		FLStrReplace-Netezza-01
--
--	Name(s):		    	FLStrReplace
--
-- 	Description:			String function which Replaces a substring within the input string with another substring
--
--	Applications:		 
--
-- 	Signature:		    	FLStrReplace(Varchar InputString, Varchar ReplaceWhat, Varchar ReplaceWith)
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

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

-- Positive test 1: Manual example
-- Expected result: good
SELECT FLStrReplace('OneTwoThreeFour', 'Three', 'TwoAndHalf');

-- Positive test 2: Empty strings or NULL values
-- Expected result: good
SELECT FLStrReplace('', 'Three', 'TwoAndHalf');
SELECT FLStrReplace('OneTwoThreeFour', '', 'TwoAndHalf');
SELECT FLStrReplace('OneTwoThreeFour', 'Three', '');
SELECT FLStrReplace(NULL, 'Three', 'TwoAndHalf');
SELECT FLStrReplace('OneTwoThreeFour', 'Three', NULL);

---- Positive Test 3: Case Sensitivity
SELECT FLStrReplace('Home Depot|WAL-MART|DUANE|MARTHA|WALMART|DWAYNE|MARHTA|', 'E', 'Z')

-- END: POSITIVE TEST(s)
-- BEGIN: NEGATIVE TEST(s)

-- Negative test 2: invalid data types
SELECT FLStrReplace(4, 'Three', 'TwoAndHalf');
SELECT FLStrReplace('OneTwoThreeFour', 4, 'TwoAndHalf');
SELECT FLStrReplace('OneTwoThreeFour', 'Three', 4);

-- Negative test 3: invalid number of arguments
SELECT FLStrReplace('OneTwoThreeFour', 'Three', 'TwoAndHalf', 'abc');
SELECT FLStrReplace('OneTwoThreeFour', 'Three');

-- END: Negative TEST(s)
