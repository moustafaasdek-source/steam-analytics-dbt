{{
  config(
    materialized = 'table',
    description  = 'Developer bridge table. One row per (app_id, developer). Join to dim_games on app_id.'
  )
}}

select * from {{ ref('stg_developers') }}
