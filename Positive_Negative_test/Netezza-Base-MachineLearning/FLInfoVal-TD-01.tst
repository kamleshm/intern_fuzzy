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
-- 	Test Category:			Data Mining
--
--	Test Unit Number:		FLInfoVal-TD-01
--
--	Name(s):		    	FLInfoVal
--
-- 	Description:			Calculates the information Values
--
--	Applications:		 
--
-- 	Signature:		    	FLInfoVal(BinId BIGINT,
--                                    Events BIGINT,
--                                    NonEvents BIGINT,
--                                    ReqdBinID  BIGINT)
--
--	Parameters:		    	See Documentation
--
--	Return value:			Double Precision
--
--	Last Updated:			04-07-2014
--
--	Author:			    	<gandhari.sen@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

.set width 2500

SELECT a.BinID,
       a.Events,
       a.NonEvents
FROM   tblInfoVal a
ORDER BY 1;

--- CREATE test table
DROP TABLE tblInfovalTest;

CREATE TABLE tblInfovalTest   (
      BinID INTEGER,
      Events INTEGER,
      NonEvents INTEGER)
PRIMARY INDEX ( BinID );

--populate the  test table
INSERT INTO tblInfovalTest
SELECT a.*
FROM   tblInfoVal a;

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: 
---Output :  Good
SELECT b.SerialVal - 1 AS BinID,
       FLInfoVal(a.BinID, a.Events, a.NonEvents, b.SerialVal - 1) AS InfoVal
FROM   tblInfoValTest a,
       fzzlSerial b
WHERE  b.SerialVal <= 6
GROUP BY b.SerialVal
ORDER BY 1;

-- PositiveTest 2  Param4 is  0 
--- goes through and returns the cumulative infoval 
DELETE FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT * 
FROM tblInfoval;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 0) AS Infoval
FROM   tblInfoVal a;

--PositiveTest case 3: constant BinID 
--Output --returns 0 good
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT 2,
                 a.Events,
                 a.NonEvents
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Positive Test case 4: dupilcate BinID s 
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT CASE WHEN a.BinID =1 THEN 2 ELSE a.BinID END,
                 a.Events,
                 a.NonEvents
FROM tblInfoVal a;

SELECT * 
FROM  tblInfoValTest  
ORDER BY 1;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 3)
FROM   tblInfoValTest a;

--Positive test 5
--when one of the Bins doesnt start from 1
DELETE FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT * FROM tblInfoval
WHERE BINID > 1;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 3)
FROM   tblInfoValTest a;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- Output Null, Good
---- Negative test
DELETE  FROM tblInfoValTest ALL;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Populate the test  table
--populate the  test table
INSERT INTO tblInfovalTest
SELECT a.*
FROM   tblInfoVal a;

--Negative test case 2: NULL arg#1
--Output NULL, Good
SELECT FLInfoVal(NULL, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative test case 3: the column is not there in the input table
--Output Error message, Good
SELECT FLInfoVal(a.NonBinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 4: negative BinID
--Output --Error message : 
--good
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT CASE WHEN a.BinID IN ( 5, 3,1 ) THEN -a.BinId ELSE a.BinID END,
                 a.Events,
                 a.NonEvents
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative test case 7 NULL arg#2
--Output NULL, Good
SELECT FLInfoVal(a.BinID, NULL, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative test case 8: the column is not there in the input table
--Output Error message, Good
SELECT FLInfoVal(a.BinID, a.NotExistEvents, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 9: negative events
--Output --Error message :
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                 CASE WHEN a.BinID IN ( 5, 3,1 ) THEN -a.Events ELSE a.Events END,
                 a.NonEvents
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 10: 0 events for all 
--Output --Error message 
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                 0,
                 a.NonEvents
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 11 : some BinIDs have 0 events 
--Output --Error message
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                 CASE WHEN BinID IN (1,2 ,3) THEN 0 ELSE a.Events END,
                 a.NonEvents
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative test case 12 :NULL arg#3
--Output NULL, Good
SELECT FLInfoVal(a.BinID, a.Events,NULL, 2)
FROM   tblInfoValTest a;

--Negative test case 13: the column is not there in the input table
--Output Error message, Good
SELECT FLInfoVal(a.BinID, a.Events, a.NotExistNonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 14: negative non events
--Output --Error message : 
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                 a.Events,
                 CASE WHEN a.BinID IN ( 5, 3,1 ) THEN -a.NonEvents ELSE a.NonEvents END
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 15:  0 non events for all 
--Output --Error message 
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                 a.Events,
                 0
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;

--Negative Test case 16 : some BinIDs have 0 nonevents 
--Output --Error message
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT a.BinID,
                a.Events,
                 CASE WHEN BinID IN (1,2 ,3) THEN 0 ELSE a.NonEvents END
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 2)
FROM   tblInfoValTest a;


--Negative Test case 17 ..Param 4 is NULL
----Output NULL, Good
DELETE  FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT *
FROM tblInfoVal a;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, NULL )
FROM   tblInfoValTest a;

--Negative Test case 18 ..Param 4 is negative
----Output : FL generated error message , Good
SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, -1)
FROM   tblInfoValTest a;

---- Negative Test 19: Param4 is  out of range.i.e ReqdBinID value is greater than  binInds in the table 
----Output : FL generated error message , Good
SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 6)
FROM   tblInfoVal a;

--Negative Test 20 when one of the Bins are missing from the group
DELETE FROM tblInfoValTest ALL;

INSERT INTO tblInfoValTest
SELECT * FROM tblInfoval
WHERE BINID <>3;

SELECT FLInfoVal(a.BinID, a.Events, a.NonEvents, 3)
FROM   tblInfoValTest a;


-- END: NEGATIVE TEST(s)
--Drop Test table 
DROP TABLE tblInfoValTest;

-- 	END: TEST SCRIPT
