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
--	Test Unit Number:		FLModeUdt-TD-01
--
--	Name(s):		    	FLModeUdt
--
-- 	Description:			Aggregate function which calculates the mode of a data series
--
--	Applications:		 
--
-- 	Signature:		    	FLModeUdt (pGroupID BIGINT, pVal DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			RETURNS TABLE (oGroupID BIGINT, oMode DOUBLE PRECISION)
--
--	Last Updated:			01-28-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--  Author:					<Diptesh.Nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
  --     CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Values with Null
--- Output 10
WITH z (pGroupID, pSerialVal)
AS (SELECT 1 as pGroupID,
			CASE WHEN a.SerialVal<10 THEN NULL ELSE a.SerialVal END as pSerialVal 
			FROM fzzlSerial a 
			WHERE a.SerialVal<=100 ) 
SELECT a.* 
FROM  (SELECT z.pGroupId, z.pSerialVal,
				NVL(LAG(0) OVER (PARTITION BY z.pGroupId ORDER BY z.pGroupId),1) AS begin_flag,
				NVL(LEAD(0) OVER (PARTITION BY z.pGroupId ORDER BY z.pGroupId),1) AS end_flag 
		FROM z) as zz
		, TABLE (FLModeUdt(zz.pGroupId,zz.pSerialVal,zz.begin_flag,zz.end_flag)) AS a;
		
---- Positive Test 2: Each value occurs once
--- Return expected results, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, a.SerialVal
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 3: Positive test cases with one mode, Result should be 1
--- Return expected result, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 4: Multiple modes, 1 and 2
--- Return 1 and 2, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal <= 10 THEN 1 WHEN a.SerialVal> 90 THEN 2 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 5: Mode of -1.0 * Value, Result should be -1
--- Return expected results, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, -1.0 *z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 6: Mode of Value + 1.0, Result should be 2
--- Return expected result, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pSerialVal + 1.0) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 7: Mode of -1.0 * Value + 1.0, Result should be 0
--- Return expected result, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, -1.0 * z.pSerialVal + 1.0) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Positive Test 8: Multiply by a very small number, Result should be 1e-100
--- Return expected result, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, 1e-100 * z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID)  AS a;

---- Positive Test 9: Multiply by a very large number, Result should be 1e100
--- Return expected result, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, 1e100 * z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID) AS a;

---- Positive Test 10: Add a very large number, Result should be 1e100+1
--- Precision issue of double SO output 1e100, Which is expected
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, 1e100 + z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID) AS a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- No Output
WITH z (pGroupID, pRandVal) AS (
SELECT 1, a.RandVal
FROM fzzlSerial a
WHERE a.SerialVal <= -1
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pRandVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID )  AS a;

---- Negative Test 2: Value(Double Precision) out of range: Mode of 1.0e400 * Value
--- Return expected error, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, 1e400 * z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID) AS a;

---- Negative Test 3: Value(Double Precision) out of range: Mode of 1.0e-400 * Value
--- Return expected error, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, 1e-400 * z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID) AS a;

---- Negative Test 4: Invalid Data Type: Input Varchar
--- Return expected error, Good
WITH z (pGroupID, pSerialVal) AS (
SELECT 1, CAST(CASE WHEN a.SerialVal < 10 THEN 1 ELSE a.SerialVal END AS VARCHAR(30))
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT *
FROM TABLE  (FLModeUdt(z.pGroupID, z.pSerialVal) HASH BY z.pGroupID LOCAL ORDER BY z.pGroupID) AS a;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
