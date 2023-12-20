{% macro python_hex_to_int() %}
def hex_to_int(hex) -> str:
    """
    Converts hex (of any size) to int (as a string). Snowflake and java script can only handle up to 64-bit (38 digits of precision)
    hex_to_int('200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int('0x200000000000000000000000000000211');
    >> 680564733841876926926749214863536423441
    hex_to_int(NULL);
    >> NULL
    """
    return (str(int(hex, 16)) if hex and hex != "0x" else None)
{% endmacro %}


{% macro python_udf_hex_to_int_with_encoding() %}
def hex_to_int(encoding, hex) -> str:
  """
  Converts hex (of any size) to int (as a string). Snowflake and java script can only handle up to 64-bit (38 digits of precision)
  hex_to_int('hex', '200000000000000000000000000000211');
  >> 680564733841876926926749214863536423441
  hex_to_int('hex', '0x200000000000000000000000000000211');
  >> 680564733841876926926749214863536423441
  hex_to_int('hex', NULL);
  >> NULL
  hex_to_int('s2c', 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffe5b83acf');
  >> -440911153
  """
  if not hex:
    return None
  if encoding.lower() == 's2c':
    if hex[0:2].lower() != '0x':
      hex = f'0x{hex}'

    bits = len(hex[2:])*4
    value = int(hex, 0)
    if value & (1 << (bits-1)):
        value -= 1 << bits
    return str(value)
  else:
    return str(int(hex, 16))
{% endmacro %}

{% macro create_udf_keccak256() %}
from Crypto.Hash import keccak

def udf_encode(event_name):
    keccak_hash = keccak.new(digest_bits=256)
    keccak_hash.update(event_name.encode('utf-8'))
    return '0x' + keccak_hash.hexdigest()
{% endmacro %}

{% macro create_udf_evm_text_signature() %}

def get_simplified_signature(abi):
    def generate_signature(inputs):
        signature_parts = []
        for input_data in inputs:
            if 'components' in input_data:
                component_signature_parts = []
                components = input_data['components']
                component_signature_parts.extend(generate_signature(components))
                component_signature_parts[-1] = component_signature_parts[-1].rstrip(",")
                if input_data['type'].endswith('[]'):
                    signature_parts.append("(" + "".join(component_signature_parts) + ")[],")
                else:
                    signature_parts.append("(" + "".join(component_signature_parts) + "),")
            else:
                signature_parts.append(input_data['type'].replace('enum ', '').replace(' payable', '') + ",")
        return signature_parts

    signature_parts = [abi['name'] + "("]
    signature_parts.extend(generate_signature(abi['inputs']))
    signature_parts[-1] = signature_parts[-1].rstrip(",") + ")"
    return "".join(signature_parts)
{% endmacro %}

{% macro create_udf_decimal_adjust() %}

from decimal import Decimal, ROUND_DOWN

def custom_divide(input, adjustment):
    try:
        if adjustment is None or input is None:
            return None

        # Perform the division using Decimal type
        result = Decimal(input) / pow(10, Decimal(adjustment))

        # Determine the number of decimal places in the result
        decimal_places = max(0, -result.as_tuple().exponent)

        # Convert the result to a string representation without scientific notation and with dynamic decimal precision
        result_str = "{:.{prec}f}".format(result, prec=decimal_places)

        return result_str
    except Exception as e:
        return None
{% endmacro %}

{% macro create_udf_cron_to_prior_timestamps() %}
import croniter
import datetime

class TimestampGenerator:

    def __init__(self):
        pass

    def process(self, workflow_name, workflow_schedule):
        for timestamp in self.generate_timestamps(workflow_name, workflow_schedule):
            yield (workflow_name, workflow_schedule, timestamp)

    def generate_timestamps(self, workflow_name, workflow_schedule):
        # Create a cron iterator object
        cron = croniter.croniter(workflow_schedule)

        # Generate timestamps for the prev 10 runs
        timestamps = []
        for i in range(10):
            prev_run = cron.get_prev(datetime.datetime)
            timestamps.append(prev_run)

        return timestamps
{% endmacro %}

{% macro create_udf_transform_logs() %}

from copy import deepcopy

def transform_tuple(components: list, values: list):
    transformed_values = []
    for i, component in enumerate(components):
        if i < len(values):
            if component["type"] == "tuple":
                transformed_values.append({"value": transform_tuple(component["components"], values[i]), **component})
            elif component["type"] == "tuple[]":
                if not values[i]:
                    transformed_values.append({"value": [], **component})
                    continue
                sub_values = [transform_tuple(component["components"], v) for v in values[i]]
                transformed_values.append({"value": sub_values, **component})
            else:
                transformed_values.append({"value": values[i], **component})
    return {item["name"]: item["value"] for item in transformed_values}

def transform_event(event: dict):
    new_event = deepcopy(event)
    if new_event.get("components"):
        components = new_event.get("components")

        if not new_event["value"]:
            return new_event

        if isinstance(new_event["value"][0], list):
            result_list = []
            for value_set in new_event["value"]:
                result_list.append(transform_tuple(components, value_set))
            new_event["value"] = result_list

        else:
            new_event["value"] = transform_tuple(components, new_event["value"])

        return new_event

    else:
        return event

def transform(events: dict):
    try:
        results = [
            transform_event(event) if event.get("decoded") else event
            for event in events["data"]
        ]
        events["data"] = results
        return events
    except:
        return events

{% endmacro %}

{% macro create_udf_hex_to_base58() %}

def transform_hex_to_base58(input):
    if input is None or not input.startswith('0x'):
        return 'Invalid input'

    input = input[2:]

    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    byte_array = bytes.fromhex(input)
    num = int.from_bytes(byte_array, 'big')

    encoded = ''
    while num > 0:
        num, remainder = divmod(num, 58)
        encoded = ALPHABET[remainder] + encoded

    for byte in byte_array:
        if byte == 0:
            encoded = '1' + encoded
        else:
            break

    return encoded

{% endmacro %}

{% macro create_udf_hex_to_bech32() %}

def transform_hex_to_bech32(input, hrp=''):
    CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

    def bech32_polymod(values):
        generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
        checksum = 1
        for value in values:
            top = checksum >> 25
            checksum = ((checksum & 0x1ffffff) << 5) ^ value
            for i in range(5):
                checksum ^= generator[i] if ((top >> i) & 1) else 0
        return checksum

    def bech32_hrp_expand(hrp):
        return [ord(x) >> 5 for x in hrp] + [0] + [ord(x) & 31 for x in hrp]

    def bech32_create_checksum(hrp, data):
        values = bech32_hrp_expand(hrp) + data
        polymod = bech32_polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
        return [(polymod >> 5 * (5 - i)) & 31 for i in range(6)]

    def bech32_convertbits(data, from_bits, to_bits, pad=True):
        acc = 0
        bits = 0
        ret = []
        maxv = (1 << to_bits) - 1
        max_acc = (1 << (from_bits + to_bits - 1)) - 1
        for value in data:
            acc = ((acc << from_bits) | value) & max_acc
            bits += from_bits
            while bits >= to_bits:
                bits -= to_bits
                ret.append((acc >> bits) & maxv)
        if pad and bits:
            ret.append((acc << (to_bits - bits)) & maxv)
        return ret

    if input is None or not input.startswith('0x'):
        return 'Invalid input'

    input = input[2:]

    data = bytes.fromhex(input)
    data5bit = bech32_convertbits(list(data), 8, 5)

    if data5bit is None:
        return 'Data conversion failed'

    checksum = bech32_create_checksum(hrp, data5bit)

    return hrp + '1' + ''.join([CHARSET[d] for d in data5bit + checksum])

{% endmacro %}

{% macro create_udf_hex_to_algorand() %}

import hashlib
import base64

def transform_hex_to_algorand(input):
    if input is None or not input.startswith('0x'):
        return 'Invalid input'

    input = input[2:]
    public_key_bytes = bytearray.fromhex(input)

    sha512_256_hash = hashlib.new('sha512_256', public_key_bytes).digest()

    checksum = sha512_256_hash[-4:]

    algorand_address = base64.b32encode(public_key_bytes + checksum).decode('utf-8').rstrip('=')

    return algorand_address

{% endmacro %}

{% macro create_udf_hex_to_tezos() %}

import hashlib

def transform_hex_to_tezos(input, prefix):
    if input is None or not input.startswith('0x'):
        return 'Invalid input'

    input = input[2:]

    if len(input) != 40:
        return 'Invalid length'

    hash_bytes = bytes.fromhex(input)

    prefixes = {
        'tz1': '06a19f',  # Ed25519
        'tz2': '06a1a1',  # Secp256k1
        'tz3': '06a1a4'   # P-256
    }

    if prefix not in prefixes:
        return 'Invalid prefix: Must be tz1, tz2, or tz3'

    prefix_bytes = bytes.fromhex(prefixes[prefix])

    prefixed_hash = prefix_bytes + hash_bytes

    checksum = hashlib.sha256(hashlib.sha256(prefixed_hash).digest()).digest()[:4]

    full_hash = prefixed_hash + checksum

    tezos_address = transform_hex_to_base58(full_hash.hex())

    return tezos_address

def transform_hex_to_base58(input):
    if input is None:
        return None

    ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    byte_array = bytes.fromhex(input)
    num = int.from_bytes(byte_array, 'big')

    encoded = ''
    while num > 0:
        num, remainder = divmod(num, 58)
        encoded = ALPHABET[remainder] + encoded

    for byte in byte_array:
        if byte == 0:
            encoded = '1' + encoded
        else:
            break

    return encoded

{% endmacro %}

{% macro create_udf_detect_overflowed_responses() %}

import pandas as pd
from snowflake.snowpark.files import SnowflakeFile

VARCHAR_MAX = 16_777_216
def main(file_url, index_cols):
    with SnowflakeFile.open(file_url, 'rb') as f:
        df = pd.read_json(f, lines=True, compression='gzip')
    data_length = df["data"].astype(str).apply(len)
    return df[data_length > VARCHAR_MAX][index_cols].values.tolist()

{% endmacro %}

{% macro create_udtf_flatten_overflowed_responses() %}

import simplejson as json

import numpy as np
import pandas as pd
from snowflake.snowpark.files import SnowflakeFile

VARCHAR_MAX = 16_777_216

class Flatten:
    """
    Recursive function to flatten a nested JSON file
    """

    def __init__(self, mode: str, exploded_key: list) -> None:
        self.mode = mode
        self.exploded_key = exploded_key

    def _flatten_response(
        self,
        response_key: str,
        responses: str,
        block_number: int,
        metadata: dict,
        seq_index: int = 0,
        path: str = "",
    ):
        """
        Example:

        input: {"a":1, "b":[77,88], "c": {"d":"X"}}

        output:
        - SEQ: A unique sequence number associated with the input record; the sequence is not guaranteed to be gap-free or ordered in any particular way.
        - KEY: For maps or objects, this column contains the key to the exploded value.
        - PATH: The path to the element within a data structure which needs to be flattened.
        - INDEX: The index of the element, if it is an array; otherwise NULL.
        - VALUE_: The value of the element of the flattened array/object.

        """
        exploded_data = []
        if self.mode == "array":
            check_mode = isinstance(responses, list)
        elif self.mode == "dict":
            check_mode = isinstance(responses, dict)
        elif self.mode == "both":
            check_mode = isinstance(responses, list) or isinstance(responses, dict)

        if check_mode:
            if isinstance(responses, dict):
                looped_keys = responses.keys()
                for key in looped_keys:
                    next_path = f"{path}.{key}" if path else key
                    index = None
                    exploded_data.append(
                        {
                            "block_number": block_number,
                            "metadata": metadata,
                            "seq": seq_index,
                            "key": key,
                            "path": next_path,
                            "index": index,
                            "value_": responses[key],
                        }
                    )
                    exploded_data.extend(
                        self._flatten_response(
                            key,
                            responses[key],
                            block_number,
                            metadata,
                            seq_index,
                            next_path,
                        )
                    )

            elif isinstance(responses, list):
                looped_keys = range(len(responses))
                if response_key in self.exploded_key or len(self.exploded_key) == 0:
                    for item_i, item in enumerate(responses):
                        if response_key == "result":
                            seq_index += 1
                        index = item_i
                        exploded_data.append(
                            {
                                "block_number": block_number,
                                "metadata": metadata,
                                "seq": seq_index,
                                "key": None,
                                "path": f"{path}[{item_i}]",
                                "index": index,
                                "value_": item,
                            }
                        )
                        exploded_data.extend(
                            self._flatten_response(
                                item_i,
                                item,
                                block_number,
                                metadata,
                                seq_index,
                                f"{path}[{item_i}]",
                            )
                        )

        return exploded_data

class FlattenRows:
    """
    Recursive function to flatten a given JSON file from Snowflake stage
    """
    def process(self, file_url: str, index_cols: list, index_vals: list):
        with SnowflakeFile.open(file_url, 'rb') as f:
            df = pd.read_json(f, lines=True, compression='gzip')

        df.set_index(index_cols, inplace=True)
        df = df.loc[index_vals]
        df.reset_index(inplace=True)

        flattener = Flatten(mode="both", exploded_key=[])

        flattened = pd.concat(
            df.apply(
                lambda x: flattener._flatten_response(
                    block_number=x["block_number"], metadata=x["metadata"], responses=x["data"], response_key=None
                ),
                axis="columns",
            )
            .apply(pd.DataFrame.from_records)
            .values.tolist()
        )
        cleansed = flattened.replace({np.nan: None})

        overflow = cleansed["value_"].astype(str).apply(len) > VARCHAR_MAX

        cleansed.loc[overflow, ["value_"]] = None

        return list(cleansed.itertuples(index=False, name=None))
{% endmacro %}