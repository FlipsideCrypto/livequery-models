-- depends_on: {{ ref('bronze__blocks') }}
-- depends_on: {{ ref('bronze__blocks_fr') }}
-- depends_on: {{ ref('fsc_evm', 'silver__blocks') }}
SELECT * FROM {{ ref('fsc_evm', 'core__fact_blocks') }}
