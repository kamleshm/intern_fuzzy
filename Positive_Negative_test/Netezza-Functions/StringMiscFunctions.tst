INFO: Reading startup configuration from file PulsarLogOn.act_ssl_config
-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Teradata Aster
--
-- Copyright (c): 2016 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.
-- Functional Test Specifications:
--
-- 	Test Category:		    Math Functions
--
--	Last Updated:			05-15-2017
--
--	Author:			    	<@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----****************************************************************
---FLCleanStr
-----****************************************************************
SELECT FLCleanStr('example6 # È¿ïü .44 %(') AS CleanStr1,
FLCleanStr('7890 %åÓë') AS CleanStr2,
FLCleanStr('example5 TOC ¤ü¹È¿ïü') AS CleanStr3,
FLCleanStr('example3 î8×é¶Óë') AS CleanStr4;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLConcatStr
-----****************************************************************
SELECT FLConcatStr(a.String1,'|') AS ConcatString
FROM tblString a;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLDLevenshteinDist
-----****************************************************************
SELECT FLDLevenshteinDist('MARTHA','Partha',1) AS DLevenshteinlDist1,
       FLDLevenshteinDist('MARTHA','Partha',0) AS DLevenshteinDist2,
       FLDLevenshteinDist('MARTHA','Parhta',1) AS DLevenshteinDist3,
       FLDLevenshteinDist('MARTHA','Parhta',0) AS DLevenshteinlDist4;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLExtractStr
-----****************************************************************
SELECT FLExtractStr(
       'Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|',5)
       AS ExtractPos5,
       FLExtractStr(
       'Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|','|',2)
       AS ExtractPos2,
       FLExtractStr(
       'Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA|',';',5)
       AS WrongDelimiter,
       FLExtractStr(
       'Home Depot|WAL-MART|DUANE|MARTHA|WALMART| DWAYNE|MARHTA','|',7) 
       AS ExtractLastWithNoDelim;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLGetFlat
-----****************************************************************
SELECT FLGetFlat(2, 
                 'One', 
                 'Two', 
                 'Three',
                 'Four',
                 'Five',
                 'Six',
                 'Seven',
                 'Eight',
                 'Nine',
                 'Ten',
                 'Eleven',
                 'Twelve');



-------------------------------------------------------------------------------------
-----****************************************************************
---FLHammingDist
-----****************************************************************
SELECT FLHammingDist('MARTHA','Partha',1,3) AS HammingDist1,
       FLHammingDist('MARTHA','Partha',0,3) AS HammingDist2,
       FLHammingDist('MARTHA','MARTHA',0,3) AS HammingDist3,
       FLHammingDist('Prof. John Doe','Dr. John Doe',1,5) 
       AS HammingDist4;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLInStr
-----****************************************************************
SELECT  
FLInStr(0,'one must separate from anything that forces one to repeat No
again and again', 'one') AS Search1,
FLInStr(23, 'one must separate from anything that forces one to repeat No
again and again', 'one') AS Search2,
FLInStr(100000, 'One must separate from anything that forces one to
repeat No again and again','one') AS WrongStartPos,
FLInStr( 15, 'One must separate from anything that forces one to repeat
No again and again', '') AS NullSubStr,
FLInStr( 1, NULL, 'one') AS NullString,
FLInStr( NULL, 'one must separate from anything that forces one to repeat
No again and again', 'from') AS StartPosNULL ;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLIsNumeric
-----****************************************************************
SELECT FLIsNumeric('1234.250') AS Case1,
       FLIsNumeric('12345G12') AS Case2,
       FLIsNumeric('45321E12') AS Case3,
       FLIsNumeric('45321ABC') AS Case4,
       FLIsNumeric('123445') AS Case5;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLJaroScore
-----****************************************************************
SELECT FLJaroScore('MARTHA','MARTHA') AS JaroScore1,
       FLJaroScore('WALMART','WAL-MART') AS JaroScore3;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLJaroWinklerScore
-----****************************************************************
SELECT FLJaroWinklerScore('MARTHA','MARTHA') AS JaroScore1,
       FLJaroWinklerScore('WALMART','WAL-MART') AS JaroScore3;



-------------------------------------------------------------------------------------
-----****************************************************************
---FLLastValue
-----****************************************************************
SELECT FLLastValue(a.ObsID, a.DateTS1)
FROM tblTestDate a;


-------------------------------------------------------------------------------------
-----****************************************************************
---FLREGEXP_LIKE
-----****************************************************************
SELECT string_pattern,
reg_exp,
FLREGEXP_LIKE(string_pattern, reg_exp, false) as noic_match,
FLREGEXP_LIKE(string_pattern, reg_exp, true) as ic_match
FROM tblRegExpPatterns p,
tblStringPatterns s
ORDER BY 1, 2;

-------------------------------------------------------------------------------------
-----****************************************************************
---FLSimStr
-----****************************************************************
SELECT a.SerialVal,
FLSimStr(RANDOM(), 20, 1, 1)
FROM fzzlSerial a
WHERE a.SerialVal <= 10
ORDER BY 1;


-------------------------------------------------------------------------------------
-----****************************************************************
---FLStrReplace
-----****************************************************************
SELECT FLStrReplace('OneTwoThreeFour', 'Three', 'TwoAndHalf');



-------------------------------------------------------------------------------------
-----****************************************************************
---FLStrTok
-----****************************************************************
SELECT FLStrTok('a|b|c|d', '|', 2);
