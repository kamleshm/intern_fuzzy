--INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata Aster
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC.
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade
-- secret or copyright law. Dissemination of this information or reproduction of this material is
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
--      Test Category:              Date Functions
--
--      Last Updated:                   05-30-2017
--
--      Author:                         <kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-- BEGIN: TEST(s)
-----****************************************************************

---FLDateConvert
-----****************************************************************
SELECT  a.ObsID, 
        a.DateIN1,
        FLDateConvert(a.DateIN1, 101) AS FLDateConvert101,
        FLDateConvert(a.DateIN1, 102) AS FLDateConvert102,
        FLDateConvert(a.DateIN1, 103) AS FLDateConvert103,
        FLDateConvert(a.DateIN1, 104) AS FLDateConvert104,
        FLDateConvert(a.DateIN1, 105) AS FLDateConvert105,
        FLDateConvert(a.DateIN1, 106) AS FLDateConvert106,
        FLDateConvert(a.DateIN1, 107) AS FLDateConvert107,
        FLDateConvert(a.DateIN1, 110) AS FLDateConvert110,
        FLDateConvert(a.DateIN1, 111) AS FLDateConvert111,
        FLDateConvert(a.DateIN1, 112) AS FLDateConvert112
FROM    tblTestDate a
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
