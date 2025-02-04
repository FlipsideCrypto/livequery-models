{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}

SELECT 
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    TX_HASH,
    ORIGIN_FUNCTION_SIGNATURE,
    ORIGIN_FROM_ADDRESS,
    ORIGIN_TO_ADDRESS,
    EVENT_INDEX,
	CONTRACT_ADDRESS,
	TOPICS,
	DATA,
	EVENT_REMOVED,
	TX_STATUS,
	_LOG_ID
FROM
    {{ source(
        'ethereum_core',
        'fact_event_logs'
    ) }}
