{% macro create_udf_bulk_rest_api_v2() %}    
    {{ log("Creating udf udf_bulk_rest_api for target:" ~ target.name ~ ", schema: " ~ target.schema ~ ", DB: " ~ target.database, info=True) }}
    {{ log("role:" ~ target.role ~ ", user:" ~ target.user, info=True) }}

    {% set sql %}
    CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_rest_api_v2(json object) returns array api_integration = 
    {% if target.name == "prod" %} 
        {{ log("Creating prod udf_bulk_rest_api_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}udf_bulk_rest_api'
    {% elif target.name == "dev" %}
        {{ log("Creating dev udf_bulk_rest_api_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}udf_bulk_rest_api'
    {% elif  target.name == "sbx" %}
        {{ log("Creating stg udf_bulk_rest_api_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}udf_bulk_rest_api'
    {% else %}
        {{ log("Creating default (dev) udf_bulk_rest_api_v2", info=True) }}
        {{ var("config")["dev"]["API_INTEGRATION"] }} AS 'https://{{ var("config")["dev"]["EXTERNAL_FUNCTION_URI"] | lower }}udf_bulk_rest_api'
    {% endif %};
    {% endset %}
    {{ log(sql, info=True) }}
    {% do adapter.execute(sql) %}
{% endmacro %}

{% macro create_udf_bulk_decode_logs() %}    
    {{ log("Creating udf udf_bulk_decode_logs_v2 for target:" ~ target.name ~ ", schema: " ~ target.schema ~ ", DB: " ~ target.database, info=True) }}
    {{ log("role:" ~ target.role ~ ", user:" ~ target.user, info=True) }}

    {% set sql %}
    CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_decode_logs_v2(json object) returns array api_integration = 
    {% if target.name == "prod" %} 
        {{ log("Creating prod udf_bulk_decode_logs_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_logs'
    {% elif target.name == "dev" %}
        {{ log("Creating dev udf_bulk_decode_logs_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_logs'
    {% elif  target.name == "sbx" %}
        {{ log("Creating stg udf_bulk_decode_logs_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_logs'
    {% else %}
        {{ log("Creating default (dev) udf_bulk_decode_logs_v2", info=True) }}
        {{ var("config")["dev"]["API_INTEGRATION"] }} AS 'https://{{ var("config")["dev"]["EXTERNAL_FUNCTION_URI"] | lower }}bulk_decode_logs'
    {% endif %};
    {% endset %}
    {{ log(sql, info=True) }}
    {% do adapter.execute(sql) %}
{% endmacro %}

{% macro create_udf_bulk_decode_traces() %}    
    {{ log("Creating udf udf_bulk_decode_traces_v2 for target:" ~ target.name ~ ", schema: " ~ target.schema ~ ", DB: " ~ target.database, info=True) }}
    {{ log("role:" ~ target.role ~ ", user:" ~ target.user, info=True) }}

    {% set sql %}
    CREATE OR REPLACE EXTERNAL FUNCTION streamline.udf_bulk_decode_traces_v2(json object) returns array api_integration = 
    {% if target.name == "prod" %} 
        {{ log("Creating prod udf_bulk_decode_traces_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_traces'
    {% elif target.name == "dev" %}
        {{ log("Creating dev udf_bulk_decode_traces_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_traces'
    {% elif  target.name == "sbx" %}
        {{ log("Creating stg udf_bulk_decode_traces_v2", info=True) }}
        {{ var("API_INTEGRATION") }} AS 'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}bulk_decode_traces'
    {% else %}
        {{ log("Creating default (dev) udf_bulk_decode_traces_v2", info=True) }}
        {{ var("config")["dev"]["API_INTEGRATION"] }} AS 'https://{{ var("config")["dev"]["EXTERNAL_FUNCTION_URI"] | lower }}bulk_decode_traces'
    {% endif %};
    {% endset %}
    {{ log(sql, info=True) }}
    {% do adapter.execute(sql) %}
{% endmacro %}

{% macro create_aws_api_integrations() %}    
    {{ log("Creating api integration for target:" ~ target.name ~ ", schema: " ~ target.schema ~ ", DB: " ~ target.database, info=True) }}
    {{ log("role:" ~ target.role ~ ", user:" ~ target.user, info=True) }}

    {% set sql %}
    CREATE OR REPLACE api integration {{ var("API_INTEGRATION") }} api_provider = aws_api_gateway api_aws_role_arn = '{{ var("API_AWS_ROLE_ARN") }}' api_allowed_prefixes = (
    'https://{{ var("EXTERNAL_FUNCTION_URI") | lower }}'
    ) enabled = TRUE;
    {% endset %}
    {{ log(sql, info=True) }}
    {% do adapter.execute(sql) %}
{% endmacro %}