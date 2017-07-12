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
--	Test Unit Number:		FLRight-Netezza-01
--
--	Name(s):		    	FLRight
--
-- 	Description:			This scalar fetches string from the end position based on second parameter.
--
--	Applications:		 
--
-- 	Signature:		    	FLRight(String STRING,
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
Select FLRIGHT('ABCDEFGH',0);

---- Positive Test 2: Returns last 2 character.
Select FLRIGHT('ABCDEFGH',2);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Invalid parameter for 2 position
Select FLRIGHT('ABCDEFGH',-1);

-- END: NEGATIVE TEST(s)
\time
-- END TEST SCRIPT
