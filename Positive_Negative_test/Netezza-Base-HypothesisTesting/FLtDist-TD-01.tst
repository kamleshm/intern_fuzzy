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
--	Test Unit Number:	FLtDist-TD-01
--
--	Name(s):		FLtDist
--
-- 	Description:	    	Function that evaluates the T-Statistic. Return P-Value of a 
--				T-Statistic given degree of freedom.
--
--	Applications:	    
--
-- 	Signature:		FLTDist(InVal DOUBLE PRECISION, Df BIGINT, NumTails BIGINT)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	01-31-2014
--
--	Author:			<Joe.Fan@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

-- BEGIN: NEGATIVE TEST(s)
---- Validate the parameters

---- Case 1a: Validate degrees of freedom
SELECT FLtDist(10, 0, 1);
-- Result: Fuzzy Logix specific error message

SELECT FLtDist(10, -1, 1);
-- Result: Fuzzy Logix specific error message

---- Case 1b: Validate tails
SELECT FLtDist(10, 5, 0);
-- Result: Fuzzy Logix specific error message

SELECT FLtDist(10, 5, -1);
-- Result: Fuzzy Logix specific error message

SELECT FLtDist(10, 5, 3);
-- Result: Fuzzy Logix specific error message

---- Case 1c: Validate that the first argument is positive
SELECT FLtDist(0, 5, 1);
-- Result: returns 0.5

SELECT FLtDist(-1, 5, 1);
-- Result: Fuzzy Logix specific error message

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

---- Compare the values with R

-- Case 1a:
SELECT a.SerialVal,
       FLtDist(a.SerialVal, 3, 1)
FROM   fzzlSerial a
WHERE  a.SerialVal <= 10
ORDER BY 1;
-- Result: standard output (matches R to 9 decimal places)
--      R: 1-pt(c(1,2,3,4,5,6,7,8,9,10),3)

---- Case 1b: Test with very large values
SELECT FLtDist(1, 500, 1);
-- Result: standard output (matches R)
--      R: 1-pt(1,500)

SELECT FLtDist(1, 5000, 1);
-- Result: standard output (matches R)
--      R: 1-pt(1,5000)

SELECT FLtDist(1, 50000, 1);
-- Result: standard output (matches R)
--      R: 1-pt(1,50000)

SELECT FLtDist(100, 5, 1);
-- Result: standard output (matches R)
--      R: 1-pt(100,5)

SELECT FLtDist(1000, 5, 1);
-- Result: off by a little bit (9.43689570931383E-015 vs 9.547918e-15 in R)
--      R: 1-pt(1000,5)

SELECT FLtDist(10000, 5, 1);
-- Result: standard output (matches R)
--      R: 1-pt(10000,5)

--Case 2 a
--increase the DF to > 10000 to see if function fails
SELECT FLtDist(4, 100000, 1)  AS FLtDist;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
