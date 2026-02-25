{{
  config(
    materialized = 'table',
    description  = 'Game dimension table. One row per Steam app. Core dimension for star schema — join to all fact and bridge tables via app_id.'
  )
}}

/*
    dim_games
    =========
    Central dimension in the star schema.
    Enriches stg_games with aggregated counts from bridge tables.
    Grain: one row per Steam application (app_id).

    Joins:
      dim_games ◄──(app_id)── fact_player_counts
      dim_games ◄──(app_id)── fact_prices
      dim_games ◄──(app_id)── dim_genres / dim_tags / dim_developers / etc.
*/

with games as (
    select * from {{ ref('stg_games') }}
),

genre_count as (
    select app_id, count(*) as genre_count
    from {{ ref('stg_genres') }}
    group by app_id
),

tag_count as (
    select app_id, count(*) as tag_count
    from {{ ref('stg_tags') }}
    group by app_id
),

lang_count as (
    select app_id, count(*) as language_count
    from {{ ref('stg_languages') }}
    group by app_id
),

player_summary as (
    select
        app_id,
        max(peak_daily_players)          as peak_players,
        round(avg(avg_daily_players), 0) as avg_daily_players,
        count(distinct activity_date)    as days_with_data
    from {{ ref('stg_player_counts') }}
    group by app_id
),

price_summary as (
    select
        app_id,
        round(avg(initial_price), 2)     as avg_initial_price,
        round(avg(final_price), 2)       as avg_final_price,
        max(discount_pct)                as max_discount_pct,
        round(avg(discount_pct), 1)      as avg_discount_pct
    from {{ ref('stg_prices') }}
    group by app_id
)

select
    g.app_id,
    g.app_name,
    g.app_type,
    g.release_date,
    g.release_year,
    g.release_month,
    g.is_free_to_play,

    coalesce(gc.genre_count, 0)      as genre_count,
    coalesce(tc.tag_count, 0)        as tag_count,
    coalesce(lc.language_count, 0)   as language_count,

    coalesce(pl.peak_players, 0)     as peak_players,
    coalesce(pl.avg_daily_players, 0) as avg_daily_players,
    coalesce(pl.days_with_data, 0)   as days_with_data,

    coalesce(pr.avg_initial_price, 0) as avg_initial_price,
    coalesce(pr.avg_final_price, 0)   as avg_final_price,
    coalesce(pr.max_discount_pct, 0)  as max_discount_pct,
    coalesce(pr.avg_discount_pct, 0)  as avg_discount_pct,

    -- Derived: price tier
    case
        when g.is_free_to_play then 'Free to Play'
        when coalesce(pr.avg_final_price, 0) = 0 then 'Free to Play'
        when pr.avg_final_price <= 5   then '$0-$5'
        when pr.avg_final_price <= 15  then '$5-$15'
        when pr.avg_final_price <= 30  then '$15-$30'
        else '$30+'
    end as price_tier,

    -- Derived: popularity quartile
    ntile(4) over (
        order by coalesce(pl.peak_players, 0)
    ) as popularity_quartile

from games g
left join genre_count    gc on g.app_id = gc.app_id
left join tag_count      tc on g.app_id = tc.app_id
left join lang_count     lc on g.app_id = lc.app_id
left join player_summary pl on g.app_id = pl.app_id
left join price_summary  pr on g.app_id = pr.app_id