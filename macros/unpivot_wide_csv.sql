{#
    unpivot_wide_csv
    ================
    Converts a headerless wide-format CSV table (COL0 = app_id, COL1..COLn = values)
    into a long-format table with columns (app_id, <value_alias>).

    The raw CSV files for genres, tags, developers, publishers, languages, and packages
    have variable column counts per row. Snowflake loads them into COL0, COL1, ..., COLn
    with NULLs for missing trailing columns.

    This macro generates a UNION ALL of SELECT statements — one per column position —
    then deduplicates the results.

    Parameters:
        source_name  : dbt source name (e.g. 'steam_bronze')
        table_name   : source table name (e.g. 'RAW_GENRES')
        max_cols     : total number of columns in the table (including COL0)
        value_alias  : output column name (e.g. 'genre', 'tag', 'developer')
#}

{% macro unpivot_wide_csv(source_name, table_name, max_cols, value_alias) %}

with raw as (
    select * from {{ source(source_name, table_name) }}
),

unpivoted as (
    {% for i in range(1, max_cols) %}
    select
        col0::INTEGER   as app_id,
        trim(col{{ i }}) as {{ value_alias }}
    from raw
    where trim(col{{ i }}) is not null
      and trim(col{{ i }}) != ''
    {% if not loop.last %} union all {% endif %}
    {% endfor %}
)

select distinct app_id, {{ value_alias }}
from unpivoted
where {{ value_alias }} is not null

{% endmacro %}
