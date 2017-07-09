INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata Aster
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    Date Functions
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----****************************************************************
---FLCOLLAPSEDATES
-----****************************************************************
SELECT OBSID,
 CASE WHEN DATEIN1>DATEIN2 THEN DATEIN2 ELSE DATEIN1 END           
      AS MINDATE,
 CASE WHEN DATEIN1<DATEIN2 THEN DATEIN2 ELSE DATEIN1 END           
      AS MAXDATE,
 FLCOLLAPSEDATES(MINDATE,MAXDATE) OVER (PARTITION BY OBSID) AS D1
FROM tbltestdate
ORDER BY 1,2;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDateAdd
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateAdd('yy', 1, a.DateIN1) AS DateAddYear,
        FLDateAdd('qq', 1, a.DateIN1) AS DateAddQuarter,
        FLDateAdd('mm', 1, a.DateIN1) AS DateAddMonth,
        FLDateAdd('wk', 1, a.DateIN1) AS DateAddWeek,
        FLDateAdd('dd', 1, a.DateIN1) AS DateAddDay
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDateConvert
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateConvert(a.DateIN1, 101) AS FLDateConvert101,
        FLDateConvert(a.DateIN1, 102) AS FLDateConvert102,
        FLDateConvert(a.DateIN1, 103) AS FLDateConvert103,
        FLDateConvert(a.DateIN1, 104) AS FLDateConvert104,
        FLDateConvert(a.DateIN1, 105) AS FLDateConvert105,
        FLDateConvert(a.DateIN1, 106) AS FLDateConvert106,
        FLDateConvert(a.DateIN1, 107) AS FLDateConvert107,
        FLDateConvert(a.DateIN1, 110) AS FLDateConvert110,
        FLDateConvert(a.DateIN1, 111) AS FLDateConvert111,
        FLDateConvert(a.DateIN1, 112) AS FLDateConvert112
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDateDiff
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1, 
        a.DateIN2,
        FLDateDiff('YEAR',a.DateIN1, a.DateIN2) AS DateDiffYear,
        FLDateDiff('QUARTER',a.DateIN1, a.DateIN2) AS DateDiffQuarter,
        FLDateDiff('MONTH',a.DateIN1, a.DateIN2) AS DateDiffMonth,
        FLDateDiff('WEEK',a.DateIN1, a.DateIN2) AS DateDiffWeek,
        FLDateDiff('DAY',a.DateIN1, a.DateIN2) AS DateDiffDay
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDatePart
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1,
        FLDatePart('yy', a.DateIN1) AS DatePartYear,
        FLDatePart('qq', a.DateIN1) AS DatePartQuarter,
        FLDatePart('mm', a.DateIN1) AS DatePartMonth,
        FLDatePart('dy', a.DateIN1) AS DatePartDayOfYear,
        FLDatePart('dd', a.DateIN1) AS DatePartDay,
        FLDatePart('wk', a.DateIN1) AS DatePartWeek,
        FLDatePart('dw', a.DateIN1) AS DatePartWeekday
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDateTrunc
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateTrunc('yy', a.DateIN1) AS TruncYear,
        FLDateTrunc('mm', a.DateIN1) AS TruncMonth,
        FLDateTrunc('dd', a.DateIN1) AS TruncDay
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDECODEDATES
-----****************************************************************
SELECT 	c.*,
       	t.Start_date,
	t.End_date
FROM
    (
      SELECT OBSID,
      	CASE WHEN DATEIN1>DATEIN2 THEN DATEIN2 ELSE DATEIN1 END AS MINDATE,
	CASE WHEN DATEIN1<DATEIN2 THEN DATEIN2 ELSE DATEIN1 END AS MAXDATE,
	FLCOLLAPSEDATES(MINDATE,MAXDATE) OVER (PARTITION BY OBSID) AS D1
	FROM tbltestdate
     ) c,
TABLE (FLDECODEDATES(C.D1)) AS T
ORDER BY 1,2;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLFirstLast
-----****************************************************************
SELECT  a.DateIN1, 
        FLFirstLast('F', a.DateTS1, a.ObsId) OVER(PARTITION BY a.DateIN1 ORDER BY a.DateIN1)
AS FirstOccurance
FROM tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
SELECT a.DateIN1,
       FLFirstLast('L', a.DateTS1, a.ObsId) OVER(PARTITION BY a.DateIN1 ORDER BY a.DateIN1) AS
 LastOccurance
FROM tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLMaxAt
-----****************************************************************
SELECT a.TickerSymbol,
       a.FLMaxAt,
       b.TxnDate,
       b.ClosePrice
FROM(
     SELECT a.TickerSymbol,
            FLMaxAt(a.DateIdx, a.ClosePrice) AS FLMaxAt
     FROM   finStockPrice a
     WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
     GROUP BY a.TickerSymbol
     ) a,
       finStockPrice b
WHERE  b.TickerSymbol = a.TickerSymbol AND b.DateIdx = a.FLMaxAt
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLMinAt
-----****************************************************************
SELECT a.TickerSymbol,
       a.FLMinAt,
       b.TxnDate,
       b.ClosePrice
FROM   (
       SELECT a.TickerSymbol,
              FLMinAt(a.DateIdx, a.ClosePrice) AS FLMinAt
       FROM   finStockPrice a
       WHERE  a.TickerSymbol IN ('AAPL','HPQ','IBM','MSFT','ORCL')
       GROUP BY a.TickerSymbol
       ) a,
       finStockPrice b
WHERE  b.TickerSymbol = a.TickerSymbol AND b.DateIdx = a.FLMinAt
ORDER BY 1;
