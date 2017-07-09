DROP TABLE FinStockPricePerc;

EXEC SP_Perc('FinStockPrice',
             'CLOSEPRICE',
             'TICKERSYMBOL',
             '0.1,0.3,0.5,0.7,0.9',
             'FinStockPricePerc');

SELECT * FROM FinStockPricePerc
ORDER BY 1,2
LIMIT 20; 