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
--  Test Unit Number:       FLDecodeDates-Netezza-01
--
--  Name(s):                FLDecodeDates
--
--  Description:            Scalar function which adds to a date part of the DATE variable
--
--  Applications:        
--
--  Signature:              FLDecodeDates(StartDate VARCHAR(100))
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

SELECT c.*,
t.Start_date,
t.End_date
FROM
(
SELECT OBSID,
		CASE WHEN DATEIN1>DATEIN2 THEN DATEIN2 ELSE DATEIN1 END AS MINDATE,
		CASE WHEN DATEIN1<DATEIN2 THEN DATEIN2 ELSE DATEIN1 END AS MAXDATE,
		FLDecodeDates(MINDATE,MAXDATE) OVER (PARTITION BY OBSID) AS D1
FROM tbltestdate
) c,
TABLE (FLDECODEDATES(C.D1)) AS T
ORDER BY 1,2;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- END: NEGATIVE TEST(s)

--  END: TEST SCRIPT
