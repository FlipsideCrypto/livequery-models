{% macro config_near_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for the Near
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}
- name: {{ schema -}}.tf_fact_blocks
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - - name: {{ schema -}}.tf_fact_blocks
  signature:
    - [block_height, INTEGER, The start block height to get the transfers from]
    - [to_latest, BOOLEAN, Whether to continue fetching transfers until the latest block or not]
  return_type:
    - "TABLE(block_id NUMBER, block_timestamp TIMESTAMP_NTZ, block_hash STRING, tx_count STRING, block_author STRING, header OBJECT, block_challenges_result ARRAY, block_challenges_root STRING, chunk_headers_root STRING, chunk_tx_root STRING, chunk_mask ARRAY, chunk_receipts_root STRING, chunks ARRAY, chunks_included NUMBER, epoch_id STRING, epoch_sync_data_hash STRING, events ARRAY, gas_price NUMBER, last_ds_final_block STRING, last_final_block STRING, latest_protocol_version NUMBER, next_bp_hash STRING, next_epoch_id STRING, outcome_root STRING, prev_hash STRING, prev_height NUMBER, prev_state_root STRING, random_value STRING, rent_paid FLOAT, signature STRING, total_supply NUMBER, validator_proposals ARRAY, validator_reward NUMBER, fact_blocks_id STRING, inserted_timestamp TIMESTAMP_LTZ, modified_timestamp TIMESTAMP_LTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the block data for a given block height. If to_latest
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the block data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block height is reached.$$
  sql: |
    {{ near_live_view_fact_blocks(schema, blockchain, network) | indent(4) -}}

{%- endmacro -%}