/*
    stg_prices
    ==========
    Cleans and renames price history from Bronze layer.

    Source: STEAM_BRONZE.RAW.RAW_PRICES (725,268 rows, 5 columns, has header)
    - Header: app_id, Date, Initialprice, Finalprice, Discount
    - 1,512 unique apps with price data
    - Date range: 2019-04-07 to 2020-08-12
    - Price range: $0.49 to $199.00
    - Discount range: 0 to 100 (percentage)
*/

select
    app_id,
    date                                as price_date,
    initialprice                        as initial_price,
    finalprice                          as final_price,
    discount                            as discount_pct,
    initialprice - finalprice           as discount_amount
from {{ source('steam_bronze', 'RAW_PRICES') }}
