{% macro create_stored_procedure(
    name_,
    signature,
    return_type,
    sql_,
    language='sql',
    execute_as='caller',
    options=none
) %}
    CREATE OR REPLACE PROCEDURE {{ name_ }}(
        {{- compile_signature(signature) }}
    )
    RETURNS {{ return_type }}
    LANGUAGE {{ language }}
    EXECUTE AS {{ execute_as }}
    {% if options %}
    {{ options }}
    {% endif %}
    AS
    $$
    {{ sql_ }}
    $$;
{% endmacro %}

{% macro ephemeral_deploy_procedures(configs) %}
    {%- set blockchain = this.schema -%}
    {%- set network = this.identifier -%}
    {% set schema = blockchain ~ "_" ~ network %}

    {% if execute and (var("LQ_UPDATE_UDFS_AND_SPS") or var("DROP_UDFS_AND_SPS")) and model.unique_id in selected_resources %}
        {% set sql %}
            {% for config in configs %}
                CREATE SCHEMA IF NOT EXISTS {{ schema }};

                {% for sp in fromyaml(config(blockchain, network)) %}
                    {% if var("DROP_UDFS_AND_SPS") %}
                        DROP PROCEDURE IF EXISTS {{ sp.name }}({{ compile_signature(sp.signature, drop_=True) }});
                    {% else %}
                        {{ create_stored_procedure(
                            name_=sp.name,
                            signature=sp.signature,
                            return_type=sp.return_type,
                            sql_=sp.sql,
                            language=sp.language | default('sql'),
                            execute_as=sp.execute_as | default('caller'),
                            options=sp.options
                        ) }}
                    {% endif %}
                {% endfor %}
            {% endfor %}
        {% endset %}

        {% if var("DROP_UDFS_AND_SPS") %}
            {% do log("Drop Stored Procedures: " ~ this.database ~ "." ~ schema, true) %}
        {% else %}
            {% do log("Deploy Stored Procedures: " ~ this.database ~ "." ~ schema, true) %}
        {% endif %}

        {% do run_query(sql ~ apply_grants_by_schema(schema)) %}
    {% endif %}

    SELECT '{{ model.schema }}' as schema_
{% endmacro %}
