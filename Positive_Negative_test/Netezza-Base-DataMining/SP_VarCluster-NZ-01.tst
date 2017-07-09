-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2015 Fuzzy Logix, LLC
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
-- 	Test Category:		Data Mining Functions
--
--	Test Unit Number:	FLAggClustering-TD-01
--
--	Name(s):		FLAggClustering
--
-- 	Description:  Uses a principal component analysis for dimensionality reduction in order to cluster a given set of input variables into a smaller representative set.
--                The number of output clusters depend on the contribution level specified.
--	Applications:	    	
-- 	Signature:		SP_VarCluster(IN  TableName    VARCHAR(256),
--                               IN  MatrixType   VARCHAR(10),
--                               IN  Contrib      DOUBLE PRECISION,
--                               IN  TableOutput  BYTEINT,
--                               OUT ResultTable  VARCHAR(256)
--
--	Parameters:		See Documentation
--
--	Return value:	    	 VARCHAR(256)
--
--	Last Updated:	    	04-02-2014
--
--	Author:			<gandhari.sen@fuzzyl.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

---- Drop and recreate the test table
DROP TABLE tblVarClusterTest;

CREATE TABLE tblVarClusterTest (
ObsID       BIGINT,
VarID       INTEGER,
Num_Val      DOUBLE PRECISION)
DISTRIBUTE ON (ObsID);

---- BEGIN: NEGATIVE TEST(s)

--	Case 1a:
---- Incorrect table name
CALL SP_VarCluster('tblVarClusterTestNotExist','COVAR', 0.75, 'OutPutTable');
CALL SP_VarCluster(NULL,'COVAR', 0.75, 'OutPutTable');
CALL SP_VarCluster('','COVAR', 0.75, 'OutPutTable');

-- Result: Fuzzy Logix specific error message

--	Case1b :
---- No data in table
CALL SP_VarCluster('tblVarClusterTest',  'COVAR', 0.75, 'OutPutTable');
--goes through and returns empty set

--Populate the table
INSERT INTO  tblVarClusterTest
SELECT * FROM tblLogRegr;

--	Case 2:

CALL SP_VarCluster('tblVarClusterTest','CLOVAR', 0.75, 'OutPutTable');

--Case 3 
CALL SP_VarCluster('tblVarClusterTest','COVAR', -10.75, 'OutPutTable');
CALL SP_VarCluster('tblVarClusterTest','COVAR', 1.75, 'OutPutTable');

---Case 4
CALL SP_VarCluster('tblVarClusterTest','COVAR', 0.9, '');
CALL SP_VarCluster('tblVarClusterTest','COVAR', 0.9, NULL);

DROP TABLE OutPutTable;

---- END: NEGATIVE TEST(s)

---- BEGIN: POSITIVE TEST(s)

--	Case a:
DELETE FROM tblVarClusterTest;

INSERT INTO tblVarClusterTest
SELECT * FROM  tblLinRegr 
WHERE VarID > 0;

---- Perform Clustering with non-sparse data and small number of VarIDs
CALL SP_VarCluster('tblVarClusterTest',  'COVAR', 0.75, 'ResultTable');
-- Result: standard outputs
Drop table ResultTable;

DELETE FROM tblVarClusterTest;

INSERT INTO tblVarClusterTest
SELECT * FROM  tblLinRegr 
WHERE VarID > 0 AND NUM_VAL>0;


---- Perform Clustering with non-sparse data and small number of VarIDs
CALL SP_VarCluster('tblVarClusterTest',  'COVAR', 0.75, 'ResultTable');
-- Result: standard outputs
Drop table ResultTable;

---- Perform Clustering with sparse data 
CALL FLVarCluster('tbllogregr',  'CORREL', 0.75,  'ResultTable');
-- Result: standard outputs
Drop table ResultTable;





----DROP the test table
DROP TABLE tblVarClusterTest; 



-- END: POSITIIVE TEST(s)

-- 	END: TEST SCRIPT
