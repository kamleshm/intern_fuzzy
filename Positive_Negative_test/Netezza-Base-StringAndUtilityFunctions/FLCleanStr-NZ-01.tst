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
--	Test Unit Number:		FLCleanStr-TD-01
--
--	Name(s):		    	FLCleanStr
--
-- 	Description:			The clean string function is a scaler that removes all non-printable characters from a string and outputs a formatted string
--
--	Applications:		 
--
-- 	Signature:		    	FLCleanStr(String1 VARCHAR(1000))
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
--- Return same results, Good
SELECT 	FLCleanStr('example6  #  È¿ïü .44 %(') AS CleanStr1,
        FLCleanStr('7890 %åÓë')                AS CleanStr2,
        FLCleanStr('example5 TOC ¤ü¹È¿ïü')     AS CleanStr3,
        FLCleanStr('example3 î8×é¶Óë')         AS CleanStr4;
		
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)		

---- Negative Test 1: Invalid Input
--- Return expected results, Good
SELECT FLCleanStr('');
SELECT FLCleanStr(NULL);
SELECT FLCleanStr(1234);

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
