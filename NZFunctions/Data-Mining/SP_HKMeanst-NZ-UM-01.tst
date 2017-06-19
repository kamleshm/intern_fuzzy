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
\timing on

-- BEGIN: TEST(s)


-----*******************************************************************************************************************************
---SP_HKMeans
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_HKMeans *****';
DROP TABLE UM_tblKMeansData;

CREATE TABLE UM_tblKMeansData AS 
                         (SELECT * FROM tblUSArrests);
						 


EXEC SP_HKMeans('UM_tblKMeansData', 
                3,                  
                3,                  
                20); 

SELECT * 
FROM  fzzlHKMeansDendrogram 
WHERE Analysisid = (SELECT * FROM analysis) 
ORDER BY 1, 2, 3, 4
LIMIT 20;

SELECT *
FROM fzzlHKMeansHierClusterID
WHERE AnalysisID = (SELECT * FROM analysis)
ORDER BY 1,2,3
LIMIT 20;

SELECT a.ObsID,
DENSE_RANK() OVER (
PARTITION BY 1
ORDER BY MIN(b.ClusterID)
) AS ClusterID
FROM fzzlHKMeansHierClusterID a,
(
SELECT DISTINCT DENSE_RANK() OVER(
PARTITION BY 1
ORDER BY HierClusterID
) AS ClusterID,
HierClusterID
FROM fzzlHKMeansDendrogram
WHERE AnalysisID = (SELECT * FROM analysis)-- Modify Analysis ID
AND LEVEL = 2 -- Modify Level
) b
WHERE AnalysisID = (SELECT * FROM analysis)-- Modify Analysis ID
AND a.HIERCLUSTERID LIKE b.HIERCLUSTERID||'%'
GROUP BY a.OBSID
ORDER BY 1,2
LIMIT 20;









-- END: TEST(s)

-- END: TEST SCRIPT
\timing off