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
--	Test Unit Number:		FL-Netezza-01
--
--	Name(s):		    	FLPercRank
--
-- 	Description:			Calculates the percent rank defined as (Rank - 1) / (Number Of Observations - 1). The rank is calculated based
--							on the specified order i.e., ascending or descending.
--
--	Applications:		 
--
-- 	Signature:		    	FLPercRank(D DOUBLE PRECISION, 
--									   C CHARACTER VARYING(10))
--
--	Parameters:		    	See Documentation
--
--	Return value:			FLOAT
--
--	Last Updated:			07-11-2017
--
--	Author:			    	Diptesh Nath,Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

-- Create table and insert values

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: One observation
--- Return 1, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.RandVal as pRandVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1
);
SELECT z.pGroupID,z.pRandVal,FLPercRank(z.pRandVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 2: Two observations
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.RandVal as pRandVal
FROM fzzlSerial a
WHERE a.SerialVal <= 2
);
SELECT z.pGroupID,z.pRandVal,FLPercRank(z.pRandVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 3: With all ties, Results should be 0
--- Return expected results, Good 
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, CASE WHEN a.SerialVal <= 100 THEN 1 ELSE a.SerialVal END AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 4: Mix with ties
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, CASE WHEN a.SerialVal <= 10 THEN 1 ELSE a.SerialVal END AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;
/*
---- Positive Test 5: Mix With Nulls
--- Output error: The value argument can not be Null, need to be    mentioned in manual
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, CASE WHEN a.SerialVal <= 10 THEN NULL ELSE a.SerialVal END AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;
*/
---- Positive Test 6: Positive test case with more than one observations
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 7: Percent Rank of -1.0 * Value
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,-1.0*z.pSerialVal,FLPercRank(-1.0*z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 8: Percent Rank of Value + 1.0, Results should not change
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal+1.0,FLPercRank(z.pSerialVal+1.0, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 9: Multiply by a very small number, Results should not change
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,1e-100*z.pSerialVal,FLPercRank(1e-100*z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 10: Multiply by a very large number, Results should not change
--- Return expected results, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,1e100*z.pSerialVal,FLPercRank(1e100*z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Positive Test 11: Add a very large number, Results should not change
--- Precision of Double issue, all values become 1e100, so output 0
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,1e100+z.pSerialVal,FLPercRank(1e100+z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- No Output
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.RandVal as pRandVal
FROM fzzlSerial a
WHERE a.SerialVal <= -1
);
SELECT z.pGroupID,z.pRandVal,FLPercRank(z.pRandVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Negative Test 2: Value(Double Precision) out of range: Percent Rank of 1.0e400 * Value
--- Return expected error, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,1e400*z.pSerialVal,FLPercRank(1e400*z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Negative Test 3: Value(Double Precision) out of range: Percent Rank of 1.0e-400 * Value
--- Return expected rank 0.01 , Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,1e-400*z.pSerialVal,FLPercRank(1e-400*z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Negative Test 4: Invalid Data Type: Input Varchar Value
--- Return expected error, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, CAST(a.SerialVal AS VARCHAR(30)) AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'A') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

---- Negative Test 5: Input Invalid RankOrder Indicator
--- Return expected error, Good
CREATE OR REPLACE VIEW z AS (
SELECT 1 AS pGroupID, a.SerialVal AS pSerialVal
FROM fzzlSerial a
WHERE a.SerialVal <= 100
);
SELECT z.pGroupID,z.pSerialVal,FLPercRank(z.pSerialVal, 'C') over (partition by z.pGroupID)  ORDER BY z.pGroupID ;

DROP VIEW Z;
-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
