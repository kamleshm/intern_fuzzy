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
--timing on

-- BEGIN: TEST(s)

-----*******************************************************************************************************************************
---SP_LinRegr
-----*******************************************************************************************************************************

--CASE 1: Linear Regression using this stored procedure
ALTER TABLE tblLinRegr RENAME num_val to value; 


EXEC SP_LinRegr('tblLinRegr', 'HelloWorld');




SELECT a.*
FROM fzzlLinRegrStats a
WHERE a.AnalysisID = (SELECT AnalysisID
                      FROM fzzlLinRegrInfo a
                      WHERE Note='HelloWorld')
LIMIT 20;

SELECT a.*
FROM fzzlLinRegrCoeffs a
WHERE  a.AnalysisID = (SELECT AnalysisID
                       FROM fzzlLinRegrInfo a
                       WHERE Note='HelloWorld')
ORDER BY 2,3
LIMIT 20;





-- END: TEST(s)

-- END: TEST SCRIPT
--timing off