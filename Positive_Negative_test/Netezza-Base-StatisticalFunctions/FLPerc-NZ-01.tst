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
--	Name(s):		    	FLPerc
--
-- 	Description:			Aggregate which calculates the percentile value.
--
--	Applications:		 
--
-- 	Signature:		    	FLPerc(A BIGINT,
--									 B DOUBLE PRECISION, 
--									C BIGINT, 
--									D DOUBLE PRECISION)
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
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good
select FLPERC(dateidx, ClosePrice, 1, 0.1) from finstockprice order by 1;



-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Fourth parameter should be less than 1
select FLPERC(dateidx, ClosePrice, 1, 1.5) from finstockprice order by 1;

---- Negative Test 2: Floating point conversion out of range
select FLPERC(dateidx, ClosePrice, 10e100, 0.1) from finstockprice order by 1;

---- Negative Test 3: Numeric value out of range
select FLPERC(dateidx, ClosePrice, 10e1000, 0.1) from finstockprice order by 1;

---- Negative Test 4: Third parameter should integer
select FLPERC(dateidx, ClosePrice, 10e-100, 0.1) from finstockprice order by 1;


-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
