{% if is_udf_api_v2_compatible() %}
{{ create_s3_express_external_access_integration() }}
{% endif %}

-- this is to pass the model render as dbt dependency in other models
-- livequery will need s3 express access to read from the s3 bucket

SELECT 1
