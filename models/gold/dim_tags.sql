{{
  config(
    materialized = 'table',
    description  = 'Community tag bridge table. One row per (app_id, tag). Join to dim_games on app_id.'
  )
}}

select * from {{ ref('stg_tags') }}