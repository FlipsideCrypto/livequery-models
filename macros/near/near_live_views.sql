-- Get Near Chain Head
{% macro near_live_view_latest_block_height(schema, blockchain, network) %}
SELECT
    live.udf_api(
        'https://rpc.mainnet.near.org',
        utils.udf_json_rpc_call(
            'block',
            {'finality': 'final'}
        )
    ):data AS result,
    result:result:header:height::integer as latest_block_height,
    coalesce(
        block_id,
        latest_block_height
    ) as min_height,
    iff(
        coalesce(to_latest, false),
        latest_block_height,
        min_height
    ) as max_height
{% endmacro %}

{% macro near_live_view_get_block_data() %}
    import json
    from typing import Iterator, Tuple
    from snowflake.snowpark.files import SnowflakeFile

    class GetBlockData:
        """
        A class to retrieve and process multiple NEAR blockchain block data files in bulk from Snowflake External Stage.

        This class serves as a handler for a Snowflake User-Defined Table Function (UDTF)
        that reads JSON block data from multiple stage files and yields the block data as a 
        VARIANT column. The block height and other data can be extracted from the block_data directly.

        Attributes:
            None

        Example:
            To use this function in Snowflake:
            ```sql
            SELECT * 
            FROM TABLE(get_block_data_bulk(ARRAY_CONSTRUCT(
                BUILD_SCOPED_FILE_URL(@stage_name, '000132121137/block.json'),
                BUILD_SCOPED_FILE_URL(@stage_name, '000132121138/block.json')
            )));
            ```
        """

        def process(self, file_urls: list) -> Iterator[Tuple[dict]]:
            """
            Process multiple block data files from specified stage file URLs.

            Args:
                file_urls (list): A list of stage file URLs created using BUILD_SCOPED_FILE_URL

            Yields:
                Iterator[Tuple[dict]]: A series of single-element tuples, each containing
                                    the complete block data structure or an error object

            Note:
                - Files must contain valid NEAR blockchain block data in JSON format
                - If a file fails to process, an error object is returned instead of skipping
                - The resulting block_data column can be queried using standard SQL JSON path notation
            """
            for file_url in file_urls:
                try:
                    with SnowflakeFile.open(file_url) as file:
                        block_data = json.load(file)
                        yield (block_data,)
                except json.JSONDecodeError as e:
                    error_info = {
                        'error': 'JSONDecodeError',
                        'details': f'Invalid JSON data: {str(e)}',
                        'url': file_url
                    }
                    yield (error_info,)
                except Exception as e:
                    error_info = {
                        'error': e.__class__.__name__,
                        'details': str(e),
                        'url': file_url
                    }
                    yield (error_info,)
{% endmacro %}

{% macro near_live_view_get_spine(schema, blockchain, network) %}
SELECT
    row_number() over (order by null) - 1 + COALESCE(block_id, 0)::integer as block_height,
    min_height,
    max_height,
    latest_block_height
FROM
    table(generator(ROWCOUNT => 1000)),
    heights 
    QUALIFY block_height BETWEEN min_height AND max_height
{% endmacro %}


-- Get near blocks
{% macro near_live_view_get_raw_blocks(schema, blockchain, network, table_name) %}
SELECT
    block_height,
    live.udf_api(
        'https://rpc.mainnet.near.org',
        utils.udf_json_rpc_call(
            'block',
            {'block_id': block_height}
        )
    ):data.result AS block_data
from
    {{ table_name }}
{% endmacro %}

-- Get Near fact data
{% macro near_live_view_fact_blocks(schema, blockchain, network) %}
WITH heights AS (
    {{ near_live_view_latest_block_height(schema, blockchain, network) }}
),
spine AS (
    {{ near_live_view_get_spine(schema, blockchain, network) }}
),
raw_blocks AS (
    WITH block_urls AS (
        SELECT 
            s.block_height,
            ARRAY_AGG(
                BUILD_SCOPED_FILE_URL(
                    '@streamline.bronze.near_lake_data_mainnet', 
                    CONCAT(LPAD(TO_VARCHAR(s.block_height), 12, '0'), '/block.json')
                )
            ) OVER () as urls
        FROM spine s
    )
    SELECT 
        u.block_height,
        b.block_data
    FROM block_urls u,
        TABLE({{ schema -}}.tf_get_block_data(u.urls)) b
)
SELECT
    block_data:header:height::NUMBER(38,0) as block_id,
    TO_TIMESTAMP_NTZ(block_data:header:timestamp::STRING) as block_timestamp,
    block_data:header:hash::STRING as block_hash,
    ARRAY_SIZE(block_data:chunks)::STRING as tx_count,
    block_data:author::STRING as block_author,
    block_data:header as header,
    block_data:header:challenges_result as block_challenges_result,  -- Removed ::ARRAY cast
    block_data:header:challenges_root::STRING as block_challenges_root,
    block_data:header:chunk_headers_root::STRING as chunk_headers_root,
    block_data:header:chunk_tx_root::STRING as chunk_tx_root,
    block_data:header:chunk_mask as chunk_mask,  -- Removed ::ARRAY cast
    block_data:header:chunk_receipts_root::STRING as chunk_receipts_root,
    block_data:chunks as chunks,
    block_data:header:chunks_included::NUMBER(38,0) as chunks_included,
    block_data:header:epoch_id::STRING as epoch_id,
    block_data:header:epoch_sync_data_hash::STRING as epoch_sync_data_hash,
    block_data:events as events,
    block_data:header:gas_price::NUMBER(38,0) as gas_price,
    block_data:header:last_ds_final_block::STRING as last_ds_final_block,
    block_data:header:last_final_block::STRING as last_final_block,
    block_data:header:latest_protocol_version::NUMBER(38,0) as latest_protocol_version,
    block_data:header:next_bp_hash::STRING as next_bp_hash,
    block_data:header:next_epoch_id::STRING as next_epoch_id,
    block_data:header:outcome_root::STRING as outcome_root,
    block_data:header:prev_hash::STRING as prev_hash,
    block_data:header:prev_height::NUMBER(38,0) as prev_height,
    block_data:header:prev_state_root::STRING as prev_state_root,
    block_data:header:random_value::STRING as random_value,
    block_data:header:rent_paid::FLOAT as rent_paid,
    block_data:header:signature::STRING as signature,
    block_data:header:total_supply::NUMBER(38,0) as total_supply,
    block_data:header:validator_proposals as validator_proposals,
    block_data:header:validator_reward::NUMBER(38,0) as validator_reward,
    MD5(block_data:header:height::STRING)::VARCHAR(32) as fact_blocks_id,
    SYSDATE()::TIMESTAMP_NTZ(9) as inserted_timestamp,
    SYSDATE()::TIMESTAMP_NTZ(9) as modified_timestamp
FROM raw_blocks
WHERE block_data IS NOT NULL

{% endmacro %}
