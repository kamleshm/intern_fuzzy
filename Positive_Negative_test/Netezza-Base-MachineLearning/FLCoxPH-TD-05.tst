.run file=../PulsarLogOn.sql

CALL FLCoxPH('tblCoxPHdeep','ObsID', 'VarID', 'Num_Val', 15, NULL,AnalysisID);
