----------------------------------------------------------------------------------------
DROP TABLE tblDeep;

SELECT '***** EXECUTING SP_RegrDataPrep *****';
EXEC SP_RegrDataPrep(NULL,         
		'tblAutoMpg',   
		'ObsID',	    
		'MPG',          
		'tblDeep',  	
		true,       	
		false,      	
		false,      	
		false,      	
		0.0001,     	
		0.98,       	
		0,          	
		'CarNum',    	
		'CarNum');     


SELECT a.* 
FROM   fzzlRegrDataPrepMap a
WHERE  a.AnalysisID = 'SSHARMA_224315'
ORDER BY a.Final_VarID
LIMIT 20;

SELECT *
FROM tblDeep
ORDER BY 1, 2
LIMIT 20;