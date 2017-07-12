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
--	Test Unit Number:		FLFormatLong-NZ-01
--
--	Name(s):		    	FLFormatLong
--
-- 	Description:			Return string format of long type.
--
--	Applications:		 
--
-- 	Signature:		    	FLFormatLong(NUMBER BIGINT)
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

---- Positive Test 1: Returns positive value.
SELECT flformatlong(400000);

---- Positive Test 2: Returns positive value.
SELECT flformatlong(0400000);

---- Positive Test 3: Returns positive value after SUM.
SELECT flformatlong(500+123);

---- Positive Test 4: Returns positive value after removing decimal.
SELECT flformatlong(400.1555555555555555553);

---- Positive Test 5: Returns positive value after round off.
SELECT flformatlong(400.7555555555555555553);

---- Positive Test 6: Returns NULL.
SELECT flformatlong(0);



-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Returns error
SELECT flformatlong(4,000);

---- Negative Test 2:Returns error
SELECT flformatlong(4,0+40);

---- Negative Test 3:Numeric value out of range
SELECT flformatlong(10e308);

---- Negative Test 4:Returns NULL value
SELECT flformatlong(10e-308);

-- END: NEGATIVE TEST(s)
\time
-- END TEST SCRIPT
