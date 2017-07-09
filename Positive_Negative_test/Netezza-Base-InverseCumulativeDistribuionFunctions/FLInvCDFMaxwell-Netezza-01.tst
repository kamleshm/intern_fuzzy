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
--	Test Unit Number:	FLInvCDFMaxwell-Netezza-01
--
--	Name(s):		FLInvCDFMaxwell
--
-- 	Description:	    	Scalar function which returns the inverse of the Maxwell cumulative distribution
--
--	Applications:	    	
--
-- 	Signature:		FLInvCDFMaxwell(param A, CDF)
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

-- Test with normal and extreme Scale factor values

--  Case 1a
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( 1.0, 0.25) AS InvCDFMaxwell;

--  Case 1b
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( 1.0, 1e-300) AS InvCDFMaxwell;      
   
-- Expected failure due to Netezza system limitations above 1e308
--  Case 1c
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( 1.0, 1e-310) AS InvCDFMaxwell;   
    
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases
        
--  Case 1a: Scale < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( -0.45, 0.25) AS InvCDFMaxwell;           

--  Case 1b: Scale == 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( 0.0, 0.25) AS InvCDFMaxwell;   

--  Case 1c: Scale == 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell(1.0, 1.0) AS InvCDFMaxwell;  

--  Case 1d: Scale > 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell(2.0, 1.0) AS InvCDFMaxwell;  

--  Case 1e: P < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell( 1.0, -0.25) AS InvCDFMaxwell;           

--  Case 1f: P == 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell(1.0, 1.0) AS InvCDFMaxwell;  

--  Case 1g: P > 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell(1.0, 1.2) AS InvCDFMaxwell;          
    
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
        FLInvCDFMaxwell(0.25) AS InvCDFMaxwell;           
        
-- Case 4b: More than expected # of parameters        
SELECT 0.25 AS CValue, 
        FLInvCDFMaxwell(0.25, 1.0, 2.0) AS InvCDFMaxwell;              

-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
