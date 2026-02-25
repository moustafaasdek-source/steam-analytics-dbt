{{
  config(
    materialized = 'table',
    description  = 'Daily player count fact table. One row per (app_id, activity_date). Dec 2017 – Aug 2020.'
  )
}}

/*
    fact_player_counts
    ──────────────────
    Materialises stg_player_counts as a physical table in the GOLD layer.
    Grain: one row per game per day (~24.3M rows).

    Star schema joins:
      fact_player_counts ──(app_id)──► dim_games
      fact_player_counts ──(app_id)──► dim_genres / dim_tags / etc.
*/

select * from {{ ref('stg_player_counts') }}