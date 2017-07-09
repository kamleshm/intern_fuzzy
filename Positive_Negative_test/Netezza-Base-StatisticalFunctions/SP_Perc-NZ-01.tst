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
--	Test Unit Number:		SP_Perc-Netezza-01
--
--	Name(s):		    	SP_Perc
--
-- 	Description:			Calculates the requested percentiles on a requested column in a table and stores the results in a predefined table.
--
--	Applications:		 
--
-- 	Signature:		    	SP_Perc(TableName VARCHAR(ANY),
--								ColumnName VARCHAR(ANY),
--								GroupByColumns VARCHAR(ANY),
--								PercentileToCompute DOUBLE PRECISION,
--								OutputTableName VARCHAR(ANY))
--	Parameters:		    	See Documentation
--
--	Return value:			VARCHAR
--
--	Last Updated:			05-02-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

--SELECT COUNT(*) AS CNT,
--       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
--FROM   fzzlSerial a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Percentiles are retrieved from the table FinStockPricePerc.
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice', 'CLOSEPRICE','TICKERSYMBOL','0.1,0.3,0.5,0.7,0.9','FinStockPricePerc');
SELECT * FROM FinStockPricePerc limit 10;

---- Positive Test 2: Percentiles are retrieved from the table FinStockPricePerc; PercentiletoCompute is different here.
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice', 'CLOSEPRICE','TICKERSYMBOL','-0.1,0.9','FinStockPricePerc');
SELECT * FROM FinStockPricePerc limit 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1:Invalid parameter; Returns attribute not found
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice', 'TICKETSYMBOL','CLOSEPRICE','0.1,0.3,0.5,0.7,0.9','FinStockPricePerc');
SELECT * FROM FinStockPricePerc limit 10;

---- Negative Test 2:Invalid number of parameter
DROP TABLE FinStockPricePerc;
EXEC SP_Perc('FinStockPrice', 'CLOSEPRICE','TICKERSYMBOL','0.1,0.3,0.5,0.7,0.9','FinStockPricePerc',1);
SELECT * FROM FinStockPricePerc limit 10;
-- END: NEGATIVE TEST(s)
