-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
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
-- 	Test Category:	    Data Mining Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\timing on

-- BEGIN: TEST(s)


-----*******************************************************************************************************************************
---SP_RegrDataPrep
-----*******************************************************************************************************************************
DROP TABLE tblDeep;

SELECT '***** EXECUTING SP_RegrDataPrep *****';
EXEC SP_RegrDataPrep(NULL,         -- New Conversion
		'tblAutoMpg',   -- Name of Input Wide Table
		'ObsID',	    -- Name of the observation id Column
		'MPG',          -- Name of the dependent variable
		'tblDeep',  	-- Name of the Output Deep Table.
					    -- This table should not exist.
		true,       	-- Transform Categorical to Dummy
		false,      	-- Perform Mean Normalization
		false,      	-- Perform Variable Reduction
		false,      	-- Make data Sparse
		0.0001,     	-- Minimum acceptable Standard Deviation
		0.98,       	-- Maximum Acceptable correlation
		0,          	-- 0 => Training data set
		'CarNum',    	-- Exclude Columns
		'CarNum');      -- Columns to exclude from conversion	


SELECT a.* 
FROM   fzzlRegrDataPrepMap a
WHERE  a.AnalysisID = (SELECT AnalysisID
                       FROM 
ORDER BY a.Final_VarID
LIMIT 20;

SELECT *
FROM tblDeep
ORDER BY 1, 2
LIMIT 20;




-- END: TEST(s)

-- END: TEST SCRIPT
\timing off