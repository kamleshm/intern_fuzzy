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
---SP_WideToDeep
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_WideToDeep *****';

DROP TABLE tblFieldMap;
DROP TABLE tblAbaloneWTD;
EXEC SP_WideToDeep('tblAbaloneWide', 
                   'ObsID', 
                   'tblFieldMap', 
                   'tblAbaloneWTD', 
                   0);
SELECT	*
FROM tblFieldMap
ORDER BY 1,2;

SELECT	*
FROM tblAbaloneWTD
ORDER BY 1,2
LIMIT 20;




-----*******************************************************************************************************************************
---SP_DeepToWide
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_DeepToWide *****';
EXEC SP_DeepToWide('tblAbaloneWTD', 
                   'tblFieldMap', 
                   'tblAbaloneWide',  
                   'tblAbaloneDTW');

SELECT	*
FROM tblAbaloneDTW
ORDER BY 1
LIMIT 10;



-----*******************************************************************************************************************************
---SP_RegrDataPrep
-----*******************************************************************************************************************************
DROP TABLE tblDeep;

SELECT '***** EXECUTING SP_RegrDataPrep *****';
\o foo.out
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
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new

CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM   fzzlRegrDataPrepMap a
WHERE  a.AnalysisID = (select * from analysis)
ORDER BY a.Final_VarID
LIMIT 20;

SELECT *
FROM tblDeep
ORDER BY 1, 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_DecisionTree
-----*******************************************************************************************************************************
--Create View
CREATE OR REPLACE VIEW tblDecisionTreeMulti_VW
AS(
SELECT OBSID, VARID, NUM_VAL AS Value FROM tblDecisionTreeMulti);
-- Execute Stored Procedure
\o foo.out
EXEC SP_DecisionTree('tblDecisionTreeMulti_VW',
                      5,
                      5,
                      0.95,
                      'Cont. Sample');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new

CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_DecisionTreeScore
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_DecisionTree *****';
\o foo.out
EXEC SP_DecisionTree('tblDecisionTreeMulti_VW',
                      100,
                      4,
                      0.8,
                     'Cont. Sample');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

					
SELECT *
FROM fzzlDecisionTree
WHERE AnalysisID = (SELECT * FROM analysis)
ORDER BY LEVEL, ChildType, ParentNodeID;	

\!rm -f foo.out new
		
DROP TABLE tblDTDataScore;

\o foo.out
EXEC SP_DecisionTreeScore('tblDecisionTreeMulti_VW',
                          'analysisId',
                          'tblDTDataScore',
                          'score test');   
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis1(col1 varchar(50));
INSERT INTO analysis1 select * from external '/export/home/nz/new';


DROP TABLE analysis;
DROP TABLE analysis1;
\!rm -f foo.out new	

	  
EXEC SP_DecisionTree('tblDecisionTreeMulti_VW',
                      10,
                      4,
                      0.99,
                      'Sparse Binary Sample');




-----*******************************************************************************************************************************
---SP_KaplanMeier
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_KaplanMeier *****';
DROP VIEW vwWHAS100;
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

\o foo.out
EXEC SP_KaplanMeier('vwWHAS100',0.05,'2 Sets Est');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT *
FROM fzzlKaplanMeierInfo
WHERE Analysisid = (SELECT * FROM analysis);
SELECT *
FROM fzzlKaplanMeier
WHERE Analysisid = (SELECT * FROM analysis)
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_KaplanMeierHypoTest
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_KaplanMeierHypoTest *****';
\o foo.out
EXEC SP_KaplanMeierHypoTest('vwWHAS100', 1, 2, 'HypoTest'); 
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT * 
FROM fzzlKaplanMeierInfo 
WHERE AnalysisID = (SELECT * FROM analysis);
SELECT * 
FROM fzzlKaplanMeierHypoTest 
WHERE AnalysisID = (SELECT * FROM analysis)
ORDER BY 3
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_HKMeans
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_HKMeans *****';
DROP TABLE tblKMeansData;

CREATE TABLE tblKMeansData AS 
                         (SELECT * FROM tblUSArrests);
						 

\o foo.out
EXEC SP_HKMeans('tblKMeansData', 
                3,                  
                3,                  
                20); 
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

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



DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_KMeans
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_KMeans *****';
\o foo.out
SELECT SP_KMeans('tblKMeansData',5,10);
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT * 
FROM fzzlKMeansCentroid 
WHERE Analysisid = (SELECT * FROM analysis) 
ORDER BY DimID, ClusterID
LIMIT 20;
 SELECT ClusterID, 
        COUNT(*) 
 FROM fzzlKMeansClusterid 
 WHERE AnalysisID = (SELECT * FROM analysis)
 GROUP BY ClusterID
 ORDER BY ClusterID
 LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new




-----*******************************************************************************************************************************
---FLLinRegrUDT
-----*******************************************************************************************************************************
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




-----*******************************************************************************************************************************
---SP_LinRegr
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LinRegr *****';
--CASE 1: Linear Regression using this stored procedure
ALTER TABLE tblLinRegr RENAME num_val to value; 

\o foo.out
EXEC SP_LinRegr('tblLinRegr', 'Demo');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.*
FROM fzzlLinRegrInfo a
WHERE a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;
SELECT a.*
FROM fzzlLinRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;
SELECT a.*
FROM fzzlLinRegrCoeffs a
WHERE  a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new

-- CASE 2: Run linear regression with SPECID
INSERT INTO fzzlLinRegrModelVarSpec 
VALUES ('SPEC TEST 1', 2, 'X');
INSERT INTO fzzlLinRegrModelVarSpec 
VALUES ('SPEC TEST 1', 8, 'X');

\o foo.out
EXEC SP_LinRegr('tblLinRegr', 'SPEC TEST 1', 'Demo');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

DROP TABLE analysis;
\!rm -f foo.out new



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

\o foo.out
CALL SP_GLM('tblDrugWide',
            'ObsID',
            'Effect',
            'GLM2', 'Int1', 'Drug',
            'Demo');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM   fzzlGLMRegrCoeffs a
WHERE   a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2, 3
LIMIT 20;


SELECT a.*
FROM fzzlGLMLSMeans a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2, 3
LIMIT 20;

SELECT  a.*
FROM fzzlGLMRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2
LIMIT 20; 

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LinRegrBW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LinRegrBW *****';
DROP TABLE tempLinRegrvw;
CREATE TABLE  tempLinRegrvw
AS 
SELECT  a.*
FROM    tblLinRegr a
WHERE  a.VarID <= 50;

ALTER TABLE tempLinRegrvw RENAME Num_Val TO Value;
 \o foo.out
EXEC SP_LinRegrBW('tempLinRegrvw','SPEC TEST 1',0.10, 'Demo');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLinRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;

SELECT  a.* 
FROM fzzlLinRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <=2  
ORDER BY 2
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---FLLinRegrBWUdt
-----*******************************************************************************************************************************
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




-----*******************************************************************************************************************************
---SP_LinRegrFB
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LinRegrFB *****';
\o foo.out
EXEC SP_LinRegrFB('tempLinRegrvw','SPEC TEST 1',0.50,0.10, 'Demo');
\o
\! cat foo.out

\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.* 
FROM fzzlLinRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;

SELECT  a.* 
FROM fzzlLinRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <=2  
ORDER BY 2
LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LinRegrMultiDataSet
-----*******************************************************************************************************************************
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
\o foo.out
CALL SP_LinRegrMultiDataSet('vw_LinRegrMulti', 'Test LinRegrMultiData');
\o
\! cat foo.out
DROP VIEW vw_LinRegrMulti;

\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT  a.*
FROM  fzzlLinRegrCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 3, 1, 2
LIMIT 20;
SELECT  a.*
FROM  fzzlLinRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 1, 2, 3;
DROP TABLE analysis;
\!rm -f foo.out new

-----*******************************************************************************************************************************
---SP_LinRegrSF
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LinRegrSF *****';
\o foo.out
EXEC SP_LinRegrSF('tempLinRegrvw','SPEC TEST 1', 'Demo');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLinRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;

SELECT  a.* 
FROM fzzlLinRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <=2  
ORDER BY 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new

-----*******************************************************************************************************************************
---SP_LinRegrSW
-----*******************************************************************************************************************************
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
\o foo.out
EXEC SP_LinRegrSW ('vw_LinRegrSWDemo','SPEC TEST 1',3,0.10, 'Demo');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.* 
FROM fzzlLinRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 1,2,3
LIMIT 20;
SELECT a.* 
FROM fzzlLinRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LinRegrSWEff
-----*******************************************************************************************************************************
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
\o foo.out
EXEC SP_LinRegrSWEff('vw_LinRegrSWDemo','SPEC TEST 1', 0.5, 0.1, 'Demo');

\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.* 
FROM fzzlLinRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 1,2,3
LIMIT 20;
SELECT a.* 
FROM fzzlLinRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new

-----*******************************************************************************************************************************
---SP_LogRegr
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegr *****';

ALTER TABLE tblLogRegrData RENAME num_val to value;
\o foo.out
EXEC SP_LogRegr('tblLogRegrData', 0.10, 25, 'Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM fzzlLogRegrCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY CoeffID
LIMIT 20;

SELECT a.*
FROM   fzzlLogRegrStats a
WHERE  a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new







-----*******************************************************************************************************************************
---SP_LogRegrBW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrBW *****';
DROP TABLE vw_LogRegrBWDemo;
CREATE TABLE vw_LogRegrBWDemo
AS 
SELECT  a.*
FROM    tblLogRegrData a
WHERE  a.VarID <= 50;
\o foo.out
EXEC SP_LogRegrBW('vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.1,'Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLogRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis) 
ORDER BY 2,3
LIMIT 20;

SELECT a.* 
FROM fzzlLogRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_LogRegrFB
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrFB *****';
\o foo.out
EXEC SP_LogRegrFB('vw_LogRegrBWDemo', 0.1,25, 'SPEC TEST 1',0.5,0.1,'Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLogRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;

SELECT a.* 
FROM fzzlLogRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LogRegrMN
-----*******************************************************************************************************************************
ALTER TABLE tblLogRegrMN10000 RENAME num_val TO Value;
\o foo.out
EXEC SP_LogRegrMN('tblLogRegrMN10000', 3, 25, 'Test RegrMN');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM fzzlLogRegrMNCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2, 3
LIMIT 20;

SELECT a.*
FROM fzzlLogRegrMNStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_LogRegrMNBW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrMNBW *****';
\o foo.out
EXEC SP_LogRegrMNBW('TBLLOGREGRMN10000', 1, 25, '' ,0.30, 'Test Notes');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT * 
FROM fzzlLogRegrMNCoeffs 
WHERE AnalysisID =(SELECT * FROM analysis)
ORDER BY 2, 3, 4
LIMIT 20;

SELECT * 
FROM fzzlLogRegrMNStats 
WHERE AnalysisID =(SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LogRegrMNFB
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrMNFB *****';
\o foo.out
EXEC SP_LogRegrMNFB('tblLogRegrMN10000', 1, 25, '', 0.70, 0.30, 'Test Notes');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLogRegrMNCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2, 3, 4
LIMIT 20;

SELECT * 
FROM fzzlLogRegrMNStats 
WHERE AnalysisID =(SELECT * FROM analysis)
ORDER BY 2, 3
LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LogRegrMNUFB
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrMNUFB *****';
\o foo.out
EXEC SP_LogRegrMNUFB('tblLogRegrMN10000',
                     1, 
                     25,
                    '',
                     0.70, 
                     0.30,
                     0.20, 
                    'Feng Test');
\o
\! cat foo.out
\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';					
					
SELECT * 
FROM fzzlLogRegrMNCoeffs 
WHERE AnalysisID =(SELECT * FROM analysis)
ORDER BY 2, 3, 4
LIMIT 20;
SELECT *  
FROM fzzlLogRegrMNStats  
WHERE Analysisid = (SELECT * FROM analysis)
ORDER BY 2,3
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new




-----*******************************************************************************************************************************
---SP_LogRegrMultiDataSet
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrMultiDataSet *****';

ALTER TABLE tblLogRegrMulti RENAME num_val To value;
\o foo.out
CALL SP_LogRegrMultiDataSet('tblLogRegrMulti', 25, 0.10,'Test Notes');
\o
\! cat foo.out

\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM fzzlLogRegrCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 3, 1, 2
LIMIT 20;
SELECT a.*
FROM fzzlLogRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 1, 2, 3
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_LogRegrSF
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrSF *****';
\o foo.out
EXEC SP_LogRegrSF('tblLogRegrData', 0.1,25,'SPEC TEST 1','Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM fzzlLogRegrCoeffsSF a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2
LIMIT 20;
SELECT a.*
FROM fzzlLogRegrStatsSF a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2
LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_LogRegrSW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrSW *****';
CREATE OR REPLACE VIEW vw_LogRegrSWDemo
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
\o foo.out
EXEC SP_LogRegrSW('vw_LogRegrSWDemo',0.1,25,'SPEC TEST 1',3,0.1,'Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.* 
FROM fzzlLogRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 1,2,3
LIMIT 20;
SELECT a.* 
FROM fzzlLogRegrStats a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new







-----*******************************************************************************************************************************
---SP_LogRegrSWEff
-----*******************************************************************************************************************************
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

\o foo.out
CALL SP_LogRegrSWEff('vw_LogRegrSWDemo', 0.10, 25,3,0.1,'Test');
\o
\! cat foo.out
DROP VIEW vw_LogRegrSWDemo;
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT a.*
FROM fzzlLogRegrCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
ORDER BY 1,2,3
LIMIT 20;
SELECT a.*
FROM fzzlLogRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
AND ModelID <= 2 
LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new




-----*******************************************************************************************************************************
---SP_LogRegrWt
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_LogRegrWt *****';
ALTER TABLE tblLogRegr RENAME num_val TO value;
\o foo.out
CALL SP_LogRegrWt('tblLogRegr',  0.10, 25, 0.8, 1, 'Test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.*
FROM fzzlLogRegrCoeffs a
WHERE a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 1
LIMIT 20;
SELECT a.*
FROM fzzlLogRegrStats a
WHERE a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new




-----*******************************************************************************************************************************
---FLCalcProb
-----*******************************************************************************************************************************
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
LIMIT 20;




-----*******************************************************************************************************************************
---FLNSBeta
-----*******************************************************************************************************************************
--CASE 1: ; l=1

DROP TABLE tblNelsonSiegel1;

CREATE TABLE tblNelsonSiegel1 
AS
(SELECT RANK() OVER (ORDER BY a.TxnDate) as groupid,

b.TenorInYear,
a.CurveValue/100.0 AS Yield
FROM finYieldCurveHist a,
finTenor b
WHERE b.TenorID = a.TenorID
AND a.CurveID = 1);

ALTER TABLE tblNelsonSiegel1 RENAME groupid to seriesID;
ALTER TABLE tblNelsonSiegel1 RENAME tenorinyear to xval;
ALTER TABLE tblNelsonSiegel1 RENAME yield to yval;



			
SELECT '***** EXECUTING FLNSBeta *****';
SELECT a.SeriesID,
        FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
        FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
        FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
        1 AS Lambda
FROM tblNelsonSiegel1 a
GROUP BY a.SeriesID
ORDER BY 1
LIMIT 20;

--CASE 2: l=1.5
SELECT '***** EXECUTING FLNSBeta *****';
SELECT a.SeriesID,
FLNSBeta('BETA0', a.XVal, a.YVal, 1.5) AS Beta0,
FLNSBeta('BETA1', a.XVal, a.Yval, 1.5) AS Beta1,
FLNSBeta('BETA2', a.XVal, a.YVal, 1.5) AS Beta2,
       1.5 AS Lambda
FROM tblNelsonSiegel a
GROUP BY a.SeriesID
ORDER BY 1
LIMIT 20;



-----*******************************************************************************************************************************
---FLNSPredict
-----*******************************************************************************************************************************
SELECT q.SeriesID,
q.Yval,
FLNSPredict(p.Beta0, p.Beta1, p.Beta2,
p.Lambda, q.XVal)
FROM(
SELECT a.seriesID,
FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
1 AS Lambda
FROM tblNelsonSiegel1 a
GROUP BY a.SeriesID
) AS p,
tblNelsonSiegel1 q
WHERE q.SeriesID = p.SeriesID
ORDER BY 1;




-----*******************************************************************************************************************************
---FLNeuralNetUdt
-----*******************************************************************************************************************************
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
LIMIT 20;




-----*******************************************************************************************************************************
---SP_NeuralNetScore
-----*******************************************************************************************************************************
DROP TABLE tblWineTest;

CREATE TABLE tblWineTest
AS  ( 
    SELECT  a.*
    FROM    tblWineDeep a
    WHERE   a.ObsID > 90
    )
DISTRIBUTE ON (ObsID);

DROP TABLE tblWineScore;
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




-----*******************************************************************************************************************************
---SP_PoissonRegr
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_PoissonRegr *****';
\o foo.out
CALL SP_PoissonRegr('tblPoissonDeep', 25, 'Test Notes');
\o
\! cat foo.out

\! grep [0-9]$ foo.out | cut -d ':' -f 2 > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT a.* 
FROM fzzlPoissonRegrCoeffs a 
WHERE  a.AnalysisID = (SELECT * FROM analysis)
ORDER BY 2
LIMIT 20;
SELECT a.* 
FROM fzzlPoissonRegrStats a 
WHERE a.AnalysisID = (SELECT * FROM analysis)
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_SurveySelectStratExact
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_SurveySelectStratExact *****';
DROP TABLE tblSample;
\o foo.out
EXEC SP_SurveySelectStratExact('tblPopulation',
                                'ObsID',
                                'StratumID',
                                'tblSample',
                                'tblStratumSize',
                                2,
                                '100 samples perc') ;
								\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT *
FROM fzzlSurveySelectInfo
WHERE Analysisid = (SELECT * FROM analysis)
LIMIT 20;
SELECT *
FROM tblSample
ORDER BY 1, 2, 3
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---SP_SurveySelectStratPerc
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_SurveySelectStratPerc *****';
DROP TABLE tblSample;
\o foo.out
EXEC SP_SurveySelectStratPerc('tblPopulation',
                            'ObsID',
                            'StratumID',
                            'tblSample',
                            'tblStratumSize',
                            2,
                            '2 samples perc');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';							

SELECT *
FROM fzzlSurveySelectInfo
WHERE Analysisid = (SELECT * FROM analysis)
LIMIT 20;
SELECT *
FROM tblSample
ORDER BY 1, 2, 3
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new



-----*******************************************************************************************************************************
---FLSVMGaussianUdt
-----*******************************************************************************************************************************
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
                       ORDER BY 1, 2, 3
					   LIMIT 20;





-----*******************************************************************************************************************************
---FLSVMLinearUdt
-----*******************************************************************************************************************************
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





-----*******************************************************************************************************************************
---FLSVMPolynomialUdt
-----*******************************************************************************************************************************
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
						 LIMIT 20;






-----*******************************************************************************************************************************
---SP_VIF
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_VIF *****';
\o foo.out
CALL SP_VIF('tblLinRegr', 'New Test 1');
CALL SP_LinRegrMultiDataSet('vw_LinRegrMulti', 'Test LinRegrMultiData');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT * 
FROM  fzzlVIFstats 
 WHERE AnalysisID = (SELECT * FROM analysis) 
 ORDER BY VarID
LIMIT 20;

DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_VIFBW
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_VIFBW *****';
CREATE OR REPLACE VIEW V_TBLLINREGR_V20_withGrpID
AS
SELECT 1 AS DATASETID,
       a.* 
FROM tblLinRegr a
WHERE a.VARID <= 20;
\o foo.out
CALL SP_VIFBW('V_TBLLINREGR_V20_withGrpID',5,'MMEHTA TEST');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';

SELECT  a.*
FROM fzzlVIFBWStats a
WHERE a.AnalysisID =(SELECT * FROM analysis)
ORDER BY 1, 2, 4, 3
LIMIT 20;


DROP TABLE analysis;
\!rm -f foo.out new


-----*******************************************************************************************************************************
---SP_VIFMultiDataSet
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_VIFMultiDataSet *****';
\o foo.out
CALL SP_VIFMultiDataSet('tbllogregrmulti','Manual test');
\o
\! cat foo.out


\! grep [0-9]$ foo.out | awk '{print $NF}' > new
CREATE TABLE analysis(col1 varchar(50));
INSERT INTO analysis select * from external '/export/home/nz/new';
SELECT *
FROM fzzlVIFStats
WHERE AnalysisID = (SELECT * FROM analysis)
ORDER BY 1, 2, 3
LIMIT 20;
DROP TABLE analysis;
\!rm -f foo.out new

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



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off