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
-- 	Test Category:		    Maximum Likelihood Estimation of Distribution Parameters
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-----****************************************************************
---FLMLEStudentsTUdt
-----****************************************************************
CREATE VIEW view_student_1000 
AS
SELECT  1 AS GroupID,
        FLSimStudentsT(a.randval,0,1,35.6895) AS NumVal
FROM fzzlSerial a
WHERE a.SerialVal <= 1000;

SELECT a.*
FROM(SELECT vw.GroupID, 
            vw.NumVal,
            NVL(LAG(0) OVER (PARTITION BY vw.GroupID ORDER BY            
           vw.GroupID), 1) AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY vw.GroupID ORDER BY           
           vw.GroupID), 1) AS end_flag 
FROM view_student_1000 vw) AS z,
TABLE (FLMLEStudentsTUdt(z.GroupID, 
                      z.NumVal, 
                      z.begin_flag, 
                      z.end_flag)) AS a;
DROP VIEW view_student_1000;

