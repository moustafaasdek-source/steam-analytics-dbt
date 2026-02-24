/*
    stg_player_counts
    =================
    Combines and unifies the two player count datasets into daily granularity.

    Top 1000 (STEAM_BRONZE.RAW.RAW_PLAYER_COUNTS_TOP):
      - 23.35M rows, hourly timestamps (YYYY-MM-DD HH:MM:SS)
      - Aggregated to daily: avg, max, min player counts per app per day
      - Count of hourly observations preserved for data quality

    Bottom 1000 (STEAM_BRONZE.RAW.RAW_PLAYER_COUNTS_BOTTOM):
      - 973K rows, daily timestamps (YYYY-MM-DD)
      - Already daily — playercount used as avg = peak = min
      - 1,000 unique apps

    Combined date range: 2017-12-14 to 2020-08-12
    Data tier column distinguishes source dataset.
*/

with top_daily as (
    select
        app_id,
        time::DATE                      as activity_date,
        avg(playercount)::INTEGER       as avg_daily_players,
        max(playercount)::INTEGER       as peak_daily_players,
        min(playercount)::INTEGER       as min_daily_players,
        count(*)                        as hourly_observations,
        'top_1000'                      as data_tier
    from {{ source('steam_bronze', 'RAW_PLAYER_COUNTS_TOP') }}
    group by app_id, time::DATE
),

bottom_daily as (
    select
        app_id,
        time                            as activity_date,
        playercount::INTEGER            as avg_daily_players,
        playercount::INTEGER            as peak_daily_players,
        playercount::INTEGER            as min_daily_players,
        1                               as hourly_observations,
        'bottom_1000'                   as data_tier
    from {{ source('steam_bronze', 'RAW_PLAYER_COUNTS_BOTTOM') }}
)

select * from top_daily
union all
select * from bottom_daily
