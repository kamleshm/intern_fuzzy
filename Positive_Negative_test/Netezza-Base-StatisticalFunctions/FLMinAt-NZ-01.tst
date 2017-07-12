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
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FLMinAt-TD-01
--
--	Name(s):		    	FLMinAt
--
-- 	Description:			Aggregate function which returns the index of the minimum value of a data series. If there are multiple minimum values, it returns the index corresponding to the first minimum
--
--	Applications:		 
--
-- 	Signature:		    	FLMinAt(pIndex BIGINT, pValue DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			BIGINT
--
--	Last Updated:			07-11-2017
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--  Author:				<Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT
\time
-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- SELECT COUNT(*) AS CNT,
--        CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Result should be 1
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 2: Min At of 0.0 * Value, Result should be 1 (returns the index corresponding to the first minimum.)
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, a.SerialVal * -0.0),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 3: Min At ties, Result should be 1 (returns the index corresponding to the first minimum.)
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, CASE WHEN a.SerialVal < 5 THEN 1 ELSE a.SerialVal END),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 4: Min At of -1.0 * Value, Result should be 10
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, a.SerialVal * -1.0),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 5: Min At of Value - 10, Result should be 1
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, a.SerialVal - 10),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 6: Multiple a very small number, Result should be 1
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, SerialVal * 1e-100),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Positive Test 7: Multiple a very large number, Result should be 1
--- Return expected result, Good
SELECT  FLMinAt(a.SerialVal, a.SerialVal * 1e100),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output 0 value, Good
SELECT  FLMinAt(a.SerialVal, a.RandVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Invalid Data type:Input Non-Integer for 1st Argument
--- Return expected error, Good
SELECT  FLMinAt(a.RandVal, a.SerialVal),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 3a: Invalid Data type: Input VarChar for 2nd Argument
--- Return expected error, Good
SELECT  FLMinAt(a.ObsID, a.City)
FROM    tblCustData a;

---- Negative Test 3b: Invalid Data type: Input VarChar for 2nd Argument
--- Return expected error, Good
SELECT  FLMinAt(a.SerialVal, CAST (a.RandVal AS VARCHAR(30))),
        COUNT(*)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
