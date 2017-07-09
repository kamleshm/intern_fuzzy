----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegr *****';
EXEC SP_LinRegr('tblLinRegr', 'Demo');
-- SELECT a.*
-- FROM fzzlLinRegrInfo a
-- WHERE a.AnalysisID = 'MMEHTA_416944';
-- SELECT a.*
-- FROM fzzlLinRegrStats a
-- WHERE a.AnalysisID = 'MMEHTA_416944';
-- SELECT a.*
-- FROM fzzlLinRegrCoeff a
-- WHERE  a.AnalysisID = 'MMEHTA_416944';


INSERT INTO fzzlLinRegrModelVarSpec 
VALUES ('SPEC TEST 1', 2, 'X');
INSERT INTO fzzlLinRegrModelVarSpec 
VALUES ('SPEC TEST 1', 8, 'X');

EXEC SP_LinRegr('tblLinRegr', 'SPEC TEST 1', 'Demo');



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrBW *****';
DROP TABLE tempLinRegrvw;
CREATE TABLE  tempLinRegrvw
AS 
SELECT  a.*
FROM    tblLinRegr a
WHERE  a.VarID <= 50;

ALTER TABLE tempLinRegrvw RENAME Num_Val TO Value;
 
EXEC SP_LinRegrBW('tempLinRegrvw','SPEC TEST 1',0.10, 'Demo');


-- SELECT a.* 
-- FROM fzzlLinRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_219049'  
-- ORDER BY 2,3;

-- SELECT  a.* 
-- FROM fzzlLinRegrStats a 
-- WHERE  a.AnalysisID = 'MMEHTA_219049' 
-- AND ModelID <=2  
-- ORDER BY 2;



----------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrFB *****';
EXEC SP_LinRegrFB('tempLinRegrvw','SPEC TEST 1',0.50,0.10, 'Demo');

-- SELECT a.* 
-- FROM fzzlLinRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_931505'  
-- ORDER BY 2,3;

-- SELECT  a.* 
-- FROM fzzlLinRegrStats a 
-- WHERE  a.AnalysisID = 'MMEHTA_931505' 
-- AND ModelID <=2  
-- ORDER BY 2;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrMultiDataSet *****';
CREATE OR REPLACE VIEW vw_LinRegrMulti AS 
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

CALL SP_LinRegrMultiDataSet('vw_LinRegrMulti', 'Test LinRegrMultiData');

DROP VIEW vw_LinRegrMulti;

-- SELECT  a.*
-- FROM  fzzlLinRegrCoeffs a
-- WHERE a.AnalysisID = 'MMEHTA_386447'
-- ORDER BY 3, 1, 2;
-- SELECT  a.*
-- FROM  fzzlLinRegrStats a
-- WHERE a.AnalysisID = 'MMEHTA_386447'
-- ORDER BY 1, 2, 3;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrSF *****';
EXEC SP_LinRegrSF('tempLinRegrvw','SPEC TEST 1', 'Demo');

-- SELECT a.* 
-- FROM fzzlLinRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_569815'  
-- ORDER BY 2,3;

-- SELECT  a.* 
-- FROM fzzlLinRegrStats a 
-- WHERE  a.AnalysisID = 'MMEHTA_569815' 
-- AND ModelID <=2  
-- ORDER BY 2;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrSW *****';
CREATE OR REPLACE VIEW vw_LinRegrSWDemo
AS (
SELECT ObsID, VarID, Value
FROM tblLinRegr 
WHERE VarID > 0
AND VarID <= 20
AND Value <> 0
UNION ALL
SELECT ObsID, VarID, Value
FROM tblLinRegr 
WHERE VarID IN (-1, 0));

EXEC SP_LinRegrSW ('vw_LinRegrSWDemo','SPEC TEST 1',3,0.10, 'Demo');

-- SELECT a.* 
-- FROM fzzlLinRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_426844' 
-- AND ModelID <= 2 
-- ORDER BY 1,2,3;
-- SELECT a.* 
-- FROM fzzlLinRegrStats a 
-- WHERE  a.AnalysisID = 'MMEHTA_426844' 
-- AND ModelID <= 2;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LinRegrSWEff *****';
CREATE OR REPLACE VIEW vw_LinRegrSWDemo
AS (
SELECT ObsID, VarID, Value
FROM tblLinRegr 
WHERE VarID > 0
AND VarID <= 20
AND Value <> 0
UNION ALL
SELECT ObsID, VarID, Value
FROM tblLinRegr
WHERE VarID IN (-1, 0));

EXEC SP_LinRegrSWEff('vw_LinRegrSWDemo','SPEC TEST 1', 0.5, 0.1, 'Demo');

-- SELECT a.* 
-- FROM fzzlLinRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_579348' 
-- AND ModelID <= 2 
-- ORDER BY 1,2,3;
-- SELECT a.* 
-- FROM fzzlLinRegrStats a 
-- WHERE  a.AnalysisID = 'MMEHTA_579348' 
-- AND ModelID <= 2;
