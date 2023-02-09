{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call livequery._internal.create_prod_clone(
        'livequery',
        'livequery_dev',
        'livequery_dev_owner'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}
