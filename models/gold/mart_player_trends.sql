/*
    mart_player_trends
    ==================
    Monthly platform-wide player activity trends with Year-over-Year growth.

    Aggregation flow:
    1. stg_player_counts (daily per app) → sum across apps per day
    2. daily totals → monthly averages
    3. Compute YoY growth by comparing same month across years

    Date range: 2017-12 to 2020-08 (~33 months of data)
*/

with daily as (
    select
        activity_date,
        sum(avg_daily_players)      as total_daily_players,
        count(distinct app_id)      as active_games
    from {{ ref('stg_player_counts') }}
    group by activity_date
),

monthly as (
    select
        to_char(activity_date, 'YYYY-MM')       as year_month,
        year(activity_date)                      as yr,
        month(activity_date)                     as mo,
        round(avg(total_daily_players), 0)       as avg_total_daily_players,
        round(avg(active_games), 0)              as avg_active_games,
        count(distinct activity_date)            as days_in_month
    from daily
    group by 1, 2, 3
),

with_lag as (
    select
        m.*,
        lag(avg_total_daily_players) over (
            partition by mo order by yr
        ) as prev_year_players
    from monthly m
)

select
    year_month,
    avg_total_daily_players,
    avg_active_games,
    days_in_month,
    prev_year_players,
    round(
        100.0 * (avg_total_daily_players - prev_year_players)
              / nullif(prev_year_players, 0),
        1
    ) as yoy_growth_pct
from with_lag
order by year_month
