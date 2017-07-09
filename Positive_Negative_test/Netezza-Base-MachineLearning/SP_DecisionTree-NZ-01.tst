----------------------------------------------------------------------------------------

--Create View
CREATE OR REPLACE VIEW tblDecisionTreeMulti_VW
AS(
SELECT OBSID, VARID, NUM_VAL AS Value FROM tblDecisionTreeMulti);

-- Execute Stored Procedure
-- note: alter table column VAL to VALUE in tblDTData.
SELECT '***** EXECUTING SP_DecisionTree *****';
EXEC SP_DecisionTree('tblDecisionTreeMulti_VW',
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


					 
----------------------------------------------------------------------------------------
DROP TABLE tblDecisionTreeMulti_VW_Score;
EXEC SP_DecisionTreeScore('tblDecisionTreeMulti_VW','SSHARMA_558233','tblDecisionTreeMulti_VW_Score','score test');