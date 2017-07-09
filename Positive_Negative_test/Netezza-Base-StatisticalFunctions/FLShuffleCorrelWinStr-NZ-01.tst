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
--  Test Category:      Basic Statistics
--
--  Test Unit Number:   FLShuffleCorrelWinStr-Netezza-01
--
--  Name(s):          FLShuffleCorrelWinStr
--
--  Description:      Aggregate function which calculates the mode of a data series
--
--  Applications:    
--
--  Parameters:         See Documentation
--
--  Last Updated:     04-21-2017
--
--  Author:           <Diptesh.Nath@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- SELECT COUNT(*) AS CNT,
--        CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
-- FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Find ShuffleCorrelStr
--- Returns expected result
SELECT p.*
FROM (  SELECT a.TickerSymbol,
        FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
        OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrelStr
        FROM finstockprice a) AS p
WHERE p.ShuffleCorrelStr IS NOT NULL
ORDER BY 1
LIMIT 20;

---- Positive Test 2: Find ShuffleCorrelStrWin
--- Return expected result
SELECT p.TickerSymbol,
       q.SerialVal,
       SUBSTR(p.ShuffleCorrel, (q.SerialVal -1) * 21 + 1, 20)::DOUBLE 
       AS Correl
FROM(
      SELECT a.TickerSymbol,
             FLShuffleCorrelWinStr(a.ClosePrice, a.Volume, 100)
      OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
      FROM finstockprice a
     ) AS p,
     fzzlSerial q
WHERE q.SerialVal <= 100
AND p.ShuffleCorrel IS NOT NULL
ORDER BY 1,2
LIMIT 20;

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Less Argument
--- Returns error
SELECT p.*
FROM (  SELECT a.TickerSymbol,
        FLShuffleCorrelWinStr(a.ClosePrice,100)
        OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrelStr
        FROM finstockprice a) AS p
WHERE p.ShuffleCorrelStr IS NOT NULL
ORDER BY 1
LIMIT 20;

---- Negative Test 2: Less argument to find ShuffleCorrelWin
--- Return expected result
SELECT p.TickerSymbol,
       q.SerialVal,
       SUBSTR(p.ShuffleCorrel, (q.SerialVal -1) * 21 + 1, 20)::DOUBLE 
       AS Correl
FROM(
      SELECT a.TickerSymbol,
             FLShuffleCorrelWinStr(a.ClosePrice, 100)
      OVER(PARTITION BY a.TickerSymbol) AS ShuffleCorrel
      FROM finstockprice a
     ) AS p,
     fzzlSerial q
WHERE q.SerialVal <= 100
AND p.ShuffleCorrel IS NOT NULL
ORDER BY 1,2
LIMIT 20;
-- END: NEGATIVE TEST(s)
--  END: TEST SCRIPT