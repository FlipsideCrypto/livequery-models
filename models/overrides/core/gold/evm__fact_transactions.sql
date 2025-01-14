-- depends_on: {{ ref('bronze__blocks') }}
-- depends_on: {{ ref('bronze__blocks_fr') }}
-- depends_on: {{ ref('bronze__transactions') }}
-- depends_on: {{ ref('bronze__transactions_fr') }}
-- depends_on: {{ ref('bronze__receipts') }}
-- depends_on: {{ ref('bronze__receipts_fr') }}
-- depends_on: {{ ref('fsc_evm', 'silver__blocks') }}
-- depends_on: {{ ref('fsc_evm', 'silver__transactions') }}
-- depends_on: {{ ref('fsc_evm', 'core__fact_blocks') }}
-- depends_on: {{ ref('fsc_evm', 'silver__receipts') }}


SELECT * FROM {{ ref('fsc_evm', 'core__fact_transactions') }}
