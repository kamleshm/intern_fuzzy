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
---SP_LogRegrFB
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrFB *****';

DROP TABLE UM_vw_LogRegrBWDemo;
CREATE TABLE UM_vw_LogRegrBWDemo
AS
SELECT a.*
FROM tblLogRegrData a
WHERE a.VarID <= 50;

EXEC SP_LogRegrFB('UM_vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.5,0.1,'HelloWorld');


SELECT a.* 
FROM fzzlLogRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLogRegrInfo
					  WHERE Note='HelloWorld')
ORDER BY 2,3
LIMIT 20;

SELECT a.* 
FROM fzzlLogRegrStats a 
WHERE  a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLogRegrInfo
					  WHERE Note='HelloWorld')
AND ModelID <= 2 
ORDER BY 2
LIMIT 20;







-- END: TEST(s)

-- END: TEST SCRIPT
--timing off