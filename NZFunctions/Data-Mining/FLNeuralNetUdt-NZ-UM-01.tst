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
--timing on

-- BEGIN: TEST(s)

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






-- END: TEST(s)

-- END: TEST SCRIPT
--timing off