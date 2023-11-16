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

{% macro create_udf_base58() %}

def transform_base58(input):
    if input is None:
        return None

    if input.startswith('0x'):
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

{% macro create_udf_bech32() %}

def transform_bech32(input, hrp=''):
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