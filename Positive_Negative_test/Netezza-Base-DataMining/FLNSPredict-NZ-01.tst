-- Pulsar Test for FLNSPredict and FLNSBeta --

DROP TABLE tblNelsonSiegel;
CREATE TABLE tblNelsonSiegel (
	 SeriesID INTEGER,
	 ObsID INTEGER,
	 XVal DOUBLE PRECISION,
	 YVal DOUBLE PRECISION
)
DISTRIBUTE ON (SeriesID, ObsID);

insert into tblNelsonSiegel values (1,1,0.05,0.0500);
insert into tblNelsonSiegel values (1,2,0.15,0.0125);
insert into tblNelsonSiegel values (1,3,0.25,0.0125);
insert into tblNelsonSiegel values (1,4,0.35,0.0150);
insert into tblNelsonSiegel values (1,5,0.45,0.0150);
insert into tblNelsonSiegel values (1,6,0.55,0.0200);
insert into tblNelsonSiegel values (1,7,0.65,0.0400);
insert into tblNelsonSiegel values (1,8,0.75,0.0600);
insert into tblNelsonSiegel values (1,9,0.85,0.0700);
insert into tblNelsonSiegel values (1,10,0.95,0.1000);
insert into tblNelsonSiegel values (2,1,0.05,0.0450);
insert into tblNelsonSiegel values (2,2,0.15,0.0145);
insert into tblNelsonSiegel values (2,3,0.25,0.0220);
insert into tblNelsonSiegel values (2,4,0.35,0.0300);
insert into tblNelsonSiegel values (2,5,0.45,0.0556);
insert into tblNelsonSiegel values (2,6,0.55,0.0665);
insert into tblNelsonSiegel values (2,7,0.65,0.0772);
insert into tblNelsonSiegel values (2,8,0.75,0.0800);
insert into tblNelsonSiegel values (2,9,0.85,0.0812);
insert into tblNelsonSiegel values (2,10,0.95,0.0845);
insert into tblNelsonSiegel values (3,1,0.05,0.0100);
insert into tblNelsonSiegel values (3,2,0.15,0.0125);
insert into tblNelsonSiegel values (3,3,0.25,0.0125);
insert into tblNelsonSiegel values (3,4,0.35,0.0150);
insert into tblNelsonSiegel values (3,5,0.45,0.0150);
insert into tblNelsonSiegel values (3,6,0.55,0.0200);
insert into tblNelsonSiegel values (3,7,0.65,0.0300);
insert into tblNelsonSiegel values (3,8,0.75,0.0600);
insert into tblNelsonSiegel values (3,9,0.85,0.0700);
insert into tblNelsonSiegel values (3,10,0.95,0.0500);

--- FLNSBeta tests ---
SELECT a.SeriesID,
	FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
	FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
	FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
	1 AS Lambda
FROM tblNelsonSiegel a
GROUP BY a.SeriesID
ORDER BY 1;

SELECT a.SeriesID,
FLNSBeta('BETA0', a.XVal, a.YVal, 1.5) AS Beta0,
FLNSBeta('BETA1', a.XVal, a.Yval, 1.5) AS Beta1,
FLNSBeta('BETA2', a.XVal, a.YVal, 1.5) AS Beta2,
1.5 AS Lambda
FROM tblNelsonSiegel a
GROUP BY a.SeriesID
ORDER BY 1;


--- FLNSPredict tests ---

SELECT q.SeriesID,
		q.ObsID,
		q.Yval,
		FLNSPredict(p.Beta0, p.Beta1, p.Beta2, p.Lambda, q.XVal)
FROM(
		SELECT a.seriesID,
			FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
			FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
			FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
			1 AS Lambda
		FROM tblNelsonSiegel a
		GROUP BY a.SeriesID
) AS p, tblNelsonSiegel q
WHERE q.SeriesID = p.SeriesID
ORDER BY 1, 2;

DROP TABLE tblNelsonSiegel;