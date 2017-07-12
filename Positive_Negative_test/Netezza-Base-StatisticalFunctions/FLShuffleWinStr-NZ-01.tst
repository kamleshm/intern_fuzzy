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
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FLShuffleWinStr-Netezza-01
--
--	Name(s):		    	FLShuffleWinStr
--
-- 	Description:			Shuffled data
--
--	Applications:		 
--
-- 	Signature:		    	FLShuffleWinStr(Value INTEGER,
--										Value INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			INTEGER
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

---- Positive Test 1: Number of columns in FLSHUFFLEWINSTR() set to 3
--- Return expected results, Good
select flshufflewinstr(ClosePrice,3) over (partition by TickerId) from finstockprice order by TickerId LIMIT 10;


---- Positive Test 2: Number of columns in FLSHUFFLEWINSTR() set to 2
--- Return expected results, Good
select flshufflewinstr(ClosePrice,2) over (partition by TickerId) from finstockprice order by TickerId LIMIT 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:  Number of columns in FLSHUFFLEWINSTR() must be set
--- Error
select flshufflewinstr(ClosePrice) over (partition by TickerId) from finstockprice order by TickerId LIMIT 10;


---- Negative test 2: Number of columns in FLSHUFFLEWINSTR() must be set. No default value for null
--- No Output
select flshufflewinstr(ClosePrice,null) over (partition by TickerId) from finstockprice order by TickerId LIMIT 10;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
