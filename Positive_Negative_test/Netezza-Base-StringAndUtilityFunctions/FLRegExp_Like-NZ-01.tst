-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
--
-- Copyright (c): 2014 Fuzzy Logix, LLC
--
-- NOTICE: All information contained herein is, and remains the property of Fuzzy Logix, LLC. 
-- The intellectual and technical concepts contained herein are proprietary to Fuzzy Logix, LLC.
-- and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade 
-- secret or copyright law. Dissemination of this information or reproduction of this material is 
-- strictly forbidden unless prior written permission is obtained from Fuzzy Logix, LLC.

-- Functional Test Specifications:
--
-- 	Test Category:		    String Functions
--
--	Test Unit Number:		FLRegExp_Like-Netezza-01
--
--	Name(s):		    	FLRegExp_Like
--
-- 	Description:			Scalar Function. Determines if the input string matches the given regexp pattern.
--
--	Applications:		 
--
-- 	Signature:		    	FLRegExp_Like(pInStr VARCHAR(ANY), pPattern VARCHAR(ANY), pIgnoreCase BOOLEAN)
--
--	Parameters:		    	See Documentation
--
--	Return value:			'False' => String is not matching. 'True' => String is matching.
--
--	Last Updated:			07-05-2017
--
--	Author:			    	Kamlesh Meena
--

-- BEGIN: TEST SCRIPT
\time
-- BEGIN: POSITIVE TEST(s)

---- Positive Test 1: Manual Example

select  string_pattern, 
        reg_exp, 
        FLREGEXP_LIKE(string_pattern, reg_exp, false) as noic_match,
        FLREGEXP_LIKE(string_pattern, reg_exp, true) as ic_match
from    tblRegExpPatterns p, 
        tblStringPatterns s
order by 1, 2;

-- END: POSITIVE TEST(s)
\time
-- 	END: TEST SCRIPT

