from h2o_wave import ui, data, Q
import pyarrow as pa
from pyarrow import compute as pc
import asyncio
import time
from concurrent.futures import ThreadPoolExecutor
import snowflake.connector
from snowflake.connector import ProgrammingError
import os
import yaml

async def pull_data_from_snowflake(query: str):
    with snowflake.connector.connect(
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        session_parameters={
            "QUERY_TAG": "realtime_monitoring",
        },
    ) as conn:
        cur = conn.cursor()
        try:
            cur.execute_async(query)
            query_id = cur.sfqid

            try:
                while conn.is_still_running(conn.get_query_status_throw_if_error(query_id)):
                    time.sleep(1)
            except ProgrammingError as err:
                print('Programming Error: {0}'.format(err))

            results = []
            cur.get_results_from_sfqid(query_id)

            #TODO: work with PyArrow and yield in batches to avoid OOM
            for row in cur.fetch_arrow_batches():
                results.extend(row.to_pylist())

            return results
        finally:
            cur.close()



QUERY = """
    SELECT *
    FROM TABLE({SCHEMA}.{TABLE_FUNCTION_NAME}(
        {table_function_args}
    ));
"""

def load_table_list_from_yaml(yaml_file):
    with open(yaml_file, 'r') as file:
        data = yaml.safe_load(file)
        return data

# table_lists = load_table_list_from_yaml('apps/table_list.yaml')

async def fetch_data_for_schema_table(schema, table, args):
    latest_block_height = 0
    query = QUERY.format(
        DATABASE=os.getenv("SNOWFLAKE_DATABASE"),
        SCHEMA=schema,
        TABLE_FUNCTION_NAME=table,
        table_function_args=args,
    )
    results = await pull_data_from_snowflake(query)
    if results:
        results_table = pa.Table.from_pylist(results)
        latest_block_height = pc.max(results_table.column('BLOCK_NUMBER')).as_py()

    return (latest_block_height, results_table)

# async def gather_tasks_and_parse_args(q: Q):
#     """
#     Gather tasks and parse args for each table and network.
#     """
#     table_lists = load_table_list_from_yaml('apps/table_list.yaml')
#     tables = table_lists['tables']

#     loop = asyncio.get_event_loop()
#     with ThreadPoolExecutor() as executor:
#         tasks = []
#         for table in tables:
#             blockchain = table['blockchain']
#             for network in table['networks']:
#                 for network_name, network_data in network.items():
#                     schema = f"{blockchain}_{network_name}"
#                     for table_data in network_data['tables']:
#                         table_name = table_data['name']
#                         args = {**network_data['default_args'], **table_data.get('extra_args', {})}
#                         formatted_args = ', '.join(f"{key}={arg['value']}::{arg['type']}" for key, arg in args.items())
#                         tasks.append(
#                             loop.run_in_executor(
#                                 executor, fetch_data_for_schema_table, q, schema, table_name, formatted_args
#                             )
#                         )
#         await asyncio.gather(*tasks)

async def execute_query() -> pa.Table:
    table_lists = {
        "schema": "ethereum_mainnet",
        "table": "tf_ez_token_transfers",
        "args": [
            {
                "block_height": "NULL::INTEGER",
                "to_latest": "TRUE::BOOLEAN",
                "ez_token_transfers_id": "'0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'::STRING"
            }
        ]
    }

    initial_args = ', '.join(f"{value}" for arg in table_lists['args'] for _, value in arg.items())
    latest_block_height, data_table = await fetch_data_for_schema_table(table_lists['schema'], table_lists['table'], initial_args)

    # Forever loop to fetch new data
    while True:
        table_lists['args'][0]['block_height'] = f"{latest_block_height}::INTEGER"
        updated_args = ', '.join(f"{value}" for arg in table_lists['args'] for _, value in arg.items())
        latest_block_height, data_table = await fetch_data_for_schema_table(table_lists['schema'], table_lists['table'], updated_args)

        yield data_table

if __name__ == "__main__":
    # data = asyncio.run(execute_query())
    import logging

    logging.basicConfig(level=logging.INFO)

    async def log_data():
        async for data_table in execute_query():
            data_array = data_table.to_pylist()
            logging.info(data_array)

    asyncio.run(log_data())
