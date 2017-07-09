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
-- 	Test Category:		Hypothesis Testing Functions
--
--	Test Unit Number:	FLCrossTab-TD-03
--
--	Name(s):		FLCrossTab
--
-- 	Description:	    	Cross tabulation, or cross tab, also called pivot table in Microsoft excel, display the joint distribution of two variables. 
--
--	Applications:	    	
--
-- 	Signature:		FLCrossTab(IN  TableName   VARCHAR(256),
--                             IN  RowColName  VARCHAR(100),
--                             IN  ColColName  VARCHAR(100),
--                             IN  WhereClause VARCHAR(512),
--                             IN  GroupBy     VARCHAR(256),
--                             IN  TableOutput byteint,
--                             OUT ResultTable VARCHAR(256))
--
--	Parameters:		See Documentation
--
--	Return value:	    	VARCHAR(256)
--
--	Last Updated:	    	07-24-2014
--
--	Author:			<zhi.wang@fuzzyl.com>

-- BEGIN: TEST SCRIPT

.run file=../PulsarLogOn.sql

-- BEGIN: POSITIVE TEST(s)

-- JIRA TD-23

CREATE MULTISET TABLE tblcrosstabJR ,FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      TABROWID INTEGER,
      TABCOLID INTEGER)
PRIMARY INDEX ( TABROWID );

ins into tblcrosstabJR values(	1	,	1000	)
;ins into tblcrosstabJR values(	2	,	999	)
;ins into tblcrosstabJR values(	3	,	998	)
;ins into tblcrosstabJR values(	4	,	997	)
;ins into tblcrosstabJR values(	5	,	996	)
;ins into tblcrosstabJR values(	6	,	995	)
;ins into tblcrosstabJR values(	7	,	994	)
;ins into tblcrosstabJR values(	8	,	993	)
;ins into tblcrosstabJR values(	9	,	992	)
;ins into tblcrosstabJR values(	10	,	991	)
;ins into tblcrosstabJR values(	11	,	990	)
;ins into tblcrosstabJR values(	12	,	989	)
;ins into tblcrosstabJR values(	13	,	988	)
;ins into tblcrosstabJR values(	14	,	987	)
;ins into tblcrosstabJR values(	15	,	986	)
;ins into tblcrosstabJR values(	16	,	985	)
;ins into tblcrosstabJR values(	17	,	984	)
;ins into tblcrosstabJR values(	18	,	983	)
;ins into tblcrosstabJR values(	19	,	982	)
;ins into tblcrosstabJR values(	20	,	981	)
;ins into tblcrosstabJR values(	21	,	980	)
;ins into tblcrosstabJR values(	22	,	979	)
;ins into tblcrosstabJR values(	23	,	978	)
;ins into tblcrosstabJR values(	24	,	977	)
;ins into tblcrosstabJR values(	25	,	976	)
;ins into tblcrosstabJR values(	26	,	975	)
;ins into tblcrosstabJR values(	27	,	974	)
;ins into tblcrosstabJR values(	28	,	973	)
;ins into tblcrosstabJR values(	29	,	972	)
;ins into tblcrosstabJR values(	30	,	971	)
;ins into tblcrosstabJR values(	31	,	970	)
;ins into tblcrosstabJR values(	32	,	969	)
;ins into tblcrosstabJR values(	33	,	968	)
;ins into tblcrosstabJR values(	34	,	967	)
;ins into tblcrosstabJR values(	35	,	966	)
;ins into tblcrosstabJR values(	36	,	965	)
;ins into tblcrosstabJR values(	37	,	964	)
;ins into tblcrosstabJR values(	38	,	963	)
;ins into tblcrosstabJR values(	39	,	962	)
;ins into tblcrosstabJR values(	40	,	961	)
;ins into tblcrosstabJR values(	41	,	960	)
;ins into tblcrosstabJR values(	42	,	959	)
;ins into tblcrosstabJR values(	43	,	958	)
;ins into tblcrosstabJR values(	44	,	957	)
;ins into tblcrosstabJR values(	45	,	956	)
;ins into tblcrosstabJR values(	46	,	955	)
;ins into tblcrosstabJR values(	47	,	954	)
;ins into tblcrosstabJR values(	48	,	953	)
;ins into tblcrosstabJR values(	49	,	952	)
;ins into tblcrosstabJR values(	50	,	951	)
;ins into tblcrosstabJR values(	51	,	950	)
;ins into tblcrosstabJR values(	52	,	949	)
;ins into tblcrosstabJR values(	53	,	948	)
;ins into tblcrosstabJR values(	54	,	947	)
;ins into tblcrosstabJR values(	55	,	946	)
;ins into tblcrosstabJR values(	56	,	945	)
;ins into tblcrosstabJR values(	57	,	944	)
;ins into tblcrosstabJR values(	58	,	943	)
;ins into tblcrosstabJR values(	59	,	942	)
;ins into tblcrosstabJR values(	60	,	941	)
;ins into tblcrosstabJR values(	61	,	940	)
;ins into tblcrosstabJR values(	62	,	939	)
;ins into tblcrosstabJR values(	63	,	938	)
;ins into tblcrosstabJR values(	64	,	937	)
;ins into tblcrosstabJR values(	65	,	936	)
;ins into tblcrosstabJR values(	66	,	935	)
;ins into tblcrosstabJR values(	67	,	934	)
;ins into tblcrosstabJR values(	68	,	933	)
;ins into tblcrosstabJR values(	69	,	932	)
;ins into tblcrosstabJR values(	70	,	931	)
;ins into tblcrosstabJR values(	71	,	930	)
;ins into tblcrosstabJR values(	72	,	929	)
;ins into tblcrosstabJR values(	73	,	928	)
;ins into tblcrosstabJR values(	74	,	927	)
;ins into tblcrosstabJR values(	75	,	926	)
;ins into tblcrosstabJR values(	76	,	925	)
;ins into tblcrosstabJR values(	77	,	924	)
;ins into tblcrosstabJR values(	78	,	923	)
;ins into tblcrosstabJR values(	79	,	922	)
;ins into tblcrosstabJR values(	80	,	921	)
;ins into tblcrosstabJR values(	81	,	920	)
;ins into tblcrosstabJR values(	82	,	919	)
;ins into tblcrosstabJR values(	83	,	918	)
;ins into tblcrosstabJR values(	84	,	917	)
;ins into tblcrosstabJR values(	85	,	916	)
;ins into tblcrosstabJR values(	86	,	915	)
;ins into tblcrosstabJR values(	87	,	914	)
;ins into tblcrosstabJR values(	88	,	913	)
;ins into tblcrosstabJR values(	89	,	912	)
;ins into tblcrosstabJR values(	90	,	911	)
;ins into tblcrosstabJR values(	91	,	910	)
;ins into tblcrosstabJR values(	92	,	909	)
;ins into tblcrosstabJR values(	93	,	908	)
;ins into tblcrosstabJR values(	94	,	907	)
;ins into tblcrosstabJR values(	95	,	906	)
;ins into tblcrosstabJR values(	96	,	905	)
;ins into tblcrosstabJR values(	97	,	904	)
;ins into tblcrosstabJR values(	98	,	903	)
;ins into tblcrosstabJR values(	99	,	902	)
;ins into tblcrosstabJR values(	100	,	901	);


call FLCrossTab('tblcrosstabJR', 'tabrowid', 'tabcolid', NULL, NULL, 0,OutTable);

DROP TABLE tblcrosstabJR;

-- END: POSITIVE TEST(s)

-- 	END: TEST SCRIPT