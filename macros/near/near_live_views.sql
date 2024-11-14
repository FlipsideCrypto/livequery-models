-- Get Near Chain Head
{% macro near_live_view_latest_block_height() %}
{#
     This macro retrieves the latest block height from the NEAR blockchain.
    
    Args:
        schema (str): The schema name.
        blockchain (str): The blockchain name.
        network (str): The network name.

    Returns:
        SQL query: A query that selects the latest block
#}
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
    import multiprocessing as mp
    from queue import Queue
    from threading import Thread

    class GetBlockData:
        """
        A class to retrieve and process multiple NEAR blockchain block data files from Snowflake External Stage.
        Uses threading from standard library for concurrent processing.
        
        The implementation uses a thread pool pattern with a work queue for better resource management
        and controlled concurrency.
        """
        
        def __init__(self):
            self.num_workers = min(10, mp.cpu_count() * 2)  # Number of worker threads
            self.chunk_size = 50  # Process files in chunks
            
        def _process_file(self, file_url: str) -> Tuple[dict]:
            """Process a single file from the stage."""
            try:
                with SnowflakeFile.open(file_url) as file:
                    block_data = json.load(file)
                    return (block_data,)
            except json.JSONDecodeError as e:
                return ({
                    'error': 'JSONDecodeError',
                    'details': f'Invalid JSON data: {str(e)}',
                    'url': file_url
                },)
            except Exception as e:
                return ({
                    'error': e.__class__.__name__,
                    'details': str(e),
                    'url': file_url
                },)

        def _worker(self, queue: Queue, results: list):
            """Worker thread to process files from the queue."""
            while True:
                file_url = queue.get()
                if file_url is None:  # Poison pill
                    break
                result = self._process_file(file_url)
                results.append(result)
                queue.task_done()

        def process(self, file_urls: list) -> Iterator[Tuple[dict]]:
            """
            Process multiple block data files using a thread pool.
            
            Args:
                file_urls (list): List of stage file URLs to process
                
            Yields:
                Iterator[Tuple[dict]]: Processed block data or error information
            """
            # Process files in chunks to manage memory
            for i in range(0, len(file_urls), self.chunk_size):
                chunk = file_urls[i:i + self.chunk_size]
                
                # Set up the thread pool
                queue = Queue()
                results = []
                threads = []
                
                # Start worker threads
                for _ in range(self.num_workers):
                    t = Thread(target=self._worker, args=(queue, results))
                    t.start()
                    threads.append(t)
                
                # Add work to the queue
                for url in chunk:
                    queue.put(url)
                
                # Add poison pills to stop workers
                for _ in range(self.num_workers):
                    queue.put(None)
                
                # Wait for all work to complete
                for t in threads:
                    t.join()
                
                # Yield results
                yield from results
{% endmacro %}

{% macro near_live_view_get_spine(table_name) %}
{#
    This macro generates a spine table for block height ranges, it creates a sequence of block heights between `min_height` and `max_height`using
    Snowflake's generator function.

    Args:
        table_name (str): Reference to a CTE or table that contains:
            - block_id: Starting block height
            - min_height: Minimum block height to generate
            - max_height: Maximum block height to generate
            - latest_block_height: Current chain head block height

#}
SELECT
    row_number() over (order by null) - 1 + COALESCE(block_id, 0)::integer as block_height,
    min_height,
    max_height,
    latest_block_height
FROM
    table(generator(ROWCOUNT => 1000)),
    {{ table_name }} 
    QUALIFY block_height BETWEEN min_height AND max_height
{% endmacro %}


{% macro near_live_view_get_raw_block_data(spine_table, schema) %}
 {#
    This macro generates SQL that retrieves raw block data from the Near Lake data stored in Snowflake external stage.
    
    It constructs URLs for block data files and uses a table function to fetch and parse the JSON data.

    The macro performs two main operations:
    
    1. Generates scoped file URLs for each block height using the Near Lake file naming convention
    2. Calls the tf_get_block_data function to fetch and parse the block JSON data

    Args:
        spine_table (str): Reference to a CTE or table containing:
            - block_height (INTEGER): The block heights to fetch data for

    Returns:
        str: A SQL query that returns a table with columns:
            - block_height (INTEGER): The height of the block
            - block_data (VARIANT): The parsed JSON data for the block

    Note:
        - Requires access to '@streamline.bronze.near_lake_data_mainnet' stage
        - Block files must follow the format: XXXXXXXXXXXX/block.json where X is the zero-padded block height
        - Uses the tf_get_block_data table function to parse JSON data
#}
 
WITH block_urls AS (
    SELECT 
        s.block_height,
        ARRAY_AGG(
            BUILD_SCOPED_FILE_URL(
                '@streamline.bronze.near_lake_data_mainnet', 
                CONCAT(LPAD(TO_VARCHAR(s.block_height), 12, '0'), '/block.json')
            )
        ) OVER () as urls
    FROM {{ spine_table }} s
)
SELECT 
    u.block_height,
    b.block_data
FROM block_urls u,
    TABLE({{ schema }}.tf_get_block_data(u.urls)) b
{% endmacro %}

-- Get Near fact data
{% macro near_live_view_fact_blocks(schema, blockchain, network) %}
{#
    This macro generates a SQL query to fetch and transform NEAR blockchain block data.

    The macro creates a series of CTEs to:
    1. Get the latest block height using near_live_view_latest_block_height
    2. Generate a spine table for block range using near_live_view_get_spine
    3. Fetch block data from Near Lake using tf_get_block_data
    4. Transform the raw block data into a structured format reflecting the near.core.fact_blocks table

#}

WITH heights AS (
    {{ near_live_view_latest_block_height() | indent(4) }}
),
spine AS (
    {{ near_live_view_get_spine('heights') | indent(4) }}
),
raw_blocks AS (
    {{ near_live_view_get_raw_block_data('spine', schema) | indent(4) }}
)
SELECT
    block_data:header:height::NUMBER(38,0) as block_id,
    TO_TIMESTAMP_NTZ(block_data:header:timestamp::STRING) as block_timestamp,
    block_data:header:hash::STRING as block_hash,
    ARRAY_SIZE(block_data:chunks)::STRING as tx_count,
    block_data:author::STRING as block_author,
    block_data:header as header,
    block_data:header:challenges_result as block_challenges_result,  
    block_data:header:challenges_root::STRING as block_challenges_root,
    block_data:header:chunk_headers_root::STRING as chunk_headers_root,
    block_data:header:chunk_tx_root::STRING as chunk_tx_root,
    block_data:header:chunk_mask as chunk_mask, 
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
