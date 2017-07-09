-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:			Basic Statistics
--
--	Test Unit Number:		FL-Netezza-01
--
--	Name(s):		    	FLModEuclideanDist
--
-- 	Description:			Returns the mod ofEuclidean distance
--	Applications:		 
--
-- 	Signature:		    	FLModEuclideanDist(A DOUBLE PRECISION,
--									B DOUBLE PRECISION, 
--									C DOUBLE PRECISION)
--
--	Parameters:		    	See Documentation
--
--	Return value:			FLOAT
--
--	Last Updated:			05-03-2017
--
--	Author:			    	Diptesh Nath
--

-- BEGIN: TEST SCRIPT

--.run file=../PulsarLogOn.sql

--.set width 2500

-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Returns expected result
--- Return expected results, Good

SELECT a.Country,b.Country,FLModEuclideanDist(a.Consumption, b.Consumption,1.5) AS FLModEuclideanDist
FROM tblProteinConsump a,tblProteinConsump b WHERE b.ProteinCode = a.ProteinCode AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country ORDER BY 1,2 LIMIT 100;

---- Positive Test 2: Returns expected result
--- Return expected results, Good

SELECT a.Country,b.Country,FLModEuclideanDist(a.Consumption, b.Consumption,-100) AS FLModEuclideanDist
FROM tblProteinConsump a,tblProteinConsump b WHERE b.ProteinCode = a.ProteinCode AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country ORDER BY 1,2 LIMIT 100;

---- Positive Test 2: Returns expected result
--- Return expected results, Good

SELECT a.Country,b.Country,FLModEuclideanDist(a.Consumption, b.Consumption,null) AS FLModEuclideanDist
FROM tblProteinConsump a,tblProteinConsump b WHERE b.ProteinCode = a.ProteinCode AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country ORDER BY 1,2 LIMIT 100;


-- END: POSITIVE TEST(s)

-- BEGIN: NEGATIVE TEST(s)

---- Negative Test 1: Bad input at 3 rd position
SELECT a.Country,b.Country,FLModEuclideanDist(a.Consumption, b.Consumption,'AAA') AS FLModEuclideanDist
FROM tblProteinConsump a,tblProteinConsump b WHERE b.ProteinCode = a.ProteinCode AND b.CountryCode <> a.CountryCode
GROUP BY a.Country, b.Country ORDER BY 1,2 LIMIT 100;


-- END: NEGATIVE TEST(s)

-- 	END: TEST SCRIPT
