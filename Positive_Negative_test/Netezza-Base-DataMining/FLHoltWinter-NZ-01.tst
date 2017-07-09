-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
--
--
-- Functional Test Specifications:
--
-- 	Test Category:		Data Mining Functions (Time Series)
--
--	Test Unit Number:	FLHoltWinter-NZ-01
--
--	Name(s):		FLHoltWinter
--
-- 	Description:		Holt-Winter’s is a commonly used forecasting method and it takes into account three factors – average
--						level, trend and seasonality. On the NPS platform, the aggregate function FLHoltWinter can be used to
--						forecast a time series
--
--	Applications:		 
--
-- 	Signature:		FLHoltWinter(   TimePeriod					INTEGER, 
--									FactValue					DOUBLE PRECISION, 
--									Seasonality					INTEGER, 
--									SmoothCoeffLevel			DOUBLE PRECISION, 
--									SmoothCoeffTrend			DOUBLE PRECISION, 
--									SmoothCoeffSeasonality		DOUBLE PRECISION, 
--									ForecastPeriod				INTEGER, 
--									SmoothWithAverage			INTEGER)  
--
--
--	Parameters:		See Documentation
--
--	Return value:	Table
--
--	Last Updated:	01-25-2014
--
--	Author:			<Shuai.Yang@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

---- Table used for HoltWinters

DROP TABLE tblExpSmoothTest;

CREATE TABLE  tblExpSmoothTest
      ( periodid   BIGINT,
        val        DOUBLE PRECISION)
DISTRIBUTE ON( periodid );

SELECT  COUNT(*)
FROM    tbltseries_hltwntr;

---- BEGIN: NEGATIVE TEST(s)

--	Case 1 Invalid Arg#8
---- Case 1a Arg#8 > 1
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              2)
		FROM tw) AS d
ORDER BY 1;
--Still works and gives output as 0 irrespective of parameters.

---- Case 1b Arg#8 < 0
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              -1)
		FROM tw) AS d
ORDER BY 1;

--	Case 2 NULL check
---- Case 2a NULL Arg#2
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, NULL, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2b Mixed NULL Arg#2
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, CASE WHEN MOD(PeriodID,2) = 0 THEN NULL ELSE Val END, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2c NULL Arg#3
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, NULL , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2d NULL Arg#4
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , NULL , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2e NULL Arg#5
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , NULL,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2f NULL Arg#6
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  NULL , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2g NULL Arg#7
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , NULL
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 2h NULL Arg#1
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , NULL, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 3 Invalid Arg#3
---- Case 3a Arg#3 <= 0
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 0 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 3b Arg#3 > NumOfObs/2
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, (COUNT(PeriodID) OVER (PARTITION BY 1))/2 + 2 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 4 Invalid Arg#4
---- Case 4a Arg#4 < 0 
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , -1.0 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 4b Arg#4 > 0
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , 1.10 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 5 Invalid Arg#5
---- Case 4a Arg#4 < 0 
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , -.20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 5b Arg#5 > 1
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , 1.20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 6 Invalid Arg#6
---- Case 6a Arg#6 < 0 
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  -.80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- Case 6b Arg#6 > 0
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  1.80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 7 Invalid Arg#8
---- Case 7a Arg#7 = 0
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 0
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme values

-- Case 1 Query example based on TD user manual
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

-- Case 2 Query example based on TD user manual with different AvgSmoothing factor
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tbltseries_hltwntr
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              0)
		FROM tw) AS d
ORDER BY 1;

-- Case 3 Empty table
SELECT d.*
FROM (	WITH tw (GroupID, PeriodID, val, periodicity, alphalevel, alphatrend, alphaseasonality, forecastperiod)
		AS ( SELECT 1 , PeriodID, Val, 7 , .20 , .20,  .80 , 7
			 FROM   tblExpSmoothTest
			 ORDER BY PeriodID ASC)		
		SELECT	FLHoltWinter( tw.PeriodID,
                              tw.val,
                              tw.periodicity,
                              tw.alphalevel,
                              tw.alphatrend,
                              tw.alphaseasonality,
                              tw.forecastperiod,
                              1)
		FROM tw) AS d
ORDER BY 1;

---DROP the test table
DROP TABLE tblExpSmoothTest;

-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT
