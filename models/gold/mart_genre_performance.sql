/*
    mart_genre_performance
    ======================
    One row per genre with aggregated game metrics.
    Joins stg_genres with mart_game_summary for pre-computed metrics.

    Filters: only genres with at least 5 games (removes noise from rare genres).
    Expected output: ~20-25 rows (26 unique genres minus very rare ones).
*/

with game_genre as (
    select
        gen.genre,
        gs.app_id,
        gs.is_free_to_play,
        gs.peak_players,
        gs.avg_daily_players,
        gs.avg_final_price,
        gs.language_count,
        gs.genre_count
    from {{ ref('stg_genres') }} gen
    inner join {{ ref('mart_game_summary') }} gs using (app_id)
)

select
    genre,
    count(distinct app_id)                                          as game_count,
    round(avg(peak_players), 0)                                     as avg_peak_players,
    round(median(peak_players), 0)                                  as median_peak_players,
    round(avg(avg_daily_players), 0)                                as avg_daily_players,
    round(avg(avg_final_price), 2)                                  as avg_price,
    round(100.0 * count_if(is_free_to_play) / count(*), 1)         as free_to_play_pct,
    round(avg(language_count), 1)                                   as avg_languages
from game_genre
group by genre
having game_count >= 5
order by avg_peak_players desc
