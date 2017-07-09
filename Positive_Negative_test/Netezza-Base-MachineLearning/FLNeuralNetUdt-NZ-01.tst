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

CREATE TEMP TABLE tblWineTrain
AS  ( 
    SELECT  a.*
    FROM    tblWineDeep a
    WHERE   a.ObsID <= 90
    )
DISTRIBUTE ON (ObsID);


SELECT '***** EXECUTING FLNeuralNetUdt *****';
CREATE TEMP TABLE tblWineModel AS (
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
CREATE TEMP TABLE tblWineTest
AS  ( 
    SELECT  a.*
    FROM    tblWineDeep a
    WHERE   a.ObsID > 90
    )
DISTRIBUTE ON (ObsID);

SELECT '***** EXECUTING SP_NeuralNetScore *****';
EXEC SP_NeuralNetScore('tblWineModel',  -- model table from previous step
          		       'tblWineTest',   -- table to be scored
                       	NULL,    	    -- group id column name
                       'ObsID',         -- observation id column name
                       'VarID',         -- variable id column name
                       'Value',         -- value column name
                       'tblWineScore'   -- Output score table
     			); 

SELECT * 
FROM tblWineScore 
ORDER BY 1,2;