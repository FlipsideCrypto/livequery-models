-- depends_on: {{ ref('silver__streamline_blocks')}}

SELECT * FROM {{ ref('near_models','core__fact_blocks')}}
