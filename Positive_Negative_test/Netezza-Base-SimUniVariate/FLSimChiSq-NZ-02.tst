
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
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
-- 	Test Category:		Simulate Univariate
--
--	Test Unit Number:	FLSimChiSq-NZ-02
--
--	Name(s):		FLSimChiSq
--
-- 	Description:		Scalar function which returns the density of a Chi-squared distribution
--
--	Applications:		 
--
-- 	Signature:		FLSimChiSq(Q,DF)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		12-24-2014
--
--	Author:			<Zhi.Wang@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- JIRA TD-8

SELECT FLSimChiSq(1000,6.432);

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT