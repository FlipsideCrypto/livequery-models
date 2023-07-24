{% macro grant_permissions_to_roles(schema) %}
{#
    Generates SQL to grant permissions to roles for a given schema.
 #}
    {% if target.name == "prod" %}
        {%- set outer = namespace(sql="") -%}
        {% for role in ["VELOCITY_INTERNAL", "VELOCITY_ETHEREUM", "INTERNAL_DEV"] %}
                {%- set sql -%}
                    {% if schema.startswith("_") %}
                        REVOKE USAGE ON SCHEMA {{ schema }} FROM {{ role }};
                        REVOKE USAGE ON ALL FUNCTIONS IN SCHEMA {{ schema }} FROM {{ role }};
                    {%- else -%}
                        GRANT USAGE ON SCHEMA {{ schema }} TO {{ role }};
                        GRANT USAGE ON ALL FUNCTIONS IN SCHEMA {{ schema }} TO {{ role }};

                        GRANT SELECT ON ALL TABLES IN SCHEMA {{ schema }} TO {{ role }};
                        GRANT SELECT ON ALL VIEWS IN SCHEMA {{ schema }} TO {{ role }};
                    {%- endif -%}
                {%- endset -%}
                {%- set outer.sql = outer.sql ~ sql -%}
        {%- endfor -%}
        {{ outer.sql }}
    {%- endif -%}
{%- endmacro -%}
