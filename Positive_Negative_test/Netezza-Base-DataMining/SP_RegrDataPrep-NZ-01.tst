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
-- Test Unit Number:    SP_RegrDataPrep-NZ-01

--
-- Name(s):             SP_RegrDataPrep
--
-- Description:         Stored Procedure which transforms a wide table into a deep table.
--
-- Applications:        In DB Lytix, all data mining functions including Logistic Regression are performed using Stored Procedures on a deep table.
--
-- Signature:           SP_RegrDataPrep(IN	AnalysisID		VARCHAR(30),
--									   IN   InWideTables    VARCHAR(100),
--                                     IN   ObsIDCol        VARCHAR(100),
--                                     IN   DepCol          VARCHAR(100),
--                                     IN   OutDeepTable    VARCHAR(100),
--                                     IN   CatToDummy      BYTEINT,
--                                     IN   PerformNorm     BYTEINT,
--                                     IN   PerformVarReduc BYTEINT,
--                                     IN   MakeDataSparse  BYTEINT,
--                                     IN   MinStdDev       DOUBLE PRECISION,
--                                     IN   MaxCorrel       DOUBLE PRECISION,
--                                     IN   Train           BYTEINT,
--                                     IN   ExcludeCols     VARCHAR(1000),
--                                     IN   ClassSpec       VARCHAR(1000))
--
--    Parameters:      See Documentation
--
--    Return value:    VARCHAR(64)
--
--    Last Updated:    01-26-2015
--
--    Author:          <raman.rajasekhar@fuzzyl.com,gandhari.sen@fuzzyl.com>, <Anurag.Reddy@fuzzyl.com>,<kamlesh.meena@fuzzl.com>


-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql

---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------

-- Case 1
---- Validate that the input table exists or not
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg_Notexists',     -- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);               

-- Case 2a
---- Validate that the ObsID column exists    
--TRAIN MODE                   
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID_Notexist',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Case 2b
---- Validate that the ObsID column exists     
--TEST MODE                    
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID_Notexist',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Case 3a
---- Validate that the dependent variable column exists      
--TRAINING MODE                   
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG_Notexist',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
 
 -- Case 3aa
---- Validate whether the dependent variable column can take empty string   
--TRAINING MODE                      
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    '',                      	-- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					); 
                    
 -- Case 3b
---- Validate that the dependent variable column exists  when specified
--TEST MODE                       
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG_Notexist',             -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

                    
 -- Case 3bb
---- Validate whether  the dependent variable Column can be an empty string
--TEST MODE
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    '',                      	-- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);  
--JIRA raised as the program should catch any empty string when the dependednt column is not NULL in Test mode

-- Case 4
---- Validate that error is thrown if deep table already exists
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
---- Run it second time without dropping the deep table
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					); 
-- Case 4a
---- Validate that error is thrown if deep table already exists
--TEST MODE
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
---- Run it second time without dropping the deep table
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Case 5a                  
---- Validate that categorical to dummy flag does not work for anything other than than true or false
--TRAIN Mode
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    falses,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
                    
 -- Case 5  a a                 
---- Validate that categorical to dummy flag does not work for anything other than than t or f
--TEST MODE
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    truee,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					); 
                
-- Case 6a
---- Validate that  perform normalization flag does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    trued,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					); 
                    
-- Case 6b
---- Validate that  perform normalization flag does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    falses,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 7a
---- Validate that perform variable reduction flag does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    f,                      	-- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
-- Case 7b
---- Validate that perform variable reduction variable  flag does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    f,                      	-- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);                     

-- Case 8a
---- Validate that make data sparse flag does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    fal,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
                    
 -- Case 8b
---- Validate that make data sparse variable  variable does not work for anything other than than t or f
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    fals,                      	-- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 9
---- Validate that the acceptable values for min standard deviation cannot be negative
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      	-- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    -0.5,                     	-- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
            
-- Case 10
---- Validate that the acceptable values for maximum acceptable correlation is > 0 and < =1
-- Case 10a: Max acceptable Correl = 0
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      	-- Perform Variable Reduction
                    false,                     	-- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
            
-- Case 10b: Max acceptable Correl < 0
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      	-- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    -0.5,                     	-- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 10c: Max acceptable Correl >1
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      	-- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    1.99,                      	-- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
        
-- Case 11        
---- Validate if invalid values of std deviation and correlation are checked if variable reduction is not required
--Expected result it should  go through
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    -0.1,                          -- Maximum Acceptable correlation
                    0.75,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 11 a     
---- Validate if invalid values of std deviation and correlation are checked if variable reduction is not required
--Expected result it should  go through
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    -0.1,                          -- Minimum acceptable Standard Deviation
                    0.75,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 12                    
---- Validate that training data set flag does not work for anything other than than 0 or 1
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    10,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 13                    
---- Validate if the excluded column exists in the input table
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName_NotExists',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					); 
-- Case 13 a                   
---- Validate if the excluded column exists in the input table
--TEST MODE 
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName_NotExists',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
                
-- Case 14                
---- Validate that error is thrown if all columns in the table including the obsid and dep variable column are excluded
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'ObsID, MPG, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
					
-- Case 14  a              
---- Validate that error is thrown if all columns in the table including the obsid and dep variable column are excluded
--TEST MODE
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'ObsID, MPG, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
                    
-- Case 15 a           
---- Exclude all columns in the table including the obs id but not the dependent variable column
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'ObsID, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
                    
-- Case 15b            
---- Exclude all columns in the table including the obs id but not the dependent variable column
--TEST MODE
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'ObsID, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
                     
-- Case 16 a                   
---- Validate error is thtown if query excludes all columns in the table including the dependent variable column but not the ObsID
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'MPG, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
-- Case 16b          
---- Validate that error is thrown if all columns in the table including the obsid and dep variable column are excluded
--TEST MODE
--when dependent coulm is specified
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'MPG, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);
 -- Case 16c          
---- Validate that error is thrown if all columns in the table excluding the obsid column excluded
--TEST MODE
--when dependent column is NULL
--it should go through
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    NULL,                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'MPG, Cylinders, Displacement, HorsePower, Weight, Acceleration, ModelYear, Origin, CarNum, CarName',                  -- Columns to exclude from conversion
                    NULL                       	-- Class Specification
					);

-- Case 17                
---- Validate error is thrown if where clause excludes all rows
  -- Case 17 a             
---- Validate error is thrown if where clause excludes all rows
--TEST Mode
--NA for NZ

-- Case 18
---- Validate error is thrown, for a categorical variable, and the specified class does not exist
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName(Hummer)',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Case 19
---- Validate that the InAnalysisID parameter is not NULL when Train parameter = 1
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Case 20
---- Validate that the InAnalysisID parameter is valid when Train parameter = 1
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    'F999999'                       -- Class Specification
					);

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

-- Case 1a
---- Call SP_RegrDataPrep with transform categorical variable set to false and the exclude columns clause remove some of the Categorical variables
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
					
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;

-- Check the output table 
SELECT *
FROM tblAutoMpgDeep a
WHERE ObsID  <= 2 
ORDER  BY 1,2;

-- Case 1aa
---- Call SP_RegrDataPrep with transform categorical variable set to false and the exclude columns clause is NULL
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
 
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


-- Check the output table 
SELECT *
FROM tblAutoMpgDeep a
WHERE VarIDCol  = 2 
ORDER  BY 1,2;                   
--JIRA raised TD-FL222  ...Its RFC known issues for this release

-- Case 1b
---- Call SP_RegrDataPrep with transform categorical variable set to false with categorical variable columns eliminated
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    'CarName, CarNum',                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

                    
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


-- Check the output table 
SELECT *
FROM tblAutoMpgDeep a
WHERE ObsID <= 2
ORDER BY 1,2;

-- Case 2
---- Call SP_RegrDataPrep with transform categorical variable set to true, check the contents
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(2)'                       -- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a
WHERE a.AnalysisID = 'FBAI_169552'
;


-- Check the output table 
SELECT *
FROM tblAutoMpgDeep a
WHERE ObsID <= 2
ORDER BY 1,2; 

-- Case 2a
---- Call SP_RegrDataPrep with transform categorical variable set to true, check the contents
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW)'                       -- Class Specification
					);
 
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


---JIRA 237  raised as categorical variable CarNum was eliminated from the final variable list in the deep table  though it was not in the class specifiction clause

-- Case 3
---- Call SP_RegrDataPrep with transform categorical variable set to true and perform normalization set to true, 
---- check the contents and see if categorical variables are normalized (should not be normalized)
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    true,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    2.5,                          -- Minimum acceptable Standard Deviation
                    0.75,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)'                      -- Class Specification
					);
                    
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


SELECT  VaridCol,
        ValueCol 
FROM tblAutoMpgDeep 
WHERE VarIDCol IN (2,3,8,9)
AND ValueCol NOT IN (0.0, 1.0)
ORDER  BY 1;
                    
-- Case 4            
---- Call SP_RegrDataPrep with variable reduction option set to true and standard deviation set to 1 and 
---- correlation SET TO 0.75, CHECK that variables are eliminated according TO the specifications
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    1,                          -- Minimum acceptable Standard Deviation
                    0.75,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);
  
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;
 
 --Check  whether the variables are omitted where StdDev < 1 
  SELECT *
  FROM (                  
		SELECT VaridCol, 
                  FLStdDev(ValueCol) AS StdDevCol
		FROM  tblAutoMpgDeep 
		WHERE Varidcol > 0
		GROUP BY  VaridCol
		) a
  WHERE a.StdDevCol < 1;
 
  --Check  whether the variables are omitted where Correlation > .75
 SELECT  * 
 FROM 	(
		SELECT 	a.VaridCol AS VarID1,
                b.VarIdCol AS VarID2,
                FLCorrel(a.ValueCol, b.ValueCol) AS Correl 
		FROM  	tblAutoMpgDeep a,
                tblAutoMpgDeep b
		WHERE 	a.Varidcol   > 0
		AND    	b.VarIDCol  > 0
		AND   	a.ObsID = b.ObsID
		GROUP BY	a.VaridCol, b.VarIdCol
		) AS x
 WHERE x.Correl > 0.75 
 AND VarID1 > VarID2 ;

-- Case 5
---- Call SP_RegrDataPrep with a class specification and ensure that no dummy variable is created for the
---- specified class value
---case when dummy variable is created
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)'                       -- Class Specification
					);
                    
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
	(SELECT a.ANALYSISID
	 FROM fzzlRegrDataPrepInfo a
	 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
	 ORDER BY a.RUNSTARTTIME DESC
	 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


---Case 5a
---Same dataset with CatToDummy  is set to false and Class specification specified
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)'                       -- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


SELECT * 
FROM tblAutoMpgDeep
WHERE VarIDCol IN (2,3)
ORDER BY 2,1;

---Case 5b
---Same dataset with CatToDummy  is set to false and Class specification Is NULL
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    false,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    NULL                       -- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


SELECT * 
FROM tblAutoMpgDeep
WHERE VarIDCol IN (2,3)
ORDER BY 2,1;                  
                                 
---- The following case requires for the user to manually insert the AnalysisID from the first run into the next                    
-- Case 6
---- Call SP_RegrDataPrep and generate an Analysis ID and transform another dataset using that analysis id
---- First run of Regrdata prep
SELECT *
FROM tblAutoMpg
LIMIT 10;

DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)'                       -- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


---- Create a testing table  with a structure with one less column than the original table.
DROP TABLE tblAutoMPGTest;
CREATE TABLE tblAutoMPGTest
     (
      ObsID BIGINT,
      MPG FLOAT,
      Cylinders BIGINT,
      Displacement FLOAT,
      HorsePower FLOAT,
      Weight FLOAT,
      Acceleration FLOAT,
      ModelYear BIGINT,
      Origin BIGINT,
      CarName VARCHAR(500)) --CHARACTER SET LATIN NOT CASESPECIFIC)
DISTRIBUTE ON( ObsID );        

---- Insert data into the testing table
DELETE FROM tblAutoMPGTest;
INSERT INTO tblAutoMPGTest
SELECT ObsID,
       MPG,
       Cylinders,
       Displacement,
       HorsePower,
       Weight,
       Acceleration,
       ModelYear,
       Origin,
       CarName
FROM tblAutoMPG a
WHERE a.ObsID <=100;

---- Specify a new AnalysisID  for a new run of the SP_RegrDataPrep from training mode 
DROP TABLE tblAutoMpgDeepTest;
CALL SP_RegrDataPrep('TestNewID',						-- Provided in case of a re-run, else NULL
					'tblAutoMpgTest',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    true,                      -- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  -- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)'                       -- Class Specification
					);

--- Display Mapping Results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 2) AS b
WHERE a.AnalysisID IN b.AnalysisID
ORDER BY Final_VarID, VarID,a.AnalysisID; 
                 
--Case 6 a...Create another table with more columns thatn the train set and use the test mode using the AnalysisID of the train set and see how it acts.
---- Create a testing table  with a structure with one less column than the original table.
DROP TABLE tblAutoMpgDeep;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					); 

DROP TABLE tblAutoMPGTest;
CREATE TABLE tblAutoMPGTest
     (
      ObsID BIGINT,
      MPG FLOAT,
      Cylinders BIGINT,
      Displacement FLOAT,
      HorsePower FLOAT,
      Weight FLOAT,
      Acceleration FLOAT,
      ModelYear BIGINT,
      Origin BIGINT,
      CarName VARCHAR(500), --CHARACTER SET LATIN NOT CASESPECIFIC,
      CarNum VARCHAR(10), --CHARACTER SET LATIN NOT CASESPECIFIC,
      CarType VARCHAR(100), --CHARACTER SET LATIN NOT CASESPECIFIC,
      ZoneDist BIGINT)
DISTRIBUTE ON( ObsID );        

---- Insert data into the testing table
DELETE FROM tblAutoMPGTest;
INSERT INTO tblAutoMPGTest
SELECT ObsID,
       MPG,
       Cylinders,
       Displacement,
       HorsePower,
       Weight,
       Acceleration,
       ModelYear,
       Origin,
       CarName,
       CarNum,
       '',
       0
FROM tblAutoMPG a
WHERE a.ObsID <=100;


---- Use the AnalysisID from the previous run of the SP_RegrDataPrep
DROP TABLE tblAutoMpgDeepTest;
CALL SP_RegrDataPrep('TestNewID2',						-- Provided in case of a re-run, else NULL
					'tblAutoMpgTest',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);
					
--- Display Mapping Results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 2) AS b
WHERE a.AnalysisID IN b.AnalysisID
ORDER BY Final_VarID, VarID,a.AnalysisID;   

--Case 7 
---Check whether Normalization takes place in Test Mode.
DROP TABLE tblAutoMpgDeepTrain;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTrain',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    true,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);

DELETE FROM fzzlRegrDataPrepMap
WHERE AnalysisID ='APulRDP';

UPDATE fzzlRegrDataPrepMap
FROM   
        (
        SELECT  a.AnalysisID
        FROM    fzzlRegrDataPrepInfo a
	    WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        )  AS p
SET AnalysisID = 'APulRDP'
WHERE fzzlRegrDataPrepMap.AnalysisID = p.AnalysisID;

DROP TABLE tblAutoMpgDeepTest;
--Enforce 'WHERE OBSID <=100',-- Where clause?
CALL SP_RegrDataPrep('APulRDP',						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    true,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);

 SELECT * 
 FROM fzzlRegrDataPrepMap 
 WHERE AnalysisId ='APulRDP'
 ORDER BY Final_VarID, VarID;    
               
--compare the outputs of the two table  to see if Normalization was done in test mode               
--Train Data 
SELECT  VaridCol AS VarID1 , 
                   FLStdDev(ValueCol) AS StdDev1
FROM      tblAutoMpgDeepTrain 
WHERE VarID1 IN ( 1, 15,16,19)
GROUP BY VaridCol 
ORDER BY 1;
--compare with Std Dev from the input wide table
SELECT   FLStdDev(x1),
                 FLStdDev(x2),
                 FLStdDev(x3),
                 FLStdDev(x4)
FROM   (
					SELECT   (b.Displacement - a.MeanDisplacement)/a.StdDevDisplacement AS x1,
					                 (b.HorsePower - a.MeanHorsePower)/a.StdDevHorsePower AS x2,
					                 (b.Weight - a.MeanWeight)/a.StdDevWeight AS x3,
					                 (b.Acceleration - a.MeanAcceleration)/a.StdDevAcceleration AS x4
					FROM (
										SELECT  FLMean(Displacement) AS MeanDisplacement,
										                FLMean(HorsePower) AS MeanHorsePower,
										                FLMean(Weight) AS MeanWeight,
										                FLMean(Acceleration) AS MeanAcceleration,
										                 FLStdDev(Displacement) AS StdDevDisplacement,
										                 FLStdDev(HorsePower) AS StdDevHorsePower,
										                 FLStdDev(Weight) AS StdDevWeight,
										                 FLStdDev(Acceleration)  AS StdDevAcceleration
										 from tblAutoMpg
			 					 ) AS a,
            					  tblAutoMpg AS b
 		   ) AS a
Order by 1,2,3,4;
 
--Check the StdDev from the test mode       
SELECT VaridCol AS VarID2, 
                  FLStdDev(ValueCol) AS StdDev2
 FROM    tblAutoMpgDeepTest
 WHERE VarID2 IN ( 1, 15,16,19)
 GROUP BY VaridCol 
ORDER BY 1;

--Compare with that from the dataset used for Test Mode
SELECT   FLStdDev(x1),
                 FLStdDev(x2),
                 FLStdDev(x3),
                 FLStdDev(x4)
FROM   (
					SELECT   (b.Displacement - a.MeanDisplacement)/a.StdDevDisplacement AS x1,
					                 (b.HorsePower - a.MeanHorsePower)/a.StdDevHorsePower AS x2,
					                 (b.Weight - a.MeanWeight)/a.StdDevWeight AS x3,
					                 (b.Acceleration - a.MeanAcceleration)/a.StdDevAcceleration AS x4
					FROM (
										SELECT  FLMean(Displacement) AS MeanDisplacement,
										                FLMean(HorsePower) AS MeanHorsePower,
										                FLMean(Weight) AS MeanWeight,
										                FLMean(Acceleration) AS MeanAcceleration,
										                 FLStdDev(Displacement) AS StdDevDisplacement,
										                 FLStdDev(HorsePower) AS StdDevHorsePower,
										                 FLStdDev(Weight) AS StdDevWeight,
										                 FLStdDev(Acceleration)  AS StdDevAcceleration
										 from tblAutoMpg
			 					 ) AS a,
            					  tblAutoMpg AS b
 					WHERE b.ObsID <=100
 		   ) AS a
 		   ORDER BY 1,2,3,4;
 
 -- Case 8
---- Call SP_RegrDataPrep with Make sparse  set to true, check the contents
--FOR Train Mode
DROP TABLE tblAutoMpgDeepTrain;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTrain',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    true,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);

-- CheckOutput Table value col
SELECT *
FROM tblAutoMpgDeepTrain  
WHERE  VaridCol > 0
AND ValueCol = 0
order by 2,1; 

DELETE 
FROM fzzlRegrDataPrepMap
WHERE AnalysisID ='APulRDP';

UPDATE fzzlRegrDataPrepMap
FROM   
        (
        SELECT  a.AnalysisID
        FROM    fzzlRegrDataPrepInfo a
	    WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        )  AS p
SET AnalysisID = 'APulRDP'
WHERE fzzlRegrDataPrepMap.AnalysisID = p.AnalysisID;

 -- Case 8a
---- Call SP_RegrDataPrep with Make sparse  set to true, check the contents
--FOR TestMode
DROP TABLE tblAutoMpgDeepTest;
--Enforce 'WHERE ObsID <=100',-- Where clause
CALL SP_RegrDataPrep('APulRDP',						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    NULL,                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    true,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);
    
-- CheckOutput Table value col
SELECT *
FROM tblAutoMpgDeepTest
WHERE  VaridCol > 0
AND ValueCol = 0
order by 2,1; 

SELECT * 
FROM fzzlRegrDataPrepMap 
WHERE AnalysisId ='APulRDP'
ORDER BY Final_VarID, VarID;  
 
 
-- Case 9
---- Call SP_RegrDataPrep where Categorical variable is used as a dependent column
--FOR Train Mode
DROP TABLE tblAutoMpgDeepTrain;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'CarNum',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTrain',           -- Name of the Output Deep Table
                    false,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);       

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;

-- CheckOutput Table value col
SELECT *
FROM tblAutoMpgDeepTrain  a
WHERE  VaridCol = -1
ORDER BY 2,1 ;

DELETE 
FROM fzzlRegrDataPrepMap
WHERE AnalysisID ='APulRDP';

UPDATE fzzlRegrDataPrepMap
FROM   
        (
        SELECT  a.AnalysisID
        FROM    fzzlRegrDataPrepInfo a
	    WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
        ORDER BY a.RunStartTime DESC
		LIMIT 1
        )  AS p
SET AnalysisID = 'APulRDP'
WHERE fzzlRegrDataPrepMap.AnalysisID = p.AnalysisID;

-- Case 9a
---- Call SP_RegrDataPrep where Categorical variable is used as a dependent column with testing mode
--FOR TestMode
DROP TABLE tblAutoMpgDeepTest;
CALL SP_RegrDataPrep('APulRDP',						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'CarNum',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    false,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    1,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);

-- CheckOutput Table value col
SELECT *
FROM tblAutoMpgDeepTest  a
WHERE  VaridCol = -1
ORDER BY 2,1 ;

SELECT * 
FROM fzzlRegrDataPrepMap 
WHERE AnalysisId ='APulRDP'
ORDER BY Final_VarID, VarID; 

DELETE 
FROM fzzlRegrDataPrepMap
WHERE AnalysisID ='APulRDP';

---- JIRA has been raised TDFL-236

--Case 10a...Check when  Normalization = 1 and StdDev = 0 for some variables
---Create another table with one column that has same values   and see how it acts.
DROP TABLE tblAutoMPGTest;
CREATE TABLE tblAutoMPGTest
     (
      ObsID BIGINT,
      MPG FLOAT,
      Cylinders BIGINT,
      Displacement FLOAT,
      HorsePower FLOAT,
      Weight FLOAT,
      Acceleration FLOAT,
      ModelYear BIGINT,
      Origin BIGINT,
      CarName VARCHAR(500), --CHARACTER SET LATIN NOT CASESPECIFIC,
      CarNum VARCHAR(10), --CHARACTER SET LATIN NOT CASESPECIFIC,
      ZoneDist DOUBLE PRECISION)
DISTRIBUTE ON( ObsID );        

---- Insert data into the testing table
DELETE FROM tblAutoMPGTest;
INSERT INTO tblAutoMPGTest
SELECT ObsID,
       MPG,
       Cylinders,
       Displacement,
       HorsePower,
       Weight,
       Acceleration,
       ModelYear,
       Origin,
       CarName,
       CarNum,
       2.5
FROM tblAutoMPG a
WHERE a.ObsID <=100;
 
 ---- Run RegrdataPrep
DROP TABLE tblAutoMpgDeepTest;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpgTest',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeepTest',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    true,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);
-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;    
 
SELECT * 
FROM tblAutoMpgDeepTest 
WHERE VarIdCol = 20
ORDER BY 2,1;
 
 -- Case 11
---- Call SP_RegrDataPrep with transform categorical flag  set to true, and data set includes data of the class specification variable
DROP TABLE tblAutoMpgDeep;
--Enforce 'WHERE CarName = ' ||''''|| 'BMW' ||'''',-- Where clause
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblAutoMpg',     			-- Input wide table
                    'ObsID',                    -- Name of the observation id Column
                    'MPG',                      -- Name of the dependent variable
                    'tblAutoMpgDeep',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    false,                      -- Make data Sparse
                    0,                          -- Minimum acceptable Standard Deviation
                    0,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'CarName(BMW),CarNum(1)' 	-- Class Specification
					);          

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1
				 ) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;

-- Case 12 a
---- Call SP_RegrDataPrep with DepCol = 0, Perform Variable Reduction = 1 
DROP TABLE tblLoanData_TRAIN_DEEP;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblLoanData',     			-- Input wide table
                    'LoanID',                    -- Name of the observation id Column
                    'Default_Ind',                      -- Name of the dependent variable
                    'tblLoanData' || '_TRAIN_DEEP',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    true,                      -- Perform Variable Reduction
                    true,                      -- Make data Sparse
                    1.0E-001,                          -- Minimum acceptable Standard Deviation
                    7.5E-001,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'term(36 months), grade(A),home_ownership(RENT),is_inc_v(TRUE),purpose(debt_consolidation)' 	-- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 1) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


-- Case 12 b
---- Call SP_RegrDataPrep with DepCol = 0, Perform Variable Reduction = 0
DROP TABLE tblLoanData_TRAIN_DEEP;
CALL SP_RegrDataPrep(NULL,						-- Provided in case of a re-run, else NULL
					'tblLoanData',     			-- Input wide table
                    'LoanID',                    -- Name of the observation id Column
                    'Default_Ind',                      -- Name of the dependent variable
                    'tblLoanData' || '_TRAIN_DEEP',           -- Name of the Output Deep Table
                    true,                      	-- Transform Categorical to Dummy (t/f)
                    false,                      -- Perform Normalization
                    false,                      -- Perform Variable Reduction
                    true,                      -- Make data Sparse
                    1.0E-001,                          -- Minimum acceptable Standard Deviation
                    7.5E-001,                          -- Maximum Acceptable correlation
                    0,                          -- 0=>Training dataset, 1=>Test dataset
                    NULL,                  		-- Columns to exclude from conversion
                    'term(36 months), grade(A),home_ownership(RENT),is_inc_v(TRUE),purpose(debt_consolidation)' 	-- Class Specification
					);

-- Display Map results                   
SELECT a.*
FROM fzzlRegrDataPrepMap a,
				(SELECT a.ANALYSISID
				 FROM fzzlRegrDataPrepInfo a
				 WHERE a.DATAPREPFNNAME = 'SP_RegrDataPrep'
				 ORDER BY a.RUNSTARTTIME DESC
				 LIMIT 10) AS b
WHERE a.AnalysisID = b.AnalysisID
ORDER BY Final_VarID;


-- END: POSITIVE TEST(s)
DROP TABLE tblAutoMpgDeep;
\time
--     END: TEST SCRIPT
