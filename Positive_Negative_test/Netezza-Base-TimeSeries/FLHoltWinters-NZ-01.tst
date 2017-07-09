-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
-- 	Test Category:		Time Series Functions
--
--	Test Unit Number:	FLHoltWintersUdt-Netezza-01
--
--	Name(s):		FLHoltWintersUdt
--
-- 	Description:		Calculate the exponential smoothing on a time series.
--
--	Applications:		 
--
-- 	Signature:		FLHoltWinter(TimePeriod INTEGER,
--                              FactValue DOUBLE PRECISION,
--                              Seasonality INTEGER,
--                              SmoothCoeffLevel DOUBLE PRECISION,
--                              SmoothCoeffTrend DOUBLE PRECISION,
--                              SmoothCoeffSeasonality DOUBLE PRECISION,
--                              ForecastPeriod INTEGER,
--                              SmoothWithAverage INTEGER)
--
--	Parameters:		See Documentation
--
--	Return value:	Table
--
--	Last Updated:	04-26-2017
--
--  Author:         <Diptesh.nath@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

---- Table used for HoltWinters

DROP TABLE tblExpSmoothTest;

---- BEGIN: NEGATIVE TEST(s)

--	Case 1 Invalid Arg#4
---- Case 1a Arg#3 is a String
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,'aa',0.20,0.80,b.SerialVal,1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 500
GROUP BY b.SerialVal
ORDER BY 1 LIMIT 10;

---- Case 2 More than 8 arguemnts
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,0.20,0.80,b.SerialVal,1,1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 500
GROUP BY b.SerialVal
ORDER BY 1 LIMIT 10;

--	Case 3 Less than 8 arguments
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,0.20,0.80,b.SerialVal)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 500
GROUP BY b.SerialVal
ORDER BY 1 LIMIT 10;

--  Case 4a Numeric value out of range
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,10e308,10e-308,0.80,b.SerialVal,1) FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;



--  Case 4b Numeric value out of range
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,10e-308,10e308,0.80,b.SerialVal,1) FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1  LIMIT 10;

--  Case 5a The first argument i.e., time period cannot be NULL
SELECT b.SerialVal,FLHoltWinter(null,a.VAL,7,0.20,0.20,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5b The second argument cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,null,7,0.20,0.20,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5c The third argument cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,null,0.20,0.20,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5d The fourth argument cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,null,0.20,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5e The fifth argument i.e., time period cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,null,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5f The sixth argument i.e., time period cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,0.2,null,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 5g The seventh argument i.e., time period cannot be NULL
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,0.2,0.80,null,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;
--  Case 5h The eigth argument cannot be NULL,Only 0 or 1 .But we still get output
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,null,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 6a Third argument cannot be negative
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,-7,0.20,0.20,0.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 6b Fourth argument between 0 and 1. NOTE: Still getting output
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,20,20,.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1 LIMIT 10;

--  Case 6c Fifth argument between 0 and 1.NOTE:Still getting output
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,.20,20,.80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1;

--  Case 6d Sixth argument between 0 and 1.NOTE:Still getting output
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,.20,.20,80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1;

--  Case 7 Returns invalid output
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,20,20,80,b.SerialVal,1)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1

--  Case 14 Last parameter has to be 0 or 1
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,.20,.20,.80,b.SerialVal,2)FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal value

-- Case 1 Query with normal value
SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,0.20,0.20,0.80,b.SerialVal,1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 500
GROUP BY b.SerialVal
ORDER BY 1;


-- Case 2 Query with extreme values in 4 th and 5 th argument

SELECT b.SerialVal,FLHoltWinter(a.PERIODID,a.VAL,7,10e-308,10e-408,0.80,b.SerialVal,1) FROM tbltseries_hltwntr a, fzzlSerial b WHERE b.SerialVal <= 500 GROUP BY b.SerialVal ORDER BY 1;


-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT
