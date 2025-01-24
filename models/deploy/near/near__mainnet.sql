-- depends_on: {{ ref('near_models','core__fact_blocks') }}
-- depends_on: {{ ref('silver__streamline_blocks') }}
-- depends_on: {{ ref('silver__streamline_shards') }}
-- depends_on: {{ ref('silver__streamline_transactions') }}
-- depends_on: {{ ref('silver__streamline_transactions_final') }}
-- depends_on: {{ ref('silver__streamline_receipts') }}
-- depends_on: {{ ref('silver__streamline_receipts_final') }}
-- depends_on: {{ ref('silver__flatten_receipts') }}
-- depends_on: {{ ref('silver__receipt_tx_hash_mapping') }}
-- depends_on: {{ ref('near_models', 'core__fact_transactions') }}
-- depends_on: {{ ref('near_models', 'core__fact_receipts') }}
{%- set configs = [
    config_near_high_level_abstractions
    ] -%}

{{- ephemeral_deploy(configs) -}}
