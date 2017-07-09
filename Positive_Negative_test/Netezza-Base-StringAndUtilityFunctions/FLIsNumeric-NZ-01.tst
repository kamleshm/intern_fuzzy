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
--	Test Unit Number:		FLIsNumeric-Netezza-01
--
--	Name(s):		    	FLIsNumeric
--
-- 	Description:			Scalar Function. Determines if the input string is a valid decimal number
--
--	Applications:		 
--
-- 	Signature:		    	FLIsNumeric(pNum VARCHAR(32))
--
--	Parameters:		    	See Documentation
--
--	Return value:			'False' => String is not a valid decimal number. 'True' => String is a valid decimal number.
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same outputs, Good
SELECT FLIsNumeric('1234.250'),	
       FLIsNumeric('12345G12'),	
       FLIsNumeric('45321E12'),	
       FLIsNumeric('45321ABC'),
       FLIsNumeric('123445'),
	   FLIsNumeric('12.3445E12');
	   
---- Positive Test 2: Case Sensitivity
--- No, Good
SELECT FLIsNumeric('1234.250'),	
       FLIsNumeric('12345g12'),	
       FLIsNumeric('45321e12'),	
       FLIsNumeric('45321abc'),
       FLIsNumeric('123445'),
	   FLIsNumeric('12.3445e12');

---- Positive Test 3: Negative
--- Return expected results, Good
SELECT FLIsNumeric('-1234.250'),	
       FLIsNumeric('-12345G12'),	
       FLIsNumeric('-45321E12'),
       FLIsNumeric('-45321ABC'),
       FLIsNumeric('-123445'),
	   FLIsNumeric('-12.3445E12');
	   
---- Positive Test 4: Other Forms
--- Return expected results, Good
SELECT FLIsNumeric('1e-4');

---- Positive Test 5: check for large numbers
--- Return expected results, Good
SELECT LENGTH('120000000000000000000000000000000034.25000000000000000000000098') As Len,
	    FLIsNumeric('120000000000000000000000000000000034.25000000000000000000000098') As isNum,
	    FLIsNumeric( '12000000000000000000000000000000034. 25000000000000000000000098') as isNotNum;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

--- Negative Test 1: Null and Empty Input
--- Return expected results, Good
SELECT FLIsNumeric(NULL),	
       FLIsNumeric('');
       
       
 ---- Negative Test 2: check for input overflow
--- Return expected results, Good
 SELECT LENGTH('12000000000000000000000000000000000034..  2500000000000000000000000098') As Str1;
 SELECT FLIsNumeric('12000000000000000000000000000000000000000034..  2500000000000000000000000098') As Str1;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
