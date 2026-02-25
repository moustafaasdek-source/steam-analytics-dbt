{{
  config(
    materialized = 'table',
    description  = 'Supported languages bridge table. One row per (app_id, language). Join to dim_games on app_id.'
  )
}}

select * from {{ ref('stg_languages') }}