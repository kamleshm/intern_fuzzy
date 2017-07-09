----------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW tblLogRegr_vw
AS (
SELECT ObsID, VarID, Num_Val as Value 
FROM tblLogRegrData);

EXEC SP_LogRegr('tblLogRegr_vw', 0.10, 25, 'Test');


----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegr *****';
EXEC SP_LogRegr('tblLogRegrData', 0.10, 25, 'Test');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'MMEHTA_165254'
-- ORDER BY 1;
-- SELECT a.*
-- FROM   fzzlLogRegrStats a
-- WHERE  a.AnalysisID = 'MMEHTA_165254';



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrBW *****';
CREATE TEMP TABLE tblLogRegrBWDemo
AS 
SELECT ObsID, VarID, Num_Val as Value
FROM    tblLogRegrData a
WHERE  a.VarID <= 50;

EXEC SP_LogRegrBW('tblLogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.1,'Test');
--SELECT a.* 
--FROM fzzlLogRegrCoeffs a 
--WHERE  a.AnalysisID = 'MMEHTA_200834' 
--ORDER BY 2,3;

--SELECT a.* 
--FROM fzzlLogRegrStats a 
--WHERE  a.AnalysisID = 'MMEHTA_200834' 
--AND ModelID <= 2 
--ORDER BY 2;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrFB *****';
EXEC SP_LogRegrFB('vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.5,0.1,'Test');

--SELECT a.* 
--FROM fzzlLogRegrCoeffs a 
--WHERE  a.AnalysisID = 'MMEHTA_667230' 
--ORDER BY 2,3;

--SELECT a.* 
--FROM fzzlLogRegrStats a 
--WHERE  a.AnalysisID = 'MMEHTA_667230' 
--AND ModelID <= 2 
--ORDER BY 2;




----------------------------------------------------------------------------------------

ALTER TABLE TBLLOGREGRMN10000 RENAME COLUMN NUM_VAL TO VALUE;

SELECT '***** EXECUTING SP_LogRegrMNBW *****';
EXEC SP_LogRegrMNBW('TBLLOGREGRMN10000', 1, 25, '' ,0.30, 'Test Notes');

-- SELECT * 
-- FROM fzzlLogRegrMNCoeffs 
-- WHERE AnalysisID ='MMEHTA_383944' 
-- ORDER BY 2, 3, 4;
-- SELECT * 
-- FROM fzzlLogRegrMNStats 
-- WHERE AnalysisID ='MMEHTA_383944' 
-- ORDER BY 2,3;


----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrMNFB *****';
EXEC SP_LogRegrMNFB('tblLogRegrMN10000', 1, 25, '', 0.70, 0.30, 'Test Notes');

-- SELECT a.* 
-- FROM fzzlLogRegrMNCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_332610' 
-- ORDER BY 2, 3, 4;
-- SELECT * 
-- FROM fzzlLogRegrMNStats 
-- WHERE AnalysisID ='MMEHTA_332610' 
-- ORDER BY 2, 3;


----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrMNUFB *****';
EXEC SP_LogRegrMNUFB('tblLogRegrMN10000',
                     1, 
                     25,
                    '',
                     0.70, 
                     0.30,
                     0.20, 
                    'Sam Test');

-- SELECT * 
-- FROM fzzlLogRegrMNCoeffs 
-- WHERE AnalysisID ='MMEHTA_584459' 
-- ORDER BY 2, 3, 4;
-- SELECT *  
-- FROM fzzlLogRegrMNStats  
-- WHERE Analysisid = 'MMEHTA_584459' 
-- ORDER BY 2,3;



----------------------------------------------------------------------------------------
CREATE TEMP TABLE tblLogRegrMultiDS AS
SELECT *, NUM_VAL as VALUE FROM tblLogRegrMulti a;

SELECT '***** EXECUTING SP_LogRegrMultiDataSet *****';
CALL SP_LogRegrMultiDataSet('tblLogRegrMultiDS', 25, 0.10,'Test Notes');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'MMEHTA_285205'
-- ORDER BY 3, 1, 2;
-- SELECT a.*
-- FROM fzzlLogRegrStats a
-- WHERE a.AnalysisID = 'MMEHTA_285205'
-- ORDER BY 1, 2, 3;


----------------------------------------------------------------------------------------
CREATE TEMP TABLE tblLogRegrSFDemo AS 
SELECT ObsID, VarID, Num_Val as Value
FROM    tblLogRegrData a
WHERE  a.VarID <= 50;

SELECT '***** EXECUTING SP_LogRegrSF *****';
EXEC SP_LogRegrSF('tblLogRegrSFDemo', 0.1,25,'SPEC TEST 1','Test');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffsSF a
-- WHERE a.AnalysisID = 'MMEHTA_265033'
-- ORDER BY 2;
-- SELECT a.*
-- FROM fzzlLogRegrStatsSF a
-- WHERE a.AnalysisID = 'MMEHTA_265033'
-- ORDER BY 2;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrSW *****';
CREATE TEMP TABLE tblLogRegrSWDemo
AS (
SELECT ObsID, VarID, Num_Val as Value
FROM tblLogRegrData
WHERE VarID > 0
AND VarID <= 10
AND value <> 0
UNION ALL
SELECT ObsID, VarID, Num_Val as Value
FROM tblLogRegrData 
WHERE VarID IN (-1, 0));

EXEC SP_LogRegrSW('tblLogRegrSWDemo',0.1,25,'SPEC TEST 1',3,0.1,'Test');

-- SELECT a.* 
-- FROM fzzlLogRegrCoeffs a 
-- WHERE  a.AnalysisID = 'ADMIN_352035' 
-- AND ModelID <= 2 
-- ORDER BY 1,2,3;
-- SELECT a.* 
-- FROM fzzlLogRegrStats a 
-- WHERE  a.AnalysisID = 'ADMIN_352035' 
-- AND ModelID <= 2;


----------------------------------------------------------------------------------------
CREATE TEMP TABLE tblLogRegrWtDemo AS 
SELECT ObsID, VarID, Num_Val as Value
FROM    tblLogRegrData a
WHERE  a.VarID <= 50;

SELECT '***** EXECUTING SP_LogRegrWt *****';
CALL SP_LogRegrWt('tblLogRegrWtDemo',  0.10, 25, 0.8, 1, 'Test');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'FBAI_570336'
-- ORDER BY 1;
-- SELECT a.*
-- FROM fzzlLogRegrStats a
-- WHERE a.AnalysisID = 'FBAI_570336';
