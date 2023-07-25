{{ config(
    materialized = 'view',
    revokes = {"select": ["VELOCITY_INTERNAL", "VELOCITY_ETHEREUM"]}
) }}

SELECT *
FROM
    {{ source(
        'ethereum_core',
        'ez_decoded_event_logs'
    ) }}