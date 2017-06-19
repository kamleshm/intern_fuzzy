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
---FLSVMLinearUdt
-----*******************************************************************************************************************************
SELECT '***** EXECUTING FLSVMLinearUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMLinSeparableDeep a) AS z,
TABLE(FLSVMLinearUdt(z.GroupID, 
                     z.ObsID, 
                     z.VarID, 
                     z.Num_Val, 
                     z.CValue, 
                     z.begin_flag, 
                     z.end_flag)) AS f;






-- END: TEST(s)

-- END: TEST SCRIPT
--timing off