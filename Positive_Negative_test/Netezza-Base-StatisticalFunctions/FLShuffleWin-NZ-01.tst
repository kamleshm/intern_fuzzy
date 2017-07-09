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
--	Test Unit Number:		FLShuffleWin-Netezza-01
--
--	Name(s):		    	FLShuffleWin
--
-- 	Description:			Output as Shuffled data
--
--	Applications:		 
--
-- 	Signature:		    	FLShuffleWin(val INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			INTEGER
--
--	Last Updated:			05-03-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

-- Create table and insert values
drop table numdata;
create table numdata ( num1 integer, num2 double precision ) distribute on random ;
insert into numdata values (3, 22);
insert into numdata values (3, 22);
insert into numdata values (3, 21);
insert into numdata values (4, 20);
insert into numdata values (4, 22);
insert into numdata values (4, 22);

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good
select flshufflewin(num2) over (partition by  num1) from numdata order by num1 ;

---- Positive Test 2: Returns expected result
--- Return expected results, Good
select flshufflewin(num2) over (partition by  num2,num1) from numdata order by num1 ;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Rank Order can be 'A' or 'D'
--- flshufflewin takes only 1 parameter
select flshufflewin(num2,num1) over (partition by  num1) from numdata order by num1 ;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
