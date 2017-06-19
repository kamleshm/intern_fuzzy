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
-- 	Test Category:		    Matrix Operations
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-----****************************************************************
-----****************************************************************
---Product of Two Matrices
-----****************************************************************
SELECT a.Row_ID,
 b.Col_ID,
 CASE
       WHEN ABS(FLSumProd(a.Cell_Val, b.Cell_Val)) < 1e-15
            THEN 0
       ELSE FLSumProd(a.Cell_Val, b.Cell_Val)
 END
FROM  tblMatrixResult a,
        tblMatrixMulti b
WHERE  a.Col_ID = b.Row_ID
AND b.Matrix_ID=5
GROUP BY a.Row_ID, b.Col_ID
ORDER BY 1, 2;
