{% macro evm_live_view_latest_block_height(schema, blockchain, network) %}
    SELECT
        {{ schema }}.udf_rpc('eth_blockNumber', []) as result,
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

{% macro evm_live_view_target_blocks(schema, blockchain, network) %}
    WITH heights AS (
        {{ evm_live_view_latest_block_height(schema, blockchain, network) | indent(4) -}}
    )
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY
                NULL
        ) - 1 + COALESCE(block_height, latest_block_height)::integer AS block_number,
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
{% macro evm_live_view_bronze_blocks(schema, table_name) %}
SELECT
    block_number,
    {{ schema }}.udf_rpc(
        'eth_getBlockByNumber',
        [utils.udf_int_to_hex(block_number), true]) AS DATA
FROM
    {{ table_name }}
{% endmacro %}

{% macro evm_live_view_bronze_receipts(schema, table_name) %}
SELECT
    latest_block_height,
    block_number,
    {{ schema }}.udf_rpc(
        'eth_getBlockReceipts',
        [utils.udf_int_to_hex(block_number)]) AS result,
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
        {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
    ),
    raw_block_txs AS (
        {{ evm_live_view_bronze_blocks( schema, 'spine') | indent(4) -}}
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
    {{ evm_live_view_target_blocks(schema, blockchain, network) | indent(4) -}}
),
raw_block_txs AS (
    {{ evm_live_view_bronze_blocks(schema, 'spine') | indent(4) -}}
),
raw_receipts AS (
    {{ evm_live_view_bronze_receipts(schema, 'spine') | indent(4) -}}
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

{% macro evm_live_view_fact_decoded_event_logs(schema, blockchain, network) %}
WITH _fact_event_logs AS (
    {{ evm_live_view_fact_logs(schema, blockchain, network) | indent(4) -}}
),

_silver_decoded_logs AS (
    SELECT
        block_number,
        block_timestamp,
        tx_hash,
        origin_function_signature,
        origin_from_address,
        origin_to_address,
        event_index,
        topics,
        DATA,
        contract_address,
        OBJECT_CONSTRUCT('topics', topics, 'data', data, 'address', contract_address) AS event_data,
        abi,
        utils.udf_evm_decode_log(abi, event_data)[0] AS decoded_data,
        event_removed,
        decoded_data:name::string AS event_name,
        {{ blockchain }}.utils.udf_transform_logs(decoded_data) AS transformed,
        _log_id,
        inserted_timestamp,
        tx_status
    FROM
        _fact_event_logs
    JOIN
        {{ blockchain }}.core.dim_contract_abis
    USING
        (contract_address)
    WHERE
        tx_status = 'SUCCESS'
),

_flatten_logs AS (
    SELECT
        b.tx_hash,
        b.block_number,
        b.event_index,
        b.event_name,
        b.contract_address,
        b.decoded_data,
        b.transformed,
        b._log_id,
        b.inserted_timestamp,
        OBJECT_AGG(
            DISTINCT CASE
                WHEN v.value :name = '' THEN CONCAT(
                    'anonymous_',
                    v.index
                )
                ELSE v.value :name
            END,
            v.value :value
        ) AS decoded_flat
    FROM
        _silver_decoded_logs b,
        LATERAL FLATTEN(
            input => b.transformed :data
        ) v
    GROUP BY
        b.tx_hash,
        b.block_number,
        b.event_index,
        b.event_name,
        b.contract_address,
        b.decoded_data,
        b.transformed,
        b._log_id,
        b.inserted_timestamp
)

SELECT
    block_number,
    C.block_timestamp,
    B.tx_hash,
    B.event_index,
    B.contract_address,
    D.name AS contract_name,
    B.event_name,
    B.decoded_flat AS decoded_log,
    B.decoded_data AS full_decoded_log,
    md5(_log_id) AS fact_decoded_event_logs_id,
    SYSDATE() AS _inserted_timestamp,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp
FROM _flatten_logs AS B
LEFT JOIN _silver_decoded_logs AS C USING (block_number, _log_id)
LEFT JOIN  {{ blockchain }}.core.dim_contracts AS D
    ON B.contract_address = D.address
{% endmacro %}

{% macro evm_live_view_fact_transactions(schema, blockchain, network) %}

WITH heights AS (
    SELECT
        {{ schema }}.udf_rpc('eth_blockNumber', []) as result,
        livequery_dev.utils.udf_hex_to_int(result:result)::integer as latest_block_height,
        coalesce(
            block_height,
            latest_block_height
        ) as min_height,
        iff(
            coalesce(to_latest, false),
            latest_block_height,
            min_height
        ) as max_height
    ),
    spine as (
        select
            row_number() over (
                order by
                    null
            ) -1 + coalesce(block_height, 0)::integer as block_number,
            min_height,
            iff(
                coalesce(to_latest, false),
                latest_block_height,
                min_height
            ) as max_height,
            latest_block_height
        from
            table(generator(ROWCOUNT => 1000)),
            heights
        qualify block_number between min_height and max_height
    ),
    raw_receipts as (
        SELECT
            latest_block_height,
            block_number,
            {{ schema }}.udf_rpc(
                'eth_getBlockReceipts',
                [utils.udf_int_to_hex(block_number)]) AS result,
            v.value as DATA
        from
            spine,
            lateral flatten(result) v
    ),
    raw_block_txs as (
            SELECT
                block_number,
                {{ schema }}.udf_rpc(
                    'eth_getBlockByNumber',
                    [utils.udf_int_to_hex(block_number), true]) AS DATA
            from
                spine
        ),
        raw_txs as (
            SELECT
                block_number,
                v.value as DATA
            from
                raw_block_txs r,
                lateral flatten(r.data:transactions) v
        ),
    blocks as (
        select
            block_number,
            livequery_dev.utils.udf_hex_to_int(DATA :baseFeePerGas::STRING)::INT AS base_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(DATA :difficulty::STRING)::INT AS difficulty,
            DATA :extraData::STRING AS extra_data,
            livequery_dev.utils.udf_hex_to_int(DATA :gasLimit::STRING)::INT AS gas_limit,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :hash::STRING AS HASH,
            DATA :logsBloom::STRING AS logs_bloom,
            DATA :miner::STRING AS miner,
            livequery_dev.utils.udf_hex_to_int(DATA :nonce::STRING)::INT AS nonce,
            livequery_dev.utils.udf_hex_to_int(DATA :number::STRING)::INT AS NUMBER,
            DATA :parentHash::STRING AS parent_hash,
            DATA :receiptsRoot::STRING AS receipts_root,
            DATA :sha3Uncles::STRING AS sha3_uncles,
            livequery_dev.utils.udf_hex_to_int(DATA :size::STRING)::INT AS SIZE,
            DATA :stateRoot::STRING AS state_root,
            livequery_dev.utils.udf_hex_to_int(DATA :timestamp::STRING)::TIMESTAMP AS block_timestamp,
            livequery_dev.utils.udf_hex_to_int(DATA :totalDifficulty::STRING)::INT AS total_difficulty,
            ARRAY_SIZE(DATA :transactions) AS tx_count,
            DATA :transactionsRoot::STRING AS transactions_root,
            DATA :uncles AS uncles,
            DATA :withdrawals AS withdrawals,
            DATA :withdrawalsRoot::STRING AS withdrawals_root,
            md5(
                cast(
                    coalesce(
                        cast(block_number as TEXT),
                        '_dbt_utils_surrogate_key_null_'
                    ) as TEXT
                )
            ) AS blocks_id,
            livequery_dev.utils.udf_hex_to_int(DATA: blobGasUsed::STRING)::INT AS blob_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA: excessBlobGas::STRING)::INT AS excess_blob_gas,
        from
            raw_block_txs
    ),
    receipts as (
        select
            latest_block_height,
            block_number,
            DATA :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(DATA :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(DATA :cumulativeGasUsed::STRING)::INT AS cumulative_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT / pow(10, 9) AS effective_gas_price,
            DATA :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :logs AS logs,
            DATA :logsBloom::STRING AS logs_bloom,
            livequery_dev.utils.udf_hex_to_int(DATA :status::STRING)::INT AS status,
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
            livequery_dev.utils.udf_hex_to_int(DATA :transactionIndex::STRING)::INT AS POSITION,
            livequery_dev.utils.udf_hex_to_int(DATA :type::STRING)::INT AS TYPE,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT AS blob_gas_price,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS blob_gas_used
        from
            raw_receipts
    ),
    txs as (
        select
            A.block_number AS block_number,
            A.data :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(A.data :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(A.data :chainId::STRING)::INT AS chain_id,
            A.data :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(A.data :gas::STRING)::INT AS gas,
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice::STRING)::INT / pow(10, 9) AS gas_price,
            A.data :hash::STRING AS tx_hash,
            A.data :input::STRING AS input_data,
            SUBSTR(input_data, 1, 10) AS origin_function_signature,
            livequery_dev.utils.udf_hex_to_int(A.data :maxFeePerGas::STRING)::INT / pow(10, 9) AS max_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(
                A.data :maxPriorityFeePerGas::STRING
            )::INT / pow(10, 9) AS max_priority_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(A.data :nonce::STRING)::INT AS nonce,
            A.data :r::STRING AS r,
            A.data :s::STRING AS s,
            A.data :to::STRING AS to_address,
            livequery_dev.utils.udf_hex_to_int(A.data :transactionIndex::STRING)::INT AS POSITION,
            A.data :type::STRING AS TYPE,
            A.data :v::STRING AS v,
            livequery_dev.utils.udf_hex_to_int(A.data :value::STRING) AS value_precise_raw,
            value_precise_raw * power(10, -18) AS value_precise,
            value_precise::FLOAT AS VALUE,
            A.data :accessList AS access_list,
            A.data,
            A.data: blobVersionedHashes::ARRAY AS blob_versioned_hashes,
            livequery_dev.utils.udf_hex_to_int(A.data: maxFeePerGas::STRING)::INT AS max_fee_per_blob_gas,
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
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice) * power(10, -18) * r.gas_used AS tx_fee_precise,
            COALESCE(tx_fee_precise::FLOAT, 0) AS tx_fee,
            r.type as tx_type,
            r.blob_gas_used,
            r.blob_gas_price,
        from
            raw_txs A
            left join blocks b on b.block_number = A.block_number
            left join receipts as r on r.tx_hash = A.data :hash::STRING
    )
    SELECT
        block_number,
        block_timestamp,
        block_hash,
        tx_hash,
        nonce,
        POSITION,
        origin_function_signature,
        from_address,
        to_address,
        VALUE,
        value_precise_raw,
        value_precise::STRING as value_precise,
        tx_fee,
        tx_fee_precise::STRING as tx_fee_precise,
        gas_price,
        gas AS gas_limit,
        gas_used,
        cumulative_gas_used,
        input_data,
        tx_status AS status,
        effective_gas_price,
        max_fee_per_gas,
        max_priority_fee_per_gas,
        r,
        s,
        v,
        tx_type,
        chain_id,
        blob_versioned_hashes,
        max_fee_per_blob_gas,
        blob_gas_used,
        blob_gas_price,
        md5(
            cast(
                coalesce(
                    cast(tx_hash as TEXT),
                    '_dbt_utils_surrogate_key_null_'
                ) as TEXT
            )
        ) AS fact_transactions_id,
        SYSDATE() inserted_timestamp,
        SYSDATE() AS modified_timestamp
    FROM
        txs

{% endmacro %}

{% macro evm_live_view_fact_traces(schema, blockchain, network) %}
WITH heights AS (
    SELECT
        {{ schema }}.udf_rpc('eth_blockNumber', []) as result,
        livequery_dev.utils.udf_hex_to_int(result:result)::integer as latest_block_height,
        coalesce(
            block_height,
            latest_block_height
        ) as min_height,
        iff(
            coalesce(to_latest, false),
            latest_block_height,
            min_height
        ) as max_height
    ),
    spine as (
        select
            row_number() over (
                order by
                    null
            ) -1 + coalesce(block_height, 0)::integer as block_number,
            min_height,
            iff(
                coalesce(to_latest, false),
                latest_block_height,
                min_height
            ) as max_height,
            latest_block_height
        from
            table(generator(ROWCOUNT => 1000)),
            heights
        qualify block_number between min_height and max_height
    ),
    raw_receipts as (
        SELECT
            latest_block_height,
            block_number,
            {{ schema }}.udf_rpc(
                'eth_getBlockReceipts',
                [utils.udf_int_to_hex(block_number)]) AS result,
            v.value as DATA
        from
            spine,
            lateral flatten(result) v
    ),
    raw_block_txs as (
            SELECT
                block_number,
                {{ schema }}.udf_rpc(
                    'eth_getBlockByNumber',
                    [utils.udf_int_to_hex(block_number), true]) AS DATA
            from
                spine
        ),
        raw_txs as (
            SELECT
                block_number,
                v.value as DATA
            from
                raw_block_txs r,
                lateral flatten(r.data:transactions) v
        ),
    blocks as (
        select
            block_number,
            livequery_dev.utils.udf_hex_to_int(DATA :baseFeePerGas::STRING)::INT AS base_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(DATA :difficulty::STRING)::INT AS difficulty,
            DATA :extraData::STRING AS extra_data,
            livequery_dev.utils.udf_hex_to_int(DATA :gasLimit::STRING)::INT AS gas_limit,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :hash::STRING AS HASH,
            DATA :logsBloom::STRING AS logs_bloom,
            DATA :miner::STRING AS miner,
            livequery_dev.utils.udf_hex_to_int(DATA :nonce::STRING)::INT AS nonce,
            livequery_dev.utils.udf_hex_to_int(DATA :number::STRING)::INT AS NUMBER,
            DATA :parentHash::STRING AS parent_hash,
            DATA :receiptsRoot::STRING AS receipts_root,
            DATA :sha3Uncles::STRING AS sha3_uncles,
            livequery_dev.utils.udf_hex_to_int(DATA :size::STRING)::INT AS SIZE,
            DATA :stateRoot::STRING AS state_root,
            livequery_dev.utils.udf_hex_to_int(DATA :timestamp::STRING)::TIMESTAMP AS block_timestamp,
            livequery_dev.utils.udf_hex_to_int(DATA :totalDifficulty::STRING)::INT AS total_difficulty,
            ARRAY_SIZE(DATA :transactions) AS tx_count,
            DATA :transactionsRoot::STRING AS transactions_root,
            DATA :uncles AS uncles,
            DATA :withdrawals AS withdrawals,
            DATA :withdrawalsRoot::STRING AS withdrawals_root,
            md5(
                cast(
                    coalesce(
                        cast(block_number as TEXT),
                        '_dbt_utils_surrogate_key_null_'
                    ) as TEXT
                )
            ) AS blocks_id,
            livequery_dev.utils.udf_hex_to_int(DATA: blobGasUsed::STRING)::INT AS blob_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA: excessBlobGas::STRING)::INT AS excess_blob_gas,
        from
            raw_block_txs
    ),
    receipts as (
        select
            latest_block_height,
            block_number,
            DATA :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(DATA :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(DATA :cumulativeGasUsed::STRING)::INT AS cumulative_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT / pow(10, 9) AS effective_gas_price,
            DATA :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :logs AS logs,
            DATA :logsBloom::STRING AS logs_bloom,
            livequery_dev.utils.udf_hex_to_int(DATA :status::STRING)::INT AS status,
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
            livequery_dev.utils.udf_hex_to_int(DATA :transactionIndex::STRING)::INT AS POSITION,
            livequery_dev.utils.udf_hex_to_int(DATA :type::STRING)::INT AS TYPE,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT AS blob_gas_price,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS blob_gas_used
        from
            raw_receipts
    ),
    txs as (
        select
            A.block_number AS block_number,
            A.data :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(A.data :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(A.data :chainId::STRING)::INT AS chain_id,
            A.data :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(A.data :gas::STRING)::INT AS gas,
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice::STRING)::INT / pow(10, 9) AS gas_price,
            A.data :hash::STRING AS tx_hash,
            A.data :input::STRING AS input_data,
            SUBSTR(input_data, 1, 10) AS origin_function_signature,
            livequery_dev.utils.udf_hex_to_int(A.data :maxFeePerGas::STRING)::INT / pow(10, 9) AS max_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(
                A.data :maxPriorityFeePerGas::STRING
            )::INT / pow(10, 9) AS max_priority_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(A.data :nonce::STRING)::INT AS nonce,
            A.data :r::STRING AS r,
            A.data :s::STRING AS s,
            A.data :to::STRING AS to_address1,
            livequery_dev.utils.udf_hex_to_int(A.data :transactionIndex::STRING)::INT AS POSITION,
            A.data :type::STRING AS TYPE,
            A.data :v::STRING AS v,
            livequery_dev.utils.udf_hex_to_int(A.data :value::STRING) AS value_precise_raw,
            value_precise_raw * power(10, -18) AS value_precise,
            value_precise::FLOAT AS VALUE,
            A.data :accessList AS access_list,
            A.data,
            A.data: blobVersionedHashes::ARRAY AS blob_versioned_hashes,
            livequery_dev.utils.udf_hex_to_int(A.data: maxFeePerGas::STRING)::INT AS max_fee_per_blob_gas,
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
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice) * power(10, -18) * r.gas_used AS tx_fee_precise,
            COALESCE(tx_fee_precise::FLOAT, 0) AS tx_fee,
            r.type as tx_type,
            r.blob_gas_used,
            r.blob_gas_price,
        from
            raw_txs A
            left join blocks b on b.block_number = A.block_number
            left join receipts as r on r.tx_hash = A.data :hash::STRING
    ),
    raw_traces AS (
        SELECT
            s.block_number,
            v.index::INT AS tx_position,
            v.value:result AS full_traces,
            SYSDATE() AS _inserted_timestamp
        FROM spine s,
        LATERAL FLATTEN(input => PARSE_JSON(
            {{ schema }}.udf_rpc(
                'debug_traceBlockByNumber',
                [utils.udf_int_to_hex(s.block_number), {'tracer': 'callTracer'}])
        )) v
    ),
    flatten_traces AS (
        SELECT
            block_number,
            tx_position,
            IFF(
                path IN (
                    'result',
                    'result.value',
                    'result.type',
                    'result.to',
                    'result.input',
                    'result.gasUsed',
                    'result.gas',
                    'result.from',
                    'result.output',
                    'result.error',
                    'result.revertReason',
                    'gasUsed',
                    'gas',
                    'type',
                    'to',
                    'from',
                    'value',
                    'input',
                    'error',
                    'output',
                    'revertReason'
                ),
                'ORIGIN',
                REGEXP_REPLACE(REGEXP_REPLACE(path, '[^0-9]+', '_'), '^_|_$', '')
            ) AS trace_address,
            _inserted_timestamp,
            OBJECT_AGG(
                key,
                VALUE
            ) AS trace_json,
            CASE
                WHEN trace_address = 'ORIGIN' THEN NULL
                WHEN POSITION(
                    '_' IN trace_address
                ) = 0 THEN 'ORIGIN'
                ELSE REGEXP_REPLACE(
                    trace_address,
                    '_[0-9]+$',
                    '',
                    1,
                    1
                )
            END AS parent_trace_address,
            SPLIT(
                trace_address,
                '_'
            ) AS str_array
        FROM
            raw_traces,
            TABLE(
                FLATTEN(
                    input => PARSE_JSON(full_traces),
                    recursive => TRUE
                )
            ) f
        WHERE
            f.index IS NULL
            AND f.key != 'calls'
            AND f.path != 'result'
        GROUP BY
            block_number,
            tx_position,
            trace_address,
            _inserted_timestamp
    ),
    sub_traces AS (
        SELECT
            block_number,
            tx_position,
            parent_trace_address,
            COUNT(*) AS sub_traces
        FROM
            flatten_traces
        GROUP BY
            block_number,
            tx_position,
            parent_trace_address
    ),
    num_array AS (
        SELECT
            block_number,
            tx_position,
            trace_address,
            ARRAY_AGG(flat_value) AS num_array
        FROM
            (
                SELECT
                    block_number,
                    tx_position,
                    trace_address,
                    IFF(
                        VALUE :: STRING = 'ORIGIN',
                        -1,
                        VALUE :: INT
                    ) AS flat_value
                FROM
                    flatten_traces,
                    LATERAL FLATTEN (
                        input => str_array
                    )
            )
        GROUP BY
            block_number,
            tx_position,
            trace_address
    ),
    cleaned_traces AS (
        SELECT
            b.block_number,
            b.tx_position,
            b.trace_address,
            IFNULL(
                sub_traces,
                0
            ) AS sub_traces,
            num_array,
            ROW_NUMBER() over (
                PARTITION BY b.block_number,
                b.tx_position
                ORDER BY
                    num_array ASC
            ) - 1 AS trace_index,
            trace_json,
            b._inserted_timestamp
        FROM
            flatten_traces b
            LEFT JOIN sub_traces s
            ON b.block_number = s.block_number
            AND b.tx_position = s.tx_position
            AND b.trace_address = s.parent_trace_address
            JOIN num_array n
            ON b.block_number = n.block_number
            AND b.tx_position = n.tx_position
            AND b.trace_address = n.trace_address
    ),
    final_traces AS (
        SELECT
            tx_position,
            trace_index,
            block_number,
            trace_address,
            trace_json :error :: STRING AS error_reason,
            trace_json :from :: STRING AS from_address,
            trace_json :to :: STRING AS to_address,
            IFNULL(
                utils.udf_hex_to_int(
                    trace_json :value :: STRING
                ),
                '0'
            ) AS eth_value_precise_raw,
            ethereum.utils.udf_decimal_adjust(
                eth_value_precise_raw,
                18
            ) AS eth_value_precise,
            eth_value_precise :: FLOAT AS eth_value,
            utils.udf_hex_to_int(
                trace_json :gas :: STRING
            ) :: INT AS gas,
            utils.udf_hex_to_int(
                trace_json :gasUsed :: STRING
            ) :: INT AS gas_used,
            trace_json :input :: STRING AS input,
            trace_json :output :: STRING AS output,
            trace_json :type :: STRING AS TYPE,
            concat_ws(
                '_',
                TYPE,
                trace_address
            ) AS identifier,
            concat_ws(
                '-',
                block_number,
                tx_position,
                identifier
            ) AS _call_id,
            _inserted_timestamp,
            trace_json AS DATA,
            sub_traces
        FROM
            cleaned_traces
    ),
    new_records AS (
    SELECT
        f.block_number,
        t.tx_hash,
        t.block_timestamp,
        t.tx_status,
        f.tx_position,
        f.trace_index,
        f.from_address,
        f.to_address,
        f.eth_value_precise_raw,
        f.eth_value_precise,
        f.eth_value,
        f.gas,
        f.gas_used,
        f.input,
        f.output,
        f.type,
        f.identifier,
        f.sub_traces,
        f.error_reason,
        IFF(
            f.error_reason IS NULL,
            'SUCCESS',
            'FAIL'
        ) AS trace_status,
        f.data,
        IFF(
            t.tx_hash IS NULL
            OR t.block_timestamp IS NULL
            OR t.tx_status IS NULL,
            TRUE,
            FALSE
        ) AS is_pending,
        f._call_id,
        f._inserted_timestamp
    FROM
        final_traces f
        LEFT OUTER JOIN ethereum.silver.transactions t
        ON f.tx_position = t.position
        AND f.block_number = t.block_number
    ),
    traces_final AS (
        SELECT
            block_number,
            tx_hash,
            block_timestamp,
            tx_status,
            tx_position,
            trace_index,
            from_address,
            to_address,
            eth_value_precise_raw,
            eth_value_precise,
            eth_value,
            gas,
            gas_used,
            input,
            output,
            TYPE,
            identifier,
            sub_traces,
            error_reason,
            trace_status,
            DATA,
            is_pending,
            _call_id,
            _inserted_timestamp
        FROM
            new_records
    )
    SELECT
        tx_hash,
        block_number,
        block_timestamp,
        from_address,
        to_address,
        eth_value AS VALUE,
        eth_value_precise_raw AS value_precise_raw,
        eth_value_precise AS value_precise,
        gas,
        gas_used,
        input,
        output,
        TYPE,
        identifier,
        DATA,
        tx_status,
        sub_traces,
        trace_status,
        error_reason,
        trace_index,
        md5(
            cast(
                coalesce(
                    cast(tx_hash as TEXT),
                    '_dbt_utils_surrogate_key_null_'
                ) || '-' || coalesce(
                    cast(trace_index as TEXT),
                    '_dbt_utils_surrogate_key_null_'
                ) as TEXT
            )
        ) as fact_traces_id,
        COALESCE(
            _inserted_timestamp,
            '2000-01-01'
        ) AS inserted_timestamp,
        SYSDATE() AS modified_timestamp
    FROM traces_final
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
    _log_id,
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
WITH heights AS (
    SELECT
        {{ schema }}.udf_rpc('eth_blockNumber', []) as result,
        livequery_dev.utils.udf_hex_to_int(result:result)::integer as latest_block_height,
        coalesce(
            block_height,
            latest_block_height
        ) as min_height,
        iff(
            coalesce(to_latest, false),
            latest_block_height,
            min_height
        ) as max_height
    ),
    spine as (
        select
            row_number() over (
                order by
                    null
            ) -1 + coalesce(block_height, 0)::integer as block_number,
            min_height,
            iff(
                coalesce(to_latest, false),
                latest_block_height,
                min_height
            ) as max_height,
            latest_block_height
        from
            table(generator(ROWCOUNT => 1000)),
            heights
        qualify block_number between min_height and max_height
    ),
    raw_receipts as (
        SELECT
            latest_block_height,
            block_number,
            {{ schema }}.udf_rpc(
                'eth_getBlockReceipts',
                [utils.udf_int_to_hex(block_number)]) AS result,
            v.value as DATA
        from
            spine,
            lateral flatten(result) v
    ),
    raw_block_txs as (
            SELECT
                block_number,
                {{ schema }}.udf_rpc(
                    'eth_getBlockByNumber',
                    [utils.udf_int_to_hex(block_number), true]) AS DATA
            from
                spine
        ),
        raw_txs as (
            SELECT
                block_number,
                v.value as DATA
            from
                raw_block_txs r,
                lateral flatten(r.data:transactions) v
        ),
    blocks as (
        select
            block_number,
            livequery_dev.utils.udf_hex_to_int(DATA :baseFeePerGas::STRING)::INT AS base_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(DATA :difficulty::STRING)::INT AS difficulty,
            DATA :extraData::STRING AS extra_data,
            livequery_dev.utils.udf_hex_to_int(DATA :gasLimit::STRING)::INT AS gas_limit,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :hash::STRING AS HASH,
            DATA :logsBloom::STRING AS logs_bloom,
            DATA :miner::STRING AS miner,
            livequery_dev.utils.udf_hex_to_int(DATA :nonce::STRING)::INT AS nonce,
            livequery_dev.utils.udf_hex_to_int(DATA :number::STRING)::INT AS NUMBER,
            DATA :parentHash::STRING AS parent_hash,
            DATA :receiptsRoot::STRING AS receipts_root,
            DATA :sha3Uncles::STRING AS sha3_uncles,
            livequery_dev.utils.udf_hex_to_int(DATA :size::STRING)::INT AS SIZE,
            DATA :stateRoot::STRING AS state_root,
            livequery_dev.utils.udf_hex_to_int(DATA :timestamp::STRING)::TIMESTAMP AS block_timestamp,
            livequery_dev.utils.udf_hex_to_int(DATA :totalDifficulty::STRING)::INT AS total_difficulty,
            ARRAY_SIZE(DATA :transactions) AS tx_count,
            DATA :transactionsRoot::STRING AS transactions_root,
            DATA :uncles AS uncles,
            DATA :withdrawals AS withdrawals,
            DATA :withdrawalsRoot::STRING AS withdrawals_root,
            md5(
                cast(
                    coalesce(
                        cast(block_number as TEXT),
                        '_dbt_utils_surrogate_key_null_'
                    ) as TEXT
                )
            ) AS blocks_id,
            livequery_dev.utils.udf_hex_to_int(DATA: blobGasUsed::STRING)::INT AS blob_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA: excessBlobGas::STRING)::INT AS excess_blob_gas,
        from
            raw_block_txs
    ),
    receipts as (
        select
            latest_block_height,
            block_number,
            DATA :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(DATA :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(DATA :cumulativeGasUsed::STRING)::INT AS cumulative_gas_used,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT / pow(10, 9) AS effective_gas_price,
            DATA :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS gas_used,
            DATA :logs AS logs,
            DATA :logsBloom::STRING AS logs_bloom,
            livequery_dev.utils.udf_hex_to_int(DATA :status::STRING)::INT AS status,
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
            livequery_dev.utils.udf_hex_to_int(DATA :transactionIndex::STRING)::INT AS POSITION,
            livequery_dev.utils.udf_hex_to_int(DATA :type::STRING)::INT AS TYPE,
            livequery_dev.utils.udf_hex_to_int(DATA :effectiveGasPrice::STRING)::INT AS blob_gas_price,
            livequery_dev.utils.udf_hex_to_int(DATA :gasUsed::STRING)::INT AS blob_gas_used
        from
            raw_receipts
    ),
    txs as (
        select
            A.block_number AS block_number,
            A.data :blockHash::STRING AS block_hash,
            livequery_dev.utils.udf_hex_to_int(A.data :blockNumber::STRING)::INT AS blockNumber,
            livequery_dev.utils.udf_hex_to_int(A.data :chainId::STRING)::INT AS chain_id,
            A.data :from::STRING AS from_address,
            livequery_dev.utils.udf_hex_to_int(A.data :gas::STRING)::INT AS gas,
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice::STRING)::INT / pow(10, 9) AS gas_price,
            A.data :hash::STRING AS tx_hash,
            A.data :input::STRING AS input_data,
            SUBSTR(input_data, 1, 10) AS origin_function_signature,
            livequery_dev.utils.udf_hex_to_int(A.data :maxFeePerGas::STRING)::INT / pow(10, 9) AS max_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(
                A.data :maxPriorityFeePerGas::STRING
            )::INT / pow(10, 9) AS max_priority_fee_per_gas,
            livequery_dev.utils.udf_hex_to_int(A.data :nonce::STRING)::INT AS nonce,
            A.data :r::STRING AS r,
            A.data :s::STRING AS s,
            A.data :to::STRING AS to_address1,
            livequery_dev.utils.udf_hex_to_int(A.data :transactionIndex::STRING)::INT AS POSITION,
            A.data :type::STRING AS TYPE,
            A.data :v::STRING AS v,
            livequery_dev.utils.udf_hex_to_int(A.data :value::STRING) AS value_precise_raw,
            value_precise_raw * power(10, -18) AS value_precise,
            value_precise::FLOAT AS VALUE,
            A.data :accessList AS access_list,
            A.data,
            A.data: blobVersionedHashes::ARRAY AS blob_versioned_hashes,
            livequery_dev.utils.udf_hex_to_int(A.data: maxFeePerGas::STRING)::INT AS max_fee_per_blob_gas,
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
            livequery_dev.utils.udf_hex_to_int(A.data :gasPrice) * power(10, -18) * r.gas_used AS tx_fee_precise,
            COALESCE(tx_fee_precise::FLOAT, 0) AS tx_fee,
            r.type as tx_type,
            r.blob_gas_used,
            r.blob_gas_price,
        from
            raw_txs A
            left join blocks b on b.block_number = A.block_number
            left join receipts as r on r.tx_hash = A.data :hash::STRING
    ),
    raw_traces AS (
        SELECT
            s.block_number,
            v.index::INT AS tx_position,
            v.value:result AS full_traces,
            SYSDATE() AS _inserted_timestamp
        FROM spine s,
        LATERAL FLATTEN(input => PARSE_JSON(
            {{ schema }}.udf_rpc(
                'debug_traceBlockByNumber',
                [utils.udf_int_to_hex(s.block_number), {'tracer': 'callTracer'}])
        )) v
    ),
    flatten_traces AS (
        SELECT
            block_number,
            tx_position,
            IFF(
                path IN (
                    'result',
                    'result.value',
                    'result.type',
                    'result.to',
                    'result.input',
                    'result.gasUsed',
                    'result.gas',
                    'result.from',
                    'result.output',
                    'result.error',
                    'result.revertReason',
                    'gasUsed',
                    'gas',
                    'type',
                    'to',
                    'from',
                    'value',
                    'input',
                    'error',
                    'output',
                    'revertReason'
                ),
                'ORIGIN',
                REGEXP_REPLACE(REGEXP_REPLACE(path, '[^0-9]+', '_'), '^_|_$', '')
            ) AS trace_address,
            _inserted_timestamp,
            OBJECT_AGG(
                key,
                VALUE
            ) AS trace_json,
            CASE
                WHEN trace_address = 'ORIGIN' THEN NULL
                WHEN POSITION(
                    '_' IN trace_address
                ) = 0 THEN 'ORIGIN'
                ELSE REGEXP_REPLACE(
                    trace_address,
                    '_[0-9]+$',
                    '',
                    1,
                    1
                )
            END AS parent_trace_address,
            SPLIT(
                trace_address,
                '_'
            ) AS str_array
        FROM
            raw_traces,
            TABLE(
                FLATTEN(
                    input => PARSE_JSON(full_traces),
                    recursive => TRUE
                )
            ) f
        WHERE
            f.index IS NULL
            AND f.key != 'calls'
            AND f.path != 'result'
        GROUP BY
            block_number,
            tx_position,
            trace_address,
            _inserted_timestamp
    ),
    sub_traces AS (
        SELECT
            block_number,
            tx_position,
            parent_trace_address,
            COUNT(*) AS sub_traces
        FROM
            flatten_traces
        GROUP BY
            block_number,
            tx_position,
            parent_trace_address
    ),
    num_array AS (
        SELECT
            block_number,
            tx_position,
            trace_address,
            ARRAY_AGG(flat_value) AS num_array
        FROM
            (
                SELECT
                    block_number,
                    tx_position,
                    trace_address,
                    IFF(
                        VALUE :: STRING = 'ORIGIN',
                        -1,
                        VALUE :: INT
                    ) AS flat_value
                FROM
                    flatten_traces,
                    LATERAL FLATTEN (
                        input => str_array
                    )
            )
        GROUP BY
            block_number,
            tx_position,
            trace_address
    ),
    cleaned_traces AS (
        SELECT
            b.block_number,
            b.tx_position,
            b.trace_address,
            IFNULL(
                sub_traces,
                0
            ) AS sub_traces,
            num_array,
            ROW_NUMBER() over (
                PARTITION BY b.block_number,
                b.tx_position
                ORDER BY
                    num_array ASC
            ) - 1 AS trace_index,
            trace_json,
            b._inserted_timestamp
        FROM
            flatten_traces b
            LEFT JOIN sub_traces s
            ON b.block_number = s.block_number
            AND b.tx_position = s.tx_position
            AND b.trace_address = s.parent_trace_address
            JOIN num_array n
            ON b.block_number = n.block_number
            AND b.tx_position = n.tx_position
            AND b.trace_address = n.trace_address
    ),
    final_traces AS (
        SELECT
            tx_position,
            trace_index,
            block_number,
            trace_address,
            trace_json :error :: STRING AS error_reason,
            trace_json :from :: STRING AS from_address,
            trace_json :to :: STRING AS to_address,
            IFNULL(
                utils.udf_hex_to_int(
                    trace_json :value :: STRING
                ),
                '0'
            ) AS eth_value_precise_raw,
            ethereum.utils.udf_decimal_adjust(
                eth_value_precise_raw,
                18
            ) AS eth_value_precise,
            eth_value_precise :: FLOAT AS eth_value,
            utils.udf_hex_to_int(
                trace_json :gas :: STRING
            ) :: INT AS gas,
            utils.udf_hex_to_int(
                trace_json :gasUsed :: STRING
            ) :: INT AS gas_used,
            trace_json :input :: STRING AS input,
            trace_json :output :: STRING AS output,
            trace_json :type :: STRING AS TYPE,
            concat_ws(
                '_',
                TYPE,
                trace_address
            ) AS identifier,
            concat_ws(
                '-',
                block_number,
                tx_position,
                identifier
            ) AS _call_id,
            _inserted_timestamp,
            trace_json AS DATA,
            sub_traces
        FROM
            cleaned_traces
    ),
    new_records AS (
    SELECT
        f.block_number,
        t.tx_hash,
        t.block_timestamp,
        t.tx_status,
        f.tx_position,
        f.trace_index,
        f.from_address,
        f.to_address,
        f.eth_value_precise_raw,
        f.eth_value_precise,
        f.eth_value,
        f.gas,
        f.gas_used,
        f.input,
        f.output,
        f.type,
        f.identifier,
        f.sub_traces,
        f.error_reason,
        IFF(
            f.error_reason IS NULL,
            'SUCCESS',
            'FAIL'
        ) AS trace_status,
        f.data,
        IFF(
            t.tx_hash IS NULL
            OR t.block_timestamp IS NULL
            OR t.tx_status IS NULL,
            TRUE,
            FALSE
        ) AS is_pending,
        f._call_id,
        f._inserted_timestamp
    FROM
        final_traces f
        LEFT OUTER JOIN ethereum.silver.transactions t
        ON f.tx_position = t.position
        AND f.block_number = t.block_number
    ),
    traces_final AS (
        SELECT
            block_number,
            tx_hash,
            block_timestamp,
            tx_status,
            tx_position,
            trace_index,
            from_address,
            to_address,
            eth_value_precise_raw,
            eth_value_precise,
            eth_value,
            gas,
            gas_used,
            input,
            output,
            TYPE,
            identifier,
            sub_traces,
            error_reason,
            trace_status,
            DATA,
            is_pending,
            _call_id,
            _inserted_timestamp
        FROM
            new_records
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
            _call_id,
            _inserted_timestamp,
            eth_value_precise_raw AS amount_precise_raw,
            eth_value_precise AS amount_precise,
            tx_position,
            trace_index
        FROM
            traces_final
        WHERE
            eth_value > 0
            AND tx_status = 'SUCCESS'
            AND trace_status = 'SUCCESS'
            AND TYPE NOT IN (
                'DELEGATECALL',
                'STATICCALL'
            )
    ),
    tx_table AS (
        SELECT
            block_number,
            tx_hash,
            from_address AS origin_from_address,
            to_address1 AS origin_to_address,
            origin_function_signature
        FROM
            txs
        WHERE
            tx_hash IN (
                SELECT
                    DISTINCT tx_hash
                FROM
                    eth_base
            )
    ),
    native_transfers AS (
        SELECT
            e.tx_hash,
            e.block_number,
            e.block_timestamp,
            e.identifier,
            t.origin_from_address,
            t.origin_to_address,
            t.origin_function_signature,
            e.from_address,
            e.to_address,
            e.amount,
            e.amount_precise_raw,
            e.amount_precise,
            ROUND(
                e.amount * p.price,
                2
            ) AS amount_usd,
            e._call_id,
            e._inserted_timestamp,
            e.tx_position,
            e.trace_index,
            md5(
                cast(
                    coalesce(cast(e.tx_hash as TEXT), '_dbt_utils_surrogate_key_null_')
                    || '-' || coalesce(cast(e.trace_index as TEXT), '_dbt_utils_surrogate_key_null_')
                    as TEXT
                )
            ) as native_transfers_id,
            SYSDATE() as inserted_timestamp,
            SYSDATE() as modified_timestamp
        FROM
            eth_base e
            JOIN tx_table t ON e.tx_hash = t.tx_hash AND e.block_number = t.block_number
            LEFT JOIN ETHEREUM.price.EZ_PRICES_HOURLY p
                ON DATE_TRUNC('hour', e.block_timestamp) = p.HOUR
                AND p.token_address = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'  -- WETH address
    )
    SELECT
        tx_hash,
        block_number,
        block_timestamp,
        tx_position,
        trace_index,
        identifier AS trace_type,
        origin_from_address,
        origin_to_address,
        origin_function_signature,
        from_address AS trace_from_address,
        to_address AS trace_to_address,
        amount,
        amount_precise_raw,
        amount_precise,
        amount_usd,
        COALESCE(
            native_transfers_id,
            md5(
                cast(
                    coalesce(cast(tx_hash as TEXT), '_dbt_utils_surrogate_key_null_')
                    || '-' || coalesce(cast(trace_index as TEXT), '_dbt_utils_surrogate_key_null_')
                    as TEXT
                )
            )
        ) AS ez_native_transfers_id,
        COALESCE(
            inserted_timestamp,
            '2000-01-01'
        ) AS inserted_timestamp,
        COALESCE(
            modified_timestamp,
            '2000-01-01'
        ) AS modified_timestamp
    FROM
        native_transfers
    QUALIFY (ROW_NUMBER() OVER (
        PARTITION BY block_number, tx_position, trace_index
        ORDER BY _inserted_timestamp DESC
    )) = 1
{% endmacro %}
