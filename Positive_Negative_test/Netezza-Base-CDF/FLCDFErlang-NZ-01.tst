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
--	Test Unit Number:	FLCDFErlang-Netezza-01
--
--	Name(s):		FLCDFErlang
--
-- 	Description:	    	Scalar function which returns the Erlang cumulative distribution
--
--	Applications:	    	
--
-- 	Signature:		FLCDFErlang (param A, param B, param C, y)
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
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 2, 1.0) AS CDFErlang;
        
--  Case 1b
SELECT 1e-300 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 2, 1e-300) AS CDFErlang;

     
--  Case 1c
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 2, 1e-310) AS CDFErlang;
-- Netezza system limitation below 1e-307 as 0 

--  Case 1d
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 2, 1e300) AS CDFErlang;
  

--  Case 1e
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 2, 1e310) AS CDFErlang;       
-- Expected failure due to Netezza system limitations above 1e308  
        
--  Case 1f
SELECT 1.0 AS CValue, 
        FLCDFErlang( 1e-300, 1.0, 2, 1.0) AS CDFErlang;     
   

--  Case 1g
SELECT 1.0 AS CValue, 
        FLCDFErlang(1e-310, 1.0, 2, 1.0) AS CDFErlang;
-- Netezza system limitation below 1e-307 as 0 
   
--  Case 1h
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1e300, 2, 1.0) AS CDFErlang;  
   

--  Case 1i
SELECT 1.0 AS CValue, 
        FLCDFErlang(0.0, 1e310, 2, 1.0) AS CDFErlang;  
-- Expected failure due to Netezza system limitations above 1e308

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: param B== 0.0
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 0.0, 2, 1.0) AS CDFErlang;  
    
-- Case 1b: Param B< 0..0
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, -1.0, 2, 1.0) AS CDFErlang; 
    
-- Case 1c: C == 0
SELECT 1.0 AS CValue, 
        FLCDFErlang(0.0, 1.0, 0, 1.0) AS CDFErlang;   
    
-- Case 1d: C < 0
SELECT 1.0 AS CValue, 
        FLCDFErlang(0.0, 1.0, -2, 1.0) AS CDFErlang; 

 -- Case 1e: C > 100
SELECT 1.0 AS CValue, 
        FLCDFErlang( 0.0, 1.0, 200, 1.0) AS CDFErlang;         
    
-- Category 2: Undefined results or error conditions due to equality

-- Not Applicable
    
-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
-- Case 3a: Shape is specified as a double precision
SELECT 1.0 AS CValue, 
        FLCDFErlang(1.0, 0.0, 1.0, 20.0) AS CDFErlang;         

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 1.0 AS CValue, 
        FLCDFErlang(0.0, 2, 1.0) AS CDFErlang; 

-- Case 4b: More than expected # of parameters
SELECT 1.0 AS CValue, 
        FLCDFErlang(0.0, 1.0, 2, 300, 1.0) AS CDFErlang;   

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT


