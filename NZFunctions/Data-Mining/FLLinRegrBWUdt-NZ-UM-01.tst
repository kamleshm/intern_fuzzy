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
-- 	Test Category:	    Data Mining Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
--timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---FLLinRegrBWUdt
-----*******************************************************************************************************************************
SELECT '***** EXECUTING FLLinRegrBWUdt *****';
SELECT f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)    
       AS begin_flag, 
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)   
       AS end_flag
FROM tbllinregrdatadeep a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, 
                     z.ObsID, 
                     z.VarID, 
                     z.Num_Val,
                     1,
                     0.01,
                     0.95,
                     0.10,
                     z.begin_flag, 
                     z.end_flag)) AS f 
ORDER BY 1 ASC, 2 DESC, 5 ASC;







-- END: TEST(s)

-- END: TEST SCRIPT
--timing off