{%- macro config_near_rpc_primitives(blockchain, network) -%}
{#-
    Generates udfs that call the Near JSON RPC API

    - rpc: Executes an RPC call on the {{ blockchain }} blockchain

 -#}
{% set schema = blockchain ~ "_" ~ network -%}

- name: {{ schema -}}.udf_rpc
  signature:
    - [method, STRING, RPC method to call]
    - [parameters, VARIANT, Parameters to pass to the RPC method]
  return_type: [VARIANT, The return value of the RPC method]
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Executes an RPC call on the {{ blockchain }} blockchain.$$
  sql: |
    SELECT live.udf_rpc('{{ blockchain }}', '{{ network }}', method, parameters)
{%- endmacro -%}