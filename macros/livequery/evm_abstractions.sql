{% macro evm_latest_native_balance_string(schema, blockchain) %}
SELECT
    lower(wallet) AS wallet_address,
    '{{blockchain}}' AS blockchain,
    CASE 
        WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
        WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
        WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
        WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
        WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
    END AS symbol,
    utils.udf_hex_to_int({{blockchain}}.rpc_eth_get_balance(wallet_address,'latest')::string) AS raw_balance,
    (raw_balance / POW(10,18))::float AS balance
{% endmacro %}

{% macro evm_latest_native_balance_array(schema, blockchain) %}
WITH address_inputs AS (
    SELECT wallets AS wallet_array
),
flat_addresses AS (
    SELECT lower(value::string) AS wallet_address 
    FROM address_inputs a, 
    LATERAL FLATTEN(input => a.wallet_array)
),
node_call AS (
    SELECT wallet_address, 
    {{blockchain}}.rpc_eth_get_balance(wallet_address,'latest')::string AS hex_balance 
    FROM flat_addresses
)
SELECT
    wallet_address,
    '{{blockchain}}' AS blockchain,
    CASE 
        WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
        WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
        WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
        WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
        WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
    END AS symbol,
    utils.udf_hex_to_int(hex_balance) AS raw_balance,
    (raw_balance / POW(10,18))::FLOAT AS balance
FROM node_call 
{% endmacro %}

{% macro evm_latest_token_balance_ss(schema, blockchain) %}
WITH inputs AS (
     SELECT
        lower(token) AS token_address,
        lower(wallet) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS DATA
),
node_call AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        {{blockchain}}.rpc_eth_call(object_construct_keep_null('from', null, 'to', token_address, 'data', data),'latest')::string AS eth_call,
        utils.udf_hex_to_int(eth_call::string) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    LEFT JOIN {{blockchain}}.core.dim_contracts ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    raw_balance,
    balance
FROM node_call
{% endmacro %}

{% macro evm_latest_token_balance_sa(schema, blockchain) %}
WITH inputs AS (
    SELECT tokens, wallet
),
flat_rows AS (
    SELECT 
        lower(value::string) AS token_address,
        lower(wallet::string) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS DATA
    FROM inputs,
    LATERAL FLATTEN(input => tokens)
),
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        {{blockchain}}.rpc_eth_call(object_construct_keep_null('from', null, 'to', token_address, 'data', data),'latest')::string AS eth_call,
        utils.udf_hex_to_int(eth_call::string) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        flat_rows
    LEFT JOIN {{blockchain}}.core.dim_contracts ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_latest_token_balance_as(schema, blockchain) %}
WITH inputs AS (
    SELECT token, wallets
),
flat_rows AS (
    SELECT 
        lower(value::string) AS wallet_address,
        lower(token::string) AS token_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS DATA
    FROM inputs,
    LATERAL FLATTEN(input => wallets)
),
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        {{blockchain}}.rpc_eth_call(object_construct_keep_null('from', null, 'to', token_address, 'data', data),'latest')::string AS eth_call,
        utils.udf_hex_to_int(eth_call::string) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        flat_rows
    LEFT JOIN {{blockchain}}.core.dim_contracts ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_latest_token_balance_aa(schema, blockchain) %}
WITH inputs AS (
    SELECT tokens, wallets
),
flat_rows AS (
    SELECT 
        lower(tokens.VALUE::STRING) AS token_address,
        lower(wallets.VALUE::STRING) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS DATA
    FROM
        inputs,
        LATERAL FLATTEN(input => tokens) tokens,
        LATERAL FLATTEN(input => wallets) wallets
),
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        {{blockchain}}.rpc_eth_call(object_construct_keep_null('from', null, 'to', token_address, 'data', data),'latest')::string AS eth_call,
        utils.udf_hex_to_int(eth_call::string) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        flat_rows
    LEFT JOIN {{blockchain}}.core.dim_contracts ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_ssi(schema, blockchain) %}
WITH inputs AS (
    SELECT
        LOWER(token) AS token_address,
        LOWER(wallet) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS data,
        block_number
), final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_ssa(schema, blockchain) %}
WITH block_inputs AS (
    SELECT block_numbers
),
blocks AS (
    SELECT value::INTEGER AS block_number
    FROM block_inputs,
    LATERAL FLATTEN(input => block_numbers)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        LOWER(wallet) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, 0)
        ) AS data
), 
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        blocks.block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(blocks.block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    CROSS JOIN blocks
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_asi(schema, blockchain) %}
WITH wallet_inputs AS (
    SELECT wallets
),
wallets AS (
    SELECT lower(value::STRING) AS wallet
    FROM wallet_inputs,
    LATERAL FLATTEN(input => wallets)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        wallet,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet, '0x', ''), 64, 0)
        ) AS data
    FROM wallets
), 
final AS (
    SELECT
        wallet AS wallet_address,
        token_address,
        symbol,
        block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_asa(schema, blockchain) %}
WITH block_inputs AS (
    SELECT block_numbers
),
blocks AS (
    SELECT value::INTEGER AS block_number
    FROM block_inputs,
    LATERAL FLATTEN(input => block_numbers)
),
wallet_inputs AS (
    SELECT wallets
),
wallets AS (
    SELECT lower(value::STRING) AS wallet
    FROM wallet_inputs,
    LATERAL FLATTEN(input => wallets)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        wallet,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet, '0x', ''), 64, '0')
        ) AS data
    FROM wallets
), 
final AS (
    SELECT
        wallet AS wallet_address,
        token_address,
        symbol,
        blocks.block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(blocks.block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    CROSS JOIN blocks
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_sai(schema, blockchain) %}
WITH token_inputs AS (
    SELECT tokens
),
tokens AS (
    SELECT value::STRING AS token
    FROM token_inputs,
    LATERAL FLATTEN(input => tokens)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        LOWER(wallet) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, '0')
        ) AS data
    FROM
        tokens
), 
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_saa(schema, blockchain) %}
WITH block_inputs AS (
    SELECT block_numbers
),
blocks AS (
    SELECT value::INTEGER AS block_number
    FROM block_inputs,
    LATERAL FLATTEN(input => block_numbers)
),
token_inputs AS (
    SELECT tokens
),
tokens AS (
    SELECT value::STRING AS token
    FROM token_inputs,
    LATERAL FLATTEN(input => tokens)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        LOWER(wallet) AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, '0')
        ) AS data
    FROM
        tokens
), 
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        blocks.block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(blocks.block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    CROSS JOIN blocks
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_aai(schema, blockchain) %}
WITH token_inputs AS (
    SELECT tokens
),
tokens AS (
    SELECT value::STRING AS token
    FROM token_inputs,
    LATERAL FLATTEN(input => tokens)
),
wallet_inputs AS (
    SELECT wallets
),
wallets AS (
    SELECT lower(value::STRING) AS wallet
    FROM wallet_inputs,
    LATERAL FLATTEN(input => wallets)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        wallet AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, '0')
        ) AS data
    FROM
        tokens,
        wallets
), 
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_token_balance_aaa(schema, blockchain) %}
WITH block_inputs AS (
    SELECT block_numbers
),
blocks AS (
    SELECT value::INTEGER AS block_number
    FROM block_inputs,
    LATERAL FLATTEN(input => block_numbers)
),
wallet_inputs AS (
    SELECT wallets
),
wallets AS (
    SELECT lower(value::STRING) AS wallet
    FROM wallet_inputs,
    LATERAL FLATTEN(input => wallets)
),
token_inputs AS (
    SELECT tokens
),
tokens AS (
    SELECT value::STRING AS token
    FROM token_inputs,
    LATERAL FLATTEN(input => tokens)
),
inputs AS (
    SELECT
        LOWER(token) AS token_address,
        wallet AS wallet_address,
        '0x70a08231' AS function_sig,
        CONCAT(
            function_sig,
            LPAD(REPLACE(wallet_address, '0x', ''), 64, '0')
        ) AS data
    FROM
        wallets,
        tokens
), 
final AS (
    SELECT
        wallet_address,
        token_address,
        symbol,
        blocks.block_number,
        {{blockchain}}.rpc_eth_call(OBJECT_CONSTRUCT_KEEP_NULL('from', NULL, 'to', token_address, 'data', data), CONCAT('0x', TRIM(TO_CHAR(blocks.block_number, 'XXXXXXXXXX'))))::STRING AS eth_call,
        utils.udf_hex_to_int(eth_call::STRING) AS raw_balance,
        raw_balance::INT / POW(10, decimals) AS balance
    FROM
        inputs
    CROSS JOIN blocks
    LEFT JOIN {{blockchain}}.core.dim_contracts
    ON token_address = address
)
SELECT 
    wallet_address,
    token_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    balance
FROM final
{% endmacro %}

{% macro evm_historical_native_balance_si(schema, blockchain) %}
SELECT
    lower(wallet) AS wallet_address,
    '{{blockchain}}' AS blockchain,
    CASE 
        WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
        WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
        WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
        WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
        WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
    END AS symbol,
    block_number,
    utils.udf_hex_to_int({{blockchain}}.rpc_eth_get_balance(wallet_address,CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX'))))::string) AS raw_balance,
    (raw_balance / POW(10,18))::float AS balance
{% endmacro %}

{% macro evm_historical_native_balance_sa(schema, blockchain) %}
WITH block_inputs AS (
    SELECT block_numbers
),
blocks AS (
    SELECT value::INTEGER AS block_number
    FROM block_inputs,
    LATERAL FLATTEN(input => block_numbers)
),
inputs AS (
    SELECT
        wallet AS wallet_address,
        CASE 
        WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
        WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
        WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
        WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
        WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
        END AS symbol,
        block_number,
        utils.udf_hex_to_int({{blockchain}}.rpc_eth_get_balance(wallet, CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX')))))::STRING AS raw_balance
    FROM blocks
)
SELECT 
    wallet_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    (raw_balance::int / pow(10,18)) ::float as balance
FROM inputs
{% endmacro %}

{% macro evm_historical_native_balance_ai(schema, blockchain) %}
WITH wallet_inputs AS (
    SELECT wallets
),
flat_wallets AS (
    SELECT lower(value::string) AS wallet
    FROM wallet_inputs,
    LATERAL FLATTEN(input => wallets)
),
inputs AS (
    SELECT
        wallet AS wallet_address,
        CASE 
        WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
        WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
        WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
        WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
        WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
        WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
        END AS symbol,
        block_number,
        utils.udf_hex_to_int({{blockchain}}.rpc_eth_get_balance(wallet, CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX')))))::STRING AS raw_balance
    FROM flat_wallets
)
SELECT 
    wallet_address,
    '{{blockchain}}' AS blockchain,
    symbol,
    block_number,
    raw_balance,
    (raw_balance::int / pow(10,18)) ::float as balance
FROM inputs
{% endmacro %}
{% macro evm_historical_native_balance_aa(schema, blockchain) %}
    WITH inputs AS (
        SELECT wallets, block_numbers
    ),
    flat_wallets AS (
        SELECT lower(wallet.value::STRING) AS wallet, block.value::INTEGER AS block_number
        FROM inputs,
        LATERAL FLATTEN(input => wallets) wallet,
        LATERAL FLATTEN(input => block_numbers) block
    ),
    final AS (
        SELECT
            wallet AS wallet_address,
            CASE 
                WHEN '{{blockchain}}' ILIKE 'avalanche%' THEN 'AVAX'
                WHEN '{{blockchain}}' ILIKE 'polygon%' THEN 'MATIC'
                WHEN '{{blockchain}}' ILIKE 'binance%' THEN 'BNB'
                WHEN '{{blockchain}}' ILIKE 'gnosis%' THEN 'xDAI'
                WHEN '{{blockchain}}' ILIKE 'ethereum%' THEN 'ETH'
                WHEN '{{blockchain}}' ILIKE 'arbitrum%' THEN 'ETH'
                WHEN '{{blockchain}}' ILIKE 'optimism%' THEN 'ETH'
                WHEN '{{blockchain}}' ILIKE 'base%' THEN 'ETH'
                WHEN '{{blockchain}}' ILIKE 'fantom%' THEN 'ETH'
                WHEN '{{blockchain}}' ILIKE 'harmony%' THEN 'ONE'
            END AS symbol,
            block_number,
            utils.udf_hex_to_int({{blockchain}}.rpc_eth_get_balance(wallet, CONCAT('0x', TRIM(TO_CHAR(block_number, 'XXXXXXXXXX')))))::STRING AS raw_balance
        FROM flat_wallets
    )
    SELECT 
        wallet_address,
        '{{blockchain}}' AS blockchain,
        symbol,
        block_number,
        raw_balance,
        (raw_balance::int / pow(10,18))::float as balance
    FROM final
{% endmacro %}

{% macro evm_latest_contract_events_s(schema, blockchain) %}
    WITH chainhead AS (
        SELECT
            {{ blockchain }}.rpc('eth_blockNumber', [])::STRING AS chainhead_hex,
            CONCAT('0x', TRIM(TO_CHAR(utils.udf_hex_to_int(chainhead_hex) - 100, 'XXXXXXXXXX'))) AS from_block_hex
    ),
    node_call AS (
        SELECT
            lower(address) AS contract_address,
            {{ blockchain }}.rpc_eth_get_logs(
                OBJECT_CONSTRUCT('address', address, 'fromBlock', from_block_hex, 'toBlock', chainhead_hex)
            ) AS eth_getLogs
        FROM chainhead
    ),
    node_flat AS (
        SELECT
            contract_address,
            utils.udf_hex_to_int(value:blockNumber::STRING)::INT AS block_number,
            value:transactionHash::STRING AS tx_hash,
            utils.udf_hex_to_int(value:transactionIndex::STRING)::INT AS tx_index,
            utils.udf_hex_to_int(value:logIndex::STRING)::INT AS event_index,
            value:removed::BOOLEAN AS event_removed,
            value:data::STRING AS event_data,
            value:topics::ARRAY AS event_topics
        FROM node_call,
        LATERAL FLATTEN(input => eth_getLogs)
    )
    SELECT
        '{{blockchain}}' AS blockchain,
        tx_hash,
        block_number,
        event_index,
        contract_address,
        event_topics,
        event_data
    FROM node_flat
{% endmacro %}

{% macro evm_latest_contract_events_si(schema, blockchain) %}
    WITH chainhead AS (
        SELECT
            {{ blockchain }}.rpc('eth_blockNumber', [])::STRING AS chainhead_hex,
            CONCAT('0x', TRIM(TO_CHAR(utils.udf_hex_to_int(chainhead_hex) - lookback, 'XXXXXXXXXX'))) AS from_block_hex
    ),
    node_call AS (
        SELECT
            lower(address) AS contract_address,
            {{ blockchain }}.rpc_eth_get_logs(
                OBJECT_CONSTRUCT('address', address, 'fromBlock', from_block_hex, 'toBlock', chainhead_hex)
            ) AS eth_getLogs
        FROM chainhead
    ),
    node_flat AS (
        SELECT
            contract_address,
            utils.udf_hex_to_int(value:blockNumber::STRING)::INT AS block_number,
            value:transactionHash::STRING AS tx_hash,
            utils.udf_hex_to_int(value:transactionIndex::STRING)::INT AS tx_index,
            utils.udf_hex_to_int(value:logIndex::STRING)::INT AS event_index,
            value:removed::BOOLEAN AS event_removed,
            value:data::STRING AS event_data,
            value:topics::ARRAY AS event_topics
        FROM node_call,
        LATERAL FLATTEN(input => eth_getLogs)
    )
    SELECT
        '{{blockchain}}' AS blockchain,
        tx_hash,
        block_number,
        event_index,
        contract_address,
        event_topics,
        event_data
    FROM node_flat
{% endmacro %}

{% macro evm_latest_contract_events_a(schema, blockchain) %}
    WITH chainhead AS (
        SELECT
            {{ blockchain }}.rpc('eth_blockNumber', [])::STRING AS chainhead_hex,
            CONCAT('0x', TRIM(TO_CHAR(utils.udf_hex_to_int(chainhead_hex) - 100, 'XXXXXXXXXX'))) AS from_block_hex
    ),
    node_call AS (
        SELECT
            lower(address) AS contract_address,
            {{ blockchain }}.rpc_eth_get_logs(
                OBJECT_CONSTRUCT('address', address, 'fromBlock', from_block_hex, 'toBlock', chainhead_hex)
            ) AS eth_getLogs
        FROM (
            SELECT value::STRING AS address
            FROM LATERAL FLATTEN(input => addresses) 
        ) inputs, chainhead
    ),
    node_flat AS (
        SELECT
            contract_address,
            utils.udf_hex_to_int(value:blockNumber::STRING)::INT AS block_number,
            value:transactionHash::STRING AS tx_hash,
            utils.udf_hex_to_int(value:transactionIndex::STRING)::INT AS tx_index,
            utils.udf_hex_to_int(value:logIndex::STRING)::INT AS event_index,
            value:removed::BOOLEAN AS event_removed,
            value:data::STRING AS event_data,
            value:topics::ARRAY AS event_topics
        FROM node_call,
        LATERAL FLATTEN(input => eth_getLogs)
    )
    SELECT
        '{{blockchain}}' AS blockchain,
        tx_hash,
        block_number,
        event_index,
        contract_address,
        event_topics,
        event_data
    FROM node_flat
{% endmacro %}

{% macro evm_latest_contract_events_ai(schema, blockchain) %}
    WITH chainhead AS (
        SELECT
            {{ blockchain }}.rpc('eth_blockNumber', [])::STRING AS chainhead_hex,
            CONCAT('0x', TRIM(TO_CHAR(utils.udf_hex_to_int(chainhead_hex) - lookback, 'XXXXXXXXXX'))) AS from_block_hex
    ),
    node_call AS (
        SELECT
            lower(address) AS contract_address,
            {{ blockchain }}.rpc_eth_get_logs(
                OBJECT_CONSTRUCT('address', address, 'fromBlock', from_block_hex, 'toBlock', chainhead_hex)
            ) AS eth_getLogs
        FROM (
            SELECT value::STRING AS address
            FROM LATERAL FLATTEN(input => addresses) 
        ) inputs, chainhead
    ),
    node_flat AS (
        SELECT
            contract_address,
            utils.udf_hex_to_int(value:blockNumber::STRING)::INT AS block_number,
            value:transactionHash::STRING AS tx_hash,
            utils.udf_hex_to_int(value:transactionIndex::STRING)::INT AS tx_index,
            utils.udf_hex_to_int(value:logIndex::STRING)::INT AS event_index,
            value:removed::BOOLEAN AS event_removed,
            value:data::STRING AS event_data,
            value:topics::ARRAY AS event_topics
        FROM node_call,
        LATERAL FLATTEN(input => eth_getLogs)
    )
    SELECT
        '{{blockchain}}' AS blockchain,
        tx_hash,
        block_number,
        event_index,
        contract_address,
        event_topics,
        event_data
    FROM node_flat
{% endmacro %}