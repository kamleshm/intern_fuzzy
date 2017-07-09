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
--	Test Unit Number:	FLCDFReciprocal-Netezza-01
--
--	Name(s):		FLCDFReciprocal
--
-- 	Description:	    	Scalar function which returns the Reciprocal cumulative distribution
--
--	Applications:	    	
--
-- 	Signature:		FLCDFReciprocal(param A, param B, y)
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

-- Test with normal and extreme Scale factor values

--  Case 1a
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 100.0, 5.0) AS CDFReciprocal;

--  Case 1b
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 100.0, 1e-300) AS CDFReciprocal;    
   

--  Case 1c
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 100.0, 1e-310) AS CDFReciprocal; 
-- Netezza system limitation below 1e-307 as 0   
    
--  Case 1d
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 100.0, 1e300) AS CDFReciprocal;       
        
-- Expected failure due to Netezza system limitations above 1e308
--  Case 1e
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 100.0, 1e310) AS CDFReciprocal;    
     
--  Case 1f
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1e-300, 100.0, 5.0) AS CDFReciprocal;       
        

--  Case 1g
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1e-310, 100.0, 5.0) AS CDFReciprocal; 
-- Netezza system limitation below 1e-307 as 0 

--  Case 1h
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 1e300, 5.0) AS CDFReciprocal;       
        

--  Case 1i
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 1e310, 5.0) AS CDFReciprocal; 
-- Expected failure due to Netezza system limitations above 1e308

        
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases
        
--  Case 1a: LowBD < 0.0   
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( -1.0, 100.0, 5.0) AS CDFReciprocal;        

--  Case 1b: LowBD == 0.0 
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 0.0, 100.0, 5.0) AS CDFReciprocal;        

--  Case 1c: LowBD > UppBD 
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 0.5, 5.0) AS CDFReciprocal;
  
--  Case 1c: LowBD == UppBD 
SELECT 5.0 AS CValue, 
        FLCDFReciprocal( 1.0, 1.0, 5.0) AS CDFReciprocal;
            
-- Category 2: Undefined results or error conditions due to equality

-- Not Applicable
    
-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters        
SELECT 5.0 AS CValue, 
        FLCDFReciprocal(5.0, 1.0) AS CDFReciprocal;        
        
-- Case 4b: More than expected # of parameters        
SELECT 5.0 AS CValue, 
        FLCDFReciprocal(5.0, 1.0, 2.0, 2.0) AS CDFReciprocal;        

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT

