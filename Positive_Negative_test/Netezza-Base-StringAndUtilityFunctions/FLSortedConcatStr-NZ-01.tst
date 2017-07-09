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
--	Test Unit Number:		FLSortedConcatStr-Netezza-01
--
--	Name(s):		    	FLSortedConcatStr
--
-- 	Description:			Concatenates and sorts into one string based on ascending/descending order parameter.
--
--	Applications:		 
--
-- 	Signature:		    	FLSortedConcatStr(String STRING,Delimiter STRING,
--												Order CHAR)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			05-02-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns Concated string in descending order.The strings are seperated by comma. Repetitive string are considered only once irrespective of capital/small
SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w',',','d');

---- Positive Test 2: Returns Concated string in ascending order.The strings are seperated by comma. Repetitive string are considered only once irrespective of capital/small
SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w',',','a');

---- Positive Test 3: Returns Concated string in ascending order(When null is 3 rd parameter).The strings are seperated by comma. Repetitive string are considered only once irrespective of capital/small
SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w',',',null);



---- Positive Test 4: Returns Concated string in ascending order(When null is 3 rd parameter).The strings are seperated by comma. Repetitive string are considered only once irrespective of capital/small
SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,f,F,f,w',',',null);




-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Delimiter(2 nd parameter) not present.

SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w','*','a

---- Negative Test 2:3 rd parameter can be 'a', 'd' or null.

SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w',',','s');

---- Negative Test 3: More parameter given.

SELECT FLSORTEDCONCATSTR('ABC,ACD,AS,a,F,f,f,w',',','s','abc');

-- END: NEGATIVE TEST(s)
