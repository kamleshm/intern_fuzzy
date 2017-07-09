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