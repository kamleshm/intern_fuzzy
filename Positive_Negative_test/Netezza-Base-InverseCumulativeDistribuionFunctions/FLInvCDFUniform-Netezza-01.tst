
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
-- 	Test Category:		    Inverse Cumulative Distribution Function
--
--	Test Unit Number:	    FLInvCDFUniform-Netezza-01
--
--	Name(s):		    FLInvCDFUniform
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Uniform distribution
--
--	Applications:		
--
-- 	Signature:		    FLInvCDFUniform(param A, param B, CDF)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Double Precision
--
--	Last Updated:		    11-18-2014
--
--	Author:			    Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Test case 1a:
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform( 0.0, 1.0, 0.25) AS FLInvCDFUniform;

--	Test case 1b:
SELECT 	0.25 AS CValue, 
	FLInvCDFUniform( 1e-300, 1.0, 0.25) AS FLInvCDFUniform;

-- Expected failure due to Netezza system limitation below 1e-307
--	Test case 1c:
SELECT 	0.25 AS CValue, 
	FLInvCDFUniform( 1e-310, 1.0, 0.25) AS FLInvCDFUniform;

--	Test case 1d:
SELECT 	0.25 AS CValue, 
	FLInvCDFUniform( 0.0, 1e300, 0.25) AS FLInvCDFUniform;

-- Expected failure due to Netezza system limitation above 1e308
--	Test case 1e:
SELECT 	0.25 AS CValue, 
	FLInvCDFUniform( 0.0, 1e310, 0.25) AS FLInvCDFUniform;

-- END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform( 2.0, 1.0, 0.25) AS FLInvCDFUniform;    

-- Case 1b: P < 0
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform( 0.0, 1.0, -0.25) AS FLInvCDFUniform;       

-- Case 1c: P > 1
SELECT 	1.1 AS CProb, 
	FLInvCDFUniform( 0.2, 1.0, 1.1) AS FLInvCDFUniform;       

-- Case 1d: P == 1
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform( 0.2, 1.0, 1.0) AS FLInvCDFUniform;       

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform( 0.2, 0.2, 0.1) AS FLInvCDFUniform;               

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--             Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
-- 	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform(0.1, 0.2) AS FLInvCDFUniform;   

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS CProb, 
	FLInvCDFUniform(0.1, 0.2, 0.4, 0.4) AS FLInvCDFUniform;      
    
-- END: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
