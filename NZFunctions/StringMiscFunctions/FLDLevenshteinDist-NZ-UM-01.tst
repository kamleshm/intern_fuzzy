-- INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata Aster
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    String and Miscellaneous Utility Functions
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
-- BEGIN: TEST(s)
-----****************************************************************
---FLDLevenshteinDist
-----****************************************************************
SELECT FLDLevenshteinDist('MARTHA','Partha',1) AS DLevenshteinlDist1,
       FLDLevenshteinDist('MARTHA','Partha',0) AS DLevenshteinDist2,
       FLDLevenshteinDist('MARTHA','Parhta',1) AS DLevenshteinDist3,
       FLDLevenshteinDist('MARTHA','Parhta',0) AS DLevenshteinlDist4;



-------------------------------------------------------------------------------------
-----****************************************************************
