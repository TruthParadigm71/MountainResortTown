-- ********************************************************************************
-- Test the CREATE OR ALTER functionality in Snowflake.
-- ********************************************************************************

-- Configure environment
USE SYSADMIN;

CREATE OR REPLACE TABLE PUBLIC.SIMPLE_POC (
    RECORD_ID INT NOT NULL,
    RECORD_DATE DATE NOT NULL,
    RECORD_DESC VARCHAR(50) NULL,
    RECORD_AMT NUMERIC(12,2) NULL
)
;
-- These rows insert according to the orginal table ddl.
INSERT INTO SIMPLE_POC VALUES (1,'2024-07-10','Started',100.00);
INSERT INTO SIMPLE_POC VALUES (2,'2024-07-10','Continue',88.88);
INSERT INTO SIMPLE_POC VALUES (3,'2024-07-10','Continue',18.22);
INSERT INTO SIMPLE_POC VALUES (4,'2024-07-10','Continue',103.34);
INSERT INTO SIMPLE_POC VALUES (5,'2024-07-10','Continue',91.55);
-- Insert satement using the udpated DDL.
INSERT INTO SIMPLE_POC VALUES (6,'2024-07-10','End',102.33,FALSE);

SELECT * 
FROM PUBLIC.SIMPLE_POC
;

-- CREATE OR ALTER makes changes while presering the data. NOT NULL columns can't be added, however.
CREATE OR ALTER TABLE PUBLIC.SIMPLE_POC (
    RECORD_ID INT NOT NULL,
    RECORD_DATE DATE NOT NULL,
    RECORD_DESC VARCHAR(50) NULL,
    RECORD_AMT NUMERIC(12,2) NULL,
    RECORD_REVISION BOOLEAN NULL
)
;

-- Cleanup to keep my monthly bill low
drop TABLE PUBLIC.SIMPLE_POC;

-- So the CREATE OR ALTER statement preserves the existing data