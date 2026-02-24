/*
    stg_tags
    ========
    Unpivots wide-format tags CSV to long format: one row per (app_id, tag).

    Source: STEAM_BRONZE.RAW.RAW_TAGS (2,000 rows, 1-21 variable columns, NO header)
    - COL0 = appid, COL1..COL20 = tag names
    - 339 unique tags found
    - Max 20 tags per game
*/

{{ unpivot_wide_csv('steam_bronze', 'RAW_TAGS', 21, 'tag') }}
