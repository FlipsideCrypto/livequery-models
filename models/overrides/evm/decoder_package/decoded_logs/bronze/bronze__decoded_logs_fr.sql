{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

    SELECT
        block_number,
        tx_hash :: STRING || '-' || event_index :: STRING AS id,
        OBJECT_CONSTRUCT('topics', topics, 'data', data, 'address', contract_address) AS event_data,
        utils.udf_evm_decode_log(abi, event_data)[0] AS DATA,
        TO_TIMESTAMP_NTZ(_inserted_timestamp) AS _inserted_timestamp
    FROM
        {{ ref('fsc_evm', 'core__fact_event_logs')}}
    JOIN
        {{ blockchain }}.core.dim_contract_abis
    USING
        (contract_address)
    WHERE
        tx_succeeded = TRUE

