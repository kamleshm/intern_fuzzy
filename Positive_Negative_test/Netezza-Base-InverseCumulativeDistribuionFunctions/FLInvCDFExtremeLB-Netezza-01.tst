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
-- 	Test Category:	    	Inverse Cumulative Distribution Function
--
--	Test Unit Number:	FLInvCDFExtremeLB-Netezza-01
--
--	Name(s):		FLInvCDFExtremeLB
--
-- 	Description:	    	Scalar function which returns the inverse of the extremeLB cumulative distribution
--
--	Applications:	    	
--
-- 	Signature:		FLInvCDFExtremeLB(param A, param B, param C, CDF)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	11-18-2014
--
--	Author:			Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Case 1a
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, 0.25) AS InvCDFExtremeLB;
               
--  Case 1b
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, 1e-300) AS InvCDFExtremeLB;
        
-- Expected failure due to Netezza system limitations below 1e-307
--  Case 1c 
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, 1e-310) AS InvCDFExtremeLB;  
        
--  Case 1d
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1e-300, 1.0, 2.0, 0.25) AS InvCDFExtremeLB; 
  
-- Expected failure due to Netezza system limitations below 1e-307
--  Case 1e
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1e-310, 1.0, 2.0, 0.25) AS InvCDFExtremeLB; 

--  Case 1f
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1e300, 2.0, 0.25) AS InvCDFExtremeLB; 
  
-- Expected failure due to Netezza system limitations above 1e308
--  Case 1g
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1e310, 2.0, 0.25) AS InvCDFExtremeLB;    

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Scale < 0
 SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, -1.0, 2.0, 0.25) AS InvCDFExtremeLB;     
    
-- Case 1b: Scale == 0.0   
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 0.0, 2.0, 0.25) AS InvCDFExtremeLB;        
    
-- Case 1c: Shape < 0.0 
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, -0.0, 0.25) AS InvCDFExtremeLB;   

-- Case 1d: Shape == 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 0.0, 0.25) AS InvCDFExtremeLB; 

-- Case 1d: Shape > 100
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 101.0, 0.25) AS InvCDFExtremeLB;

-- Case 1e: P < 0.0 
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, -0.25) AS InvCDFExtremeLB;   

-- Case 1d: P == 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, 1.0) AS InvCDFExtremeLB; 

-- Case 1d: P > 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB( 1.0, 1.0, 2.0, 1.25) AS InvCDFExtremeLB;          
        
-- Category 2: Undefined results or error conditions due to equality

-- Not Applicable
    
-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision 

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters 
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB(0.25, 1.0, 1.0) AS InvCDFExtremeLB;           

-- Case 4b: More than expected # of parameters
SELECT 0.25 AS CValue, 
        FLInvCDFExtremeLB(0.25, 1.0, 1.0, 0.0, 2.0) AS InvCDFExtremeLB;           

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
