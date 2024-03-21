-- Create a dynamic table that refreshes every minute
-- DROP DYNAMIC TABLE ORDER_REGION_SUMMARY;

CREATE OR REPLACE DYNAMIC TABLE ORDER_REGION_SUMMARY
TARGET_LAG = '1 minute'
WAREHOUSE = PRACTICEWH
AS
SELECT ORDERDATE,
REGION,
SUM(UNITS) AS TOTAL_UNITS,
SUM(UNITCOST) AS TOTAL_COST
FROM LND_ORDERS
GROUP BY 1,2
ORDER BY 1,2
;

SELECT SUM(TOTAL_UNITS) AS TOTAL_UNITS,
SUM(TOTAL_COST) AS TOTAL_COST,
COUNT(*) AS RECORD_COUNT
FROM ORDER_REGION_SUMMARY
;
-- TOTAL_UNITS	TOTAL_COST	RECORD_COUNT
-- 2121	        873.27	    3 (8:58 am)
-- 4242	        1746.54	    6 (9:00 am) -- Added 10/22 file.
-- 4242	        1746.54	    6 (9:03 am) -- Removed 10/22 file. Does not account for deleted files.

# The Snowpark package is required for Python Worksheets. 
# You can add more packages by selecting them using the Packages control and then importing them.

import snowflake.snowpark as snowpark
from snowflake.snowpark.functions import col