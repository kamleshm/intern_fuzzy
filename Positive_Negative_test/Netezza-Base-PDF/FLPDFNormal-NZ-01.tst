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
-- 	Test Category:		    Probability Density Functions
--
--	Test Unit Number:	    FLPDFNormal-NZ-01
--
--	Name(s):		    FLPDFNormal
--
-- 	Description:		    Scalar function which returns the cumulative probability of a Normal distribution
--
--	Applications:		
--
-- 	Signature:		    FLPDFNormal(Q, Mean, StdDev)
--
--	Parameters:		    See Documentation
--
--	Return value:		    Double Precision
--
--	Last Updated:		    07-11-2017
--
--	Author:			    <Kamlesh.Meena@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\time
-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Test case 1a:
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0, 1.0, 1.0) AS FLPDFNormal;

--  Test case 1b:
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0,1.0,1e-300) AS FLPDFNormal;

--  Test case 1c:
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0,1.0,1e-310) AS FLPDFNormal;

--  Test case 1d:
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0, 1.0, 1e300) AS FLPDFNormal;

-- Expected failure due to Teradata system limitationa above 1e308
--  Test case 1e:
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0, 1.0, 1e310) AS FLPDFNormal;

--  Test case 1f:
SELECT  1.0 AS CValue, 
 FLPDFNormal(1e-300, 1.0, 1.0) AS FLPDFNormal;
 
--  Test case 1g:
SELECT  1.0 AS CValue, 
FLPDFNormal(1e-310, 1.0, 1.0) AS FLPDFNormal;
 
--  Test case 1h:
SELECT  1.0 AS CValue, 
FLPDFNormal(1e300, 1.0, 1.0) AS FLPDFNormal;
 
-- Expected failure due to Teradata system limitationa above 1e308
--  Test case 1i:
SELECT  1.0 AS CValue, 
FLPDFNormal(1e310, 1.0, 1.0) AS FLPDFNormal;
 
--  Test case 1j:
SELECT  1.0 AS CValue, 
FLPDFNormal(0.0, 1e300, 1.0) AS FLPDFNormal; 
 
-- Expected failure due to Teradata system limitationa above 1e308
--  Test case 1k:
SELECT  1.0 AS CValue, 
FLPDFNormal(0.0, 1e310, 1.0) AS FLPDFNormal; 
 
-- END: POSITIVE TEST(s)

-- 	BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: StdDev < 0
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0, -1.0,1.0) AS FLPDFNormal;
 
-- Case 1b: StdDev == 0
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0, 0.0,1.0) AS FLPDFNormal;
 
-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b: 
--  Not applicable

-- Category 3: Data type mismatch conditions -
--             Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
-- 	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT  1.0 AS CValue, 
 FLPDFNormal(0.0,1.0) AS FLPDFNormal;
 
-- Case 4b: More than expected # of parameters
SELECT  1.0 AS CValue, 
 FLPDFNormal(1.0, 0.0, 1.0, 1.0) AS FLPDFNormal;
 
-- END: NEGATIVE TEST(s)
\time
-- 	END: TEST SCRIPT
 

