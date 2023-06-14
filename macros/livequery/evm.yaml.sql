{% macro config_evm_high_level_abstractions(blockchain, network) -%}
{#
    This macro is used to generate the high level abstractions for an EVM
    blockchain.
 #}
- name: {{ schema -}}.latest_native_balance
  signature:
    - [address, STRING, The address to get the balance of]
  return_type: [TABLE (STRING, STRING, STRING, FLOAT)] 
  options: |
    NOT NULL
    RETURNS NULL ON NULL INPUT
    VOLATILE
    COMMENT = $$Returns the native asset balance at the latest block for the address.$$
  sql: |

{%- endmacro -%}