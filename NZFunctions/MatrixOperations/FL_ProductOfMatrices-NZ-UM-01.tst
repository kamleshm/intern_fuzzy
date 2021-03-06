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
TRUNCATE TABLE tblMatrixResult;
INSERT INTO tblMatrixResult
        SELECT a.Row_ID,
                a.Col_ID,
                FLMatrixInv(a.Row_ID, a.Col_ID, a.CELL_VAL)
                OVER (PARTITION BY 1) AS Inverse
        FROM tblMatrixMulti a
        WHERE a.Matrix_ID=5
        ORDER BY 1, 2;
SELECT a.Row_ID,
        b.Col_ID,
        FLSumProd(a.CELL_VAL, b.CELL_VAL) AS Product
FROM tblMatrixResult a,
        tblMatrixMulti b
WHERE a.Col_ID = b.Row_ID
AND b.Matrix_ID=5
GROUP BY a.Row_ID, b.Col_ID
ORDER BY 1, 2;
