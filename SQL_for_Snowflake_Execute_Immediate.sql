-- ***************************************************************************************
-- SQL Scripts for demonstrating the Execute Immediate funcitonality in Snowflake.
-- We will call this script to demo that we can exec directly from a git repo.
-- ***************************************************************************************

CREATE OR REPLACE TABLE PUBLIC.SIMPLE_POC (
    RECORD_ID INT NOT NULL,
    RECORD_DATE DATE NOT NULL,
    RECORD_DESC VARCHAR(50) NULL,
    RECORD_AMT NUMERIC(12,2) NULL
)
;

INSERT INTO PUBLIC.SIMPLE_POC VALUES (1,'2024-07-12','Init',0.00)
;
INSERT INTO PUBLIC.SIMPLE_POC VALUES (2,'2024-07-12','Continue',5.00)
;
INSERT INTO PUBLIC.SIMPLE_POC VALUES (3,'2024-07-12','Continue',11.73)
;
INSERT INTO PUBLIC.SIMPLE_POC VALUES (4,'2024-07-12','Complete',0.62)
;

SELECT RECORD_ID,
RECORD_DATE,
RECORD_DESC,
RECORD_AMT 
FROM PUBLIC.SIMPLE_POC 
;

-- Make sure we drop the table so we minimize our monthly billing.
DROP TABLE PUBLIC.SIMPLE_POC 
;