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
--	Name(s):		    	FLPercRank
--
-- 	Description:			Calculates the percent rank defined as (Rank - 1) / (Number Of Observations - 1). The rank is calculated based
--							on the specified order i.e., ascending or descending.
--
--	Applications:		 
--
-- 	Signature:		    	FLPercRank(D DOUBLE PRECISION, 
--									   C CHARACTER VARYING(10))
--
--	Parameters:		    	See Documentation
--
--	Return value:			FLOAT
--
--	Last Updated:			05-03-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

-- Create table and insert values

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good
select FLPercRank(ClosePrice,'A') over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10;

---- Positive Test 2: Returns expected result
--- Return expected results, Good
select FLPercRank(ClosePrice,'D') over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Second parameter in FLPercRank can be 'A' or 'D'
select FLPercRank(ClosePrice,'XX') over (partition by TickerId ) from finstockprice order by TickerId LIMIT 10;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
