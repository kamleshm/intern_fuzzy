-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata

-- Copyright (c): 2014 Fuzzy Logix, LLC

-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:

-- 	Test Category:			Math Functions

--	Test Unit Number:		FLCubicSpline-TD-01

--	Name(s):		    	FLCubicSpline

-- 	Description:			Aggregate function which returns the predicted value by using Cubic Spline interpolation for a requested data value

--	Applications:		 

-- 	Signature:		    	FLCubicSpline(XVal DOUBLE PRECISION, YVal DOUBLE PRECISION, PredXVal DOUBLE PRECISION)

--	Parameters:		    	See Documentation

--	Return value:			Double Precision

--	Last Updated:			02-19-2014

--	Author:			    	<Zhi.Wang@fuzzyl.com>                                      

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

SELECT COUNT(*) AS CNT,
       CASE WHEN CNT = 0 THEN ' Please Load Test Data!!! ' ELSE ' Test Data Loaded ' END AS TestOutcome
FROM   tblCubicSpline a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Positive Case
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(a.XVal, a.YVal, b.SerialVal - 1 + 0.25) AS PredYVal
FROM    tblCubicSpline a,
        fzzlConstantSerial b
WHERE   b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Positive Test 2: 1e300
SELECT  (b.SerialVal - 1 + 0.25)*1e300 AS PredXVal,
        FLCubicSpline(a.XVal * 1e300, a.YVal * 1e300, (b.SerialVal - 1 + 0.25)*1e300) AS PredYVal
FROM    tblCubicSpline a,
        fzzlConstantSerial b
WHERE   b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Positive Test 3: 1e-300
SELECT  (b.SerialVal - 1 + 0.25)*1e-300 AS PredXVal,
        FLCubicSpline(a.XVal*1e-300, a.YVal*1e-300, (b.SerialVal - 1 + 0.25)*1e-300) AS PredYVal
FROM    tblCubicSpline a,
        fzzlConstantSerial b
WHERE   b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Positive Test 4: When only two points
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(a.SerialVal, a.RandVal, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <= 2 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Positive Test 5: With Null's
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(CASE WHEN a.SerialVal<3 THEN NULL ELSE a.SerialVal End, a.RandVal, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <=10 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)


---- Negative Test 1: PredXVal < Min(XVal)
--- Output Null, Good
SELECT  b.SerialVal - 10 + 0.25 AS PredXVal,
        FLCubicSpline(a.XVal, a.YVal, PredXVal) AS PredYVal
FROM    tblCubicSpline a,
        fzzlConstantSerial b
WHERE   b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Negative Test 2: PredXVal > Max(XVal)
--- Output Null, Good
SELECT  b.SerialVal + 10 + 0.25 AS PredXVal,
        FLCubicSpline(a.XVal, a.YVal, PredXVal) AS PredYVal
FROM    tblCubicSpline a,
        fzzlConstantSerial b
WHERE   b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Negative Test 3: Less than 2 points
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(a.SerialVal, a.RandVal, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <=1 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Negative Test 4:  More than 1000 points
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(a.SerialVal, a.RandVal, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <=1001 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Negative Test 5:  Same x different y identical points/duplicated points
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(CASE WHEN a.SerialVal<3 THEN 1 ELSE a.SerialVal End, a.RandVal, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <=10 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

---- Negative Test 6:  Duplicated points
SELECT  b.SerialVal - 1 + 0.25 AS PredXVal,
        FLCubicSpline(CASE WHEN a.SerialVal<3 THEN 1 ELSE a.SerialVal End, CASE WHEN a.SerialVal<3 THEN 1 ELSE a.RandVal End, PredXVal) AS PredYVal
FROM    fzzlConstantSerial a,
        fzzlConstantSerial b
WHERE   a.SerialVal <=10 AND b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;



SELECT FLCubicSpline(NULL) AS DiGamma;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
