-- depends_on: {{ ref('bronze__blocks') }}
-- depends_on: {{ ref('bronze__blocks_fr') }}
SELECT * FROM {{ ref('fsc_evm', 'silver__blocks') }}
