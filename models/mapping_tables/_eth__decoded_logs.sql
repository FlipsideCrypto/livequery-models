{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'ez_decoded_event_logs'
    ) }}
