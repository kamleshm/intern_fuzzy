-- Fuzzy Logix, LLC: Functional Testing Script for DB Lytix functions on Netezza
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
--     Test Category:    Hypothesis Testing Functions
--
--     Test Unit Number: SP_ANCOVA-NZ-01
--
--     Name(s):          SP_ANCOVA
--
--     Description:      FLAncovaUdt performs Analysis of Covariance (ANCOVA).  
--                       ANCOVA is used to test if population means of a dependent variable 
--                       are equal across levels of a categorical independent variable, 
--                       while controlling for the effects of other continuous variables 
--                       (known as covariates) that are not of primary interest. 
--
--     Applications:            
--
--     Signature:        FLAncovaUdt (m_id    BIGINT, 
--                                 cat     VARCHAR(100),
--                                 num_x   DOUBLE PRECISION, 
--                                 num_y   DOUBLE PRECISION,
--                                 Sig     DOUBLE PRECISION)
--                       RETURNS TABLE (o_m_id     BIGINT, 
--                                      ss_between DOUBLE PRECISION, 
--                                      ss_within  DOUBLE PRECISION,
--                                      ss_total   DOUBLE PRECISION, 
--                                      df_between BIGINT, 
--                                      df_within  BIGINT, 
--                                      df_total   BIGINT,
--                                      ms_between DOUBLE PRECISION, 
--                                      ms_within  DOUBLE PRECISION,
--                                      f_stat     DOUBLE PRECISION, 
--                                      p_value    DOUBLE PRECISION, 
--                                      crit_fstat DOUBLE PRECISION)
--
--     Parameters:        See Documentation
--
--     Return value:            Table
--
--     Last Updated:            07-07-2017
--
--     Author:            <Joe.Fan@fuzzyl.com>
--     Author:            Kamlesh Meena

-- BEGIN: TEST SCRIPT
\time
--.run file=../PulsarLogOn.sql


-- BEGIN: NEGATIVE TEST(s)

---- Initialization
DROP TABLE tblAncovaTest_Pulsar IF EXISTS;

CREATE TABLE tblAncovaTest_Pulsar
(
OBSID INTEGER,
GROUPID VARCHAR(10),
XVAL FLOAT,
YVAL FLOAT)
DISTRIBUTE ON(OBSID);

--The following helps display results correctly but previous analysisID's are lost.
DELETE FROM fzzlANCOVAStats;

-- Case 1: Input validation

-- Case 1a: Empty input table
Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 0.05);

-- Display result
SELECT *
FROM fzzlANCOVAStats
ORDER BY 1 DESC
LIMIT 1;

-- Result: standard outputs
/*
ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 105 at execute statement

ERROR [HY000] ERROR:  cannot EXECUTE NULL query */


-- Case 1b: Negative dataset number
-- Not applicable to Netezza stored process SP_ANCOVA

-- Case 1c: Only 1 GroupID
DELETE FROM tblAncovaTest_Pulsar;

INSERT INTO tblAncovaTest_Pulsar
SELECT  ObsID,
        'A',
        XVal,
        YVal
FROM    tblAncovaTest;

DELETE FROM fzzlANCOVAStats; 
Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 0.05);
-- Display result
SELECT *
FROM fzzlANCOVAStats
ORDER BY 1 DESC
LIMIT 1;
-- Result: standard outputs
/*
ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 94 at assignment

ERROR [HY000] ERROR:  float8div: divide by zero error */

-- Case 1d: bad significance number
DELETE FROM tblAncovaTest_Pulsar;

INSERT INTO tblAncovaTest_Pulsar
SELECT  ObsID,
        GroupID,
        XVal,
        YVal
FROM    tblAncovaTest;
 
DELETE FROM fzzlANCOVAStats; 

Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 0);
--Result:
/*ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 98 at assignment

ERROR [HY000] ERROR:  Value must be between 0 and 1 */

Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 1);
--Result:
/*ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 98 at assignment

ERROR [HY000] ERROR:  Value must be between 0 and 1 */

Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', -0.05);
--Result:
/*ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 98 at assignment

ERROR [HY000] ERROR:  Value must be between 0 and 1 */

Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 1.05);
--Result:
/*ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 98 at assignment

ERROR [HY000] ERROR:  Value must be between 0 and 1 */

-- Display result
SELECT *
FROM fzzlANCOVAStats
ORDER BY 1 DESC; 

-- Case 2: YVal = XVal
DELETE FROM tblAncovaTest_Pulsar;

INSERT INTO tblAncovaTest_Pulsar
SELECT  ObsID,
        GroupID,
        XVal,
        XVal  -- look here
FROM    tblAncovaTest;

Exec SP_ANCOVA('tblAncovaTest_Pulsar', 'GROUPID', 'XVAL','YVAL', 0.05);
-- Result:
/*ERROR [01000] NOTICE:  Error occurred while executing PL/pgSQL function SP_ANCOVA

ERROR [01000] NOTICE:  line 97 at assignment

ERROR [HY000] ERROR:  Value must be positive */

---- Wrapup
DROP TABLE tblAncovaTest_Pulsar;
-- END: NEGATIVE TEST(s)


-- BEGIN: POSITIVE TEST(s)
DELETE FROM fzzlANCOVAStats;

-- Case 1: use tblAncovaTest
Exec SP_ANCOVA('tblAncovaTest', 'GROUPID', 'XVAL','YVAL', 0.05);

-- Display result
SELECT *
FROM fzzlANCOVAStats
ORDER BY 1 DESC
LIMIT 1;
-- Result: standard outputs

-- dat = read.table("tblAncovaTest.dat", sep="|", col.names = c("ObsID","GroupID","XVal","YVal"))
-- results=lm(YVal~XVal+GroupID, data=dat)
-- anova(results)


-- END: POSITIVE TEST(s)
\time
-- END: TEST SCRIPT
