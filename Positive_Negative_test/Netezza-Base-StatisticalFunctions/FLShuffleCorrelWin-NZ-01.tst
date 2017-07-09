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
--	Test Unit Number:		FLShuffleCorrelWin-Netezza-01
--
--	Name(s):		    	FLShuffleCorrelWin
--
-- 	Description:			Aggregate function which calculates the mode of a data series
--
--	Applications:		 
--
--	Parameters:		    	See Documentation
--
--	Last Updated:			04-21-2017
--
--	Author:			    	<Diptesh.Nath@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- SELECT COUNT(*) AS CNT,
--        CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Find ShuffleCorrel
--- Returns expected result
SELECT p.*
FROM(SELECT a.TickerSymbol,
            FLShuffleCorrelWin(a.closeprice, a.Volume) 
     OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
     FROM FINSTOCKPRICE a) AS p
WHERE p.ShuffleCorrel IS NOT NULL
ORDER BY 1
LIMIT 20;
-- END: POSITIVE TEST(s)
-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Less Argument
--- Retun error
SELECT p.*
FROM(SELECT a.TickerSymbol,
            FLShuffleCorrelWin(a.closeprice) 
     OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
     FROM FINSTOCKPRICE a) AS p
WHERE p.ShuffleCorrel IS NOT NULL
ORDER BY 1
-- END: NEGATIVE TEST(s)
-- 	END: TEST SCRIPT