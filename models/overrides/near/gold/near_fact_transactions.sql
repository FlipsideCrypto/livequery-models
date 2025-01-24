-- depends_on: {{ ref('livequery_models','silver__streamline_blocks')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_shards')}}
-- depends_on: {{ ref('livequery_models','silver__streamline_transactions')}}

SELECT * FROM {{ ref('near_models','core__fact_transactions')}}
