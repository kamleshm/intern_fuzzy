-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
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
-- 	Test Category:		Time Series Functions
--
--	Test Unit Number:	FLGARCHpqUdt-NZ-01
--
--	Name(s):		    FLGARCHpqUdt
--
-- 	Description:		Calculates the coefficients of the generalized autoregressive conditional heteroskedasticity (GARCH) model.
--
--	Applications:		 
--
-- 	Signature:		FLGARCHpqUdt (pGroupID   INTEGER,
--                                pQ         INTEGER,
--                                pp         INTEGER,
--                                pValueType VARCHAR(1),
--                                pValue     DOUBLE PRECISION)
--
--	Parameters:		See Documentation
--
--	Return value:	Table
--
--	Last Updated:	08-02-2016
--
--	Author:			<Ankit.Mahato@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT
---- Table used for GARCHpqUdt

DROP TABLE tblGARCHTest;

CREATE TABLE tblGARCHTest(
GroupID    BIGINT,
ObsID      BIGINT,
NumVal     DOUBLE PRECISION,
P          INTEGER,
Q          INTEGER)
DISTRIBUTE ON (GroupID);


---- BEGIN: NEGATIVE TEST(s)

--	Case 1 Invalid parameters
---- Case 1a  Arg#2 <= 0 

SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            0 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;

--	Case 1b Arg#3 < 0

SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            -1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;

----  Case 1c Arg#4 != 'R' or 'P' 
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            1 AS p,
            'S' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;


--	Case 2 Extreme parameters
----  Case 2a Arg#2 >= Num Of Observations
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            COUNT(id) OVER (PARTITION BY groupid) AS q,
            0 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;

---- Case 2b Arg#3 >= Num Of Observations
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            COUNT(id) OVER (PARTITION BY groupid) AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;

---- Case 2c Arg#2 + Arg#3 >= Num Of Observations
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            COUNT(id) OVER (PARTITION BY groupid)/2 + 1 AS q,
            COUNT(id) OVER (PARTITION BY groupid)/2 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a
ORDER BY 1;

-- Case 3 NULL check
---- Case 3a Mixed NULL Arg#5
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            CASE WHEN id % 2 = 0 THEN NULL ELSE a.stockreturn END AS stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

---- Case 3b NULL Arg#5
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            NULL AS stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

---- Case 3c NULL Arg#1
SELECT a.*
FROM(SELECT NULL AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

---- Case 3d NULL Arg#2
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            NULL AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

---- Case 3e NULL Arg#3
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            NULL AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

--	Case 4  Constant Arg#5
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            1.0 AS stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme values

-- Case 1 Query example in user manual
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockreturn,
            1 AS q,
            1 AS p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac_return a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockreturn,
                         z.begin_flag,
                         z.end_flag)) AS a;

-- Case 2 Different Arg#4
SELECT a.*
FROM(SELECT 1 AS GroupID,
            a.id,
            a.stockprice,
            1 AS q,
            1 AS p,
            'P' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, id), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, id), 1) AS end_flag
    FROM tblbac a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                         z.q,
                         z.p,
                         z.value_type,
                         z.stockprice,
                         z.begin_flag,
                         z.end_flag)) AS a;

--	Case 3 Empty table
TRUNCATE TABLE tblGARCHTest;
SELECT a.*
FROM(SELECT a.GroupID,
            a.obsid,
            a.numval,
            a.q,
            a.p,
            'R' AS value_type,
            NVL(LAG(0) OVER (PARTITION BY GroupID ORDER BY
                             GroupID, obsid), 1) AS begin_flag,
            NVL(LEAD(0) OVER (PARTITION BY GroupID ORDER BY
                              GroupID, obsid), 1) AS end_flag
    FROM tblGARCHTest a
    ) AS z,
TABLE (FLGARCHpqUdt(z.GroupID,
                     z.q,
                     z.p,
                     z.value_type,
                     z.numval,
                     z.begin_flag,
                     z.end_flag)) AS a;

---DROP the test table
DROP TABLE tblGARCHTest;

-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT



