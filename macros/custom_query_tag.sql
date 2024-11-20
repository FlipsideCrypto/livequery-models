{% macro get_query_tag() %}
    {# Get the full path of the model #}
    {% set model_path = model.path | string %}
    {% set folder_path = '/'.join(model_path.split('/')[:-1]) %}
    
    {# Get core folders from vars #}
    {% set core_folders = var('core_folders') %}
    
    {# Initialize is_core and check each path pattern #}
    {% set ns = namespace(is_core=false) %}
    
    {% for folder in core_folders %}
        {% if folder in folder_path %}
            {% set ns.is_core = true %}
        {% endif %}
    {% endfor %}
    
    {# Build the JSON query tag #}
    {% set tag_dict = {
        "project": project_name,
        "model": model.name,
        "model_type": "core" if ns.is_core else "non_core",
        "invocation_id": invocation_id,
        "dbt_tags": config.get('tags', [])
    } %}
    
    {% set query_tag = tojson(tag_dict) %}
    
    {# Return the properly escaped string #}
    {{ return("'" ~ query_tag ~ "'") }}
{% endmacro %}

{% macro set_query_tag() %}
    {% set tag = fsc_utils.get_query_tag() %}
    {% do run_query("alter session set query_tag = " ~ tag) %}
    {{ return("") }}
{% endmacro %} 