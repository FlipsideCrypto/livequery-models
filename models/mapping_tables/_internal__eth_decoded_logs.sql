{{ config(
    materialized = 'view'
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'ez_decoded_event_logs'
    ) }}