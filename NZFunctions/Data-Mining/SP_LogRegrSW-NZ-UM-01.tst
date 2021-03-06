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
---SP_LogRegrSW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrSW *****';
CREATE OR REPLACE VIEW UM_vw_LogRegrSWDemo
AS (
SELECT ObsID, VarID, Value
FROM tblLogRegrData
WHERE VarID > 0
AND VarID <= 10
AND value <> 0
UNION ALL
SELECT ObsID, VarID, Value
FROM tblLogRegrData 
WHERE VarID IN (-1, 0));

EXEC SP_LogRegrSW('UM_vw_LogRegrSWDemo',0.1,25,'SPEC TEST 1',3,0.1,'HelloWorld');


SELECT a.* 
FROM fzzlLogRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLogRegrInfo
					  WHERE Note='HelloWorld')
AND ModelID <= 2 
ORDER BY 1,2,3
LIMIT 20;
SELECT a.* 
FROM fzzlLogRegrStats a 
WHERE  a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLogRegrInfo
					  WHERE Note='HelloWorld')
AND ModelID <= 2
LIMIT 20;





-- END: TEST(s)

-- END: TEST SCRIPT
--timing off