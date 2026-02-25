{{
  config(
    materialized = 'table',
    description  = 'Genre bridge table. One row per (app_id, genre). Join to dim_games on app_id.'
  )
}}

select * from {{ ref('stg_genres') }}