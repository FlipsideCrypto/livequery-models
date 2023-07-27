{{ config(
    materialized = 'view',
    grants = {'+select': ['INTERNAL_DEV']}
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'ez_decoded_event_logs'
    ) }}