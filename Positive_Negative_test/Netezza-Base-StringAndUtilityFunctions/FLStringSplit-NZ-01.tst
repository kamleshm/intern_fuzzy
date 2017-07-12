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
--	Test Unit Number:		FLStringSplit-Netezza-01
--
--	Name(s):		    	FLStringSplit
--
-- 	Description:			The extract string function is a scaler that extracts a segment from a string concatenated with delimiter
--
--	Applications:		 
--
-- 	Signature:		    	FLStringSplit(String1 VARCHAR(1000), Delimiter VARCHAR(1))
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
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

---- Positive Test 1: Split string by delimiter. Works as expected.
Select * FROM TABLE(FLSTRINGSPLIT('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|'));

---- Positive Test 2: Wrong delimiter gives the entire string
Select * FROM TABLE(FLSTRINGSPLIT('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','?'));


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Wrong delimiter
--- Result: Wrong delimiter gives the entire string
Select * FROM TABLE(FLSTRINGSPLIT('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','?'));

---- Negative Test 1: Less Argument
Select * FROM TABLE(FLSTRINGSPLIT('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|'));

---- Negative Test 2: More Argument
Select * FROM TABLE(FLSTRINGSPLIT('Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|',1));




-- END: NEGATIVE TEST(s)
\time
-- END TEST SCRIPT

