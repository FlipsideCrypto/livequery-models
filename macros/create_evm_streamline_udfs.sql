{% macro create_evm_streamline_udfs() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% set sql %}
        BEGIN;
        {{ create_udf_bulk_rest_api_v2_evm() }}
        {{ create_udf_bulk_decode_logs() }}
        COMMIT;
        {% endset %}
        {% do run_query(sql) %}
    {% endif %}
{% endmacro %}