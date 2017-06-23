-----*******************************************************************************************************************************
---SP_KaplanMeier
-----*******************************************************************************************************************************
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
EXEC SP_KaplanMeier('vwWHAS100',0.05,'helloworld');
SELECT *
FROM fzzlKaplanMeierInfo
WHERE Analysisid = (SELECT analysisid FROM fzzlkaplanmeierinfo WHERE NOTE='helloworld');
SELECT *
FROM fzzlKaplanMeier
WHERE Analysisid = (SELECT analysisid FROM fzzlkaplanmeierinfo WHERE NOTE='helloworld')
LIMIT 20;



-----*******************************************************************************************************************************
---SP_KaplanMeierHypoTest
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_KaplanMeierHypoTest *****';
EXEC SP_KaplanMeierHypoTest('vwWHAS100', 1, 2, 'helloworld'); 
SELECT * 
FROM fzzlKaplanMeierInfo 
WHERE AnalysisID = (SELECT analysisid FROM fzzlkaplanmeierinfo WHERE NOTE='helloworld');
SELECT * 
FROM fzzlKaplanMeierHypoTest 
WHERE AnalysisID = (SELECT analysisid FROM fzzlkaplanmeierinfo WHERE NOTE='helloworld')
ORDER BY 3
LIMIT 20;
