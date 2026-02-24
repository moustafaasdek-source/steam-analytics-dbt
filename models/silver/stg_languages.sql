/*
    stg_languages
    =============
    Unpivots wide-format languages CSV to long format: one row per (app_id, language).

    Source: STEAM_BRONZE.RAW.RAW_LANGUAGES (2,000 rows, 1-29 variable columns, NO header)
    - COL0 = appid, COL1..COL28 = language names
    - 31 unique languages found
    - Max 28 languages per game
    - Note: values have leading spaces (e.g. " Korean") — TRIM() handles this
*/

{{ unpivot_wide_csv('steam_bronze', 'RAW_LANGUAGES', 29, 'language') }}
