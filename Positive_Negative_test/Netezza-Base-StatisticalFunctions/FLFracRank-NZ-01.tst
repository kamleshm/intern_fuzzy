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
--	Last Updated:			05-03-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

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


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Bad input in partition
SELECT p.Rank,
FLFracRank(p.Rank, COUNT(*)) AS FracRank
FROM
(
SELECT a.GroupID,
a.ObsID,
RANK() OVER (PARTITION BY 1 ORDER BY a.NUM ASC)
FROM tblHypoTest a
) AS p
GROUP BY p.Rank


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
