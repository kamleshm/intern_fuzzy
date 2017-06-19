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
---SP_GLM
-----*******************************************************************************************************************************
--Insert into fzzlGLMColumns table for ColSpecID
SELECT '***** EXECUTING SP_GLM *****';
DELETE FROM fzzlGLMColumns
WHERE SPECID IN ('GLM1', 'GLM2');
INSERT INTO fzzlGLMColumns
VALUES ('GLM1', 1 ,'ObsID');
INSERT INTO fzzlGLMColumns
VALUES ('GLM1', 1 ,'Drug');
INSERT INTO fzzlGLMColumns
VALUES ('GLM2', 2 ,'Disease');

-----Insert into fzzlGLMIntColumns table for IntSpecID
DELETE FROM fzzlGLMIntColumns
WHERE SPECID IN ( 'Int1', 'Int2') ;
INSERT INTO fzzlGLMIntColumns
VALUES ('Int1', 1 ,'DRUG','Disease');
INSERT INTO fzzlGLMIntColumns
VALUES ('Int2', 1 ,'DISEASE','Trial');

--Insert into fzzlLinRegrModelVarSpec table for ColSpecID
DELETE FROM fzzlLinRegrModelVarSpec
WHERE SPECID IN ('GLM1', 'GLM2');
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('GLM1', 1 ,'I');
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('GLM1', 2 ,'I');
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('GLM2', 3 ,'I');

-----Insert into fzzlLogRegrModelVarSpec table for IntSpecID
DELETE FROM fzzlLinRegrModelVarSpec
WHERE SPECID IN ( 'Int1', 'Int2') ;
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('Int1', 4 ,'I');
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('Int2', 4 ,'I');
INSERT INTO fzzlLinRegrModelVarSpec
VALUES ('Int2', 1 ,'I');


CALL SP_GLM('tblDrugWide',
            'ObsID',
            'Effect',
            'GLM2', 'Int1', 'Drug',
            'HelloWorld');

SELECT a.*
FROM   fzzlGLMRegrCoeffs a
WHERE   a.AnalysisID = (SELECT AnalysisID
                        FROM fzzlGLMinfo
						WHERE Note='HelloWorld')
ORDER BY 2, 3
LIMIT 20;


SELECT a.*
FROM fzzlGLMLSMeans a
WHERE a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlGLMinfo
					  WHERE Note='HelloWorld')
ORDER BY 2, 3
LIMIT 20;

SELECT  a.*
FROM fzzlGLMRegrStats a
WHERE a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlGLMinfo
					  WHERE Note='HelloWorld')
ORDER BY 2
LIMIT 20; 




-- END: TEST(s)

-- END: TEST SCRIPT
--timing off