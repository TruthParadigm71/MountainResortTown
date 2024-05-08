-- Set session variables to hold keys
-- This is the user project-bucket-user
SET V_AWS_KEY_ID = 'AKIA5JDY2QSXTDGWSZLO';
SET V_AWS_SECRET_KEY='';

-- Create a storage  for S3
CREATE OR REPLACE STAGE STAGE_USER_JSON
  FILE_FORMAT = csvformat_forfiles
  URL = 's3://users-json/' 
  credentials=(AWS_KEY_ID=$V_AWS_KEY_ID AWS_SECRET_KEY=$V_AWS_SECRET_KEY) -- Embed the credentials in the stage
  directory=(enable=true)
  ;
  
-- Query the directory table
SELECT * 
FROM directory(@STAGE_USER_JSON)
;  

-- What data is in this stage?
SELECT metadata$filename, metadata$file_row_number, 
$1, $2, $3, $4, $5, $6, $7, $8 , $9
FROM @STAGE_USER_JSON
;

-- Insert into a table with a variant column
CREATE OR REPLACE TABLE LND_USER_JSON (
JSON_DATA VARIANT )
;

-- If you run this successively, will it load duplicates?
COPY INTO LND_USER_JSON
FROM @STAGE_USER_JSON
FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = true);
;
-- On 2nd execution: 'Copy executed with 0 files processed.'


-- Confirm raw data
SELECT *
FROM LND_USER_JSON
;

-- Flatten the data into rows
-- Query the json data, pull out specific keys
SELECT T1.VALUE,
T1.VALUE:emailAddress as emailAddress,
T1.VALUE:lastName as lastName,
T1.VALUE:firstName as firstName,
T1.VALUE:phoneNumber as phoneNumber,
T1.VALUE:userId as userId
FROM JSON_FILES_RAW
,LATERAL FLATTEN (input => "JSON_DATA") AS T0
,LATERAL FLATTEN (input => T0.value) AS T1 
WHERE JSON_DATA:users::string IS NOT NULL 
ORDER BY 6
;

-- Create a users table that will serve as our source for user data
CREATE OR REPLACE TABLE D_USER (
USERID INT,
EMAILADDRESS VARCHAR(100),
LASTNAME VARCHAR(100),
FIRSTNAME VARCHAR(100),
PHONENUMBER VARCHAR(25),
CREATION_TS TIMESTAMP,
UPDATE_TS TIMESTAMP,
ACTIVE_FL BOOLEAN DEFAULT TRUE)
;

INSERT INTO D_USER (
USERID,
EMAILADDRESS,
LASTNAME,
FIRSTNAME,
PHONENUMBER,
CREATION_TS)
SELECT 
T1.VALUE:userId as userId,
T1.VALUE:emailAddress as emailAddress,
T1.VALUE:lastName as lastName,
T1.VALUE:firstName as firstName,
T1.VALUE:phoneNumber as phoneNumber,
CURRENT_TIMESTAMP() as CREATION_TS
FROM JSON_FILES_RAW
,LATERAL FLATTEN (input => "JSON_DATA") AS T0
,LATERAL FLATTEN (input => T0.value) AS T1 
;

-- Confirm data
SELECT * 
FROM D_USER
;

-- Create a summary based on incoming product orders (see code in Data Integration worksheet)
SELECT * 
FROM LND_ORDERS
;