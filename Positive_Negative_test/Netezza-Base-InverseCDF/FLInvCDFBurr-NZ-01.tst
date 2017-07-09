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
--	Test Unit Number:	FLInvCDFBurr-Netezza-01
--
--	Name(s):		FLInvCDFBurr
--
-- 	Description:	    	Scalar function which returns the inverse of the Burr cumulative distribution
--	Applications:	    	
--
-- 	Signature:		FLInvCDFBurr(param A, param B, param C, param D, CDF)
--
--	Parameters:		See Documentation
--
--	Return value:	    	Double Precision
--
--	Last Updated:	    	07-05-2017
--
--	Author:			Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Case 1a
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 1.0, 0.25) AS InvCDFBurr;       
        
--  Case 1b
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 1.0, 1e-300) AS InvCDFBurr;    
        
-- Expected failure due to Netezza system limitations above 1e308
--  Case 1c
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 1.0, 1e-310) AS InvCDFBurr; 
        
--  Case 1d
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 1e-300, 1.0, 2.0, 1.0, 0.25) AS InvCDFBurr; 
   
-- Expected failure due to Netezza system limitations below 1e-307
--  Case 1e
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 1e-310, 1.0, 2.0, 1.0, 0.25) AS InvCDFBurr;         
   
--  Case 1f
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1e300, 2.0, 1.0, 0.25) AS InvCDFBurr; 
   
-- Expected failure due to Netezza system limitations above 1e308
--  Case 1g
 SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1e310, 2.0, 1.0, 0.25) AS InvCDFBurr;               

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Scale < 0
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, -1.0, 2.0, 1.0, 0.25) AS InvCDFBurr;         
    
-- Case 1b: Scale == 0.0  
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 0.0, 2.0, 1.0, 0.25) AS InvCDFBurr; 
    
-- Case 1c: Shape1 < 0.0 
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, -2.0, 1.0, 0.25) AS InvCDFBurr;   

-- Case 1d: Shape1 == 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 0.0, 1.0, 0.25) AS InvCDFBurr;          
    
-- Case 1e: Shape1 > 100.0  
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 110.0, 1.0, 0.25) AS InvCDFBurr; 
        
-- Case 1f: Shape2 < 0.0  
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, -1.0, 0.25) AS InvCDFBurr;

-- Case 1g: Shape2 > 100.0  
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 110.0, 0.25) AS InvCDFBurr;
        
-- Case 1h: Prob < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 1.0, -0.25) AS InvCDFBurr;        
        
-- Case 1i: Prob > 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFBurr( 0.0, 1.0, 2.0, 1.0, 1.25) AS InvCDFBurr; 
        
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
        FLInvCDFBurr(0.25, 0.0, 1.0, 2.0) AS InvCDFBurr;          

-- Case 4b: More than expected # of parameters
SELECT 0.25 AS CValue, 
        FLInvCDFBurr(0.25, 0.0, 1.0, 2.0, 1.0, 3.0) AS InvCDFBurr;          

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
