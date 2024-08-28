{% macro drop_function(
        func_name,
        signature
    ) %}
    DROP FUNCTION IF EXISTS {{ func_name }}({{ fsc_utils.compile_signature(signature, drop_ = True) }});
{% endmacro %}

{%- macro construct_api_route(route) -%}
    'https://{{ var("REST_API_ID_PROD") if target.name == "prod" else var("REST_API_ID_DEV") }}.execute-api.{{ var( aws_region, "us-east-1" ) }}.amazonaws.com/{{ target.name }}/{{ route }}'
{%- endmacro -%}

{%- macro compile_signature(
        params,
        drop_ = False
    ) -%}
    {% for name,
        data_type in params -%}
        {% if drop_ %}
            {{ data_type -}}
        {% else %}
            {{ name ~ " " ~ data_type -}}
        {% endif -%}
        {%-if not loop.last -%},
        {%- endif -%}
    {% endfor -%}
{% endmacro %}

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
            {{- fsc_utils.compile_signature(signature) }}
    )
    COPY GRANTS
    RETURNS {{ return_type }}
    {% if options -%}
        {{ options }}
    {% endif %}
    {%- if api_integration -%}
    api_integration = {{ api_integration }}
    AS {{ fsc_utils.construct_api_route(sql_) ~ ";" }}
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
    {% set return_type = config ["return_type"] %}
    {% set sql_ = config ["sql"] %}
    {% set options = config ["options"] %}
    {% set api_integration = config ["api_integration"] %}
    {% set func_type = config ["func_type"] %}

    {% if not drop_ -%}
        {{ fsc_utils.create_sql_function(
            name_ = name_,
            signature = signature,
            return_type = return_type,
            sql_ = sql_,
            options = options,
            api_integration = api_integration,
            func_type = func_type
        ) }}
    {%- else -%}
        {{ fsc_utils.drop_function(
            name_,
            signature = signature,
        ) }}
    {%- endif %}
{% endmacro %}

{% macro if_data_call_function_v2(
        func,
        target,
        params
    ) %}
    {% if var(
            "STREAMLINE_INVOKE_STREAMS"
        ) %}
        {% if execute %}
            {{ log(
                "Running macro `if_data_call_function`: Calling udf " ~ func ~ " with params: \n" ~ params | tojson(indent=2) ~  "\n on " ~ target,
                True
            ) }}
        {% endif %}
    SELECT
        {{ func }}( parse_json($${{ params | tojson }}$$) )
    WHERE
        EXISTS(
            SELECT
                1
            FROM
                {{ target }}
            LIMIT
                1
        )
    {% else %}
        {% if execute %}
            {{ log(
                "Running macro `if_data_call_function`: NOOP",
                False
            ) }}
        {% endif %}
    SELECT
        NULL
    {% endif %}
{% endmacro %}

{% macro if_data_call_wait() %}
    {% if var(
            "STREAMLINE_INVOKE_STREAMS"
        ) %}
        {% set query %}
    SELECT
        1
    WHERE
        EXISTS(
            SELECT
                1
            FROM
                {{ model.schema ~ "." ~ model.alias }}
            LIMIT
                1
        ) {% endset %}
        {% if execute %}
            {% set results = run_query(
                query
            ) %}
            {% if results %}
                {{ log(
                    "Waiting...",
                    info = True
                ) }}

                {% set wait_query %}
            SELECT
                system$wait(
                    {{ var(
                        "WAIT",
                        400
                    ) }}
                ) {% endset %}
                {% do run_query(wait_query) %}
            {% else %}
            SELECT
                NULL;
            {% endif %}
        {% endif %}
    {% endif %}
{% endmacro %}