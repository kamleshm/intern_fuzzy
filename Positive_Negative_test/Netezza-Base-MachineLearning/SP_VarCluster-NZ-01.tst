---------------------------------------------------------------------------
SELECT '***** EXECUTING SP_RegrDataPrep *****';

EXEC SP_VarCluster('tblLogRegr','COVAR', 0.75, 'VarClustOutTable');

select * 
from SSHARMA_162058_PCATMP
order by 1,2
limit 10;

select *
from SSHARMA_162058_Scores
order by 1,2
limit 10;