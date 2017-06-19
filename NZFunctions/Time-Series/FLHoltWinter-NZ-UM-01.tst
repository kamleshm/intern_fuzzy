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
-- 	Test Category:	    Time Series Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
--timing on

-- BEGIN: TEST(s)


-----*******************************************************************************************************************************
---FLHoltWinter
-----*******************************************************************************************************************************						 
--Input Table
SELECT * 
FROM tbltseries_hltwntr
LIMIT 20;

--Output Table
SELECT b.SerialVal,
       FLHoltWinter(a.PERIODID,
                    a.VAL,
                    7,
                    0.20,
                    0.20,
                    0.80,
                    b.SerialVal,
                    1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 28
GROUP BY b.SerialVal
ORDER BY 1;



-- END: TEST(s)

-- END: TEST SCRIPT
--timing off