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
-- 	Test Category:		    Math Functions
--
--	Test Unit Number:		FLAbs-TD-01
--
--	Name(s):		    	FLAbs
--
-- 	Description:			Scalar function which returns the absolute value of a number
--
--	Applications:		 
--
-- 	Signature:		    	FLAbs(x DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			01-29-2014
--
--	Author:			    	<Zhi.Wang@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

-- .set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example
--- Return expected results, Good
SELECT FLAbs(-100.1) AS FLAbs;

---- Positive Test 2: Absolute Value of Value * -1
--- Return expected results, Good
SELECT FLAbs(-100.1 * -1) AS FLAbs;

---- Positive Test 3: Absolute Value of Value + 1e100
--- double precision precision issue, output 1e100
SELECT FLAbs(-100.1 + 1e100) AS FLAbs;

---- Positive Test 4: Absolute Value of Value * 1e100
--- Return expected results, Good
SELECT FLAbs(-100.1 * 1e100) AS FLAbs;

---- Positive Test 5: Absolute Value of Value * 1e-100
--- Return expected results, Good
SELECT FLAbs(-100.1 * 1e-100) AS FLAbs;

---- Positive Test 6: Close to Boundary -1e-307
SELECT FLAbs(-1e-307) AS FLAbs;

---- Positive Test 7: Close to Boundary -1e307
SELECT FLAbs(-1e307) AS FLAbs;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Absolute Value of Value * 1e-400
--- Return expected error, Good
SELECT -100.1 * 1e-400 AS Val;
SELECT FLAbs(-100.1 * 1e-400) AS FLAbs;

---- Negative Test 2: Absolute Value of Value * 1e400
--- Return expected error, Good
-- SELECT -100.1 * 1e400 AS Val;
SELECT FLAbs(-100.1 * 1e400) AS FLAbs;

---- Negative Test 3: Invalid Data Type
--- Return expected error, Good
SELECT FLAbs(NULL) AS FLAbs;

---- Negative Test 4: Input from an Empty Table
--- No Output, Good
DROP TABLE tblAbsTest;
CREATE TEMP TABLE tblAbsTest AS
(SELECT SerialVal AS ObsID,
                  NULL AS NumVal
 FROM fzzlSerial
 WHERE SerialVal < 1
 ) DISTRIBUTE ON (ObsID) ;
 
 SELECT FLAbs(NumVal) AS FLAbs
 FROM tblAbsTest;
 
---- Negative Test 5: Input Null From a Table
--- Return expected error, Good
 INSERT INTO tblAbsTest
 SELECT SerialVal AS ObsID,
                  NULL AS NumVal
 FROM fzzlSerial
 WHERE SerialVal <= 1;
 
 SELECT FLAbs(NumVal) AS FLAbs
 FROM tblAbsTest;

-- 	END: TEST SCRIPT
DROP TABLE tblAbsTest;
