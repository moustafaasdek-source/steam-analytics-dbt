/*
    stg_genres
    ==========
    Unpivots wide-format genres CSV to long format: one row per (app_id, genre).

    Source: STEAM_BRONZE.RAW.RAW_GENRES (2,000 rows, 1-9 variable columns, NO header)
    - COL0 = appid, COL1..COL8 = genre names
    - 26 unique genres found
    - Max 8 genres per game

    Data quality: Filters out numeric junk value "60" found in app 585410.
*/

{{ unpivot_wide_csv('steam_bronze', 'RAW_GENRES', 9, 'genre') }}
    and not regexp_like(genre, '^[0-9]+$')   -- filter out junk value "60"
