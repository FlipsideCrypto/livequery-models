{{ config(
    materialized = 'view',
    grants = {'+select': fromyaml(var('ROLES'))}
) }}

SELECT 
    BLOCK_NUMBER,
	BLOCK_TIMESTAMP,
	TX_HASH,
	EVENT_INDEX,
	CONTRACT_ADDRESS,
	CONTRACT_NAME,
	EVENT_NAME,
	DECODED_LOG,
	FULL_DECODED_LOG,
	ORIGIN_FUNCTION_SIGNATURE,
	ORIGIN_FROM_ADDRESS,
	ORIGIN_TO_ADDRESS,
	TOPICS,
	DATA,
	EVENT_REMOVED,
	TX_STATUS
FROM
    {{ source(
        'ethereum_core',
        'ez_decoded_event_logs'
    ) }}
