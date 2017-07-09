----------------------------------------------------------------------
SELECT '***** EXECUTING SP_DeepToWide *****';
EXEC SP_DeepToWide('tblAbaloneWTD', 
                   'tblFieldMap', 
                   'tblAbaloneWide',  
                   'tblAbaloneDTW');

SELECT	*
FROM	tblAbaloneDTW
ORDER BY 1
LIMIT 10;