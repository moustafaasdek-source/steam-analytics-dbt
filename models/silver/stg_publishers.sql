/*
    stg_publishers
    ==============
    Unpivots wide-format publishers CSV to long format: one row per (app_id, publisher).

    Source: STEAM_BRONZE.RAW.RAW_PUBLISHERS (2,000 rows, 1-5 variable columns, NO header)
    - COL0 = appid, COL1..COL4 = publisher names
    - 919 unique publishers found
    - Max 4 publishers per game
*/

{{ unpivot_wide_csv('steam_bronze', 'RAW_PUBLISHERS', 5, 'publisher') }}
