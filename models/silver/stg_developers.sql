/*
    stg_developers
    ==============
    Unpivots wide-format developers CSV to long format: one row per (app_id, developer).

    Source: STEAM_BRONZE.RAW.RAW_DEVELOPERS (2,000 rows, 1-8 variable columns, NO header)
    - COL0 = appid, COL1..COL7 = developer names
    - 1,330 unique developers found
    - Max 7 developers per game
    - Max developer name length: 137 characters
*/

{{ unpivot_wide_csv('steam_bronze', 'RAW_DEVELOPERS', 8, 'developer') }}
