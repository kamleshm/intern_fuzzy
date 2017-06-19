-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
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
-- 	Test Category:	    	Hypothesis Testing Functions
--
--	Last Updated:		    05-29-2017
--
--	Author:			        <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
--timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---FLCrossTabUdt with Large Contingency Tables
-----*******************************************************************************************************************************
--Input Table
SELECT * 
FROM tblHardware
LIMIT 20;

SELECT * 
FROM tblMajor
LIMIT 20;

SELECT * 
FROM tblStudentCrossRef
LIMIT 20;


--Output Table
SELECT  a.HardwareID,
        b.MajorID,
        FLChiSq('EXP_VAL', a.HardwareID, b.MajorID, c.HardwareID,
c.MajorID, 1) AS Exp_Val,
        FLChiSq('CHI_SQ', a.HardwareID, b.MajorID, c.HardwareID, c.MajorID,
1) AS Chi_SQ
FROM   tblHardware a,
        tblMajor b,
       tblStudentCrossRef c
GROUP BY a.HardwareID,b.MajorID
ORDER BY 1, 2;




-- END: TEST(s)

-- END: TEST SCRIPT
--timing off

