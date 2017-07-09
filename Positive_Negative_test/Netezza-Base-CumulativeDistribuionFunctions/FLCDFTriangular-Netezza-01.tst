
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
-- 	Test Category:		 Cumulative Distribution Function
-- 
--	Test Unit Number:	 FLCDFTriangular-Netezza-01
--
--	Name(s):		 FLCDFTriangular
--
-- 	Description:		 Scalar function which returns the Triangular cumulative distribution
--
--	Applications:	
--  		
--
-- 	Signature:		 FLCDFTriangular(param A, param B, param C, y)
--
--	Parameters:		 See Documentation
--
--	Return value:		 Double Precision
--
--	Last Updated:		 11-12-2014
--
--	Author:			 Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Test case 1a:
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, 2.0,-2.0) AS FLCDFTriangular;


--  Test case 1b:
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -1e-310, 4.0, 2.0, -2.0) AS FLCDFTriangular;
-- Netezza system limitation below 1e-307 as 0 

--  Test case 1c:
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 1e300, 2.0, -2.0) AS FLCDFTriangular;


--  Test case 1d:
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 1e310, 2.0, -2.0) AS FLCDFTriangular;
-- Expected failure due to Netezza system limitation above 1e308

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( 4.0, -4.0, 2.0, -2.0) AS FLCDFTriangular;

-- Case 1b: Theta < LowBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, -5.0,6.0) AS FLCDFTriangular;

-- Case 1c: Theta > UppBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, 5.0, 6.0) AS FLCDFTriangular;

-- Case 1d: Theta == LowBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( 3.0, 4.0, 3.0, 6.0) AS FLCDFTriangular;

-- Case 1e: Theta == UppBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, 4.0, 6.0) AS FLCDFTriangular;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( 4.0, 4.0, 4.0, 6.0) AS FLCDFTriangular;

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, -2.0) AS FLCDFTriangular;

-- Case 4b: More than expected # of parameters
SELECT 	-2.0 AS CValue, 
	FLCDFTriangular( -4.0, 4.0, 2.0, 2.0, -2.0) AS FLCDFTriangular;

-- END: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
