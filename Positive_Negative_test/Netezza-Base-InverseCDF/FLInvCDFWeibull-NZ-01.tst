
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
-- 	Test Category:              Inverse Cumulative Distribution Function
--
--	Test Unit Number:	    FLInvCDFWeibull-Netezza-01
--
--	Name(s):		    FLInvCDFWeibull
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Weibull distribution
--
--	Applications:		 
--
-- 	Signature:		    FLInvCDFWeibull(param A, param B, param C, CDF)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Double Precision
--
--	Last Updated:		    07-05-2017
--
--	Author:			    Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Test case 1a:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 3.0, 0.25) AS FLInvCDFWeibull;    

--	Test case 1b:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1e-300, 2.0, 3.0, 0.25) AS FLInvCDFWeibull;    

-- Expected failure due to Netezza system limitation below 1e-307
--	Test case 1c:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1e-310, 2.0, 3.0, 0.25) AS FLInvCDFWeibull;    

--	Test case 1d:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1e300, 2.0, 3.0, 0.25) AS FLInvCDFWeibull;    

-- Expected failure due to Netezza system limitation above 1e308
--	Test case 1e:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1e310, 2.0, 3.0, 0.25) AS FLInvCDFWeibull;    

--	Test case 1f:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 1e300, 3.0, 0.25) AS FLInvCDFWeibull;    

-- Expected failure due to Netezza system limitation above 1e308
--	Test case 1g:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 1e310, 3.0, 0.25) AS FLInvCDFWeibull;    

--	Test case 1h:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 1e300, 0.25) AS FLInvCDFWeibull;    

-- Expected failure due to Netezza system limitation above 1e308
--	Test case 1i:
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 1e310, 0.25) AS FLInvCDFWeibull;    

-- END: POSITIVE TEST(s)


-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: P < 0
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 3.0, -0.25) AS FLInvCDFWeibull;

-- Case 1b: P > 1
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 3.0, 1.25) AS FLInvCDFWeibull;

-- Case 1c: P == 1
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 2.0, 3.0, 1.0) AS FLInvCDFWeibull;

-- Case 1d: Scale < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, -2.0, 3.0, 0.25) AS FLInvCDFWeibull;

-- Case 1e: Scale  == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 0.0, 3.0, 0.25) AS FLInvCDFWeibull;    

-- Case 1f: Shape < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 0.4, -3.0, 0.25) AS FLInvCDFWeibull;  

-- Case 1g: Shape == 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull( 1.0, 0.4, 0.0, 0.25) AS FLInvCDFWeibull;  

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
	FLInvCDFWeibull(0.25, 1.0, 0.4) AS FLInvCDFWeibull;  

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFWeibull(0.25, 1.0, 0.4, 0.4, 0.4) AS FLInvCDFWeibull;  

-- END: NEGATIVE TEST(s)
\time    
-- 	END: TEST SCRIPT
