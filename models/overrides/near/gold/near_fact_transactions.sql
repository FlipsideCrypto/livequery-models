-- depends_on: {{ ref('silver__streamline_transactions')}}
-- depends_on: {{ ref('silver__streamline_shards')}}

SELECT * FROM {{ ref('near_models','core__fact_transactions')}}
