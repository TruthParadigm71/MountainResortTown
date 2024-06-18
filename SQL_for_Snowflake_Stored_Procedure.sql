CREATE OR REPLACE PROCEDURE SP_LOAD_D_USER()
  RETURNS INT
  LANGUAGE SQL
  AS
  /**************************************************************************
  Created by: Rob Wozniak
  Created date: 2023-11-16
  DB: PRACTICEDB
  Schema: ROB_WOZNIAK
  Warehouse: PRACTICEWH

  Description: This stored procedure "Merges" json formatted data from a variant 
  column to rows and columns in a dimensionally modeled table, D_USER. 
  
  A type 1 SCD load pattern is employed. It is effectively a logical MERGE statement.
  
  The INSERT and UPDATE statements are executed separately so we can accurately record 
  the number of records inserted and updated. The stored procedure format allows 
  us to capture and log exceptions.

  ***************************************************************************/
  $$
    -- Snowflake Scripting code
    DECLARE
        run_id INT;
        rows_inserted INT;
        rows_updated INT;
        err_msg VARCHAR;
        proc_name VARCHAR;
        target_table VARCHAR;
    BEGIN
        -- Init runtime metadata, get new run id
        CALL SP_INIT_DATA_LOAD_HISTORY('D_USER')
        ;

        SELECT MAX(RUN_ID)
        INTO :run_id
        FROM DATA_LOAD_HISTORY
        WHERE TARGET_TABLE_NAME = 'D_USER'
        ;

        -- Insert statement Where not exists
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
        FROM LND_USER_JSON
        ,LATERAL FLATTEN (input => "JSON_DATA") AS T0
        ,LATERAL FLATTEN (input => T0.value) AS T1 
        WHERE NOT EXISTS (SELECT 1 FROM D_USER S1 
        WHERE S1.USERID = T1.VALUE:userId )
        ;

        -- Capture the number of rows inserted
        rows_inserted := SQLROWCOUNT
        ;

        -- Update load history using Run_id, ROW_COUNT
        CALL SP_UPDATE_DATA_LOAD_HISTORY(:run_id,
                                'INSERT',
                                :rows_inserted)
        ;

        -- Update statement Where exists with differences
        UPDATE D_USER 
        SET D_USER.EMAILADDRESS = TRIM(S1.EMAILADDRESS,'"'),
        D_USER.LASTNAME = TRIM(S1.LASTNAME,'"'),
        D_USER.FIRSTNAME = TRIM(S1.FIRSTNAME,'"'),
        D_USER.PHONENUMBER = TRIM(S1.PHONENUMBER,'"'),
        UPDATE_TS = CURRENT_TIMESTAMP()
        FROM (SELECT L1.VALUE:userId as userId,
                L1.VALUE:emailAddress as emailAddress,
                L1.VALUE:lastName as lastName,
                L1.VALUE:firstName as firstName,
                L1.VALUE:phoneNumber as phoneNumber
              FROM LND_USER_JSON
              ,LATERAL FLATTEN (input => "JSON_DATA") AS L0
              ,LATERAL FLATTEN (input => L0.value) AS L1 ) S1
        WHERE S1.USERID = D_USER.USERID
        AND (D_USER.EMAILADDRESS != TRIM(S1.EMAILADDRESS,'"')
        OR D_USER.LASTNAME != TRIM(S1.LASTNAME,'"')
        OR D_USER.FIRSTNAME != TRIM(S1.FIRSTNAME,'"')
        OR D_USER.PHONENUMBER != TRIM(S1.PHONENUMBER,'"'))
        ;

        -- Capture the number of rows updated
        rows_updated := SQLROWCOUNT
        ;

        -- Update load history using Run_id, ROW_COUNT
        CALL SP_UPDATE_DATA_LOAD_HISTORY(:run_id,
                                'UPDATE',
                                :rows_updated)
        ;

        -- Return the run_id
        RETURN :run_id
        ;

    EXCEPTION 
      WHEN OTHER THEN
          -- Capture error message
          INSERT INTO DATA_LOAD_EXCEPTION (
                                RUN_ID,
                                EXCEPTION_TS,
                                ERR_MSG)
          VALUES (:run_id,
                  CURRENT_TIMESTAMP(),
                  :SQLERRM)
          ;

          -- Return error code
        RETURN -1;
    END;
  $$
  ;   
