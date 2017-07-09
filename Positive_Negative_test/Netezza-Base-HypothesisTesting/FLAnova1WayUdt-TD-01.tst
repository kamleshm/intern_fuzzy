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
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLAnova1WayUdt-TD-01
--
--	Name(s):		FLAnova1WayUdt
--
-- 	Description:	    	FLAnova1WayUdt performs One-way Analysis of Variance. One-way Analysis 
--				of Variance (ANOVA) is used to test the difference between two or 
--				more groups based on a single attribute.
--	Applications:	    	
--
-- 	Signature:		FLAnova1WayUdt (m_id BIGINT, cat VARCHAR(100), num_val DOUBLE PRECISION)
--	
--	Parameters:		See Documentation
--
--	Return value:	    	Table
--
--	Last Updated:	    	02-27-2014
--
--	Author:			<Joe.Fan@fuzzyl.com>
--				Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
.run file=../PulsarLogOn.sql

-- BEGIN: NEGATIVE TEST(s)

-- Case 1: Replace values of all categories with a constant
WITH tw (GroupID, City, SalesPerVisit) AS
(
SELECT  serialval AS GroupID,
        City,
        1
FROM    tblCustData t, fzzlserial s
WHERE City <> 'Boston'
AND serialval <= 1
)
SELECT  d.*
FROM    (SELECT tw.GroupID,tw.City,tw.SalesPerVisit,
		NVL(LAG(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS begin_flag,
		NVL(LEAD(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS end_flag
        FROM tw) as z,
		TABLE(FLANOVA1WAYUdt(z.GroupID,z.City,z.SalesPerVisit,z.begin_flag,z.end_flag)) AS d
ORDER BY 1;
-- Result: standard outputs


-- Case 2: Replace values of different categories with different constants
WITH tw (GroupID, City, SalesPerVisit) AS 
(
SELECT  serialval AS GroupID,
        City,
        CASE WHEN City <> 'Chicago' THEN 1 ELSE 0 END
FROM    tblCustData t, fzzlserial s
WHERE City <> 'Boston'
AND serialval <= 1
)
SELECT  d.*
FROM    (SELECT tw.GroupID,tw.City,tw.SalesPerVisit,
		NVL(LAG(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS begin_flag,
		NVL(LEAD(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS end_flag
        FROM tw) as z,
		TABLE(FLANOVA1WAYUdt(z.GroupID,z.City,z.SalesPerVisit,z.begin_flag,z.end_flag)) AS d
ORDER BY 1;

-- Result: standard outputs

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

-- P: Query example in user manual
WITH tw (GroupID, City, SalesPerVisit) AS 
(
SELECT  serialval AS GroupID,
        City,
        SalesPerVisit
FROM    tblCustData t, fzzlserial s
WHERE City <> 'Boston'
AND serialval <= 1
)
SELECT  d.*
FROM    (SELECT tw.GroupID,tw.City,tw.SalesPerVisit,
		NVL(LAG(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS begin_flag,
		NVL(LEAD(0) OVER (PARTITION BY tw.GroupID ORDER BY tw.City), 1) AS end_flag
        FROM tw) as z,
		TABLE(FLANOVA1WAYUdt(z.GroupID,z.City,z.SalesPerVisit,z.begin_flag,z.end_flag)) AS d
ORDER BY 1;

-- END: POSITIVE TEST(s)

\time
-- 	END: TEST SCRIPT

