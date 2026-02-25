{{
  config(
    materialized = 'table',
    description  = 'Daily price observation fact table. One row per (app_id, price_date). Apr 2019 – Aug 2020.'
  )
}}

/*
    fact_prices
    ───────────
    Materialises stg_prices as a physical table in the GOLD layer.
    Grain: one row per game per day (725,268 rows).

    Star schema joins:
      fact_prices ──(app_id)──► dim_games
      fact_prices ──(app_id)──► dim_genres / dim_tags / etc.
*/

select * from {{ ref('stg_prices') }}