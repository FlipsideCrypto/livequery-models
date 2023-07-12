{% macro get_marketplace_db_name(db_name) %}
    {% if var("IS_PROD") %}       
        {{db_name}}
    {% else %}
        {{db_name}}_dev
    {% endif %}
{% endmacro %}