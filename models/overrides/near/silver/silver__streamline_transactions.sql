-- models/silver/silver__streamline_blocks.sql
{{ config(
    materialized = 'ephemeral',
    tags = ['near_models','core','override']
) }}

{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

WITH chunks AS (
    SELECT 
        s.block_height as block_id,
        s.shard_id,
        s.chunk,
        s._partition_by_block_number,
        SYSDATE() as _inserted_timestamp,
        SYSDATE() as _modified_timestamp
    FROM {{ ref('silver__streamline_shards') }} s
    WHERE chunk IS NOT NULL
),
flatten_transactions AS (
    SELECT
        VALUE:transaction:hash::STRING AS tx_hash,
        block_id,
        shard_id,
        INDEX AS transactions_index,
        chunk:header:chunk_hash::STRING AS chunk_hash,
        VALUE:outcome:execution_outcome:outcome:receipt_ids::ARRAY AS outcome_receipts,
        VALUE AS tx,
        _partition_by_block_number,
        _inserted_timestamp,
        _modified_timestamp
    FROM chunks,
    LATERAL FLATTEN(input => chunk:transactions::ARRAY)
),
txs AS (
    SELECT
        tx_hash,
        block_id,
        shard_id,
        transactions_index,
        chunk_hash,
        outcome_receipts,
        tx,
        tx:transaction:actions::variant AS _actions,
        tx:transaction:hash::STRING AS _hash,
        tx:transaction:nonce::STRING AS _nonce,
        tx:outcome:execution_outcome::variant AS _outcome,
        tx:transaction:public_key::STRING AS _public_key,
        []::ARRAY AS _receipt,
        tx:transaction:receiver_id::STRING AS _receiver_id,
        tx:transaction:signature::STRING AS _signature,
        tx:transaction:signer_id::STRING AS _signer_id,
        _partition_by_block_number,
        _inserted_timestamp,
        _modified_timestamp
    FROM flatten_transactions
)
SELECT
    *,
    {{ dbt_utils.generate_surrogate_key(['tx_hash']) }} AS streamline_transactions_id,
    SYSDATE() AS inserted_timestamp,
    SYSDATE() AS modified_timestamp,
    'override' AS _invocation_id
FROM txs