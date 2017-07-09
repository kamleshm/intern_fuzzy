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
--	Test Unit Number:	FLFDist-TD-01
--
--	Name(s):		FLFDist
--
-- 	Description:	    	FLFDist returns P-Value of F-statistic given degrees of freedom. 
--				In other words, this function calculates the probability of 
--				obtaining the F-Statistic given the degrees of freedom.
--	Applications:	    
--
-- 	Signature:		FLFDist(FStat DOUBLE PRECISION, Df1 BIGINT, Df2 BIGINT)
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

-- Case 1a:
---- Validate degrees of freedom
SELECT FLFDist(10, 0, 10);
-- Result: Fuzzy Logix specific error message

-- Case 1b:
SELECT FLFDist(10, -1, 10);
-- Result: Fuzzy Logix specific error message

-- Case 1c:
SELECT FLFDist(10, 10, 0);
-- Result: Fuzzy Logix specific error message

-- Case 1d:
SELECT FLFDist(10, 10, -1);
-- Result: Fuzzy Logix specific error message

-- Case 2a:
---- Validate that the first argument is positive
SELECT FLFDist(-1, 5, 10);
-- Result: Fuzzy Logix specific error message

-- Case 3a:
---- Boundary condition
SELECT FLFDist(0, 5, 10);
-- Result: standard outputs (matches R)
--      R: pf(0,5,10, lower.tail=F)

-- Case 4a:
---- Test with very large values
SELECT FLFDist(1, 500, 100);
-- Result: standard outputs (matches R)
--      R: pf(1,500,100, lower.tail=F)

-- Case 4b:
SELECT FLFDist(1, 5000, 1000);
-- Result: standard outputs (matches R)
--      R: pf(1,5000,1000, lower.tail=F)

-- Case 4c:
SELECT FLFDist(1, 50000, 10000);
-- Result: standard outputs (matches R)
--      R: pf(1,50000,10000, lower.tail=F)

-- Case 4d:
SELECT FLFDist(100, 5, 1);
-- Result: standard outputs (matches R)
--      R: pf(100,5,1, lower.tail=F)

-- Case 4e:
SELECT FLFDist(1000, 5, 1);
-- Result: standard outputs (matches R)
--      R: pf(1000,5,1, lower.tail=F)

-- Case 4f:
SELECT FLFDist(10000, 5, 1);
-- Result: standard outputs (matches R)
--      R: pf(10000,5,1, lower.tail=F)

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

---- Compare the values with R

SELECT a.SerialVal,
       FLFDist(a.SerialVal, 10, 20)
FROM   fzzlSerial a
WHERE  a.SerialVal <= 10
ORDER BY 1;
-- Result: standard outputs (matches R)
--      R: pf(c(1,2,3,4,5,6,7,8,9,10),10,20, lower.tail=F)

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
