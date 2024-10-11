{% macro evm_live_view_latest_block_height(blockchain, network) %}
    SELECT
        live.udf_api(
            '{service}/{Authentication}',
            utils.udf_json_rpc_call(
                'eth_blockNumber',
                []
            )
        ):data AS result,
        utils.udf_hex_to_int(result:result)::integer AS latest_block_height,
        COALESCE(
            block_height,
            latest_block_height
        ) AS min_height,
        iff(
            COALESCE(to_latest, false),
            latest_block_height,
            min_height
        ) AS max_height
{% endmacro %}

{% macro evm_live_view_target_blocks(blockchain, network) %}
    WITH heights AS (
        {{ evm_live_view_latest_block_height(blockchain, network) | indent(4) -}}
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                NULL
        ) - 1 + COALESCE(block_height, 0)::integer AS block_number,
        min_height,
        IFF(
            COALESCE(to_latest, false),
            block_height,
            min_height
        ) AS max_height,
        latest_block_height
    FROM
        TABLE(generator(ROWCOUNT => 1000)),
        heights qualify block_number BETWEEN min_height
        AND max_height
{% endmacro %}

-- Get Raw EVM chain data
{% macro evm_live_view_bronze_blocks(table_name) %}
SELECT
    block_number,
    live.udf_api(
        '{service}/{Authentication}',
        utils.udf_json_rpc_call(
            'eth_getBlockByNumber',
            [utils.udf_int_to_hex(block_number), true]
        )
    ):data.result AS DATA
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_bronze_receipts(table_name) %}
SELECT
    latest_block_height,
    block_number,
    live.udf_api(
        '{service}/{Authentication}',
        utils.udf_json_rpc_call(
            'eth_getBlockReceipts',
            [utils.udf_int_to_hex(block_number)]
        )
    ):data.result AS result,
    v.value AS DATA
FROM
    {{ table_name }},
    LATERAL FLATTEN(result) v
{% endmacro %}

{% macro evm_live_view_bronze_logs(table_name) %}
SELECT
    r.block_number,
    v.value
FROM
    {{ table_name }} AS r,
    lateral flatten(r.data:logs) v
{% endmacro %}

{% macro evm_live_view_bronze_transactions(table_name) %}
SELECT
    block_number,
    v.value as DATA
FROM
    {{ table_name }} AS r,
    lateral flatten(r.data:transactions) v
{% endmacro %}

-- Transformation macro for EVM chains
{% macro evm_live_view_silver_blocks(table_name) %}
SELECT
    block_number,
    utils.udf_hex_to_int(DATA:timestamp::STRING)::TIMESTAMP AS block_timestamp,
    utils.udf_hex_to_int(DATA:baseFeePerGas::STRING)::INT AS base_fee_per_gas,
    utils.udf_hex_to_int(DATA:difficulty::STRING)::INT AS difficulty,
    DATA:extraData::STRING AS extra_data,
    utils.udf_hex_to_int(DATA:gasLimit::STRING)::INT AS gas_limit,
    utils.udf_hex_to_int(DATA:gasUsed::STRING)::INT AS gas_used,
    DATA:hash::STRING AS HASH,
    DATA:logsBloom::STRING AS logs_bloom,
    DATA:miner::STRING AS miner,
    utils.udf_hex_to_int(DATA:nonce::STRING)::INT AS nonce,
    utils.udf_hex_to_int(DATA:number::STRING)::INT AS NUMBER,
    DATA:parentHash::STRING AS parent_hash,
    DATA:receiptsRoot::STRING AS receipts_root,
    DATA:sha3Uncles::STRING AS sha3_uncles,
    utils.udf_hex_to_int(DATA:size::STRING)::INT AS SIZE,
    DATA:stateRoot::STRING AS state_root,
    utils.udf_hex_to_int(DATA:totalDifficulty::STRING)::INT AS total_difficulty,
    ARRAY_SIZE(DATA:transactions) AS tx_count,
    DATA:transactionsRoot::STRING AS transactions_root,
    DATA:uncles AS uncles,
    DATA:withdrawals AS withdrawals,
    DATA:withdrawalsRoot::STRING AS withdrawals_root,
    md5(
        CAST(
            COALESCE(
                CAST(block_number AS TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) AS TEXT
        )
    ) AS blocks_id,
    utils.udf_hex_to_int(DATA:blobGasUsed::STRING)::INT AS blob_gas_used,
    utils.udf_hex_to_int(DATA:excessBlobGas::STRING)::INT AS excess_blob_gas
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_silver_receipts(table_name) %}
SELECT
    latest_block_height,
    block_number,
    DATA :blockHash::STRING AS block_hash,
    utils.udf_hex_to_int(DATA :blockNumber::STRING)::INT AS blockNumber,
    utils.udf_hex_to_int(DATA :cumulativeGasUsed::STRING)::INT AS cumulative_gas_used,
    utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT / pow(10, 9) AS effective_gas_price,
    DATA :from::STRING AS from_address,
    utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
    DATA :logs AS logs,
    DATA :logsBloom::STRING AS logs_bloom,
    utils.udf_hex_to_int(DATA :status::STRING)::INT AS status,
    CASE
        WHEN status = 1 THEN TRUE
        ELSE FALSE
    END AS tx_success,
    CASE
        WHEN status = 1 THEN 'SUCCESS'
        ELSE 'FAIL'
    END AS tx_status,
    DATA :to::STRING AS to_address1,
    CASE
        WHEN to_address1 = '' THEN NULL
        ELSE to_address1
    END AS to_address,
    DATA :transactionHash::STRING AS tx_hash,
    utils.udf_hex_to_int(DATA :transactionIndex::STRING)::INT AS POSITION,
    utils.udf_hex_to_int(DATA :type::STRING)::INT AS TYPE,
    utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT AS blob_gas_price,
    utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS blob_gas_used
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_silver_logs(silver_receipts, silver_transactions) %}
SELECT
    r.block_number,
    txs.block_timestamp,
    r.tx_hash,
    txs.origin_function_signature,
    r.from_address AS origin_from_address,
    r.to_address AS origin_to_address,
    utils.udf_hex_to_int(v.VALUE :logIndex::STRING)::INT AS event_index,
    v.VALUE :address::STRING AS contract_address,
    v.VALUE :blockHash::STRING AS block_hash,
    v.VALUE :data::STRING AS DATA,
    v.VALUE :removed::BOOLEAN AS event_removed,
    v.VALUE :topics AS topics,
    r.tx_status,
    CASE
        WHEN txs.block_timestamp IS NULL
        OR txs.origin_function_signature IS NULL THEN TRUE
        ELSE FALSE
    END AS is_pending,
FROM
    {{ silver_receipts }} AS r
    LEFT JOIN {{ silver_transactions }} AS txs on txs.tx_hash = r.tx_hash,
    lateral flatten(r.logs) v
{% endmacro %}

{% macro evm_live_view_silver_transactions(bronze_transactions, silver_blocks, silver_receipts) %}
SELECT
    A.block_number AS block_number,
    A.data :blockHash::STRING AS block_hash,
    utils.udf_hex_to_int(A.data :blockNumber::STRING)::INT AS blockNumber,
    utils.udf_hex_to_int(A.data :chainId::STRING)::INT AS chain_id,
    A.data :from::STRING AS from_address,
    utils.udf_hex_to_int(A.data :gas::STRING)::INT AS gas,
    utils.udf_hex_to_int(A.data :gasPrice::STRING)::INT / pow(10, 9) AS gas_price,
    A.data :hash::STRING AS tx_hash,
    A.data :input::STRING AS input_data,
    SUBSTR(input_data, 1, 10) AS origin_function_signature,
    utils.udf_hex_to_int(A.data :maxFeePerGas::STRING)::INT / pow(10, 9) AS max_fee_per_gas,
    utils.udf_hex_to_int(
        A.data :maxPriorityFeePerGas::STRING
    )::INT / pow(10, 9) AS max_priority_fee_per_gas,
    utils.udf_hex_to_int(A.data :nonce::STRING)::INT AS nonce,
    A.data :r::STRING AS r,
    A.data :s::STRING AS s,
    A.data :to::STRING AS to_address1,
    utils.udf_hex_to_int(A.data :transactionIndex::STRING)::INT AS POSITION,
    A.data :type::STRING AS TYPE,
    A.data :v::STRING AS v,
    utils.udf_hex_to_int(A.data :value::STRING) AS value_precise_raw,
    value_precise_raw * power(10, -18) AS value_precise,
    value_precise::FLOAT AS VALUE,
    A.data :accessList AS access_list,
    A.data,
    A.data: blobVersionedHashes::ARRAY AS blob_versioned_hashes,
    utils.udf_hex_to_int(A.data: maxFeePerGas::STRING)::INT AS max_fee_per_blob_gas,
    block_timestamp,
    CASE
        WHEN block_timestamp IS NULL
        OR tx_status IS NULL THEN TRUE
        ELSE FALSE
    END AS is_pending,
    r.gas_used,
    tx_success,
    tx_status,
    cumulative_gas_used,
    effective_gas_price,
    utils.udf_hex_to_int(A.data :gasPrice) * power(10, -18) * r.gas_used AS tx_fee_precise,
    COALESCE(tx_fee_precise::FLOAT, 0) AS tx_fee,
    r.type as tx_type,
    r.blob_gas_used,
    r.blob_gas_price,
FROM
    {{ bronze_transactions }} AS A
    LEFT JOIN {{ silver_blocks }} AS b on b.block_number = A.block_number
    LEFT JOIN {{ silver_receipts }} AS r on r.tx_hash = A.data :hash::STRING
{% endmacro %}

-- Get EVM chain fact data
{% macro evm_live_view_fact_blocks(schema, blockchain, network) %}
WITH spine AS (
        {{ evm_live_view_target_blocks(blockchain, network) | indent(4) -}}
    ),
    raw_block_txs AS (
        {{ evm_live_view_bronze_blocks('spine') | indent(4) -}}
    ),
    silver_blocks AS (
        {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
    )
    select
        block_number,
        block_timestamp,
        '{{ network }}' AS network,
        '{{ blockchain }}' AS blockchain,
        tx_count,
        difficulty,
        total_difficulty,
        extra_data,
        gas_limit,
        gas_used,
        HASH,
        parent_hash,
        miner,
        nonce,
        receipts_root,
        sha3_uncles,
        SIZE,
        uncles AS uncle_blocks,
        OBJECT_CONSTRUCT(
            'baseFeePerGas',
            base_fee_per_gas,
            'difficulty',
            difficulty,
            'extraData',
            extra_data,
            'gasLimit',
            gas_limit,
            'gasUsed',
            gas_used,
            'hash',
            HASH,
            'logsBloom',
            logs_bloom,
            'miner',
            miner,
            'nonce',
            nonce,
            'number',
            NUMBER,
            'parentHash',
            parent_hash,
            'receiptsRoot',
            receipts_root,
            'sha3Uncles',
            sha3_uncles,
            'size',
            SIZE,
            'stateRoot',
            state_root,
            'timestamp',
            block_timestamp,
            'totalDifficulty',
            total_difficulty,
            'transactionsRoot',
            transactions_root,
            'uncles',
            uncles,
            'excessBlobGas',
            excess_blob_gas,
            'blobGasUsed',
            blob_gas_used
        ) AS block_header_json,
        excess_blob_gas,
        blob_gas_used,
        block_number::STRING AS fact_blocks_id,
        SYSDATE() AS inserted_timestamp,
        SYSDATE() AS modified_timestamp,
        withdrawals,
        withdrawals_root
    from silver_blocks
{% endmacro %}

{% macro evm_live_view_fact_logs(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(blockchain, network) | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks('spine') | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts('spine') | indent(4) -}}
),
raw_logs AS (
    {{ evm_live_view_bronze_logs('raw_receipts') | indent(4) -}}
),
raw_transactions AS (
    {{ evm_live_view_bronze_transactions('raw_block_txs') | indent(4) -}}
),
blocks AS (
    {{ evm_live_view_silver_blocks('raw_block_txs') | indent(4) -}}
),
receipts AS (
    {{ evm_live_view_silver_receipts('raw_receipts') | indent(4) -}}
),
transactions AS (
    {{ evm_live_view_silver_transactions('raw_transactions', 'blocks', 'receipts') | indent(4) -}}
),
logs AS (
    {{ evm_live_view_silver_logs('receipts', 'transactions') | indent(4) -}}
)
SELECT
    block_number,
    block_timestamp,
    tx_hash,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    event_index,
    contract_address,
    topics,
    DATA,
    event_removed,
    tx_status,
    CONCAT(
        tx_hash :: STRING,
        '-',
        event_index :: STRING
    ) AS _log_id,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(event_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) AS fact_event_logs_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM logs
{% endmacro %}

-- Get EVM chain ez data
{% macro evm_live_view_ez_token_transfers(schema, blockchain, network) %}
WITH fact_logs AS (
    {{ evm_live_view_fact_logs(schema, blockchain, network) | indent(4) -}}
)

SELECT
    block_number,
    block_timestamp,
    tx_hash,
    event_index,
    origin_function_signature,
    origin_from_address,
    origin_to_address,
    contract_address::STRING AS contract_address,
    CONCAT('0x', SUBSTR(topics [1], 27, 40))::STRING AS from_address,
    CONCAT('0x', SUBSTR(topics [2], 27, 40))::STRING AS to_address,
    utils.udf_hex_to_int(SUBSTR(DATA, 3, 64)) AS raw_amount_precise,
    raw_amount_precise::FLOAT AS raw_amount,
    IFF(
        C.decimals IS NOT NULL,
        raw_amount_precise * power(10, C.decimals * -1),
        NULL
    ) AS amount_precise,
    amount_precise::FLOAT AS amount,
    IFF(
        C.decimals IS NOT NULL
        AND price IS NOT NULL,
        amount * price,
        NULL
    ) AS amount_usd,
    C.decimals AS decimals,
    C.symbol AS symbol,
    price AS token_price,
    CASE
        WHEN C.decimals IS NULL THEN 'false'
        ELSE 'true'
    END AS has_decimal,
    CASE
        WHEN price IS NULL THEN 'false'
        ELSE 'true'
    END AS has_price,
    md5(
        cast(
            coalesce(
                cast(tx_hash as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) || '-' || coalesce(
                cast(event_index as TEXT),
                '_dbt_utils_surrogate_key_null_'
            ) as TEXT
        )
    ) as ez_token_transfers_id,
    sysdate() as inserted_timestamp,
    sysdate() as modified_timestamp
FROM
    fact_logs l
    LEFT JOIN {{ blockchain }}.price.EZ_PRICES_HOURLY p ON l.contract_address = p.token_address
    AND DATE_TRUNC('hour', l.block_timestamp) = HOUR
    LEFT JOIN {{ blockchain }}.core.DIM_CONTRACTS C ON l.contract_address = C.address
WHERE
    topics [0]::STRING = ez_token_transfers_id
    AND tx_status = 'SUCCESS'
    and raw_amount IS NOT NULL
    AND to_address IS NOT NULL
AND from_address IS NOT NULL
{% endmacro %}

{% macro evm_live_view_ez_native_transfers(schema, blockchain, network) %}
WITH spine AS (
    {{ evm_live_view_target_blocks(blockchain, network) }}
),

raw_block_data AS (
    SELECT
        s.block_number AS block_number,
        live.udf_api(
            '{service}/{Authentication}',
            utils.udf_json_rpc_call(
                'eth_getBlockByNumber',
                [utils.udf_int_to_hex(s.block_number), true]
            )
        ):data AS block_data,
        b.value AS tx_data,
        TO_TIMESTAMP_NTZ(utils.udf_hex_to_int(block_data:result:timestamp::string)) AS block_timestamp,
        tx_data:hash::string AS tx_hash,
        tx_data:from::string AS from_address,
        tx_data:to_address::string AS to_address,
        TRY_TO_NUMBER(utils.udf_hex_to_int(tx_data:value::string), 38, 0) / 1e18 AS eth_value,
        TRY_TO_NUMBER(utils.udf_hex_to_int(tx_data:value::string), 38, 0) AS eth_value_precise_raw,
        TRY_TO_NUMBER(utils.udf_hex_to_int(tx_data:value::string), 38, 0) / 1e18 AS eth_value_precise,
        tx_data:input::string AS input,
        utils.udf_hex_to_int(tx_data:transactionIndex::string)::INTEGER AS tx_position,
        'CALL' AS TYPE,
        'SUCCESS' AS tx_status,
        'SUCCESS' AS trace_status,
        CASE
            WHEN LEFT(input, 10) = '0x' THEN SUBSTRING(input, 1, 10)
            ELSE NULL
        END AS origin_function_signature,
        'native_transfer' AS identifier,
        NULL AS trace_index
    FROM
        spine s,
        LATERAL FLATTEN(input => block_data:result:transactions) b
    WHERE
        TRY_TO_NUMBER(utils.udf_hex_to_int(tx_data:value::string), 38, 0) > 0
),
eth_base AS (
    SELECT
        tx_hash,
        block_number,
        block_timestamp,
        identifier,
        from_address,
        to_address,
        eth_value AS amount,
        eth_value_precise_raw AS amount_precise_raw,
        eth_value_precise AS amount_precise,
        tx_position,
        trace_index
    FROM
        raw_block_data
    WHERE
        eth_value > 0
        AND tx_status = 'SUCCESS'
        AND trace_status = 'SUCCESS'
        AND TYPE NOT IN ('DELEGATECALL', 'STATICCALL')
),
tx_table AS (
    SELECT
        block_number,
        block_timestamp,
        tx_hash,
        from_address AS origin_from_address,
        to_address AS origin_to_address,
        origin_function_signature
    FROM
        raw_block_data
    WHERE
        tx_hash IN (SELECT DISTINCT tx_hash FROM eth_base)
),
price_data AS (
    SELECT
        DATE_TRUNC('hour', e.block_timestamp) AS hour,
        AVG(p.price) AS price
    FROM
        eth_base e
        JOIN {{ blockchain }}.PRICE.EZ_PRICES_HOURLY p
            ON DATE_TRUNC('hour', e.block_timestamp) = p.hour
            AND p.token_address = native_token_address
    GROUP BY 1
)
SELECT
    A.tx_hash,
    A.block_number,
    A.block_timestamp,
    A.tx_position,
    A.trace_index,
    A.identifier,
    T.origin_from_address,
    T.origin_to_address,
    T.origin_function_signature,
    A.from_address,
    A.to_address,
    A.amount::FLOAT,
    A.amount_precise_raw::NUMBER(38,0),
    A.amount_precise::FLOAT,
    ROUND(A.amount * P.price, 2)::FLOAT AS amount_usd,
    MD5(CONCAT(A.tx_hash, '|', COALESCE(A.trace_index::STRING, ''))) AS ez_native_transfers_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM
    eth_base A
    LEFT JOIN price_data P ON DATE_TRUNC('hour', A.block_timestamp) = P.hour
    JOIN tx_table T ON A.tx_hash = T.tx_hash AND A.block_number = T.block_number
{% endmacro %}

