// Create some time travel examples
-- Create a sequence
CREATE OR REPLACE SEQUENCE SEQ_TIME_TRAVEL
; -- Insufficient privileges

CREATE OR REPLACE TABLE IMPORTANT_DATA (
ID VARCHAR(50) NOT NULL,
DATA_VAL VARCHAR(50),
ROW_INSERTED TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
;

-- INSERT sample rows
INSERT INTO ROB_WOZNIAK.IMPORTANT_DATA (
ID,
DATA_VAL )
SELECT C_NAME,
C_ADDRESS
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
WHERE C_CUSTKEY BETWEEN 60001 AND 60100
;

-- Confirm we have rows
SELECT *
FROM IMPORTANT_DATA
;

-- Drop the table -- OOPS!
DROP TABLE IMPORTANT_DATA
;

-- Look at the history of this table.
-- Note the value in the DROPPED_ON column.
SHOW TABLES HISTORY LIKE '%IMPORTANT%'
;

-- Undrop the table
UNDROP TABLE IMPORTANT_DATA
;

-- Confirm data
SELECT *
FROM IMPORTANT_DATA
;

-- Review metadata again
-- dropped_on is set to null

-- Delete a single record
DELETE FROM IMPORTANT_DATA 
WHERE ID = 'Customer#000060001'
;

-- Get the query id related to the most recent (I.e. DELETE)
SET QUERY_ID = (SELECT TOP 1  QUERY_ID 
FROM TABLE (INFORMATION_SCHEMA.QUERY_HISTORY()) 
WHERE QUERY_TEXT LIKE 'DELETE FROM IMPORTANT%')
;

-- confirm query id
SELECT $QUERY_ID
;

-- Create a clone of the original using query id
CREATE OR REPLACE TABLE IMPORTANT_DATA_V2
CLONE IMPORTANT_DATA BEFORE (STATEMENT => $QUERY_ID) 
;

-- Confirm deleted record exists in clone 
SELECT * 
FROM IMPORTANT_DATA_V2
WHERE ID = 'Customer#000060001' 
; -- OKAY

-- Use the offset to a few minutes earlier than the current record
SELECT * 
FROM IMPORTANT_DATA_V2 V2 
LEFT JOIN IMPORTANT_DATA AT (OFFSET => -60*17) V1
ON V1.ID = V2.ID 
WHERE V1.ID IS NULL
;

-- How do I get query history?
SELECT * 
FROM ACCOUNT_USAGE.QUERY_HISTORY
;