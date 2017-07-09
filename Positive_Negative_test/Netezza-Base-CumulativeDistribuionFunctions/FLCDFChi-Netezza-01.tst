
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
--	Test Unit Number:	FLCDFChi-Netezza-01
--
--	Name(s):		FLCDFChi
--
-- 	Description:		Scalar function which returns the Chi cumulative distribution 
--
--	Applications:		 
--
-- 	Signature:		FLCDFChi(param A, param B, param C, y)
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

---.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Case 1a
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 1.0, 2.0, 1.0) AS FLCDFChi;

--  Case 1b
SELECT 1e300 AS CValue, 
	FLCDFChi( 0.0, 1.0, 2.0, 1e300) AS FLCDFChi;
   
--  Case 1c
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 1.0, 2.0, 1e310) AS FLCDFChi;
-- Expected failure due to Netezza system limitation above 1e308

    
--  Case 1d
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 1e300, 2.0, 1.0) AS FLCDFChi;
   
--  Case 1e
SELECT 1.0 AS CValue, 
	FLCDFChi( 0.0, 1e310, 2.0, 1.0) AS FLCDFChi;
-- Expected failure due to Netezza system limitation above 1e308


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: param B < 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, -1.0, 2.0, 1.0) AS FLCDFChi;

-- Case 1b: param B == 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 0.0, 2.0, 1.0) AS FLCDFChi;

-- Case 1c: param C  < 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 0.0, -2.0, 1.0) AS FLCDFChi;

-- Case 1d: param C  == 0.0
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 0.0, 0.0, 1.0) AS FLCDFChi;

-- Case 1e: param C  > 100.0
SELECT 	1.0 AS CValue, 
	FLCDFChi( 0.0, 0.0, 101.0, 1.0) AS FLCDFChi;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a, b:
-- Not Applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFChi(0.0, 1.0, 2.0) AS FLCDFChi;

-- Case 4b: More than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFChi(1.0, 0.0, 1.0, 2.0, 2.0) AS FLCDFChi;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
