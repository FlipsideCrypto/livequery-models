-- depends_on: {{ ref('livequery_models','silver__streamline_transactions')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_transactions_final')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_receipts')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_receipts_final')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_blocks')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_shards')}}
-- depends_on: {{ ref('livequery_models','silver__receipt_tx_hash_mapping')}}
-- depends_on: {{ ref('livequery_models','silver__flatten_receipts')}}
SELECT * FROM {{ ref('near_models','core__fact_transactions')}}
