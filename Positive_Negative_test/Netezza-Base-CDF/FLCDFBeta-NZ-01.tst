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
-- 	Test Category:	    	Cumulative Distribution Function
--
--	Test Unit Number:	FLCDFBeta-Netezza-01
--
--	Name(s):		FLCDFBeta
--
-- 	Description:	    	Scalar function which returns the Beta cumulative distribution
--
--	Applications:	    	The beta distribution can be used to model events which are constrained to take 
--  				place within an interval defined by a minimum and maximum value 
--
-- 	Signature:		FLCDFBeta(param A, param B, param C, param D, y)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	11-10-2014
--
--	Author:			Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Case 1a
SELECT 	0.25 AS CValue, 
       	FLCDFBeta( 0.0, 1.0, 1.0, 2.0,0.25) AS FLCDFBeta;

--  Case 1b
SELECT 	0.25 AS CValue, 
       	FLCDFBeta(0.0, 1.0, 1.0, 2.0, 1e300) AS FLCDFBeta;
-- Expected failure due to value not within limits of parameters a and b

--  Case 1c
SELECT 	0.25 AS CValue,
       	FLCDFBeta(0.0, 1.0, 1.0, 2.0,1e310) AS FLCDFBeta;
-- Expected failure due to Netezza system limitation above 1e308
    
--  Case 1d
SELECT 	0.25 AS CValue, 
	FLCDFBeta(1e-300, 1.0, 1.0, 2.0,0.25) AS FLCDFBeta;
   

--  Case 1e
SELECT 	0.25 AS CValue, 
	FLCDFBeta(1e-310, 1.0, 1.0, 2.0,0.25) AS FLCDFBeta;
-- Netezza system limitation below 1e-307 as 0
   
--  Case 1f
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1e300, 1.0, 2.0,0.25) AS FLCDFBeta;
   
--  Case 1g
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.25, 0.0, 1e310, 1.0, 2.0) AS FLCDFBeta;
-- Expected failure due to Netezza system limitation above 1e308
   
--  Case 1h
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, 1e-300, 2.0, 0.25) AS FLCDFBeta;
    
--  Case 1i
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, 1e-330, 2.0, 0.25) AS FLCDFBeta;
-- Expected failure due to Netezza system limitation below 1e-307
    
--  Case 1j
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, 1.0, 1e300, 0.25) AS FLCDFBeta;
   
--  Case 1k
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.25, 0.0, 1.0, 1.0, 1e310) AS FLCDFBeta;
-- Expected failure due to Netezza system limitation above 1e308

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Param A > param B
SELECT 	0.25 AS CValue, 
	FLCDFBeta(1.0, 0.0, 1.0, 2.0,0.25) AS FLCDFBeta;
    
-- Case 1b: Param C < 0.0
SELECT 0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, -0.25, 2.0, 0.25) AS FLCDFBeta;
    
-- Case 1c: Param C == 0.0
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, 0.0, 2.0, 0.25) AS FLCDFBeta;
    
-- Case 1d: Param D < 0.0
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.0, 1.0, 1.0, -0.25, 0.25) AS FLCDFBeta;
    
-- Case 1e: Param D == 0.0
SELECT 	0.25 AS CValue, 
	FLCDFBeta( 0.0, 1.0, 1.0, 0.0, 0.25) AS FLCDFBeta;
    
-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.0, 0.0, 1.0, 2.0, 0.25) AS FLCDFBeta;
    
-- Case 2b:
-- Not Applicable
    
-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision
    
-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.0, 0.0, 1.0, 2.0) AS FLCDFBeta;

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS CValue, 
	FLCDFBeta(0.0, 0.0, 1.0, 2.0, 1.0, 0.25) AS FLCDFBeta;

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
