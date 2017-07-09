--------------------------------------------------------------
SELECT '***** EXECUTING SP_WIDETODEEP *****';

EXEC SP_WideToDeep('tblAbaloneWide',
					 'ObsID',
					 'tblFieldMap',
					 'tblAbaloneWTD',
					 0);

-- select * from tblAbaloneWTD;


--------------------------------------------------------------
SELECT '***** EXECUTING SP_WIDETODEEPCH *****';

-- gives error, to be investigated. 
EXEC SP_WideToDeepCh('tblAbaloneWide',
					 'ObsID',
					 'tblFieldMap',
					 'tblAbaloneWTD',
					 0);
					 