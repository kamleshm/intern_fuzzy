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
--	Test Unit Number:	FLInvCDFInvNormal-Netezza-01
--
--	Name(s):		FLInvCDFInvNormal
--
-- 	Description:	    	Scalar function which returns the inverse of the Inverse Normal cumulative distribution
--
--	Applications:	    	
--
-- 	Signature:		FLInvCDFInvNormal(param A, param B, CDF)
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
        FLInvCDFInvNormal( 1.0, 1.0, 0.25) AS InvCDFInvNormal;

--  Case 1b
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, 1.0, 1e-300) AS InvCDFInvNormal;
   
-- Expected failure due to Netezza system limitations below 1e-300
--  Case 1c
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, 1.0, 1e-310) AS InvCDFInvNormal;

-- Expected failure due to Netezza system limitations at and above 1e308
--  Case 1d
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1e310, 1.0, 0.25) AS InvCDFInvNormal;
    
-- Expected failure due to Netezza system limitations at and above 1e308
--  Case 1e
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, 1e310, 0.25) AS InvCDFInvNormal;
    
-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Mu == 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 0.0, 1.0, 0.25) AS InvCDFInvNormal;
    
--  Case 1b: Mu < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( -1.0, 1.0, 0.25) AS InvCDFInvNormal;
        
-- Case 1c: Lambda == 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, 0.0, 0.25) AS InvCDFInvNormal;
    
--  Case 1d: Lambda < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, -1.0, 0.25) AS InvCDFInvNormal;  

--  Case 1e: P < 0.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal( 1.0, 1.0, -1.0) AS InvCDFInvNormal;
        
-- Case 1f: P == 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal(1.0, 1.0, 1.0) AS InvCDFInvNormal;
    
--  Case 1g: P > 1.0
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal(1.0, 1.0, 1.2) AS InvCDFInvNormal; 
        

-- Category 2: Undefined results or error conditions due to equality

-- Not Applicable
    
-- Category 3:  Data type mismatch conditions -
--	            Test with most likely mismatched data type for the function which is
--		        usually data types within the parameter list
--
--	 Not applicable - parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal(0.25, 1.0) AS InvCDFInvNormal; 

-- Case 4b: Nore than expected # of parameters        
SELECT 0.25 AS CValue, 
        FLInvCDFInvNormal(0.25, 1.0, 1.0, 1.0) AS InvCDFInvNormal;         

-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT

