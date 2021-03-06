
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Ntezza
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
-- 	Test Category:		  Cumulative Distribution Function
--
--	Test Unit Number:	  FLCDFUniform-Netezza-01
--
--	Name(s):		  FLCDFUniform
--
-- 	Description:		  Scalar function which returns the Uniform cumulative distribution
--
--	Applications:		
--
-- 	Signature:		  FLCDFUniform(param A, param B, y)
--
--	Parameters:		  See Documentation
--
--	Return value:		  Double Precision
--
--	Last Updated:		  11-12-2014
--
--	Author:			  Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--	Test case 1a:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1.0, 0.45) AS FLCDFUniform;

--	Test case 1b:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1.0,1e-300) AS FLCDFUniform;


--	Test case 1c:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1.0, 1e-310) AS FLCDFUniform;
-- Netezza system limitation below 1e-307 as 0 

--	Test case 1d:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1.0, 1e300) AS FLCDFUniform;


--	Test case 1e:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1.0, 1e310) AS FLCDFUniform;
-- Expected failure due to Netezza system limitation above 1e308

--	Test case 1f:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 1e-300, 1.0, 0.45) AS FLCDFUniform;


--	Test case 1g:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 1e-310, 1.0, 0.45) AS FLCDFUniform;
-- Netezza system limitation below 1e-307 as 0 

--	Test case 1h:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1e300, 0.45) AS FLCDFUniform;


--	Test case 1i:
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.0, 1e310, 0.45) AS FLCDFUniform;
-- Expected failure due to Netezza system limitation above 1e308

-- END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 1.0, 0.0, 0.45) AS FLCDFUniform;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.50, 0.50, 0.45) AS FLCDFUniform;

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--             Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
-- 	 Not applicable - all parameters are double precision


-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.50,0.45) AS FLCDFUniform;

-- Case 4b: More than expected # of parameters
SELECT 	0.45 AS CValue, 
	FLCDFUniform( 0.50, 0.6, 0.7, 0.45) AS FLCDFUniform;

-- END: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
