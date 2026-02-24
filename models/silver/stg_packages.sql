/*
    stg_packages
    ============
    Unpivots wide-format packages CSV to long format: one row per (app_id, package_id).

    Source: STEAM_BRONZE.RAW.RAW_PACKAGES (2,000 rows, 1-15 variable columns, NO header)
    - COL0 = appid, COL1..COL14 = numeric package IDs
    - Max package ID: 365,526
    - Max 14 packages per game
    - Unlike other wide CSVs, values are integers not strings
*/

with raw as (
    select * from {{ source('steam_bronze', 'RAW_PACKAGES') }}
),

unpivoted as (
    {% for i in range(1, 15) %}
    select
        col0::INTEGER           as app_id,
        try_to_number(trim(col{{ i }}))  as package_id
    from raw
    where trim(col{{ i }}) is not null
      and trim(col{{ i }}) != ''
    {% if not loop.last %} union all {% endif %}
    {% endfor %}
)

select distinct app_id, package_id
from unpivoted
where package_id is not null
