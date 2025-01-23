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
txs AS (
    SELECT
        tx_hash,
        outcome_receipts,
        _partition_by_block_number
    FROM
        {{ ref('silver__streamline_transactions') }}

),
FINAL AS (
    SELECT
        tx_hash,
        A.item,
        FALSE is_primary_receipt
    FROM
        ancestrytree A
        JOIN txs b
        ON A.parent = b.outcome_receipts [0] :: STRING
    WHERE
        item IS NOT NULL
    UNION ALL
    SELECT
        A.tx_hash,
        outcome_receipts [0] :: STRING AS receipt_id,
        TRUE is_primary_receipt
    FROM
        txs A
)
SELECT
    tx_hash,
    item AS receipt_id,
    is_primary_receipt
FROM
    FINAL
