{% macro drop_function(
        func_name,
        signature
    ) %}
    DROP FUNCTION IF EXISTS {{ func_name }}({{ compile_signature(signature, drop_ = True) }});
{% endmacro %}

{%- macro construct_api_route(route) -%}
    'https://{{ var("REST_API_ID_PROD") if target.name == "prod" else var("REST_API_ID_DEV") }}.execute-api.{{ var( aws_region, "us-east-1" ) }}.amazonaws.com/{{ target.name }}/{{ route }}'
{%- endmacro -%}

{%- macro compile_signature(
        params,
        drop_ = False
    ) -%}
    {% for p in params -%}
        {%- set name = p.0 -%}
        {%- set data_type = p.1 -%}
        {% if drop_ %}
            {{ data_type -}}
        {% else %}
            {{ name ~ " " ~ data_type -}}
        {%- endif -%}
        {%-if not loop.last -%},
        {%- endif -%}
    {% endfor -%}
{%- endmacro -%}

{% macro create_sql_function(
        name_,
        signature,
        return_type,
        sql_,
        api_integration = none,
        options = none,
        func_type = none
    ) %}
    CREATE OR REPLACE {{ func_type }} FUNCTION {{ name_ }}(
            {{- compile_signature(signature) }}
    )
    COPY GRANTS
    RETURNS {{ return_type }}
    {% if options -%}
        {{ options }}
    {% endif %}
    {%- if api_integration -%}
    api_integration = {{ api_integration }}
    AS {{ construct_api_route(sql_) ~ ";" }}
    {% else -%}
    AS
    $$
    {{ sql_ }}
    $$;
    {%- endif -%}
{%- endmacro -%}

{%- macro create_or_drop_function_from_config(
        config,
        drop_ = False
    ) -%}
    {% set name_ = config ["name"] %}
    {% set signature = config ["signature"] %}
    {% set return_type = config ["return_type"] if config ["return_type"] is string else config ["return_type"][0] %}
    {% set sql_ = config ["sql"] %}
    {% set options = config ["options"] %}
    {% set api_integration = config ["api_integration"] %}
    {% set func_type = config ["func_type"] %}

    {% if not drop_ -%}
        {{ create_sql_function(
            name_ = name_,
            signature = signature,
            return_type = return_type,
            sql_ = sql_,
            options = options,
            api_integration = api_integration,
            func_type = func_type
        ) }}
    {%- else -%}
        {{ drop_function(
            name_,
            signature = signature,
        ) }}
    {%- endif %}
{% endmacro %}
