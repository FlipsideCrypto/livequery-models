{% macro config_near_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for the Near
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}

- name: {{ schema -}}.udf_get_block_data
  signature:
    - [file_url, STRING, File URL created using BUILD_SCOPED_FILE_URL() snowflake internal function]
  return_type:
    - VARIANT
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    PACKAGES = ('snowflake-snowpark-python')
    HANDLER = 'process_file'
    COMMENT = $$A UDF to retrieve NEAR block data stored in files from the Near Lake Snowflake External Stage.$$
  sql: |
    {{ near_live_view_udf_get_block_data() | indent(4) -}}

- name: {{ schema -}}.tf_get_block_data
  signature:
    - [file_urls, ARRAY, List of stage file URLs created using BUILD_SCOPED_FILE_URL() snowflake internal function]
  return_type:
    - "TABLE(block_data VARIANT)"
  options: |
    LANGUAGE PYTHON
    RUNTIME_VERSION = '3.11'
    PACKAGES = ('snowflake-snowpark-python')
    HANDLER = 'GetBlockData'
    COMMENT = $$A UDTF to retrieve NEAR block data stored in files from the Near Lake Snowflake External Stage.$$
  sql: |
    {{ near_live_view_get_block_data() | indent(4) -}}

- name: {{ schema -}}.tf_fact_blocks
  signature:
    - [block_id, INTEGER, The start block height to get the blocks from]
    - [to_latest, BOOLEAN, Whether to continue fetching blocks until the latest block or not]
  return_type:
    - "TABLE(block_id NUMBER, block_timestamp TIMESTAMP_NTZ, block_hash STRING, tx_count STRING, block_author STRING, header VARIANT, block_challenges_result VARIANT, block_challenges_root STRING, chunk_headers_root STRING, chunk_tx_root STRING, chunk_mask VARIANT, chunk_receipts_root STRING, chunks VARIANT, chunks_included NUMBER, epoch_id STRING, epoch_sync_data_hash STRING, events VARIANT, gas_price NUMBER, last_ds_final_block STRING, last_final_block STRING, latest_protocol_version NUMBER, next_bp_hash STRING, next_epoch_id STRING, outcome_root STRING, prev_hash STRING, prev_height NUMBER, prev_state_root STRING, random_value STRING, rent_paid FLOAT, signature STRING, total_supply NUMBER, validator_proposals VARIANT, validator_reward NUMBER, fact_blocks_id STRING, inserted_timestamp TIMESTAMP_NTZ, modified_timestamp TIMESTAMP_NTZ)"
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the block data for a given block height. If to_latest is true, it will continue fetching blocks until the latest block. Otherwise, it will fetch blocks until the block_id height is reached.$$
  sql: |
    {{ near_live_view_fact_blocks(schema, blockchain, network) | indent(4) -}}

{%- endmacro -%}

