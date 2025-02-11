-- depends_on: {{ ref('bronze__decoded_logs') }}
-- depends_on: {{ ref('bronze__decoded_logs_fr') }}
-- depends_on: {{ ref('fsc_evm', 'silver__decoded_logs') }}
-- depends_on: {{ ref('core__dim_contracts')}}

SELECT * FROM {{ ref('fsc_evm', 'core__ez_decoded_event_logs') }}
