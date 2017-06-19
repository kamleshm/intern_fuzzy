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
---FLEigenSystemStr
-----****************************************************************
SELECT FLMatrixRow(p.EigenSystem) AS Row,
       FLMatrixCol(p.EigenSystem) AS Col,
       FLEigenValue(Row,Col,FLMatrixVal(p.EigenSystem))
OVER (PARTITION BY 1) AS EigenValue,
      FLEigenVector(Row,Col,FLMatrixVal(p.EigenSystem))
OVER (PARTITION BY 1) AS EigenVector
FROM (
      SELECT FLEigenSystemStr(a.Row_ID,
							a.Col_ID,
							a.Cell_Val)
      OVER (PARTITION BY 1) AS EigenSystem
      FROM tblMatrixMulti a
      WHERE a.Matrix_ID = 5
      ) AS p
ORDER BY 1,2;
