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
--  Test Category:          Basic Statistics
--
--  Test Unit Number:       FLFirstLast-Netezza-01
--
--  Name(s):                FLFirstLast
--
--  Description:            Scalar function which adds to a date part of the DATE variable
--
--  Applications:        
--
--  Signature:              FLFirstLast(FirstOrLast VARCHAR(1), Date TIMESTAMP, Datacolumn DOUBLE PRECISION)
--
--  Parameters:             See Documentation
--
--  Return value:           DATE
--
--  Last Updated:           01-20-2017
--
--  Author:                 Sam Sharma
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)


---- Positive Test 1a: Manual Example
--- Same Output, Good

SELECT a.DateIN1,
		FLFirstLast('F', a.DateTS1, a.ObsId) OVER(PARTITION BY a.DateIN1)
		AS FirstOccurance
FROM tblTestDate a
ORDER BY 1;

---- Positive Test 1b: Manual Example
--- Same Output, Good

SELECT a.DateIN1,
		FLFirstLast('L', a.DateTS1, a.ObsId) OVER(PARTITION BY a.DateIN1) AS
		LastOccurance
FROM tblTestDate a
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- END: NEGATIVE TEST(s)

--  END: TEST SCRIPT
