-- Update to DDL using CREATE OR ALTER syntax
CREATE OR ALTER TABLE PUBLIC.SIMPLE_POC (
    RECORD_ID INT NOT NULL,
    RECORD_DATE DATE NOT NULL,
    RECORD_DESC VARCHAR(50) NULL,
    RECORD_AMT NUMERIC(12,2) NULL,
    RECORD_REVISION BOOLEAN NULL,
    RECORD_UPDATE_DATE DATA NULL
)
;