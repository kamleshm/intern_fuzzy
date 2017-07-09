-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2017 Fuzzy Logix, LLC
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
-- 	Test Category:		Machine Learning Functions
--
--	Test Unit Number:	FLLogRegrUdt-NZ-01
--
--	Name(s):		    FLLogRegrUdt
--
-- 	Description:	    User Defined Table Function which performs Logistic Regression.
--
--	Applications:	    	
--
-- 	Signature:		    FLLogRegrUdt(pGroupID         	BIGINT, 
--                                     pObsID           BIGINT,
--                                     pVarID           BIGINT,
--                                     pValue           DOUBLE PRECISION,
--                                     pReduceVars      BIGINT, 
--                                     pThresholdStdDev DOUBLE PRECISION,
--                                     pThresholdCorrel DOUBLE PRECISION)
--
--	Parameters:		    See Documentation
--
--	Returns table:      (GroupID      BIGINT, 
--                       CoeffID      BIGINT,
--                       InOrOut      VARCHAR(5),
--                       OutReason    VARCHAR(30), 
--                       RegrStep     BIGINT,
--                       CoeffEst     DOUBLE PRECISION,
--                       StdErr       DOUBLE PRECISION, 
--                       TStat        DOUBLE PRECISION,
--                       P_Value      DOUBLE PRECISION)VARCHAR(64)
--
--	Last Updated:	   	05-08-2017
--
--	Author:			    <sam.sharma@fuzzylogix.com>

-- BEGIN: TEST SCRIPT

-- .run file=../PulsarLogOn.sql

------ Table used for regression
SELECT	 DatasetID,
		 VarID,
		 COUNT(*)
FROM	 TBLLOGREGRMULTI
GROUP BY 1,2
ORDER BY 1,2;


---- Drop and recreate the test table
DROP TABLE tblLogRegrDataDeepTest;

CREATE TEMP TABLE tblLogRegrDataDeepTest AS 
(
SELECT	 *
FROM	 TBLLOGREGRMULTI
) ;

---- Drop and recreate a table with singular X'X 
-- DROP TABLE tblLogRegrUdtNegTest;

-- CREATE TABLE tblLogRegrUdtNegTest AS 
-- (
-- SELECT  *
-- FROM  tblLogRegrDataNegTest a
-- ) ;


---- BEGIN: NEGATIVE TEST(s)

---------------------------------------------------------------------------------------
---------------------- Negative test cases --------------------------------------------
---------------------------------------------------------------------------------------
---- Perform Linear Regression with backward subsitution


---Case 1  Run with GroupID parameter as NULL
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(NULL,
		z.ObsID,
		z.VarID,
		z.Value,
		1,
		0.05,
		0.95,
		25,
		0.10,
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 2  Run with ObsID parameter as NULL
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		NULL,
		z.VarID,
		z.Value,
		1,
		0.05,
		0.95,
		25,
		0.10,
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 3  Run with VarID parameter as NULL
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		NULL,
		z.Value,
		1,
		0.05,
		0.95,
		25,
		0.10,
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 4  Run with Num_Val parameter as NULL
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		NULL,
		1,
		0.05,
		0.95,
		25,
		0.10,
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 5  Run with Eliminate variables parameter as NULL
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		NULL,									---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;



---Case 6: Run with Min acceptable StdDev parameter as NULL
---Case 6a: With Eliminate Variable = 0

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		NULL,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 6b: With Eliminate Variable = 1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		NULL,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;



---Case 7  Run with Max acceptable correlation parameter as NULL
---Case 7a: With Eliminate Variable = 0

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		NULL,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 7b:  With Eliminate Variable = 1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		NULL,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 8:  Run with Max iterations parameter as NULL

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		NULL,									---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 9:  Run with Max P-Value threshold parameter as NULL

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		NULL,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 10: Run with Begin/End flag parameters as NULL
---Case 10a: Setting Begin flag as NULL.
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		NULL,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;

---Case 10b : Setting Begin flag as NULL.
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		NULL)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 11  Run with an empty input table
TRUNCATE TABLE tblLogRegrDataDeepTest;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- Case 12 Input table does not have a Dependent variable 
-- JIRA TDFL-536 created
---It should return an error message : "dependent variable (varid = -1) is requrired" now
TRUNCATE TABLE tblLogRegrDataDeepTest;

-- Insert data without the dependent variable
INSERT INTO tblLogRegrDataDeepTest
SELECT	 a.DatasetID,
		 a.ObsId,
		 a.VarID,
		 a.Value
FROM	 TBLLOGREGRMULTI a
WHERE	 a.VarID <> -1;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- Case 13  Number of ObsIDs for dependent variable is less than that of the independent variables
-- Refer ro the constraints section of the documentaion of the function for explanation
-- Insert dependent variable with one less observation than the other variables
TRUNCATE TABLE tblLogRegrDataDeepTest;

-- Insert data with less obs for dependent variable.
INSERT INTO tblLogRegrDataDeepTest
SELECT	 a.DatasetID,
		 a.ObsId - 1,
		 a.VarID,
		 a.Value
FROM	 TBLLOGREGRMULTI a
WHERE 	a.VarID = -1
AND 	a.ObsID >= 2;

INSERT INTO tblLogRegrDataDeepTest
SELECT	 a.DatasetID,
		 a.ObsId,
		 a.VarID,
		 a.Value
FROM	 TBLLOGREGRMULTI a
WHERE	 a.VarID <> -1;


-- Check if the dependent variable has one less observation
SELECT DatasetID,
		VarID,
		COUNT(ObsID)
FROM 	tblLogRegrDataDeepTest
GROUP BY 1,2
ORDER BY 1,2;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- Case 14  Number of ObsIDs for dependent variable is less than the independent variables
-- Insert  num observations  <  than the max VarID
--should return an error meessage now :Number of observations cannot be less than independent variables"
TRUNCATE TABLE tblLogRegrDataDeepTest;

INSERT INTO tblLogRegrDataDeepTest 
SELECT	*
FROM 	TBLLOGREGRMULTI a
WHERE 	a.ObsID < 4;


-- Check if the observations are less than  independent variables. 
SELECT DatasetID,
		VarID,
		COUNT(ObsID)
FROM 	tblLogRegrDataDeepTest
GROUP BY 1,2
ORDER BY 1,2;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- Case 15 Input table does has only Dependent variables  and independent variables
-- JIRA TDFL-539 created: Case commented out as it hangs Gandalf
--should return  Error message : "Intercept variable (varid  = 0 ) is requrired"
TRUNCATE TABLE tblLogRegrDataDeepTest;

-- Insert data without the intercept.
INSERT INTO tblLogRegrDataDeepTest
SELECT	 a.DatasetID,
		 a.ObsId,
		 a.VarID,
		 a.Value
FROM	 TBLLOGREGRMULTI a
WHERE	 a.VarID <> 0;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 16: Validate that Eliminate variables parameter only accepts 1 or 0
TRUNCATE TABLE tblLogRegrDataDeepTest;

INSERT INTO tblLogRegrDataDeepTest 
SELECT	*
FROM 	TBLLOGREGRMULTI a;

---Case 17a Check if Eliminate variables parameter is < 0
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		-3,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 17b: Check if Eliminate variables parameter is > 1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM tblLogRegrDataDeepTest a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		5,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.05,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


----Case 18: If Eliminate variables parameter is 0 the values of std dev and corr variables should not matter
-- Case 18a: StdDev is out of boundary
---it should go through
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		-0.5,									---- Minimum acceptable std dev
		0.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 18b: Correl parameter is out of boundary
-- it should go through
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.1,									---- Minimum acceptable std dev
		-1.95,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 19: Min StdDev parameter cannot be negative
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		-0.5,									---- Minimum acceptable std dev
		0,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 20: Max Acceptatble correlation is should be between -1 and 1
-- Case 20a: Correl param = -1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0,										---- Minimum acceptable std dev
		-1,										---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- Case 20b: Correl param < -1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0,										---- Minimum acceptable std dev
		-1.01,									---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 20c: Correl param = 1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0,										---- Minimum acceptable std dev
		1,										---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


---Case 20d: Correl param > 1
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0,										---- Minimum acceptable std dev
		1.5,										---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;



-- END: NEGATIVE TEST(s)

--BEGIN: POSITIVE TEST(s)
---------------------------------------------------------------------------------------
---------------------- Positive test cases --------------------------------------------
---------------------------------------------------------------------------------------

---- Case 1: Run without variable elimination and make sure that the std dev and correl parameters have no effect
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,										---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.6,										---- Minimum acceptable std dev
		0.5,										---- Maximum acceptable correlation
		25,										---- Maximum iterations
		0.10,									---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;



---- Case 2: Run with variable elimination, StdDev and Correl
SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		1,											---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.6,										---- Minimum acceptable std dev
		0.5,										---- Maximum acceptable correlation
		25,											---- Maximum iterations
		0.10,										---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;



-- Case 3 Input table does has only Dependent variables  and intercept
TRUNCATE TABLE tblLogRegrDataDeepTest;

-- Insert data without the independent variables.
INSERT INTO tblLogRegrDataDeepTest
SELECT	 a.DatasetID,
		 a.ObsId,
		 a.VarID,
		 a.Value
FROM	 TBLLOGREGRMULTI a
WHERE	 a.VarID < 1;

SELECT DatasetID,
		VarID,
		COUNT(ObsID)
FROM 	tblLogRegrDataDeepTest
GROUP BY 1,2
ORDER BY 1,2;

SELECT f.*
FROM(
	SELECT a.DatasetID,
			a.ObsID,
			a.VarID,
			a.Value,
			NVL(LAG(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS begin_flag,
			NVL(LEAD(0) OVER (PARTITION BY a.DatasetID ORDER BY a.ObsID), 1)
			AS end_flag
	FROM TBLLOGREGRMULTI a
) AS z,
TABLE(FLLogRegrUDT(z.DatasetID,
		z.ObsID,
		z.VarID,
		z.Value,
		0,											---- Eliminate variables based on std dev and correlation 0: No, 1: Yes
		0.01,										---- Minimum acceptable std dev
		0.95,										---- Maximum acceptable correlation
		25,											---- Maximum iterations
		0.10,										---- P-Value Threshold for False Positives.
		z.begin_flag,
		z.end_flag)) AS f
ORDER BY 1 ASC, 2 DESC, 5 ASC;


-- END: POSITIVE TEST(s)
---- Drop the test table
DROP TABLE tblLinRegrDataDeepTest;
-- 	END: TEST SCRIPT



