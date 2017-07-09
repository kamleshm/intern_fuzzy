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
--	Test Unit Number:		FLLastValue-Netezza-01
--
--	Name(s):		    	FLLastValue
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
--	Last Updated:			07-05-2017
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

---- Positive Test 1: Returns value.
SELECT FLLastValue(a.ObsID, a.DateTS1) FROM tblTestDate a;

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Invalid parameter for 2 position

SELECT FLLastValue(a.ObsID, 1) FROM tblTestDate a;

-- END: NEGATIVE TEST(s)
\time
--END: TEST SCRIPT(S)
