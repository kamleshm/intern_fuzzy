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
---SP_DecisionTreeScore
-----*******************************************************************************************************************************
SELECT '***** EXECUTING SP_DecisionTree *****';

CREATE OR REPLACE VIEW UM_tblDecisionTreeMulti_VW
AS(
SELECT OBSID, VARID, NUM_VAL AS Value FROM tblDecisionTreeMulti);

EXEC SP_DecisionTree('UM_tblDecisionTreeMulti_VW',
                      100,
                      4,
                      0.8,
                     'HelloWorld');

					
SELECT *
FROM fzzlDecisionTree
WHERE AnalysisID = (SELECT AnalysisID  
                    FROM fzzlDecisionTree
					WHERE Note='HelloWorld')
ORDER BY LEVEL, ChildType, ParentNodeID;	

		
DROP TABLE tblDTDataScore;


EXEC SP_DecisionTreeScore('UM_tblDecisionTreeMulti_VW',
                            ),
                          'tblDTDataScore',
                          'HelloWorld');

						  





SELECT * 
FROM 

-- END: TEST(s)

-- END: TEST SCRIPT
--timing off