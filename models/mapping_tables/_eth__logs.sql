{{ config(
    materialized = 'view',
    grants = {'+select': var('ROLES')}
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'fact_event_logs'
    ) }}
