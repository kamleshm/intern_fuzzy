----------------------------------------------------------------------------------------
CREATE TEMP TABLE tblPoissonTest AS
select *, num_val as value from tblPoissonDeep;


SELECT '***** EXECUTING SP_PoissonRegr *****';
EXEC SP_PoissonRegr('tblPoissonTest', 25, 'Test Notes');

-- SELECT a.* 
-- FROM fzzlPoissonRegrCoeffs a 
-- WHERE  a.AnalysisID = 'SSHARMA_762725' 
-- ORDER BY 2;

-- SELECT a.* 
-- FROM fzzlPoissonRegrStats a 
-- WHERE a.AnalysisID = 'SSHARMA_762725';

