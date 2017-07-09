-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    Date Functions
--
--	Test Unit Number:		FLIntToDate-TD-01
--
--	Name(s):		    	FLIntToDate
--
-- 	Description:			Scalar function which converts an integer to date. The integer could be positive or negative and represents the difference in days from Jan1, 1990. The scalar function return the date Jan 1, 1990 for the integer value zero.
--
--	Applications:		 
--
-- 	Signature:		    	FLIntToDate(pNumOfDays INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Date
--
--	Last Updated:			05-11-2017
--
--	Author:			    	<Zhi.Wang@fuzzyl.com, Joydeep.Das@fuzzyl.com>, Sam Sharma
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500
-- set session dateform = ANSIDATE ; 

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT FLIntToDate(-726467) AS FLIntToDate1,
FLIntToDate(-726468) AS FLIntToDate2,
FLIntToDate(0) AS FLIntToDate3,
FLIntToDate(5678) AS FLIntToDate4,
FLIntToDate(2925591) AS FLIntToDate5,
FLIntToDate(2925592) AS FLIntToDate6;

---- Positive Test 2: And more for additional coverage
SELECT  FLIntToDate(-72646) AS FLIntToDate1,
        FLIntToDate(-42646) AS FLIntToDate2,
        FLIntToDate(992559) AS FLIntToDate3;

---- Positive Test 3: Additional coverage, multiples of 10x
SELECT FLIntToDate(10000 ); 
SELECT FLIntToDate(100000 ); 
SELECT FLIntToDate(1000000 ); 
SELECT FLIntToDate(10000000);

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Invalid Data Type
--- Return expected error msg, Good		
SELECT  FLIntToDate(NULL) AS FLIntToDate1;
SELECT  FLIntToDate(1.2) AS FLIntToDate1;
-- SELECT  FLIntToDate('2010: type') AS FLIntToDate1;
-- SELECT  FLIntToDate(CAST ('01/01/0001' AS DATE)) AS FLIntToDate1;
-- SELECT  FLIntToDate(CAST ('0001-01-01 00:00:00.000000' AS TIMESTAMP)) AS FLIntToDate1;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
