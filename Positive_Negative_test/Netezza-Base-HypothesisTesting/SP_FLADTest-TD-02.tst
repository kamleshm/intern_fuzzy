-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
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
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLADTest-TD-02
--
--	Name(s):		FLADTest
--
-- 	Description:	    	FLADTest performs Anderson Darling Test. Anderson Darling Test is 
--				used to test if a given sample of data is drawn from a specified 
--				normal distribution.
--	Applications:	    	
--
-- 	Signature:		FLADTest(IN TableName VARCHAR(256), IN ValCol VARCHAR(31),
--				IN Mean DOUBLE PRECISION, IN StdDev DOUBLE PRECISION,
--				IN WhereClause VARCHAR(200), IN GroupBy VARCHAR(200),
--				IN TableOutput BYTEINT, OUT OutTable VARCHAR(256))
--
--	Parameters:		See Documentation
--
--	Return value:	    	Table
--
--	Last Updated:	    	03-24-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>
--

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

-- Input table
SELECT  a.DataSetID, a.DistType, COUNT(*)
FROM    fuzzy.tblADTest a
GROUP BY a.DataSetID, a.DistType
ORDER BY 1;

-- BEGIN: NEGATIVE TEST(s)
--case 1
-- N: Modify Case 1 to use non-existing table in TableName argument
CALL FLADTest('fuzzy.Dummy', 'Num_Val', 1, 10, NULL, 'DataSetID', 0, ResultTable);

--case 1 b
-- N: Modify Case 1 to use non-existing databasename in TableName argument
CALL FLADTest('Dummy.tblADTest', 'Num_Val', 1, 10, NULL, 'DataSetID', 0, ResultTable);

-- Result: Fuzzy Logix specific error message

--Case 2
-- N: Modify Case 1 to use non-existing column in ValueCol argument
CALL FLADTest('fuzzy.tblADTest', 'Dummy', 1, 10, NULL, 'DataSetID', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

--Case 3
-- N: Modify Case 1 to use varchar in Mean argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 'String', 10, '', 'DATASETID', 0,ResultTable);
--- Result: Teradata generic error message

--Case 4
-- N: Modify Case 1 to use varchar in StdDev argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 'String', '', 'DATASETID', 0,ResultTable);
-- Result: Teradata generic error message

--Case 5
-- N: Modify Case 1 to use non-existing column in GroupBy argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, NULL, 'Dummy', 0, ResultTable);
-- Result: Fuzzy Logix specific error message

--Case 6
-- N: Modify Case 1 to use 2 in TableOutput argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, '', 'DATASETID', -1 ,ResultTable);
-- Result: Fuzzy Logix specific error message

--Case 7
-- N: Modify Case 1 to user very large numbers
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1e10, 1e10, '', 'DATASETID', 0,ResultTable);
-- Result: standard outputs

-- END: NEGATIVE TEST(s)

-- BEGIN: POSITIVE TEST(s)

-- Test with normal and extreme scale factor values

--Case 8
-- P: Follow Case 1 in user manual
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, '', 'DATASETID', 0,ResultTable);
-- Result: standard outputs

--Case 9
-- P: Follow Case 2 in user manual
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', NULL, 10, '', 'DATASETID', 0, ResultTable);
-- Result: standard outputs

--Case 10
-- P: Follow Case 3 in user manual
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, NULL, '', 'DATASETID', 0, ResultTable);
-- Result: standard outputs

--Case 11
-- P: Follow Case 4 in user manual
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', NULL, NULL, '', 'DATASETID', 0, ResultTable);
-- Result: standard outputs

--Case 12
-- P: Modify Case 1 to add DistType in GroupBy argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, 
              NULL, 'DataSetID, DistType', 0, ResultTable);
-- Result: standard outputs

--Case 13a
-- P: Modify Case 1 to use filter in WhereClause argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, 
              'WHERE ObsID < 1000', 'DATASETID', 0,ResultTable);
--Case 13b
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, 
              'WHERE DataSetID = 1', 'DATASETID', 0,ResultTable);
-- Result: standard outputs

--Case 14
-- P: Modify Case 1 to use 1 in TableOutput argument
CALL FLADTest('fuzzy.tblADTest', 'Num_Val', 1, 10, '', 'DATASETID', 1,ResultTable);

SELECT  * 
FROM    A971603_ADTest
ORDER BY 1;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT
