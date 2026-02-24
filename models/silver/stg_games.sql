/*
    stg_games
    =========
    Cleans applicationInformation from Bronze layer.

    Key transformations:
    - Casts appid to INTEGER
    - Trims and lowercases app_type
    - Handles TWO date formats found in raw data:
        * "21-Dec-17" (D-Mon-YY) — 1,854 rows
        * "Nov-14" (Mon-YY, no day) — 7 rows (defaults day to 1)
    - Converts freetoplay from string "0"/"1" to BOOLEAN
    - Derives release_year and release_month

    Source: STEAM_BRONZE.RAW.RAW_APPLICATION_INFO (2,000 rows, 5 columns)
*/

with raw as (
    select * from {{ source('steam_bronze', 'RAW_APPLICATION_INFO') }}
),

cleaned as (
    select
        appid                                           as app_id,
        nullif(lower(trim(type)), '')                   as app_type,
        trim(name)                                      as app_name,

        -- Handle two date formats:
        --   Format 1: "21-Dec-17" (DD-Mon-YY) — 1,854 rows
        --   Format 2: "Nov-14"   (Mon-YY)     — 7 rows, default day to 1st
        case
            when releasedate is null or trim(releasedate) = '' then null
            when regexp_like(trim(releasedate), '^[0-9]{1,2}-[A-Za-z]{3}-[0-9]{2}$')
                then try_to_date(trim(releasedate), 'DD-MON-YY')
            when regexp_like(trim(releasedate), '^[A-Za-z]{3}-[0-9]{2}$')
                then try_to_date('01-' || trim(releasedate), 'DD-MON-YY')
            else null
        end                                             as release_date,

        -- Convert string "0"/"1" to boolean
        case
            when trim(freetoplay) = '1' then true
            when trim(freetoplay) = '0' then false
            else null
        end                                             as is_free_to_play

    from raw
    where appid is not null
)

select
    app_id,
    app_type,
    app_name,
    release_date,
    year(release_date)      as release_year,
    month(release_date)     as release_month,
    is_free_to_play
from cleaned
