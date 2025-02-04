{{ config(
    materalized = 'ephemeral',
    unique_key = 'receipt_id',
    tags = ['helper', 'receipt_map','scheduled_core']
) }}

{%- set blockchain = this.schema -%}
{%- set network = this.identifier -%}
{%- set schema = blockchain ~ "_" ~ network -%}

WITH 
recursive ancestrytree AS (
    SELECT
        item,
        PARENT
    FROM
        {{ ref('silver__flatten_receipts') }}
    WHERE
        PARENT IS NOT NULL
    UNION ALL
    SELECT
        items.item,
        t.parent
    FROM
        ancestrytree t
        JOIN {{ ref('silver__flatten_receipts') }}
        items
        ON t.item = items.parent
),
base_transactions AS (
    SELECT 
        VALUE:transaction:hash::STRING AS tx_hash,
        VALUE:outcome:execution_outcome:outcome:receipt_ids::ARRAY AS outcome_receipts,
        _partition_by_block_number
    FROM {{ ref('silver__streamline_shards') }},
    LATERAL FLATTEN(input => chunk:transactions::ARRAY)
    WHERE chunk IS NOT NULL
),
FINAL AS (
    SELECT
        tx_hash,
        A.item,
        FALSE is_primary_receipt
    FROM
        ancestrytree A
        JOIN base_transactions b
        ON A.parent = b.outcome_receipts [0] :: STRING
    WHERE
        item IS NOT NULL
    UNION ALL
    SELECT
        A.tx_hash,
        outcome_receipts [0] :: STRING AS receipt_id,
        TRUE is_primary_receipt
    FROM
        base_transactions A
)
SELECT
    tx_hash,
    item AS receipt_id,
    is_primary_receipt
FROM
    FINAL
