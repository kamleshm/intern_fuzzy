----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_VIF *****';
EXEC SP_VIF('tblLinRegr', 'New Test 1');

-- SELECT * 
-- FROM  fzzlVIFstats 
-- WHERE AnalysisID = 'SSHARMA_884310' 
-- ORDER BY VarID;



----------------------------------------------------------------------------------------
SELECT '***** EXECUTING SP_VIFBW *****';
CREATE TEMP TABLE TBLLINREGR_V20_withGrpID
AS
SELECT 1 AS DATASETID,
       a.*
FROM tblLinRegr a
WHERE a.VARID <= 20;

EXEC SP_VIFBW('TBLLINREGR_V20_withGrpID', 5,'VIFBW_TEST');

-- SELECT  a.*
-- FROM fzzlVIFBWStats a
-- WHERE a.AnalysisID ='SSHARMA_197853'
-- ORDER BY 1, 2, 4, 3;


-- this is to be investigated. doesnt work yet. Not able to find MS system tables.
EXEC SP_VIFBWMS('TBLLINREGR_V20_withGrpID', 5,'VIFBWMS_TEST');

-- SELECT  a.*
-- FROM fzzlVIFBWStats a
-- WHERE a.AnalysisID ='SSHARMA_398849'
-- ORDER BY 1, 2, 4, 3;

----------------------------------------------------------------------------------------
CREATE TEMP TABLE VifMDSTest AS
select *, num_val as value from tbllogregrmulti;

SELECT '***** EXECUTING SP_VIFMultiDataSet *****';
EXEC SP_VIFMultiDataSet('VifMDSTest','Manual test');

-- SELECT *
-- FROM fzzlVIFStats
-- WHERE AnalysisID = 'SSHARMA_640614'
-- ORDER BY 1, 2, 3;

