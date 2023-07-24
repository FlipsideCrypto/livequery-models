{% macro apply_grants_by_schema(schema) %}
{#
    Generates SQL to grant permissions to roles for a given schema.
    This gets run automatically when a deployment is made to prod.

    This can be manually run to grant permissions to a new schema:
    `dbt run-operation apply_grants_by_schema --args '{"schema": "my_schema"}'`
 #}
    {% if target.name == "prod" %}
        {%- set outer = namespace(sql="") -%}
        {% for role in ["VELOCITY_INTERNAL", "VELOCITY_ETHEREUM", "INTERNAL_DEV"] %}
                {% set sql -%}
                    {% if schema.startswith("_") %}
                        REVOKE USAGE ON SCHEMA {{ target.database }}.{{ schema }} FROM {{ role }};
                        REVOKE USAGE ON ALL FUNCTIONS IN SCHEMA {{ target.database }}.{{ schema }} FROM {{ role }};
                    {%- else -%}
                        GRANT USAGE ON SCHEMA {{ target.database }}.{{ schema }} TO {{ role }};
                        GRANT USAGE ON ALL FUNCTIONS IN SCHEMA {{ target.database }}.{{ schema }} TO {{ role }};

                        GRANT SELECT ON ALL TABLES IN SCHEMA {{ target.database }}.{{ schema }} TO {{ role }};
                        GRANT SELECT ON ALL VIEWS IN SCHEMA {{ target.database }}.{{ schema }} TO {{ role }};
                    {%- endif -%}
                {%- endset -%}
                {%- set outer.sql = outer.sql ~ sql -%}
        {%- endfor -%}
        {{ outer.sql }}
    {%- endif -%}
{%- endmacro -%}

{% macro apply_grants_to_all_schema() %}
{#
    Run SQL to grant permissions to roles for all schemas.
    This is useful for when a new role is created and needs to be granted access to all schemas.
    This is not used in the normal grant process.

    `dbt run-operation apply_grants_to_all_schema`
 #}
    {% if execute and target.name == "prod" %}
        {% set sql_get_schema %}
            SELECT SCHEMA_NAME
            FROM {{ target.database }}.INFORMATION_SCHEMA.SCHEMATA
            WHERE SCHEMA_NAME NOT IN ('PUBLIC', 'INFORMATION_SCHEMA')
        {%- endset -%}
        {%- set results = run_query(sql_get_schema) -%}
        {% set sql_apply_grants %}
            {%- for schema in results.columns[0].values() -%}
                {{ apply_grants_by_schema(schema) }}
            {%- endfor -%}
        {%- endset -%}
        {% do log(sql_apply_grants, true) %}
        {% do run_query(sql_apply_grants) %}
    {%- endif -%}
{%- endmacro -%}