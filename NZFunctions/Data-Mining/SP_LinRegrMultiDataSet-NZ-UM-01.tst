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
--timing on

-- BEGIN: TEST(s)


-----*******************************************************************************************************************************
---SP_LinRegrMultiDataSet
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LinRegrMultiDataSet *****';
CREATE OR REPLACE VIEW UM_vw_LinRegrMulti AS 
SELECT 1 AS DataSetID, 
       a.ObsID,
       a.VarID,
       a.Value
FROM   tblLinRegr a
WHERE  a.VarID <= 50  AND a.ObsID <= 2000
UNION
SELECT 2 AS DataSetID, a.*
FROM   tblLinRegr  a
WHERE  a.VarID <= 50 AND a.ObsID <= 3000;

CALL SP_LinRegrMultiDataSet('UM_vw_LinRegrMulti', 'HelloWorld');

DROP VIEW UM_vw_LinRegrMulti;


SELECT  a.*
FROM  fzzlLinRegrCoeffs a
WHERE a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLinRegrinfo
					  WHERE Note='HelloWorld')
ORDER BY 3, 1, 2
LIMIT 20;
SELECT  a.*
FROM  fzzlLinRegrStats a
WHERE a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLinRegrinfo
					  WHERE Note='HelloWorld')
ORDER BY 1, 2, 3;








-- END: TEST(s)

-- END: TEST SCRIPT
--timing off