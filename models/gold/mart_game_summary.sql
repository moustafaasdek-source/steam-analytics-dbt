/*
    mart_game_summary
    =================
    Primary analytics mart: ONE ROW PER GAME with all metrics pre-joined.

    Joins stg_games with aggregated data from:
    - stg_genres (concatenated list + count)
    - stg_tags (concatenated list + count)
    - stg_developers (concatenated list + count)
    - stg_publishers (concatenated list)
    - stg_languages (count)
    - stg_prices (avg initial/final price, max/avg discount)
    - stg_player_counts (peak, avg daily, days with data)

    Derived columns:
    - price_tier: categorical bucket based on avg final price
    - popularity_quartile: NTILE(4) based on peak players

    Expected output: ~2,000 rows (one per app in applicationInformation)
*/

with games as (
    select * from {{ ref('stg_games') }}
),

genre_agg as (
    select
        app_id,
        listagg(genre, ', ') within group (order by genre)  as genres,
        count(*)                                              as genre_count
    from {{ ref('stg_genres') }}
    group by app_id
),

tag_agg as (
    select
        app_id,
        listagg(tag, ', ') within group (order by tag)      as tags,
        count(*)                                              as tag_count
    from {{ ref('stg_tags') }}
    group by app_id
),

dev_agg as (
    select
        app_id,
        listagg(developer, ', ') within group (order by developer) as developers,
        count(*)                                                    as developer_count
    from {{ ref('stg_developers') }}
    group by app_id
),

pub_agg as (
    select
        app_id,
        listagg(publisher, ', ') within group (order by publisher) as publishers
    from {{ ref('stg_publishers') }}
    group by app_id
),

lang_agg as (
    select
        app_id,
        count(*) as language_count
    from {{ ref('stg_languages') }}
    group by app_id
),

price_agg as (
    select
        app_id,
        round(avg(initial_price), 2)       as avg_initial_price,
        round(avg(final_price), 2)         as avg_final_price,
        max(discount_pct)                   as max_discount_pct,
        round(avg(discount_pct), 1)        as avg_discount_pct
    from {{ ref('stg_prices') }}
    group by app_id
),

player_agg as (
    select
        app_id,
        max(peak_daily_players)             as peak_players,
        round(avg(avg_daily_players), 0)    as avg_daily_players,
        count(distinct activity_date)       as days_with_data
    from {{ ref('stg_player_counts') }}
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

    -- Genres
    coalesce(gen.genres, 'Unknown')             as genres,
    coalesce(gen.genre_count, 0)                as genre_count,

    -- Tags
    coalesce(t.tags, 'None')                    as tags,
    coalesce(t.tag_count, 0)                    as tag_count,

    -- Developers & Publishers
    coalesce(d.developers, 'Unknown')           as developers,
    coalesce(d.developer_count, 0)              as developer_count,
    coalesce(pub.publishers, 'Unknown')         as publishers,

    -- Languages
    coalesce(l.language_count, 0)               as language_count,

    -- Prices
    coalesce(pr.avg_initial_price, 0)           as avg_initial_price,
    coalesce(pr.avg_final_price, 0)             as avg_final_price,
    coalesce(pr.max_discount_pct, 0)            as max_discount_pct,
    coalesce(pr.avg_discount_pct, 0)            as avg_discount_pct,

    -- Player counts
    coalesce(pl.peak_players, 0)                as peak_players,
    coalesce(pl.avg_daily_players, 0)           as avg_daily_players,
    coalesce(pl.days_with_data, 0)              as days_with_data,

    -- Derived: price tier
    case
        when g.is_free_to_play then 'Free to Play'
        when coalesce(pr.avg_final_price, 0) = 0 then 'Free to Play'
        when pr.avg_final_price <= 5   then '$0-$5'
        when pr.avg_final_price <= 15  then '$5-$15'
        when pr.avg_final_price <= 30  then '$15-$30'
        else '$30+'
    end                                         as price_tier,

    -- Derived: popularity quartile (1=lowest, 4=highest)
    ntile(4) over (
        order by coalesce(pl.peak_players, 0)
    )                                           as popularity_quartile

from games g
left join genre_agg   gen on g.app_id = gen.app_id
left join tag_agg     t   on g.app_id = t.app_id
left join dev_agg     d   on g.app_id = d.app_id
left join pub_agg     pub on g.app_id = pub.app_id
left join lang_agg    l   on g.app_id = l.app_id
left join price_agg   pr  on g.app_id = pr.app_id
left join player_agg  pl  on g.app_id = pl.app_id