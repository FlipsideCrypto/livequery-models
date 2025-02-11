{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

    SELECT
        block_number,
        fact_event_logs_id AS id,
        utils.udf_evm_decode_log(abi, event_data)[0] AS DATA,
        TO_TIMESTAMP_NTZ(_inserted_timestamp) AS _inserted_timestamp
    FROM
        {{ ref('fsc_evm', 'core__fact_event_logs')}}
    JOIN
        {{ blockchain }}.core.dim_contract_abis
    USING
        (contract_address)
    WHERE
        tx_status = 'SUCCESS'

