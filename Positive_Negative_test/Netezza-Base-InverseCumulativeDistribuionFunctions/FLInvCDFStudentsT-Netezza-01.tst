
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
-- 	Test Category:          Inverse Cumulative Distribution Function
--
--	Test Unit Number:	FLInvCDFStudentsT-Netezza-01
--
--	Name(s):		FLInvCDFStudentsT
--
-- 	Description:		Scalar function which returns the cumulative probability of a StudentsT distribution
--
--	Applications:		 
--
-- 	Signature:		FLInvCDFStudentsT(param A, param B, param C, CDF)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		11-18-2014
--
--	Author:			Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Test case 1a:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 0.0, 1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

--  Test case 1b:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 1e-300, 1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

-- Expected failure due to Netezza system limitation below 1e-307
--  Test case 1c:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 1e-310, 1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

--  Test case 1d:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 1e300, 1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

-- Expected failure due to Netezza system limitation above 1e308
--  Test case 1e:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 1e310, 1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

--  Test case 1f:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 0.0, 1e300, 2.0, 0.25) AS FLInvCDFStudentsT;

-- Expected failure due to Netezza system limitation above 1e308
--  Test case 1g:
SELECT 	0.25 AS CValue, 
	FLInvCDFStudentsT( 0.0, 1e310, 2.0, 0.25) AS FLInvCDFStudentsT;

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: 
--  P < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, 2.0, -0.25) AS FLInvCDFStudentsT;

-- Case 1b:
--  P == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, 2.0, 0.0) AS FLInvCDFStudentsT;

-- Case 1c: 
--  P > 1.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, 2.0, 1.25) AS FLInvCDFStudentsT;

-- Case 1d: Scale < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, -1.0, 2.0, 0.25) AS FLInvCDFStudentsT;

-- Case 1e: Scale  == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 0.0, 2.0, 0.25) AS FLInvCDFStudentsT;

-- Case 1f: DF < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, -2.0, 0.25) AS FLInvCDFStudentsT;

-- Case 1g: DF == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, 0.0, 0.25) AS FLInvCDFStudentsT;

-- Case 1h: DF > 100.0
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT( 0.0, 1.0, 101.0, 0.25) AS FLInvCDFStudentsT;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b: 
-- Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT(0.25, 0.0, 1.0) AS FLInvCDFStudentsT;

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFStudentsT(0.25, 0.0, 1.0, 9.0, 9.0) AS FLInvCDFStudentsT;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
