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
--	Test Unit Number:	FLFCritical-TD-01
--
--	Name(s):		FLFCritical
--
-- 	Description:	    	Function that evaluates the critical value for F-Statistic at given 
--				significant level and degrees of freedom.
--	Applications:	    
--
-- 	Signature:		FLFCritical(InVal DOUBLE PRECISION, Df1 BIGINT, Df2 BIGINT)
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
SELECT FLFCritical(0.1, 0, 10);
-- Result: Fuzzy Logix specific error message

-- Case 1b:
SELECT FLFCritical(0.1, -1, 10);
-- Result: Fuzzy Logix specific error message

-- Case 1c:
SELECT FLFCritical(0.1, 10, 0);
-- Result: Fuzzy Logix specific error message

-- Case 1d:
SELECT FLFCritical(0.1, 10, -1);
-- Result: Fuzzy Logix specific error message

-- Case 2a:
---- Validate the first argument
SELECT FLFCritical(-0.1, 5, 10);
-- Result: Fuzzy Logix specific error message

-- Case 2b:
SELECT FLFCritical(1.1, 5, 10);
-- Result: Fuzzy Logix specific error message

-- Case 3a:
---- Boundary condition
SELECT FLFCritical(0, 5, 10);
-- Result: Fuzzy Logix specific error message

-- Case 3b:
SELECT FLFCritical(0.9999999999, 5, 10);
-- Result: does not match R
--      R: qf(1-0.9999999999, 5, 10)

-- Case 4a:
---- Test with very large values
SELECT FLFCritical(0.5, 500, 100);
-- Result: standard outputs (matches R)
--      R: qf(1-0.5, 500, 100)

-- Case 4b:
SELECT FLFCritical(0.5, 5000, 1000);
-- Result: standard outputs (matches R)
--      R: qf(1-0.5, 5000, 1000)

-- Case 4c:
SELECT FLFCritical(0.5, 50000, 10000);
-- Result: standard outputs (matches R)
--      R: qf(1-0.5, 50000, 10000)

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

---- Compare the values with R

SELECT a.SerialVal,
       FLFCritical(a.SerialVal * 0.01, 10, 20)
FROM   fzzlSerial a
WHERE  a.SerialVal <= 10
ORDER BY 1;
-- Results: standard outputs (minor differences R in the 6th decimal place)
--       R: qf(1-c(1,2,3,4,5,6,7,8,9,10)/100, 10, 20)

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
