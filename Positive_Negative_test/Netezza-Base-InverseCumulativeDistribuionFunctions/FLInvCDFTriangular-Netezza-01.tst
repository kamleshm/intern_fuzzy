
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
--	Test Unit Number:	    FLInvCDFTriangular-Netezza-01
--
--	Name(s):		    FLInvCDFTriangular
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Triangular distribution
--
--	Applications:	
--  		
--
-- 	Signature:		    FLInvCDFTriangular(param A, param B, param C, CDF)
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

-- Case 1a:
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, 2.0, 0.25) AS InvCDFTriangular;

-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: LowBD > UppBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( 5.0, 4.0, 2.0, 0.25) AS InvCDFTriangular;

-- Case 1b: P < 0.0
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, 2.0, -0.25) AS InvCDFTriangular;

-- Case 1c: P > 1
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, 2.0, 1.25) AS InvCDFTriangular;

-- Case 1d: Theta < LowBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, -5.0, 0.25) AS InvCDFTriangular;

-- Case 1e: Theta > UppBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, 5.0, 0.25) AS InvCDFTriangular;

-- Case 1f: Theta == LowBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, -4.0, 0.25) AS InvCDFTriangular;

-- Case 1g: Theta == UppBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( -4.0, 4.0, 4.0, 0.25) AS InvCDFTriangular;

-- Category 2: Undefined results or error conditions due to equality

-- Case 2a: LowBD == UppBD
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular( 4.0, 4.0, 2.0, 0.25) AS InvCDFTriangular;

-- Case 2b:
--  Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular(0.25, -4.0, 4.0) AS InvCDFTriangular;

-- Case 4b: More than expected # of parameters
SELECT 	0.25 AS Prob, 
	FLInvCDFTriangular(0.25, -4.0, 4.0, 2.0, 2.0) AS InvCDFTriangular;

-- END: NEGATIVE TEST(s)
    
-- 	END: TEST SCRIPT
