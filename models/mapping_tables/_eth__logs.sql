{{ config(
    materialized = 'view',
    grants = {'+select': ['INTERNAL_DEV']}
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'fact_event_logs'
    ) }}