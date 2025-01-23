{# {% macro get_rendered_model(package_name, model_name, schema, blockchain, network) %}
    {# 
    This macro retrieves and renders a specified model from the graph.

    Args:
        package_name (str): The name of the package containing the model.
        model_name (str): The name of the model to be rendered.
        schema (str): The schema to be used.
        blockchain (str): The blockchain to be used.
        network (str): The network to be used.

    Returns:
        str: The rendered SQL of the specified model.
    #}
    {% if execute %}
    {{ log("=== Starting get_rendered_model ===", info=True) }}
    {# Use a list to store the node to avoid scope issues #}
    {%- set nodes = [] -%}
    {{ log("Looking for node: " ~ package_name ~ "." ~ model_name, info=True) }}
    {%- for node in graph.nodes.values() -%}
        {%- if node.package_name == package_name and node.name == model_name -%}
            {{ log("Found target node: " ~ node.unique_id, info=True) }}
            {%- do nodes.append(node) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- if nodes | length == 0 -%}
        {{ log("No target node found!", info=True) }}
        {{ return('') }}
    {%- endif -%}

    {%- set target_node = nodes[0] -%}
    {{ log("Processing node: " ~ target_node.unique_id, info=True) }}
    {{ log("Dependencies:\n\t\t" ~ (target_node.depends_on.nodes | pprint).replace("\n", "\n\t\t"), info=True) }}

    {# First render all dependency CTEs #}
    {%- set ctes = [] -%}
    {%- for dep_id in target_node.depends_on.nodes -%}
        {{ log("Processing dependency: " ~ dep_id, info=True) }}
        {%- set dep_node = graph.nodes[dep_id] -%}
        {%- set rendered_sql = render(dep_node.raw_code) | trim -%}

        {%- if rendered_sql -%}
            {%- set cte_sql -%}
__dbt__cte__{{ dep_node.name }} AS (
    {{ rendered_sql }}
)
            {%- endset -%}
            {%- do ctes.append(cte_sql) -%}
        {%- endif -%}
    {%- endfor -%}

    {{ log("Number of CTEs generated: " ~ ctes | length, info=True) }}

    {# Combine CTEs with main query #}
    {%- set final_sql -%}
WITH {{ ctes | join(',\n\n') }}

{{ render(target_node.raw_code) }}
    {%- endset -%}

    {{ log("=== End get_rendered_model ===\n\n" , info=True) }}

    {{ return(final_sql) }}
    {% endif %}
{% endmacro %} #}
{% macro get_rendered_model(package_name, model_name, schema, blockchain, network) %}
    {% if execute %}
    {{ log("=== Starting get_rendered_model ===", info=True) }}
    
    {# Use a list to store the node to avoid scope issues #}
    {%- set nodes = [] -%}
    {{ log("Looking for node: " ~ package_name ~ "." ~ model_name, info=True) }}
    {%- for node in graph.nodes.values() -%}
        {%- if node.package_name == package_name and node.name == model_name -%}
            {{ log("Found target node: " ~ node.unique_id, info=True) }}
            {%- do nodes.append(node) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- if nodes | length == 0 -%}
        {{ log("No target node found!", info=True) }}
        {{ exceptions.raise_compiler_error("Target node not found: " ~ package_name ~ "." ~ model_name) }}
    {%- endif -%}

    {%- set target_node = nodes[0] -%}
    {{ log("Processing node: " ~ target_node.unique_id, info=True) }}
    {{ log("Dependencies: " ~ target_node.depends_on.nodes | join(", "), info=True) }}

    {# First render all dependency CTEs #}
    {%- set ctes = [] -%}
    {%- set rendered_ctes = {} -%}  {# Track which CTEs have been rendered #}
    {%- for dep_id in target_node.depends_on.nodes -%}
        {%- set dep_node = graph.nodes[dep_id] -%}
        {%- if dep_node.name not in rendered_ctes -%}  {# Only render each CTE once #}
            {{ log("Processing dependency: " ~ dep_id, info=True) }}
            {%- set rendered_sql = render(dep_node.raw_code) | trim -%}
            {%- if rendered_sql -%}
                {%- set cte_sql -%}
__dbt__cte__{{ dep_node.name }} AS (
    {{ rendered_sql }}
)
                {%- endset -%}
                {%- do ctes.append(cte_sql) -%}
                {%- do rendered_ctes.update({dep_node.name: true}) -%}
            {%- endif -%}
        {%- endif -%}
    {%- endfor -%}

    {{ log("Number of CTEs generated: " ~ ctes | length, info=True) }}

    {# Add depends_on comments #}
    {%- set depends_on = [] -%}
    {%- for dep_id in target_node.depends_on.nodes -%}
        {%- set dep_node = graph.nodes[dep_id] -%}
        {%- do depends_on.append("-- depends_on: __dbt__cte__" ~ dep_node.name) -%}
    {%- endfor -%}

    {# Combine CTEs with main query #}
    {%- set final_sql -%}
    {%- if ctes -%}
WITH {{ ctes | join(',\n\n') }}

{{ depends_on | join('\n') }}

    {%- endif -%}
{{ render(target_node.raw_code) }}
    {%- endset -%}

    {{ log("=== End get_rendered_model ===", info=True) }}
    {{ return(final_sql) }}
    {% endif %}
{% endmacro %}