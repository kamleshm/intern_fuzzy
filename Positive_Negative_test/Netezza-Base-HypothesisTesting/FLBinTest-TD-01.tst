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
--	Test Unit Number:	FLBinTest-TD-01
--
--	Name(s):		FLBinTest
--
-- 	Description:	    	FLBinTest performs the Binomial Test. Let's assume that in a single 
--				trial, the probability of an event is known.  In Binomial Test, we 
--				evaluate the probability of the occurrence of a certain number of events 
--				upon conducting the trial multiple times. 
--
--	Applications:	    	
--
-- 	Signature:		FLBinTest(NumOfTrials BIGINT, NumOfEvents BIGINT,
--				ProbOfEvent DOUBLE PRECISION, TypeOfProb VARCHAR(10))
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

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale values

-- Case 1a:
-- P: Query example in user manual
SELECT  FLBinTest(28, 18, 0.65, 'EXACT') As Prob_EXACT,
        FLBinTest(28, 18, 0.65, 'LE') As Prob_LE,
        FLBinTest(28, 18, 0.65, 'LT') As Prob_LT,
        FLBinTest(28, 18, 0.65, 'GE') As Prob_GE,
        FLBinTest(28, 18, 0.65, 'GT') As Prob_GT,
        FLBinTest(28, 18, 0.65, 'TWO_SIDED') As Prob_TWO_SIDED;
-- Result: standard outputs


-- Case 2a:
-- P: ProbOfEvent = negative number
SELECT  FLBinTest(28, 18, -0.65, 'EXACT') As Prob_EXACT,
        FLBinTest(28, 18, -0.65, 'LE') As Prob_LE,
        FLBinTest(28, 18, -0.65, 'LT') As Prob_LT,
        FLBinTest(28, 18, -0.65, 'GE') As Prob_GE,
        FLBinTest(28, 18, -0.65, 'GT') As Prob_GT,
        FLBinTest(28, 18, -0.65, 'TWO_SIDED') As Prob_TWO_SIDED;
-- Fuzzy Logix specific error message


-- Case 3a:
-- P: Check total probability
SELECT  SUM(CASE WHEN FLRound(a.Sum1,10) <> 1.0000000000 THEN 1 ELSE 0 END) AS Check1,
        SUM(CASE WHEN FLRound(a.Sum2,10) <> 1.0000000000 THEN 1 ELSE 0 END) AS Check2,
        SUM(CASE WHEN FLRound(a.Sum3,10) <> 1.0000000000 THEN 1 ELSE 0 END) AS Check3
FROM    (
        SELECT  a.SerialVal,
                FLBinTest(28, 18, a.RandVal, 'EXACT') As Prob_EXACT,
                FLBinTest(28, 18, a.RandVal, 'LE') As Prob_LE,
                FLBinTest(28, 18, a.RandVal, 'LT') As Prob_LT,
                FLBinTest(28, 18, a.RandVal, 'GE') As Prob_GE,
                FLBinTest(28, 18, a.RandVal, 'GT') As Prob_GT,
                FLBinTest(28, 18, a.RandVal, 'TWO_SIDED') As Prob_TWO_SIDED,
                Prob_LE + Prob_GT AS Sum1,
                Prob_LT + Prob_GE AS Sum2,
                Prob_LE + Prob_GE - Prob_EXACT AS Sum3
        FROM    fzzlSerial a
        WHERE   a.SerialVal <= 1e6
        AND     a.RandVal > 0 AND a.RandVal < 1
        ) a;
-- Result: zero, zero, zero (good)

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Case 1a:
-- N: Use ProbOfEvent = 0
SELECT  FLBinTest(28, 18, 0, 'EXACT') As Prob_EXACT,
        FLBinTest(28, 18, 0, 'LE') As Prob_LE,
        FLBinTest(28, 18, 0, 'LT') As Prob_LT,
        FLBinTest(28, 18, 0, 'GE') As Prob_GE,
        FLBinTest(28, 18, 0, 'GT') As Prob_GT,
        FLBinTest(28, 18, 0, 'TWO_SIDED') As Prob_TWO_SIDED;
-- Result: floating point exception: divide by zero

-- Case 2a:
-- N: Use ProbOfEvent = 1
SELECT  FLBinTest(28, 18, 1, 'EXACT') As Prob_EXACT,
        FLBinTest(28, 18, 1, 'LE') As Prob_LE,
        FLBinTest(28, 18, 1, 'LT') As Prob_LT,
        FLBinTest(28, 18, 1, 'GE') As Prob_GE,
        FLBinTest(28, 18, 1, 'GT') As Prob_GT,
        FLBinTest(28, 18, 1, 'TWO_SIDED') As Prob_TWO_SIDED;
-- Result: floating point exception: divide by zero

-- Case 3a:
-- N: Use non-sensical TypeOfProb
SELECT  FLBinTest(28, 18, 0.65, 'Dummy') As Prob_EXACT,
        FLBinTest(28, 18, 0.65, 'LE') As Prob_LE,
        FLBinTest(28, 18, 0.65, 'LT') As Prob_LT,
        FLBinTest(28, 18, 0.65, 'GE') As Prob_GE,
        FLBinTest(28, 18, 0.65, 'GT') As Prob_GT,
        FLBinTest(28, 18, 0.65, 'TWO_SIDED') As Prob_TWO_SIDED;
-- Result: Fuzzy Logix specific error message

-- Case 4a:
-- N: Use large NumOfTrials and NumOfEvents
SELECT  FLBinTest(28000, 18000, 0.65, 'EXACT') As Prob_EXACT,
        FLBinTest(28000, 18000, 0.65, 'LE') As Prob_LE,
        FLBinTest(28000, 18000, 0.65, 'LT') As Prob_LT,
        FLBinTest(28000, 18000, 0.65, 'GE') As Prob_GE,
        FLBinTest(28000, 18000, 0.65, 'GT') As Prob_GT,
        FLBinTest(28000, 18000, 0.65, 'TWO_SIDED') As Prob_TWO_SIDED,
        Prob_LE + Prob_GT AS Sum1,
        Prob_LT + Prob_GE AS Sum2,
        Prob_LE + Prob_GE - Prob_EXACT AS Sum3;
-- Result: standard outputs

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
