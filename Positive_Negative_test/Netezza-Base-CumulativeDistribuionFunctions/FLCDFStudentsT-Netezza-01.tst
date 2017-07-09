
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
-- 	Test Category:          Cumulative Distribution Function
--
--	Test Unit Number:	FLCDFStudentsT-Netezza-01
--
--	Name(s):		FLCDFStudentsT
--
-- 	Description:		Scalar function which returns the Students-t cumulative distribution
--
--	Applications:		 
--
-- 	Signature:		FLCDFStudentsT(param A, param B, param C, y)
--
--	Parameters:		See Documentation
--
--	Return value:		Double Precision
--
--	Last Updated:		11-10-2014
--
--	Author:			Surya Deepak Garimella
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--  Test case 1a:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 2.0, 1.0) AS FLCDFStudentsT;

--  Test case 1b:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 2.0, 1e-300) AS FLCDFStudentsT;


--  Test case 1c:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 2.0, 1e-310) AS FLCDFStudentsT;
-- Netezza system limitation below 1e-307 as 0 

--  Test case 1d:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 2.0, 1e300) AS FLCDFStudentsT;


--  Test case 1e:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 2.0, 1e310) AS FLCDFStudentsT;
-- Expected failure due to Netezza system limitation above 1e308

--  Test case 1f:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 1e-300, 1.0, 2.0, 1.0) AS FLCDFStudentsT;


--  Test case 1g:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 1e-310, 1.0, 2.0, 1.0) AS FLCDFStudentsT;
-- Netezza system limitation below 1e-307 as 0 

--  Test case 1h:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 1e300, 1.0, 2.0, 1.0) AS FLCDFStudentsT;


--  Test case 1ig:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 1e310, 1.0, 2.0, 1.0) AS FLCDFStudentsT;
-- Expected failure due to Netezza system limitation above 1e308

--  Test case 1j:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1e300, 2.0, 1.0) AS FLCDFStudentsT;


--  Test case 1k:
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1e310, 2.0, 1.0) AS FLCDFStudentsT;
-- Expected failure due to Netezza system limitation above 1e308
	
-- Case 1l: DF > 100.0
---JIRA 618 resolved
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 101.0, 1.0) AS FLCDFStudentsT;

-- BEGIN: NEGATIVE TEST(s)

-- Category 1: Out of boundary condition test cases

-- Case 1a: Scale < 0.0
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, -1.0, 2.0, 1.0) AS FLCDFStudentsT;

-- Case 1b: Scale  == 0.0
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 0.0, 2.0, 1.0) AS FLCDFStudentsT;

-- Case 1c: DF < 0.0
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, -2.0, 1.0) AS FLCDFStudentsT;

-- Case 1d: DF == 0.0
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT( 0.0, 1.0, 0.0, 1.0) AS FLCDFStudentsT;



-- Category 2: Undefined results or error conditions due to equality

-- Case 2a,b: 
-- Not applicable

-- Category 3: Data type mismatch conditions -
--	       Test with most likely mismatched data type for the function which is
--	       usually data types within the parameter list
--
--	 Not applicable - all parameters are double precision

-- Category 4: Test function with non-matching # of parameters

-- Case 4a: Fewer than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT(1.0, 0.0, 1.0) AS FLCDFStudentsT;

-- Case 4b: More than expected # of parameters
SELECT 	1.0 AS CValue, 
	FLCDFStudentsT(1.0, 0.0, 1.0, 100.0, 100.0) AS FLCDFStudentsT;
	
    
-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
