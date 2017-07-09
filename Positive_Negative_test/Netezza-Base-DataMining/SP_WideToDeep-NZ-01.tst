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
-- Test Category:       Data Mining Functions
--
-- Test Unit Number:    SP_WideToDeep-NZ-01
--
-- Name(s):             SP_WideToDeep
--
-- Description:         Stored Procedure which transforms a wide table into a deep table.
--
-- Applications:        In DB Lytix, all data mining functions including Logistic Regression 
--						are performed using Stored Procedures on a deep table.
--
-- Signature:           SP_WideToDeep(IN   InWideTable    VARCHAR(100),
--                                    IN   ObsIDCol       VARCHAR(100),
--                                    OUT  FieldMapTable  VARCHAR(100),
--                                    OUT  OutDeepTable   VARCHAR(100),
--                                    IN   PopulateNulls  INTEGER)
--
--    Parameters:      See Documentation
--
--    Return value:    VARCHAR(64)
--
--    Last Updated:    01-30-2015
--
--    Author:          <raman.rajasekhar@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,<kamlesh.meena@fuzzl.com>

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------
-- Case 1
---- Validate that the input table exists
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg_Notexists',	-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0); 
                  
-- Case 2                             
---- Validate that the ObsID column exists                         
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID_NotExists',      -- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0);
                  
-- Case 3
---- Try to run with an existing deep table                         
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0); 

---- Run the function again without deleting the deep table                         
-- DROP TABLE tblAutoMpgDeep;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0); 

-- Case 4                                                    
---- Exclude columns that do not exist in the table
-- Case 5
---- Exclude all columns in the table including the obs id column
-- Case 6
---- Try with a where clause that excludes all rows
-- Case 7                                    
---- For a categorical variable, specify a class which does not exist
--
--NA for NZ                  

-- Case 8
---- Check if populate nulls column can take inputs other than 0 or 1.
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					2); 
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					-1); 
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					NULL); 
					
					
-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

-- Case 1        
---- Call SP_WideToDeep without a class specification(NA for NZ)
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0);

---- Check the wide table and then compare with the original input table
SELECT 	* 
FROM 	tblAutoMpgDeep
LIMIT 10;

--Check if empty
SELECT Count(*)
FROM tblAutoMpgDeep a;

-- Display Map Results
SELECT *
FROM tblFieldMap;               
                  
-- Case 2        
---- Call SP_WideToDeep with a class specification and ensure that no dummy variable is created for the
---- specified CLASS VALUE
DROP TABLE tblAutoMpgDeep;
DROP TABLE tblFieldMap;
CALL SP_WideToDeep(	'tblAutoMpg',			-- CSV wide tables
					'ObsID',              	-- Name of the observation id Column 
					'tblFieldMap',     		-- Name of the Output FieldMap Table.
					'tblAutoMpgDeep',     	-- Name of the Output Deep Table.
					0);
					
---- Check the wide table and then compare with the original input table
SELECT 	* 
FROM 	tblAutoMpgDeep
LIMIT 10;

--Check if empty
SELECT Count(*)
FROM tblAutoMpgDeep a;

-- Display Map Results
SELECT *
FROM tblFieldMap;              
                    
-- END: POSITIVE TEST(s)
\time
--     END: TEST SCRIPT
