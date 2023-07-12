{% test sequence_gaps(
    model,
    partition_by,
    column_name
) %}
{%- set partition_sql = partition_by | join(", ") -%}
{%- set previous_column = "prev_" ~ column_name -%}
WITH source AS (
    SELECT
        {{ partition_sql + "," if partition_sql }}
        {{ column_name }},
        LAG(
            {{ column_name }},
            1
        ) over (
            {{ "PARTITION BY " ~ partition_sql if partition_sql }}
            ORDER BY
                {{ column_name }} ASC
        ) AS {{ previous_column }}
    FROM
        {{ model }}
)
SELECT
    {{ partition_sql + "," if partition_sql }}
    {{ previous_column }},
    {{ column_name }},
    {{ column_name }} - {{ previous_column }}
    - 1 AS gap
FROM
    source
WHERE
    {{ column_name }} - {{ previous_column }} <> 1
ORDER BY
    gap DESC 
{% endtest %}

{% test tx_block_count(
        model,
        column_name
) %}

SELECT 
    {{ column_name }}, 
    COUNT(DISTINCT block_number) AS num_blocks
FROM
    {{ model }}
GROUP BY {{ column_name }}
HAVING num_blocks > 1
{% endtest %}

{% macro tx_gaps(
        model
    ) %}
    WITH block_base AS (
        SELECT
            block_number,
            tx_count
        FROM
            {{ ref('test_silver__blocks_full') }}
    ),
    model_name AS (
        SELECT
            block_number,
            COUNT(
                DISTINCT tx_hash
            ) AS model_tx_count
        FROM
            {{ model }}
        GROUP BY
            block_number
    )
SELECT
    block_base.block_number,
    tx_count,
    model_name.block_number AS model_block_number,
    model_tx_count
FROM
    block_base
    LEFT JOIN model_name
    ON block_base.block_number = model_name.block_number
WHERE
    (
        tx_count <> model_tx_count
    )
    OR (
        model_tx_count IS NULL
        AND tx_count <> 0
    )
{% endmacro %}

{% macro recent_tx_gaps(
        model
    ) %}
    WITH block_base AS (
        SELECT
            block_number,
            tx_count
        FROM
            {{ ref('test_silver__blocks_recent') }}
    ),
    model_name AS (
        SELECT
            block_number,
            COUNT(
                DISTINCT tx_hash
            ) AS model_tx_count
        FROM
            {{ model }}
        GROUP BY
            block_number
    )
SELECT
    block_base.block_number,
    tx_count,
    model_name.block_number AS model_block_number,
    model_tx_count
FROM
    block_base
    LEFT JOIN model_name
    ON block_base.block_number = model_name.block_number
WHERE
    (
        tx_count <> model_tx_count
    )
    OR (
        model_tx_count IS NULL
        AND tx_count <> 0
    )
{% endmacro %}