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
-- 	Test Category:		Data Mining Functions
--
--	Test Unit Number:	FLMixedModelUdt-TD-01
--
--	Name(s):		    FLMixedModelUdt
--
-- 	Description:	    User Defined Table Function which performs Linear Regression.
--
--	Applications:	    	
--
-- 	Signature:		    FLMixedModelUdt(pGroupID        BIGINT,  
--                pDepVar         DOUBLE PRECISION, 
 --               pFixVar         BIGINT, 
 --               pRanVar         BIGINT, 
  --              pInterceptExist BYTEINT) 
                                 
--
--	Parameters:		    See Documentation
--
--	RETURNS TABLE (GroupID        BIGINT, 
--               CoeffID        BIGINT, 
--               CoeffName      VARCHAR(10), 
 --              CoeffEst       DOUBLE PRECISION, 
--               StdErr         DOUBLE PRECISION, 
--               TStat          DOUBLE PRECISION, 
--               pValue         DOUBLE PRECISION, 
 --              CovRandom      DOUBLE PRECISION, 
  --             CovErr         DOUBLE PRECISION, 
  --             LogLikeliHood  DOUBLE PRECISION, 
   --            AIC            DOUBLE PRECISION)  
--
--	Last Updated:	   	20-12-2014
--
--	Author:			    <gandhari.sen@fuzzyl.com>

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql


---- Drop and recreate the test table
DROP TABLE tblMixedModelTest;

CREATE TABLE tblMixedModelTest AS 
(
SELECT	*
FROM	tblMixedModel a
) WITH DATA;


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------
---- Perform Linear Regression with backward subsitution


---Case 1  Run with GroupID parameter as NULL
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(NULL, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 2  Run with DepVar parameter as NULL
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            NULL, 
                            z.xVal, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 3  Run with FixedVarparameter as NULL
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            NULL, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 4  Run with Random effect Var parameter as NULL
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            NULL,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 5  Run with Intercept Indicator parameter as NULL
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            NULL)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 6: Run with Fixed Effect Variable parameter as negative or zero
---Case 6a: With pFixVar = 0

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            0, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---Case 6b: With pFixVar < 0

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            -1, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;



---Case 7---Case 6: Run with Random Effect Variable parameter as negative or zero
---Case 7a: With pRanVar = 0

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            0,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;



---Case 6b: With pRanVar < 0

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            -2,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;

--Case 8 Run with values other than 1 or 0 for Intercept Indicator
WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            5)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;

---Case 9  Run with an empty input table
---No rows returned..expected result
DELETE FROM tblMixedModelTest;

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModelTest a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;

-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

---- Case 1: Manual example

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---- Case 2: No intercept

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModel a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            0)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;


---- Case 3: Run with non-consecutive FixVars
DELETE FROM tblMixedModelTest;

INSERT INTO TblMixedModelTest
SELECT a.ObsID,
       a.yVal,
	   a.FixVal *2,
	   a.RanVal
FROM tblMixedModel a;	   

WITH z(GroupID, ObsID, yVal, xVal, zVal) AS
(
SELECT 1 AS GroupID, a.*
FROM   tblMixedModelTest a
)
SELECT a.*
FROM TABLE (FLMixedModelUdt(z.GroupID, 
                            z.yVal, 
                            z.xVal, 
                            z.zVal,
                            1)
HASH BY z.GroupID
LOCAL ORDER BY z.GroupID) AS a
ORDER BY 1,2;

-- END: POSITIVE TEST(s)
---- Drop the test table
DROP TABLE tblMixedModelTest;
-- 	END: TEST SCRIPT



