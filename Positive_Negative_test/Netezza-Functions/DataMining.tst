----------------------------------------------------------------------------------------

SELECT '***** EXECUTING SP_WideToDeep *****';
DROP TABLE tblFieldMap;
DROP TABLE tblAbaloneWTD;
DROP TABLE tblAbaloneDTW;
EXEC SP_WideToDeep('tblAbaloneWide', 
                   'ObsID', 
                   'tblFieldMap', 
                   'tblAbaloneWTD', 
                   0);
SELECT	*
FROM	tblFieldMap
ORDER BY 1,2;

SELECT	*
FROM	tblAbaloneWTD
ORDER BY 1,2
LIMIT 20;

SELECT '***** EXECUTING SP_DeepToWide *****';
EXEC SP_DeepToWide('tblAbaloneWTD', 
                   'tblFieldMap', 
                   'tblAbaloneWide',  
                   'tblAbaloneDTW');

SELECT	*
FROM	tblAbaloneDTW
ORDER BY 1
LIMIT 10;

----------------------------------------------------------------------------------------
DROP TABLE tblDeep;

SELECT '***** EXECUTING SP_RegrDataPrep *****';
EXEC SP_RegrDataPrep(NULL,         -- New Conversion
		'tblAutoMpg',   -- Name of Input Wide Table
		'ObsID',	    -- Name of the observation id Column
		'MPG',          -- Name of the dependent variable
		'tblDeep',  	-- Name of the Output Deep Table.
					    -- This table should not exist.
		true,       	-- Transform Categorical to Dummy
		false,      	-- Perform Mean Normalization
		false,      	-- Perform Variable Reduction
		false,      	-- Make data Sparse
		0.0001,     	-- Minimum acceptable Standard Deviation
		0.98,       	-- Maximum Acceptable correlation
		0,          	-- 0 => Training data set
		'CarNum',    	-- Exclude Columns
		'CarNum');      -- Columns to exclude from conversion	


SELECT a.* 
FROM   fzzlRegrDataPrepMap a
WHERE  a.AnalysisID = 'MMEHTA_117756'
ORDER BY a.Final_VarID
LIMIT 20;

SELECT *
FROM tblDeep
ORDER BY 1, 2
LIMIT 20;



----------------------------------------------------------------------------------------

--Create View
CREATE OR REPLACE VIEW tblDecisionTreeMulti_VW
AS(
SELECT OBSID, VARID, NUM_VAL AS Value FROM tblDecisionTreeMulti);
-- Execute Stored Procedure
SELECT '***** EXECUTING SP_DecisionTree *****';
EXEC SP_DecisionTree('tblDTData',
                      5,
                      5,
                      0.95,
                     'Cont. Sample');





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_DecisionTree *****';
EXEC SP_DecisionTree('tblDTData',
                      100,
                      4,
                      0.8,
                     'Cont. Sample');

--DROP TABLE tblDTDataScore;
--EXEC SP_DecisionTreeScore('tblDecisionTreeMulti_VW',
  --                        'MMEHTA_368901',
    --                      'tblDTDataScore',
      --                     'score test');





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLHoltWinter *****';
SELECT b.SerialVal,
FLHoltWinter(a.PERIODID, 
             a.VAL, 
             7, 
             0.20, 
             0.20, 
             0.80,
             b.SerialVal, 
             1)
FROM tbltseries_hltwntr a, fzzlSerial b
WHERE b.SerialVal <= 28
GROUP BY b.SerialVal
ORDER BY 1;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_KaplanMeier *****';
CREATE OR REPLACE VIEW vwWHAS100 AS
SELECT 1 AS DataSetID,
       a.ID AS ObsID,
       a.FolDate - a.AdmitDate AS TIME,
       a.FStat AS STATUS,
       a.Gender
FROM tblWHAS100 a
UNION ALL
SELECT 2 AS DataSetID,
       a.ID AS ObsID,
       a.FolDate - a.AdmitDate AS TIME,
       a.FStat AS STATUS,
       a.Gender
FROM tblWHAS100 a;

EXEC SP_KaplanMeier('vwWHAS100',0.05,'2 Sets Est');

--SELECT *
--FROM fzzlKaplanMeierInfo
--WHERE Analysisid = 'MMEHTA_454356';
--SELECT *
--FROM fzzlKaplanMeier
--WHERE Analysisid = 'MMEHTA_454356';



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_KaplanMeierHypoTest *****';
EXEC SP_KaplanMeierHypoTest('vwWHAS100', 1, 2, 'HypoTest'); 
--SELECT * 
--FROM fzzlKaplanMeierInfo 
--WHERE AnalysisID = 'MMEHTA_820702';
--SELECT * 
--FROM fzzlKaplanMeierHypoTest 
--WHERE AnalysisID = 'MMEHTA_820702'
--ORDER BY 3;




----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_KMeans *****';
SELECT SP_KMeans('tblKMeansData',5,10);
--SELECT * 
--FROM fzzlKMeansCentroid 
--WHERE Analysisid = 'MMEHTA_414317' 
--ORDER BY DimID, ClusterID;
-- SELECT ClusterID, 
--        COUNT(*) 
-- FROM fzzlKMeansClusterid 
-- WHERE AnalysisID = 'MMEHTA_414317' 
-- GROUP BY ClusterID
-- ORDER BY ClusterID;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_HKMeans *****';
EXEC SP_HKMeans('tblKMeansData', 
                3,                  
                3,                  
                20); 


-- SELECT * 
-- FROM  fzzlHKMeansDendrogram 
-- WHERE Analysisid = 'MMEHTA_188230' 
-- ORDER BY 1, 2, 3, 4;

-- SELECT * 
-- FROM  fzzlHKMeansHierClusterID 
-- WHERE AnalysisID = 'MMEHTA_188230' 
-- ORDER BY 1,2,3;

-- SELECT a.ObsID,
--        DENSE_RANK() OVER (
--                           PARTITION BY 1 
--                           ORDER BY MIN(b.ClusterID)
--                           ) AS ClusterID
-- FROM fzzlHKMeansHierClusterID a,
-- (
-- SELECT DISTINCT DENSE_RANK() OVER(
--                                   PARTITION BY 1 
--                                   ORDER BY HierClusterID
--                                   ) AS ClusterID, 
--         HierClusterID 
-- FROM fzzlHKMeansDendrogram 
-- WHERE AnalysisID = 'MMEHTA_188230'
-- -- Modify Analysis ID
-- AND LEVEL = 2                      
-- -- Modify Level
-- ) b
-- WHERE AnalysisID = 'MMEHTA_188230'
-- -- Modify Analysis ID
-- AND a.HIERCLUSTERID LIKE b.HIERCLUSTERID||'%'
-- GROUP BY a.OBSID
-- ORDER BY 1,2;






----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLLinRegrUDT *****';
SELECT  f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)    
        AS begin_flag, 
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)   
        AS end_flag
FROM tbllinregrdatadeep a
) AS z,
TABLE(FLLinRegrUDT(z.GroupID, 
                   z.ObsID, 
                   z.VarID, 
                   z.Num_Val,
                   1,
                   0.05,
                   0.95,                    
                   z.begin_flag, 
                   z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20; 




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

-----Insert into fzzlGLMIntColumns table for  IntSpecID
DELETE FROM  fzzlGLMIntColumns 
WHERE SPECID IN ( 'Int1', 'Int2') ;
INSERT INTO fzzlGLMIntColumns
VALUES ('Int1', 1 ,'DRUG','Disease');
INSERT INTO fzzlGLMIntColumns
VALUES ('Int2', 1 ,'DISEASE','Trial');


CALL SP_GLM('tblDrugWide', 
            'ObsID', 
            'Effect', 
            'GLM2', 
            '', 
            'Drug', 
            'GLM Test 2');


-- SELECT a.*
-- FROM   fzzlGLMRegrCoeffs a
-- WHERE   a.AnalysisID = 'MMEHTA_721448'
-- ORDER BY 2, 3;

-- SELECT a.*
-- FROM fzzlGLMLSMeans a
-- WHERE a.AnalysisID = 'MMEHTA_721448'
-- ORDER BY 2, 3;

-- SELECT  a.*
-- FROM fzzlGLMRegrStats a
-- WHERE a.AnalysisID = 'MMEHTA_721448'
-- ORDER BY 2; 







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




----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLLinRegrBWUdt *****';
SELECT f.*
FROM(
SELECT a.GroupID,
       a.ObsID,
       a.VarID,
       a.Num_Val,
       NVL(LAG(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)    
       AS begin_flag, 
       NVL(LEAD(0) OVER (PARTITION BY a.GroupID ORDER BY a.ObsID), 1)   
       AS end_flag
FROM tbllinregrdatadeep a) AS z,
TABLE(FLLinRegrBWUdt(z.GroupID, 
                     z.ObsID, 
                     z.VarID, 
                     z.Num_Val,
                     1,
                     0.01,
                     0.95,
                     0.10,
                     z.begin_flag, 
                     z.end_flag)) AS f 
ORDER BY 1 ASC, 2 DESC, 5 ASC
LIMIT 20;




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
CREATE TABLE vw_LogRegrBWDemo
AS 
SELECT  a.*
FROM    tblLogRegrData a
WHERE  a.VarID <= 50;
EXEC SP_LogRegrBW('vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.1,'Test');
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
CREATE OR REPLACE VIEW tblLogRegr_vw
AS (
SELECT ObsID, VarID, Value 
FROM tblLogRegrData);

EXEC SP_LogRegr('tblLogRegr_vw', 0.10, 25, 'Test');











----------------------------------------------------------------------------------------
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
                    'Feng Test');
-- SELECT * 
-- FROM fzzlLogRegrMNCoeffs 
-- WHERE AnalysisID ='MMEHTA_584459' 
-- ORDER BY 2, 3, 4;
-- SELECT *  
-- FROM fzzlLogRegrMNStats  
-- WHERE Analysisid = 'MMEHTA_584459' 
-- ORDER BY 2,3;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrMultiDataSet *****';
CALL SP_LogRegrMultiDataSet('tblLogRegrMulti', 25, 0.10,'Test Notes');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'MMEHTA_285205'
-- ORDER BY 3, 1, 2;
-- SELECT a.*
-- FROM fzzlLogRegrStats a
-- WHERE a.AnalysisID = 'MMEHTA_285205'
-- ORDER BY 1, 2, 3;




----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrSF *****';
EXEC SP_LogRegrSF('tblLogRegrData', 0.1,25,'SPEC TEST 1','Test');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffsSF a
-- WHERE a.AnalysisID = 'MMEHTA_265033'
-- ORDER BY 2;
-- SELECT a.*
-- FROM fzzlLogRegrStatsSF a
-- WHERE a.AnalysisID = 'MMEHTA_265033'
-- ORDER BY 2;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrFB *****';
EXEC SP_LogRegrFB('vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.5,0.1,'Test');





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegr *****';
CREATE OR REPLACE VIEW tblLogRegr_vw
AS (
SELECT ObsID, VarID, value FROM tblLogRegrData);

EXEC SP_LogRegr('tblLogRegr_vw', 0.1,25,'SPEC TEST 1','Test');





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrSW *****';
CREATE TEMP TABLE tblLogRegrSWDemo
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

EXEC SP_LogRegrSW('vw_LogRegrSWDemo',0.1,25,'SPEC TEST 1',3,0.1,'Test');

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
SELECT '***** EXECUTING SP_LogRegrSWEff *****';
CREATE OR REPLACE VIEW vw_LogRegrSWDemo
AS (
SELECT  a.*
FROM    tblLogRegrData a
WHERE   a.VarID > 0
AND     a.VarID <= 10
AND     a.Value <> 0
UNION ALL
SELECT  a.*
FROM    tblLogRegrData a
WHERE   a.VarID IN (-1, 0));
CALL SP_LogRegrSWEff('vw_LogRegrSWDemo', 0.10, 25,3,0.1,'Test');
DROP VIEW vw_LogRegrSWDemo;

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'FBAI_918504'
-- AND ModelID <= 2 
-- ORDER BY 1,2,3;
-- SELECT a.*
-- FROM fzzlLogRegrStats a
-- WHERE a.AnalysisID = 'FBAI_918504'
-- AND ModelID <= 2 ;







----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_LogRegrWt *****';
CALL SP_LogRegrWt('tblLogRegrData',  0.10, 25, 0.8, 1, 'Test');

-- SELECT a.*
-- FROM fzzlLogRegrCoeffs a
-- WHERE a.AnalysisID = 'FBAI_570336'
-- ORDER BY 1;
-- SELECT a.*
-- FROM fzzlLogRegrStats a
-- WHERE a.AnalysisID = 'FBAI_570336';






----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLCalcProb *****';
SELECT a.ObsID,
       FLCalcProb(b.CoeffValue, a.Value) AS p_hat
FROM   tblLogRegr a,
       fzzlLogRegrCoeffs b
WHERE  a.VarID = b.CoeffID
AND    b.MODELID = 1
AND    b.AnalysisID = 'MMEHTA_615119'
GROUP  BY a.ObsID
ORDER  BY a.ObsID;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLNSBeta *****';
SELECT a.SeriesID,
        FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
        FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
        FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
        1 AS Lambda
FROM tblNelsonSiegel a
GROUP BY a.SeriesID
ORDER BY 1;



SELECT '***** EXECUTING FLNSBeta *****';
SELECT a.SeriesID,
FLNSBeta('BETA0', a.XVal, a.YVal, 1.5) AS Beta0,
FLNSBeta('BETA1', a.XVal, a.Yval, 1.5) AS Beta1,
FLNSBeta('BETA2', a.XVal, a.YVal, 1.5) AS Beta2,
       1.5 AS Lambda
FROM tblNelsonSiegel a
GROUP BY a.SeriesID
ORDER BY 1;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLNSPredict *****';
SELECT q.SeriesID,
      q.ObsID,
      q.Yval,
      FLNSPredict(p.Beta0, p.Beta1, p.Beta2,
      p.Lambda, q.XVal)
FROM(
    SELECT a.seriesID,
    FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
    FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
    FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
    1 AS Lambda
    FROM tblNelsonSiegel a
    GROUP BY a.SeriesID
     ) AS p,
    tblNelsonSiegel q
WHERE q.SeriesID = p.SeriesID
ORDER BY 1, 2;





----------------------------------------------------------------------------------------
DROP TABLE tblWineDeep;
DROP TABLE tblWineTrain;
DROP TABLE tblWineModel;

EXEC SP_RegrDataPrep(NULL,            
                    'tblWine',  
                    'ObsID',            
                    'Wine_Type',    
                    'tblWineDeep',     
                    false,          
                    true,           
                    false,       
                    false,           
                    0,        
                    1,          
                    0,         
                    '', 
                    '');

CREATE TABLE tblWineTrain
AS  ( 
    SELECT  a.*
    FROM    tblWineDeep a
    WHERE   a.ObsID <= 90
    )
DISTRIBUTE ON (ObsID);

SELECT '***** EXECUTING FLNeuralNetUdt *****';
CREATE TABLE tblWineModel AS (
SELECT f.*
FROM(SELECT 1 AS GroupID,
                 a.ObsID,
                 a.VarID,
                 a.Value,
                 10 AS NeuronCount1,
                 5 AS NeuronCount2,
                 0.2 AS LearningRate,
                 500 AS MaxEpochs,
                 1 AS ExecutionMode,
                 NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
a.ObsID,a.VarID), 1) AS begin_flag, 
                 NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
a.ObsID,a.VarID), 1) AS end_flag
FROM tblWineTrain a) AS z,
TABLE (FLNeuralNetUdt(z.GroupID, 
                      z.ObsID, 
                      z.VarID, 
                      z.Value, 
                      z.NeuronCount1, 
                      z.NeuronCount2, 
                      z.LearningRate, 
                      z.MaxEpochs, 
                      z.ExecutionMode, 
                      z.begin_flag, 
                      z.end_flag)) AS f ORDER BY 1,2,3,4 );

SELECT * 
FROM tblWineModel 
ORDER BY 1,2,3,4;  





----------------------------------------------------------------------------------------
DROP TABLE tblWineTest;
CREATE TABLE tblWineTest
AS  ( 
    SELECT  a.*
    FROM    tblWineDeep a
    WHERE   a.ObsID > 90
    )
DISTRIBUTE ON (ObsID);

SELECT '***** EXECUTING SP_NeuralNetScore *****';
CALL SP_NeuralNetScore('tblWineModel', -- model table from previous step
          		         'tblWineTest', -- table to be scored
                       	NULL,    	-- group id column name
                       'ObsID',         -- observation id column name
                       'VarID',         -- variable id column name
                       'Value',        -- value column name
                       'tblWineScore'  -- Output score table
     			); 

SELECT * 
FROM tblWineScore 
ORDER BY 1,2;



-- Skipped the SP_NeuralNetScore to be fixed later
----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_PoissonRegr *****';
CALL SP_PoissonRegr('tblPoissonDeep', 25, 'Test Notes');

-- SELECT a.* 
-- FROM fzzlPoissonRegrCoeffs a 
-- WHERE  a.AnalysisID = 'MMEHTA_824330' 
-- ORDER BY 2;
-- SELECT a.* 
-- FROM fzzlPoissonRegrStats a 
-- WHERE a.AnalysisID = 'MMEHTA_824330';





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_SurveySelectStratExact *****';
DROP TABLE tblSample;
EXEC SP_SurveySelectStratExact('tblPopulation',
                                'ObsID',
                                'StratumID',
                                'tblSample',
                                'tblStratumSize',
                                2,
                                '100 samples perc') ;

-- SELECT *
-- FROM fzzlSurveySelectInfo
-- WHERE Analysisid = 'MMEHTA_202432';
-- SELECT *
-- FROM tblSample
-- ORDER BY 1, 2, 3;
-- SELECT *
-- FROM tblSample
-- ORDER BY 1, 2, 3;




----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_SurveySelectStratPerc *****';
DROP TABLE tblSample;
EXEC SP_SurveySelectStratPerc('tblPopulation',
                            'ObsID',
                            'StratumID',
                            'tblSample',
                            'tblStratumSize',
                            2,
                            '2 samples perc');

-- SELECT *
-- FROM fzzlSurveySelectInfo
-- WHERE Analysisid = 'MMEHTA_791124';
-- SELECT *
-- FROM tblSample
-- ORDER BY 1, 2, 3;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLSVMGaussianUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            0.1 As SigmaSqr,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMnonLinearSeparated a) AS z,
TABLE(FLSVMGaussianUdt(z.GroupID, 
                       z.ObsID, 
                       z.VarID, 
                       z.Num_Val, 
                       z.CValue, 
                       z.SigmaSqr, 
                       z.begin_flag, 
                       z.end_flag)) AS f
                       ORDER BY 1, 2, 3;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLSVMLinearUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMLinSeparableDeep a) AS z,
TABLE(FLSVMLinearUdt(z.GroupID, 
                     z.ObsID, 
                     z.VarID, 
                     z.Num_Val, 
                     z.CValue, 
                     z.begin_flag, 
                     z.end_flag)) AS f;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING FLSVMPolynomialUdt *****';
SELECT f.*
FROM(SELECT 1 As GroupID,
            a.ObsID,
            a.VarID,
            a.Num_Val,
            5 As CValue,
            2 As Degree,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1) 
            AS begin_flag, 
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY a.ObsID), 1)
            AS end_flag
FROM tblSVMnonLinearSeparated a) AS z,
TABLE(FLSVMPolynomialUdt(z.GroupID, 
                         z.ObsID, 
                         z.VarID, 
                         z.Num_Val, 
                         z.CValue, 
                         z.Degree, 
                         z.begin_flag, 
                         z.end_flag)) AS f
                         ORDER BY 1, 2, 3;






----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_VIF *****';
CALL SP_VIF('tblLinRegr', 'New Test 1');

-- SELECT * 
-- FROM  fzzlVIFstats 
-- WHERE AnalysisID = 'MMEHTA_230345' 
-- ORDER BY VarID;




----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_VIFBW *****';
CREATE OR REPLACE VIEW V_TBLLINREGR_V20_withGrpID
AS
SELECT 1 AS DATASETID,
       a.* 
FROM tblLinRegr a
WHERE a.VARID <= 20;

CALL SP_VIFBW('V_TBLLINREGR_V20_withGrpID',5,'MMEHTA TEST');

-- SELECT  a.*
-- FROM fzzlVIFBWStats a
-- WHERE a.AnalysisID ='MMEHTA_315056'
-- ORDER BY 1, 2, 4, 3;





----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_VIFMultiDataSet *****';
CALL SP_VIFMultiDataSet('tbllogregrmulti','Manual test');

-- SELECT *
-- FROM fzzlVIFStats
-- WHERE AnalysisID = 'MMEHTA_209744'
-- ORDER BY 1, 2, 3;


-- DROP TABLES
DROP TABLE tblFieldMap;
DROP TABLE tblAbaloneWTD;
DROP TABLE tblAbaloneDTW;
DROP TABLE tblDeep;
DROP TABLE tempLinRegrvw;
DROP TABLE TABLE vw_LogRegrBWDemo;
DROP TABLE tblWineDeep;
DROP TABLE tblWineTrain;
DROP TABLE tblWineModel;
DROP TABLE tblWineTest;
DROP TABLE tblSample;