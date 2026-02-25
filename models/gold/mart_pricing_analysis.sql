/*
    mart_pricing_analysis
    =====================
    One row per price tier showing player engagement metrics.
    Answers: "Does game price affect player engagement?"

    Filters: only app_type = 'game' (excludes advertising, demos, mods, DLC).
    Expected output: 5 rows (Free to Play, $0-$5, $5-$15, $15-$30, $30+).
*/

with base as (
    select
        price_tier,
        peak_players,
        avg_daily_players,
        avg_final_price,
        language_count,
        genre_count
    from {{ ref('mart_game_summary') }}
    where app_type = 'game'
)

select
    price_tier,
    case price_tier
        when 'Free to Play' then 0
        when '$0-$5'        then 1
        when '$5-$15'       then 2
        when '$15-$30'      then 3
        when '$30+'         then 4
    end                                     as tier_sort_order,
    count(*)                                as game_count,
    round(avg(peak_players), 0)             as avg_peak_players,
    round(median(peak_players), 0)          as median_peak_players,
    round(avg(avg_daily_players), 0)        as avg_daily_players,
    round(avg(avg_final_price), 2)          as avg_price_in_tier,
    round(avg(language_count), 1)           as avg_languages,
    round(avg(genre_count), 1)              as avg_genres
from base
group by price_tier
order by tier_sort_order