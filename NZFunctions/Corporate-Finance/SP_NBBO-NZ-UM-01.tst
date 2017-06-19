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
-- 	Test Category:	    Corporate Finance Functions
--
--	Last Updated:		05-29-2017
--
--	Author:			    <deept.mahendiratta@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT
\timing on

-- BEGIN: TEST(s)

--Input Data

SELECT *
FROM finTaqQuote
LIMIT 20;


--Executing SP_NBBO
CALL SP_NBBO('finTaqQuote' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'HelloWorld');
			
			
            
--Output Tables
SELECT *
FROM fzzlNBBOInfo
WHERE Analysisid = (SELECT AnalysisId 
                    FROM fzzlNBBOInfo
					WHERE Note='HelloWorld');

SELECT *
FROM fzzlNBBO
WHERE AnalysisID = (SELECT AnalysisId 
                    FROM fzzlNBBOInfo
					WHERE Note='HelloWorld');



-- END: TEST(s)

-- END: TEST SCRIPT
\timing off