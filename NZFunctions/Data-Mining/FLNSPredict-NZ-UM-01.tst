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
\timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---FLNSPredict
-----*******************************************************************************************************************************

DROP TABLE tblNelsonSiegel1;

CREATE TABLE tblNelsonSiegel1 
AS
(SELECT RANK() OVER (ORDER BY a.TxnDate) as groupid,

b.TenorInYear,
a.CurveValue/100.0 AS Yield
FROM finYieldCurveHist a,
finTenor b
WHERE b.TenorID = a.TenorID
AND a.CurveID = 1);

ALTER TABLE tblNelsonSiegel1 RENAME groupid to seriesID;
ALTER TABLE tblNelsonSiegel1 RENAME tenorinyear to xval;
ALTER TABLE tblNelsonSiegel1 RENAME yield to yval;


SELECT q.SeriesID,
q.Yval,
FLNSPredict(p.Beta0, p.Beta1, p.Beta2,
p.Lambda, q.XVal)
FROM(
SELECT a.seriesID,
FLNSBeta('BETA0', a.XVal, a.YVal, 1) AS Beta0,
FLNSBeta('BETA1', a.XVal, a.Yval, 1) AS Beta1,
FLNSBeta('BETA2', a.XVal, a.YVal, 1) AS Beta2,
1 AS Lambda
FROM tblNelsonSiegel1 a
GROUP BY a.SeriesID
) AS p,
tblNelsonSiegel1 q
WHERE q.SeriesID = p.SeriesID
ORDER BY 1;







-- END: TEST(s)

-- END: TEST SCRIPT
\timing off