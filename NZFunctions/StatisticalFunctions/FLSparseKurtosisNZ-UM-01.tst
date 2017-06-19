-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    Statistical Functions
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-- BEGIN: TEST(s)
-----*******************************************************************************************************************************
---FLSparseKurtosis
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseKurtosis(a.VarSum,
                        a.VarSqSum,
                        a.VarCuSum,
                        a.VarQdSum,
                        a.VarCount) AS FLSparseKurtosis
FROM( 
     SELECT MediaOutletID,
            SUM(Num_Val) AS VarSum,
            SUM(Num_Val * Num_Val) AS VarSqSum,
            SUM(Num_Val * Num_Val * Num_Val) AS VarCuSum,
            SUM(Num_Val * Num_Val * Num_Val * Num_Val) AS VarQdSum,
            9605 AS VarCount
     FROM   tblHomeSurveySparse
     GROUP BY MediaOutletID
     ) AS a
WHERE MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
