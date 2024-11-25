{% macro create_sps() %}
    {% if var("UPDATE_UDFS_AND_SPS") %}
        {% if target.database == 'LIVEQUERY' %}
            CREATE schema IF NOT EXISTS _internal;
    {{ sp_create_prod_clone('_internal') }};
        {% endif %}
    {% endif %}
{% endmacro %}
