-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata
--
-- Copyright (c): 2015 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:			Corporate Finance Functions
--
--	Test Unit Number:		SP_NBBO-NZ-01
--
--	Name(s):		    	SP_NBBO
--
-- 	Description:		   Calculates the National Best Bid and Offer (NBBO) for a US equity
--
--	Applications:		 
--
-- 	Signature:		    	SP_NBBO(TableName        VARCHAR(30),
--                                  TickerSymbol     VARCHAR(6),
--                                  QuoteDateTimeCol VARCHAR(30),
--                                  ExchangeCol      VARCHAR(30),
--                                  SymbolRootCol    VARCHAR(30),
--                                  BidPriceCol      VARCHAR(30),
--                                  BidSizeCol       VARCHAR(30),
--                                  AskPriceCol      VARCHAR(30),
--                                  AskSizeCol       VARCHAR(30),
--                                  StartTime        TIMESTAMP,
--                                  QuoteTime        TIMESTAMP, 
--                                  Note             VARCHAR(255))
--            
--	Parameters:		    	See Documentation
--
--	Return value:			DOUBLE PRECISION
--
--	Last Updated:			08-09-2016
--
--	Author:			    	<Ankit.Mahato@fuzzylogix.com>
--

-- BEGIN: TEST SCRIPT

-- Create table for testing
DROP TABLE finTaqQuote_test;
CREATE TABLE finTaqQuote_test AS (
SELECT *
FROM finTaqQuote
WHERE SymbolRoot IN ('MSFT','IBM','BCS')
);

-- BEGIN: Negative Test(s)

---- Case 1: Param 1 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test_notexist' ,
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
            'IBM NBBO');

---- Case 2: Param 2 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM_notexist',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 3: Param 3 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime_notexist',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');                      

---- Case 4: Param 4 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange_notexist',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');                      

---- Case 5: Param 5 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot_notexist',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');   

---- Case 6: Param 6 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice_notexist',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');   
            
---- Case 7: Param 7 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize_notexist',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');
            
---- Case 8: Param 8 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice_notexist',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');
            
---- Case 9: Param 9 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize_notexist',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');            

---- Case 10: Param 10 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '_notexist',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');     

---- Case 11: Param 11 does not exist
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test' ,
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 _notexist',
            'IBM NBBO');                         

---- Case 12: Param 1 is NULL
---- Result: Throws error - good
CALL SP_NBBO(NULL,
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
            'IBM NBBO');   

---- Case 13: Param 2 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            NULL,
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 14: Param 3 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            NULL,
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');                        

---- Case 15: Param 4 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            NULL,
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 16: Param 5 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            NULL,
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 17: Param 6 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            NULL,
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');            
            
---- Case 18: Param 7 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            NULL,
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');  
            
---- Case 19: Param 8 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            NULL,
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');  
            
---- Case 20: Param 9 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            NULL,
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 21: Param 10 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            NULL,
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 22: Param 11 is NULL
---- Result: Throws error - good
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            NULL,
            'IBM NBBO');

---- Case 23: Quote time is after the Quote time
---- Result: Throws error - good            
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2020-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');

---- Case 24: Non existant Ticker symbol
---- Result: Throws error - good    
CALL SP_NBBO('finTaqQuote_test',
            'FLOP',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2010-01-04 10:00:01',
            '2010-01-04 18:07:56.948000',
            'IBM NBBO');        

---- Case 25: No data for particular ticker
---- Result: Throws error - good  
CALL SP_NBBO('finTaqQuote_test',
            'IBM',
            'QuoteDateTime',
            'Exchange',
            'SymbolRoot',
            'BidPrice',
            'Bidsize',
            'AskPrice',
            'AskSize',
            '2050-01-04 10:00:01',
            '2050-01-04 18:07:56.948000',
            'IBM NBBO');                         
            
-- END: Negative Test(s)

-- BEGIN: Positive Test(s)

---- Positive Test 1: basic example 

-- END: Positive Test(s)
CALL SP_NBBO('finTaqQuote_test',
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
            'IBM NBBO');           

SELECT * 
FROM fzzlNBBO 
WHERE AnalysisID IN (SELECT AnalysisID 
                     FROM   fzzlNBBOinfo 
                     WHERE  RunStartTime IN (SELECT MAX(RunStartTime) 
                                             FROM fzzlNBBOinfo));        

-- DROP test tables  aftertesting
DROP TABLE finTaqQuote_test;

-- 	END: TEST SCRIPT

