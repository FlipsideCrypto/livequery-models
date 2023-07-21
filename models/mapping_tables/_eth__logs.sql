{{ config(
    materialized = 'view'
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'fact_event_logs'
    ) }}