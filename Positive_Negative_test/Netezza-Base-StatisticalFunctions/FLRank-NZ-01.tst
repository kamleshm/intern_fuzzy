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
--	Test Unit Number:		FLrank-Netezza-01
--
--	Name(s):		    	FLRank
--
-- 	Description:			Calculates the rank of each observation in a data series
--
--	Applications:		 
--
-- 	Signature:		    	FLRank(pValue DOUBLE PRECISION,
--										pOrder VARCHAR(10))
--
--	Parameters:		    	See Documentation
--
--	Return value:			INTEGER
--
--	Last Updated:			03-04-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good
WITH z (pTxnDate,pGroupID,pTickerSymbol,pValue, pRankOrder) AS (
SELECT a.TxnDate,
	a.TickerID,
	a.TickerSymbol,
	a.ClosePrice,
	'D'
FROM finStockPrice a 
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL') 
AND a.TxnDate BETWEEN '2002-01-01' AND '2002-02-01')
SELECT z.pTickerSymbol,z.pTxnDate,z.pGroupID,z.pValue,
FLRank(z.pValue, z.pRankOrder) OVER (PARTITION BY z.pTickerSymbol) 
AS Rank FROM z 
ORDER BY 1,2
LIMIT 20 ;

---- Positive Test 2: One observation
--- Return 1, Good
WITH z (pGroupID, pRandVal,pRankOrder) AS (
SELECT 1, 
	a.RandVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=1
)
SELECT z.pGroupID,z.pRandVal,
FLRank(z.pRandVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 1
LIMIT 20 ;

---- Positive Test 3: Two observations
--- Return expected results, Good
WITH z (pGroupID, pRandVal,pRankOrder) AS (
SELECT 1,
        a.RandVal,
        'A'
FROM fzzlSerial a
WHERE a.SerialVal <=2
)
SELECT z.pGroupID,z.pRandVal,
FLRank(z.pRandVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 1
LIMIT 20 ;

---- Positive Test 4: With all ties, Results should be 1
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1, 
	CASE WHEN a.SerialVal <= 100 THEN 1 ELSE a.SerialVal END,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT z.pGroupID,z.pSerialVal,
FLRank(z.pSerialVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 1
LIMIT 20 ;

---- Positive Test 5: Mix with ties
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1, 
	CASE WHEN a.SerialVal <= 10 THEN 1 ELSE a.SerialVal END,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT z.pGroupID,z.pSerialVal,
FLRank(z.pSerialVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20 ;

---- Positive Test 6: Mix With Nulls
--- Output error: The value argument can not be Null, need to be mentioned in manual
--- To be investigated
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1, 
	CASE WHEN a.SerialVal <= 10 THEN NULL ELSE a.SerialVal END,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT z.pGroupID,z.pSerialVal,
FLRank(z.pSerialVal,z.pRankOrder) OVER (PARTITION BY z.pGroupID)
AS Rank FROM z
ORDER BY 2
LIMIT 20 ;

---- Positive Test 7: Positive test case with more than one observations
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT z.pGroupID,z.pSerialVal,
FLRank(z.pSerialVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20 ;

---- Positive Test 8: Percent Rank of -1.0 * Value
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1, 
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <=100
)
SELECT z.pGroupID,-1.0*z.pSerialVal,
FLRank(-1.0*z.pSerialVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2 DESC
LIMIT 20 ;

---- Positive Test 9: Percent Rank of Value + 1.0, Results should not change
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal+1.0,
FLRank(z.pSerialVal+1.0,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2 
LIMIT 20 ;

---- Positive Test 10: Multiply by a very small number, Results should not change
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal*1e-100,
FLRank(z.pSerialVal*1e-100,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2 
LIMIT 20 ;


---- Positive Test 11: Multiply by a very large number, Results should not change
--- Return expected results, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal*1e100,
FLRank(z.pSerialVal*1e100,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20 ;

---- Positive Test 12: Add a very large number, Results should not change
--- Precision of Double issue, all values become 1e100, so output 0, which is expected
--- to be investigated
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal+1e100,
FLRank(z.pSerialVal+1e100,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20 ;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Rank Order can be 'A' or 'D'
--- Error
WITH z (pTxnDate,pGroupID,pTickerSymbol,pValue, pRankOrder) AS (
SELECT a.TxnDate,a.TickerID,a.TickerSymbol,a.ClosePrice,'X'
FROM finStockPrice a 
WHERE a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL') 
AND a.TxnDate BETWEEN '2002-01-01' AND '2002-02-01')
SELECT z.pTickerSymbol,z.pTxnDate,z.pGroupID,z.pValue,
FLRank(z.pValue, z.pRankOrder) OVER (PARTITION BY z.pTickerSymbol) 
AS Rank 
FROM z 
ORDER BY 1,2;

---- Negative test 2: TicketSymbol is set to values which are not present
--- No Output
WITH z (pTxnDate,pGroupID,pTickerSymbol,pValue, pRankOrder) AS (
SELECT a.TxnDate,a.TickerID,a.TickerSymbol,a.ClosePrice,'D'
FROM finStockPrice a 
WHERE a.TickerSymbol IN ('ORCLX') 
AND a.TxnDate BETWEEN '2002-01-01' AND '2002-02-01')
SELECT z.pTickerSymbol,z.pTxnDate,z.pGroupID,z.pValue,
FLRank(z.pValue, z.pRankOrder) OVER (PARTITION BY z.pTickerSymbol) 
AS Rank 
FROM z 
ORDER BY 1,2;

---- Negative Test 3: No data
--- No Output
WITH z (pGroupID, pRandVal,pRankOrder) AS (
SELECT 1, 
	a.RandVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= -1
)
SELECT z.pGroupID,z.pRandVal,
FLRank(z.pRandVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2;

---- Negative Test 4: Value(Double Precision) out of range: Percent Rank of 1.0e400 * Value
--- Return expected error, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal*1e400,
FLRank(z.pSerialVal*1e400,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2;

---- Negative Test 5: Value(Double Precision) out of range: Percent Rank of 1.0e-400 * Value
--- Return 0 value, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	a.SerialVal,
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal*1e-400,
FLRank(z.pSerialVal*1e-400,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20;

---- Negative Test 6: Invalid Data Type: Input Varchar Value
--- Return expected error, Good
WITH z (pGroupID, pSerialVal,pRankOrder) AS (
SELECT 1,
	CAST(a.SerialVal AS VARCHAR(30)),
	'A'
FROM fzzlSerial a
WHERE a.SerialVal <= 100
)
SELECT z.pGroupID,z.pSerialVal,
FLRank(z.pSerialVal,pRankOrder) OVER (PARTITION BY 1)
AS Rank FROM z
ORDER BY 2
LIMIT 20;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
