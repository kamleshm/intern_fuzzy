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
-- 	Test Category:		    Mathematical Functions
--
--	Last Updated:			05-30-2017
--
--	Author:			    	<kamlesh.meena@fuzzyl.com>
--
-- BEGIN: TEST SCRIPT
\timing on
Timing is on
-- BEGIN: TEST(s)
-----*******************************************************************************************************************************
---FLCap
-----*******************************************************************************************************************************
SELECT FLCap(5.0, 3.0) AS Cap;

-----*******************************************************************************************************************************
---FLCollar
-----*******************************************************************************************************************************
SELECT FLCollar(39.0, -5.0, 5.0) AS Collar;

-----*******************************************************************************************************************************
---FLGammaLn
-----*******************************************************************************************************************************
SELECT FLGammaLn(2.5) AS GammaLn;

-----*******************************************************************************************************************************
---FLFloor
-----*******************************************************************************************************************************
SELECT FLFloor(-3.0, -2.0) AS Floor;

-----*******************************************************************************************************************************
---FLSinH
-----*******************************************************************************************************************************
SELECT FLSinH(0.5) AS Sinh; 

-----*******************************************************************************************************************************
---FLCosH
-----*******************************************************************************************************************************
SELECT FLCosH(0) AS Cosineh; 

-----*******************************************************************************************************************************
---FLTanH
-----*******************************************************************************************************************************
SELECT FLTanH(2) AS Tanh; 

-----*******************************************************************************************************************************
---FLCotH
-----*******************************************************************************************************************************
SELECT FLCotH(1.5) AS Coth;

-----*******************************************************************************************************************************
---FLSecH
-----*******************************************************************************************************************************
SELECT FLSecH(2.0) AS Sech;

-----*******************************************************************************************************************************
---FLCosecH
-----*******************************************************************************************************************************
SELECT FLCosecH(0.5) AS Cosech;

-----*******************************************************************************************************************************
---FLInvSinH
-----*******************************************************************************************************************************
SELECT FLInvSinH(0.3) AS ArcSinh;

-----*******************************************************************************************************************************
---FLInvCosH
-----*******************************************************************************************************************************
SELECT FLInvCosH(2.0) AS ArcCosh;

-----*******************************************************************************************************************************
---FLInvTanH
-----*******************************************************************************************************************************
SELECT FLInvTanH(0.5) AS ArcTanh;

-----*******************************************************************************************************************************
---FLInvCotH
-----*******************************************************************************************************************************
SELECT FLInvCotH(2.5) AS ArcCoth;

-----*******************************************************************************************************************************
---FLInvSecH
-----*******************************************************************************************************************************
SELECT FLInvSecH(0.5) AS ArcSech;

-----*******************************************************************************************************************************
---FLInvCosecH
-----*******************************************************************************************************************************
SELECT FLInvCosecH(1.5) AS ArcCosech;
