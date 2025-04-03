{% macro config_near_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for the Near
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}


- name: {{ schema -}}.tf_fact_blocks
  signature:
    - [_block_height, INTEGER, The start block height to get the blocks from]
    - [to_latest, BOOLEAN, Whether to continue fetching blocks until the latest block or not]
  return_type:
    - "TABLE(block_id NUMBER, block_timestamp TIMESTAMP_NTZ, block_hash STRING, block_author STRING, header OBJECT, block_challenges_result ARRAY, block_challenges_root STRING, chunk_headers_root STRING, chunk_tx_root STRING, chunk_mask ARRAY, chunk_receipts_root STRING, chunks ARRAY, chunks_included NUMBER, epoch_id STRING, epoch_sync_data_hash STRING, gas_price FLOAT, last_ds_final_block STRING, last_final_block STRING, latest_protocol_version INT, next_bp_hash STRING, next_epoch_id STRING, outcome_root STRING, prev_hash STRING, prev_height NUMBER, prev_state_root STRING, random_value STRING, rent_paid FLOAT, signature STRING, total_supply FLOAT, validator_proposals ARRAY, validator_reward FLOAT, fact_blocks_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the block data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block_id height is reached.$$
  sql: |
    {{ near_live_table_fact_blocks(schema, blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_transactions
  signature:
    - [_block_height, INTEGER, The start block height to get the transactions from]
    - [to_latest, BOOLEAN, Whether to continue fetching blocks until the latest block or not]
  return_type:
    - "TABLE(tx_hash STRING, block_id NUMBER, block_timestamp TIMESTAMP_NTZ, block_timestamp_epoch INTEGER, shard_id INTEGER, nonce INT, signature STRING, tx_receiver STRING, tx_signer STRING, tx VARIANT, gas_used FLOAT, transaction_fee FLOAT, attached_gas FLOAT, tx_succeeded BOOLEAN, fact_transactions_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns transaction details for blocks starting from a given height. Fetches up to the latest block if to_latest is true.$$
  sql: |
    {{ near_live_table_fact_transactions_unabstracted(schema, blockchain, network) | indent(4) -}}

- name: {{ schema -}}.tf_fact_transactions_test
  signature:
    - [_block_height, INTEGER, The start block height to get the transactions from]
    - [to_latest, BOOLEAN, Whether to continue fetching blocks until the latest block or not]
  return_type:
    - "TABLE(tx_hash STRING, block_id NUMBER, block_timestamp TIMESTAMP_NTZ, nonce INT, signature STRING, tx_receiver STRING, tx_signer STRING, tx VARIANT, gas_used NUMBER, transaction_fee NUMBER, attached_gas NUMBER, tx_succeeded BOOLEAN, fact_transactions_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns transaction details for blocks starting from a given height. Fetches up to the latest block if to_latest is true.$$
  sql: |
    {{ near_live_table_fact_transactions(schema, blockchain, network) | indent(4) -}}

{%- endmacro -%}

