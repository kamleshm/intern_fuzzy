-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
--	Test Unit Number:		FLInStr-NZ-01
--
--	Name(s):		    	FLInStr
--
-- 	Description:			The clean string function is a scaler that removes all non-printable characters from a string and outputs a formatted string
--
--	Applications:		 
--
-- 	Signature:		    	FLInStr(String1 VARCHAR(1000))
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			07-04-2017
--
--	Author:			    	Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
-- .run file=../PulsarLogOn.sql

-- .set width 8000

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Same Output, Good
SELECT  FLInstr( 0, 'one must separate from anything that forces one to repeat No again and again', 'one') AS Search1,
        FLInstr( 23, 'one must separate from anything that forces one to repeat No again and again', 'one') AS Search2;

---- Positive Test 2: Case Sensitivity
--- Yes, Good
SELECT  FLInstr( 0, 'one must separate from anything that forces one to repeat No again and again', 'ONE') AS Search1;
		
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)		

---- Negative Test 1: Wrong Start Position
--- Return expected results, Good
SELECT  FLInstr( -1, 'One must separate from anything that forces one to repeat No again and again', 'one') AS WrongStartPos;
SELECT  FLInstr( 100000, 'One must separate from anything that forces one to repeat No again and again', 'one') AS WrongStartPos;

---- Negative Test 2: Null and Empty Input
--- Return expected results, Good
SELECT  FLInstr( 15, 'One must separate from anything that forces one to repeat No again and again', NULL) AS NullSubStr;
SELECT  FLInstr( 15, 'One must separate from anything that forces one to repeat No again and again', '') AS NullSubStr;
SELECT  FLInstr( 1, NULL, 'one') AS NullString;
SELECT  FLInstr( 1, '', 'one') AS NullString;
SELECT  FLInstr( NULL, 'one must separate from anything that forces one to repeat No again and again', 'one') AS Search1;

---- Negative Test 3: Invalid Data Type
--- Return expected results, Good
SELECT FLInstr(23.0, 'one must separate from anything that forces one to repeat No again and again', 'one') AS Search2;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
