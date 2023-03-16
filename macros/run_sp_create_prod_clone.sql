{% macro run_sp_create_prod_clone() %}
    {% set clone_query %}
    call reference._internal.create_prod_clone(
        'reference',
        'reference_dev',
        'reference_dev_owner'
    );
{% endset %}
    {% do run_query(clone_query) %}
{% endmacro %}
