{{
  config(
    materialized = 'table',
    description  = 'Publisher bridge table. One row per (app_id, publisher). Join to dim_games on app_id.'
  )
}}

select * from {{ ref('stg_publishers') }}
