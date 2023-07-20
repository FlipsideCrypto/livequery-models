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

{% macro crud_udfs(config_func, schema, drop_) %}
{#
    Generate create or drop statements for a list of udf configs for a given schema

    config_func: function that returns a list of udf configs
    drop_: whether to drop or create the udfs
 #}
    {% set udfs = fromyaml(config_func())%}
    {%- for udf in udfs -%}
        {% if udf["name"].split(".") | first == schema %}
            CREATE SCHEMA IF NOT EXISTS {{ schema }};
            {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
        {%- endif -%}
    {%- endfor -%}
{%- endmacro -%}

{% macro crud_udfs_by_chain(config_func, blockchain, network, drop_) %}
{#
    Generate create or drop statements for a list of udf configs for a given blockchain and network

    config_func: function that returns a list of udf configs
    blockchain: blockchain name
    network: network name
    drop_: whether to drop or create the udfs
 #}
  {% set schema = blockchain if not network else blockchain ~ "_" ~ network %}
    CREATE SCHEMA IF NOT EXISTS {{ schema }};
    {%-  set configs = fromyaml(config_func(blockchain, network)) if network else fromyaml(config_func(schema, blockchain)) -%}
    {%- for udf in configs -%}
        {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
    {%- endfor -%}
{%- endmacro -%}

{% macro crud_udfs_by_marketplace(config_func, schema, utility_schema, drop_) %}
{#
    Generate create or drop statements for a list of udf configs for a given blockchain and network

    config_func: function that returns a list of udf configs
    schema: schema name
    utility_schema: utility schema name
 #}
    CREATE SCHEMA IF NOT EXISTS {{ schema }};
    {%- set configs = fromyaml(config_func(schema, utility_schema)) if utility_schema else fromyaml(config_func(schema, schema)) -%}
    {%- for udf in configs -%}
        {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
    {%- endfor -%}
{%- endmacro -%}

{% macro crud_marketplace_udfs(config_func, schemaName, base_api_schema_name, drop_) %}
{#
    Generate create or drop statements for a list of udf configs for a given schema and api

    config_func: function that returns a list of udf configs
    schemaName: the target schema to build the udfs
    base_api_schema_name: the schema that contains base api functions
    drop_: whether to drop or create the udfs
 #}
  {%-  set udfs = fromyaml(config_func(schemaName, base_api_schema_name)) -%}
  {%- for udf in udfs -%}
    {{- create_or_drop_function_from_config(udf, drop_=drop_) -}}
  {%- endfor -%}
{%- endmacro -%}

{% macro ephemeral_deploy_core(config) %}
{#
    This macro is used to deploy functions using ephemeral models.
    It should only be used within an ephemeral model.
 #}
    {% do log("XXX:"~selected_resources) %}
    {% do log("XXX:"~model.unique_id ) %}
    {% do log("XXX:"~this.schema ) %}
    {% do log("XXX:"~"___________" ) %}
    {% if execute and (var("UPDATE_UDFS_AND_SPS") or var("DROP_UDFS_AND_SPS")) and model.unique_id in selected_resources %}
        {% set sql %}
            {{- crud_udfs(config, this.schema, var("DROP_UDFS_AND_SPS")) -}}
        {%- endset -%}
        {%- do log("Deploy core udfs: " ~ this.database ~ "." ~ this.schema, true) -%}
        {%- do run_query(sql) -%}
    {%- endif -%}
{%- endmacro -%}

{% macro ephemeral_deploy(configs) %}
{#
    This macro is used to deploy functions using ephemeral models.
    It should only be used within an ephemeral model.
 #}
    {%- set blockchain = this.schema -%}
    {%- set network = this.identifier -%}
    {% if execute and (var("UPDATE_UDFS_AND_SPS") or var("DROP_UDFS_AND_SPS")) and model.unique_id in selected_resources %}
        {% set sql %}
            {% for config in configs %}
                {{- crud_udfs_by_chain(config, blockchain, network, var("DROP_UDFS_AND_SPS")) -}}
            {%- endfor -%}
        {%- endset -%}
        {%- do log("Deploy partner udfs: " ~ this.database ~ "." ~ this.schema ~ "--" ~ this.identifier, true) -%}
        {%- do run_query(sql) -%}
    {%- endif -%}
{%- endmacro -%}

{% macro ephemeral_deploy_marketplace(configs) %}
{#
    This macro is used to deploy functions using ephemeral models.
    It should only be used within an ephemeral model.
 #}
    {%- set schema = this.schema -%}
    {%- set utility_schema = this.identifier -%}
    {% if execute and (var("UPDATE_UDFS_AND_SPS") or var("DROP_UDFS_AND_SPS")) and model.unique_id in selected_resources %}
        {% set sql %}
            {% for config in configs %}
                {{- crud_udfs_by_marketplace(config, schema, utility_schema, var("DROP_UDFS_AND_SPS")) -}}
            {%- endfor -%}
        {%- endset -%}
        {%- do log("Deploy marketplace udfs: " ~ this.database ~ "." ~ schema, true) -%}
        {%- do run_query(sql) -%}
    {%- endif -%}
{%- endmacro -%}