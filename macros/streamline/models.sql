{% macro decode_logs_history(
        start,
        stop
    ) %}
    WITH look_back AS (
        SELECT
            block_number
        FROM
            {{ ref("_max_block_by_date") }}
            qualify ROW_NUMBER() over (
                ORDER BY
                    block_number DESC
            ) = 1
    )
SELECT
    l.block_number,
    l._log_id,
    A.abi AS abi,
    OBJECT_CONSTRUCT(
        'topics',
        l.topics,
        'data',
        l.data,
        'address',
        l.contract_address
    ) AS DATA
FROM
    {{ ref("silver__logs") }}
    l
    INNER JOIN {{ ref("silver__complete_event_abis") }} A
    ON A.parent_contract_address = l.contract_address
    AND A.event_signature = l.topics[0]:: STRING
    AND l.block_number BETWEEN A.start_block
    AND A.end_block
WHERE
    (
        l.block_number BETWEEN {{ start }}
        AND {{ stop }}
    )
    AND l.block_number <= (
        SELECT
            block_number
        FROM
            look_back
    )
    AND _log_id NOT IN (
        SELECT
            _log_id
        FROM
            {{ ref("streamline__complete_decode_logs") }}
        WHERE
            (
                block_number BETWEEN {{ start }}
                AND {{ stop }}
            )
            AND block_number <= (
                SELECT
                    block_number
                FROM
                    look_back
            )
    )
{% endmacro %}

{% macro block_reorg(target, hours) %}
DELETE 
FROM
    {{ target }}
    t
WHERE
    t._inserted_timestamp > DATEADD(
        'hour',
        -{{ hours}},
        SYSDATE()
    )
    AND NOT EXISTS (
        SELECT
            1
        FROM
            {{ ref('silver__transactions') }}
            s
        WHERE
            s._inserted_timestamp > DATEADD(
                'hour',
                -{{ hours}},
                SYSDATE()
            )
            AND s.block_number = t.block_number
            AND s.tx_hash = t.tx_hash
    );
{% endmacro %}
