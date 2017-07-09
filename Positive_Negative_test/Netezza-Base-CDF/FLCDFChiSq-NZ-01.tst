
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
-- 	Test Category:		Cumulative Distribution Function
--
--	Test Unit Number:	FLCDFChiSq-Neezza-01
--
--	Name(s):		FLCDFChiSq
--
-- 	Description:		Scalar function which returns the Chi Square cumulative distribution
--
--	Applications:		 
--
-- 	Signature:		FLCDFChiSq(DF, y)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		11-10-2014
--
--	Author:			Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Case 1a
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( 3.0, 1.0) AS FLCDFChiSq;

--  Case 1b
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( 3.0, 1e300) AS FLCDFChiSq;

-- Expected failure due to Netezza system limitation above 1e308
--  Case 1c
SELECT 	1e300 AS CValue, 
	FLCDFChi( 3.0, 1e310) AS FLCDFChi;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: DF < 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( -2.0, 0.0) AS FLCDFChiSq;

-- Case 1b: DF == 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( 0.0, 0.0) AS FLCDFChiSq;

-- This is acceptable for CDF called from other functions
-- Case 1c: DF > 100.0
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( 101.0, 0.0) AS FLCDFChiSq;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b:
-- Not Applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFChiSq(0.0) AS FLCDFChiSq;

-- Case 4b: More than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFChiSq( 3.0, 2.0, 0.0) AS FLCDFChiSq;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
