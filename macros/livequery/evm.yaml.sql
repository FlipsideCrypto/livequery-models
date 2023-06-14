{% macro config_evm_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for an EVM
    blockchain.
 #}
{% set schema = blockchain ~ "_" ~ network %}
- name: {{ schema -}}.latest_native_balance
  signature:
    - [address, STRING, The address to get the balance of]
  return_type:
    - "TABLE(a STRING, b STRING, c STRING, d NUMBER)"
    - |
        The table has the following columns:
        * `blockchain` - The blockchain name
        * `network` - The network name
        * `address` - The address
        * `balance` - The native asset balance
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance at the latest block for the address.$$
  sql: |
    {{ evm_latest_native_balance(schema) | indent(4) -}}
{%- endmacro -%}