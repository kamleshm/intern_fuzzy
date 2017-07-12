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
--	Test Unit Number:		FLLeft-Netezza-01
--
--	Name(s):		    	FLLeft
--
-- 	Description:			This scalar fetches string from the start position based on second parameter.
--
--	Applications:		 
--
-- 	Signature:		    	FLLeft(String STRING,
--												Position INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			07-11-2017
--
--	Author:			    	Diptesh Nath,Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns NULL string.
Select FLLEFT('ABCDEFGH',0);

---- Positive Test 2: Returns last 2 character.
Select FLLEFT('ABCDEFGH',2);

---- Positive Test 3: Returns the full string.
Select FLLEFT('ABCDEFGH',1000);

---- Positive Test 4: Returns the first 2 digits.
Select FLLEFT(12345,2);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Invalid parameter for 2 position
Select FLLEFT('ABCDEFGH',-1);

---- Negative Test 2:Value out of range
Select FLLEFT('ABCDEFGH',10e308);

---- Negative Test 3:Returns NULL
Select FLLEFT('ABCDEFGH',10e-308);

---- Negative Test 4:Bad data type
Select FLLEFT(123xz45,2);

-- END: NEGATIVE TEST(s)
\time
-- END TEST SCRIPT
