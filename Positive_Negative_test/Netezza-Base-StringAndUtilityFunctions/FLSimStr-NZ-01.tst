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
--	Test Unit Number:		FLSimStr-Netezza-01
--
--	Name(s):		    	FLSimStr
--
-- 	Description:			This scalar generates a random string of specified length.
--
--	Applications:		 
--
-- 	Signature:		    	FLSimStr(Seed DOUBLE PRECISION,
--												StrLen INTEGER,
--												FixedLength INTEGER,
--												Case INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			07-05-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Generate random string.
SELECT a.SerialVal,FLSimStr(RANDOM(), 20, 1, 1)FROM fzzlSerial a WHERE a.SerialVal <= 10 ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: 2 nd parameter cannot be less than 1
SELECT a.SerialVal,FLSimStr(RANDOM(), -10, 1, 1)FROM fzzlSerial a WHERE a.SerialVal <= 10 ORDER BY 1;

---- Negative Test 2: 3 rd parameter must be 1 or 2
SELECT a.SerialVal,FLSimStr(RANDOM(), 20, 10, 1)FROM fzzlSerial a WHERE a.SerialVal <= 10 ORDER BY 1;

---- Negative Test 3: 4 th parameter must be 1 or 2 or 3
SELECT a.SerialVal,FLSimStr(RANDOM(), 20, 1, 5)FROM fzzlSerial a WHERE a.SerialVal <= 10 ORDER BY 1;




-- END: NEGATIVE TEST(s)
\time
--END TEST SCRIPT
