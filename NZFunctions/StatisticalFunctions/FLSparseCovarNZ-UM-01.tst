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
---FLSparseCovar
-----****************************************************************
WITH tblHomeSurveyStats (MediaOutletID, VarSum, VarSqSum) AS
(
SELECT a.MediaOutletID,
       SUM(a.Num_Val) AS VarSum,
       SUM(a.Num_Val * a.Num_Val) AS VarSqSum
FROM   tblHomeSurveySparse a
GROUP BY a.MediaOutletID
)
SELECT a.MediaOutletID1,
       a.MediaOutletID2,
       FLSparseCovar(a.VarSumXY,
                     x1.VarSum,
                     x2.VarSum,
                     x1.VarSqSum,
                     x2.VarSqSum,
                     9605) AS FLSparseCovar
FROM
       (
       SELECT a.MediaOutletID AS MediaOutletID1,
              b.MediaOutletID AS MediaOutletID2,
              SUM(a.Num_Val * b.Num_Val) AS VarSumXY
       FROM   tblHomeSurveySparse a,
              tblHomeSurveySparse b
       WHERE   b.ValueID = a.ValueID
       GROUP BY a.MediaOutletID, b.MediaOutletID
       ) AS a,
       tblHomeSurveyStats x1,
       tblHomeSurveyStats x2
WHERE  x1.MediaOutletID = a.MediaOutletID1
AND    x2.MediaOutletID = a.MediaOutletID2
AND    x1.MediaOutletID <= 10
AND    x2.MediaOutletID <= 10
AND    x1.MediaOutletID <= x2.MediaOutletID
ORDER BY 1, 2
LIMIT 20;



-------------------------------------------------------------------------------------
-----****************************************************************
