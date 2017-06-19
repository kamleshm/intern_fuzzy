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
---FLSparseVar
-----****************************************************************
SELECT a.MediaOutletID,
       FLSparseVar(a.VarSum,
                   a.VarSqSum,
                   a.VarCount) AS FLSparseVar
FROM( 
     SELECT MediaOutletID,
          SUM(Num_Val) AS VarSum,
          SUM(Num_Val * Num_Val) AS VarSqSum,
          9605 AS VarCount
     FROM tblHomeSurveySparse
     GROUP BY MediaOutletID
    ) AS a
WHERE  MediaOutletID <= 10
ORDER BY 1;



-------------------------------------------------------------------------------------
-----****************************************************************
