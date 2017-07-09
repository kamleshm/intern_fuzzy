
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
-- 	Test Category:	        Inverse Cumulative Distribution Function
--
--	Test Unit Number:	FLInvCDFGamma-Netezza-01
--
--	Name(s):		FLInvCDFGamma
--
-- 	Description:		Scalar function which returns the inverse of the Gamma cumulative distribution
--
--	Applications:		 
--
-- 	Signature:		FLInvCDFGamma(param A, param B, param C, CDF)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		07-05-2017
--
--	Author:			Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-- 	BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Test case 1a:
SELECT 	0.25 AS CValue, 
	FLInvCDFGamma( 0.0, 1.0, 2.0, 0.25) AS FLInvCDFGamma;

--  Test case 1b:
SELECT 	0.25 AS CValue, 
	FLInvCDFGamma( 0.0, 1e300, 2.0, 0.25) AS FLInvCDFGamma;

-- Expected failure due to Netezza system limitation above 1e308
--  Test case 1c:
SELECT 	0.25 AS CValue, 
	FLInvCDFGamma( 0.0, 1e310, 2.0, 0.25) AS FLInvCDFGamma;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: P < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 1.0, 2.0, -0.25) FLInvCDFGamma;

-- Case 1b: P == 1.0   
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 1.0, 2.0, 1.0) FLInvCDFGamma;

-- Case 1c: P > 1.0   
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 1.0, 2.0, 2.0) FLInvCDFGamma;

-- Case 1d: Scale < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, -0.1, 2.0, 0.25) FLInvCDFGamma;

-- Case 1e: Scale == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 0.0, 2.0, 0.25) FLInvCDFGamma;

-- Case 1f: Shape  < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 0.0, -2.0, 0.25) FLInvCDFGamma;    

-- Case 1g: Shape == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 1.0, 0.0, 0.25) FLInvCDFGamma;      

-- Case 1h: Shape > 100.0
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma( 0.0, 1.0, 102.0, 0.25) FLInvCDFGamma;      

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,2b: 
--  Not Applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma(0.25, 0.0, 1.0) FLInvCDFGamma;      

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFGamma(0.25, 0.0, 0.0, 1.0, 2.0) FLInvCDFGamma;      

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
