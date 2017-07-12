-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FL-Netezza-01
--
--	Name(s):		    	FLFracRank
--
-- 	Description:			Scalar function that returns the fractional rank.
--	Applications:		 
--
-- 	Signature:		    	FLFracRank(A INTEGER,
--									B INTEGER)
--
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			07-11-2017
--
--	Author:			    	Diptesh Nath,Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good
SELECT p.Rank,
FLFracRank(p.Rank, COUNT(*)) AS FracRank
FROM
(
SELECT a.GroupID,
a.ObsID,
RANK() OVER (PARTITION BY 1 ORDER BY a.NUM_VAL ASC)
FROM tblHypoTest a
) AS p
GROUP BY p.Rank;

---- Positive Test 2: FrackRank should be the same as oRank since All Freq = 1
--- Return expected results, Good
SELECT  a.SerialVal AS oRank, 1 AS oFreq, FLFracRank(a.SerialVal, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: No data
--- No Output
SELECT  FLFracRank(a.SerialVal, a.SerialVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= -1;

---- Negative Test 2: Original rank with Invalid Freqs
--- Still return values, need to check if the input table is valid or not
SELECT  a.SerialVal AS oRank, a.SerialVal AS oFreq, FLFracRank(a.SerialVal, a.SerialVal)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 3: Condition Test (pRank >0): Zero and Negative Rank
--- Return expected error, Good
SELECT  FLFracRank(a.SerialVal - 1, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

SELECT  FLFracRank(a.SerialVal * -1, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 4: Condition Test (pFreq >0): Zero Freq
--- Return expected error, Good
SELECT  FLFracRank(a.SerialVal, 0)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 5: Condition Test (pFreq >0): Negative Freq
--- Return expected error, Good
SELECT  FLFracRank(a.SerialVal, -1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 6: Invalid Data Type(BIGINT): Non-Integer Rank
--- Return expected error, Good
SELECT  FLFracRank(a.RandVal, 1)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

---- Negative Test 7: Invalid Data Type(BIGINT): Non_Integer Freq
--- Return expected error, Good
SELECT  FLFracRank(a.SerialVal, 1.0)
FROM    fzzlSerial a
WHERE   a.SerialVal <= 10;

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT

---- Negative Test 8: Bad input in partition
SELECT p.Rank,
FLFracRank(p.Rank, COUNT(*)) AS FracRank
FROM
(
SELECT a.GroupID,
a.ObsID,
RANK() OVER (PARTITION BY 1 ORDER BY a.NUM ASC)
FROM tblHypoTest a
) AS p
GROUP BY p.Rank;



-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
