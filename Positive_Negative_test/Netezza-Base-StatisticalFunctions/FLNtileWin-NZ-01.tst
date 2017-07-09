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
--	Test Unit Number:		FL-Netezza-01
--
--	Name(s):		    	FLNtileWin
--
-- 	Description:			Assigns each observation in a data series to an Ntile bucket.
--	Applications:		 
--
-- 	Signature:		    	FLNtileWin(B DOUBLE PRECISION, 
--									C INT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			INT
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good

select FLNtileWin(ClosePrice,4) over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10;

---- Positive Test 2: Returns expected result
--- Return expected results, Good

select FLNtileWin(ClosePrice,4.5) over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10;
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Requested Ntile should be greater than 1
select FLNtileWin(ClosePrice,-4) over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
