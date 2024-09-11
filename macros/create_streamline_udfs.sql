{% macro create_streamline_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {{ create_udf_bulk_rest_api_v2() }}
    {% endif %}
{% endmacro %}

{% macro create_evm_streamline_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {{ create_udf_bulk_rest_api_v2() }}
        {{ create_udf_bulk_decode_logs() }}
        {{ create_udf_bulk_decode_traces() }}
    {% endif %}
{% endmacro %}
