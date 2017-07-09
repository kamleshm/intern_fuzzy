----------------------------------------------------------
SELECT '***** EXECUTING SP_NaiveBayesModel *****';

CREATE TEMP TABLE tblNBModelDemo AS
SELECT ObsID, VarID, Num_Val as Value
FROM tblNBData
WHERE VarID <= 20;

EXEC SP_NaiveBayesModel('tblNBModelDemo', 1,'Training NB Model with Laplacian Correction');

SELECT * 
FROM fzzlNaiveBayesModel 
WHERE AnalysisID = 'SSHARMA_205908' 
ORDER BY 1,2,3,4
LIMIT 10;

----------------------
DROP TABLE tblNBDataTestPredict;

EXEC SP_NaiveBayesPredict('tblNBModelDemo', 'SSHARMA_205908', 'Testing using NB Model ID SSHARMA_205908');

SELECT * 
FROM fzzlNaiveBayesPredict
WHERE AnalysisID = 'SSHARMA_555145' 
ORDER BY 1,2
LIMIT 10;