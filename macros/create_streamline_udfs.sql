{% macro create_streamline_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {{ create_aws_api_integrations() }}
        {{ create_udf_bulk_rest_api_v2() }}
    {% endif %} 
{% endmacro %}

{% macro create_evm_streamline_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {{ create_aws_api_integrations() }}
        {{ create_udf_bulk_rest_api_v2() }}
        {{ create_udf_bulk_decode_logs() }}
    {% endif %} 
{% endmacro %}