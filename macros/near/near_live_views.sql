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


{% macro near_live_view_udf_get_block_data() %}
{#
    This macro generates a Python UDF for reading NEAR block data from Snowflake staged files mapped to the Near Lake.
    
    Returns:
        Python function that reads JSON block data:
            - Input: file_url (str) - Scoped file URL to block.json
        - Output: dict - Parsed block data

    Dependencies:
        - snowflake.snowpark.files
        - Stage read permissions
#}
    from snowflake.snowpark.files import SnowflakeFile

    def process_file(file_url: str) -> dict:
        """
        Process a single block data file from specified stage file URL.

        Args:
            file_url (str): The stage file URL created using BUILD_SCOPED_FILE_URL

        Returns:
            dict: The block data or error information

        Note:
            - File must contain valid NEAR blockchain block data in JSON format
            - If file fails to process, an error object is returned
        """
    
        with SnowflakeFile.open(file_url) as file:
            return file.read()
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
    block_height,
    ROW_NUMBER() OVER (ORDER BY block_height) - 1 as partition_num
FROM 
    (
        SELECT 
            row_number() over (order by seq4()) - 1 + COALESCE(block_height, 0)::integer as block_height,
            min_height,
            max_height
        FROM
            table(generator(ROWCOUNT => 1000)),
            {{ table_name }}
        QUALIFY block_height BETWEEN min_height AND max_height
    )
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
        partition_num,
        BUILD_SCOPED_FILE_URL(
            '@streamline.bronze.near_lake_data_mainnet', 
            CONCAT(LPAD(TO_VARCHAR(block_height), 12, '0'), '/block.json')
        ) as url
    FROM {{spine_table}}
)
SELECT 
    partition_num,
    url,
    PARSE_JSON({{ schema -}}.udf_get_block_data_(url::STRING)) as block_data
FROM block_urls

{% endmacro %}

-- Get Near fact data
{% macro get_fact_blocks_transformations(schema) %}
    {% set get_view_sql %}
        SELECT GET_DDL('VIEW', '{{ schema }}.fact_blocks')
    {% endset %}
    
    {% set results = run_query(get_view_sql) %}
    {% set view_ddl = results.rows[0][0] %}
    
    -- Find the inner SELECT with all the transformations
    {% set select_pos = view_ddl.find('SELECT\n    block_id') %}
    {% set from_pos = view_ddl.find('\nFROM\n    blocks') %}
    
    -- Extract just the transformations part
    {% set transformations = view_ddl[select_pos + 6:from_pos].strip() %}
    
    {% do log("Extracted transformations: " ~ transformations, info=True) %}
    
    {{ return(transformations) }}
{% endmacro %}


{% macro near_live_view_fact_blocks(schema, blockchain, network) %}
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
    {{ get_fact_blocks_transformations(schema) }}
FROM raw_blocks

{% endmacro %}
