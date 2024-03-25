-- ********************************************************************
--
-- The purpose of this script is to highligt the use of window functions
-- in a practical context.
-- Here is the outline of the syntax:
/*

 (expression)
    over (
    [partition by clause]
    [order by clause]
    ) AS COLUMN_NAME

*/
-- ********************************************************************

-- Here is how we use a window function to create a simple running total
SELECT POS_ORD_KEY_ID,
POS_ORD_BEG_TM,
POS_TOT_GRSS_TRN_AM,
SUM(POS_TOT_GRSS_TRN_AM) OVER (ORDER BY POS_ORD_BEG_TM) AS RNG_TOT_GRSS_TRN_AM,
SUM(1) OVER (ORDER BY POS_ORD_BEG_TM) AS RNG_TOT_GRSS_TRN_CT
FROM PUBLIC.LND_POS_TRN_LVL_HDR 
ORDER BY 2
;

-- Use a WITH clause to create a temporary table contain the total amount for the day
WITH totalAmt (POS_TOT_AM) AS (
SELECT SUM(POS_TOT_GRSS_TRN_AM) AS POS_TOT_AM
FROM LND_POS_TRN_LVL_HDR),
runningTotalAmt (POS_ORD_KEY_ID, POS_ORD_BEG_TM, POS_TOT_GRSS_TRN_AM, RNG_TOT_GRSS_TRN_AM, RNG_TOT_GRSS_TRN_CT) AS (SELECT POS_ORD_KEY_ID,
POS_ORD_BEG_TM,
POS_TOT_GRSS_TRN_AM,
SUM(POS_TOT_GRSS_TRN_AM) OVER (ORDER BY POS_ORD_BEG_TM) AS RNG_TOT_GRSS_TRN_AM,
SUM(1) OVER (ORDER BY POS_ORD_BEG_TM) AS RNG_TOT_GRSS_TRN_CT
FROM PUBLIC.LND_POS_TRN_LVL_HDR )
SELECT POS_ORD_KEY_ID, 
POS_ORD_BEG_TM, 
POS_TOT_GRSS_TRN_AM, 
RNG_TOT_GRSS_TRN_AM, 
RNG_TOT_GRSS_TRN_CT,
RNG_TOT_GRSS_TRN_AM/POS_TOT_AM AS RNG_TOT_GRSS_TRN_PCTCT 
FROM runningTotalAmt, totalAmt
ORDER BY 2
;



