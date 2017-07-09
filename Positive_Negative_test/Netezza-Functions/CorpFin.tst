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
            'IBM NBBO');
            

SELECT *
FROM fzzlNBBOInfo
WHERE Analysisid = 'AMAHATO_531155';

SELECT *
FROM fzzlNBBO
WHERE AnalysisID ='AMAHATO_531155';