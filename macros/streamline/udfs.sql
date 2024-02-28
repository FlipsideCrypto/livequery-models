{% macro create_udf_bulk_rest_api_v2() %}    
    {{ log("Creating udf udf_bulk_rest_api for target:" ~ target.name ~ ", schema: " ~ target.schema ~ ", DB: " ~ target.database, info=True) }}
    {{ log("role:" ~ target.role ~ ", user:" ~ target.user, info=True) }}
    {% set sql %}
    CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_rest_api_v2(json variant) returns variant api_integration = 
    {% if target.name == "prod" %} 
        {{ log("Creating prod udf_bulk_rest_api", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}/udf_bulk_rest_api'
    {% elif target.name == "dev" %}
        {{ log("Creating dev udf_bulk_rest_api", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}/udf_bulk_rest_api'
    {% elif  target.name == "sbx" %}
        {{ log("Creating stg udf_bulk_rest_api", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}/udf_bulk_rest_api'
    {%- endif %}
    {% endset %}
    {{ log(sql, info=True) }}
    {% do adapter.execute(sql) %}
{% endmacro %}