{% macro create_gha_tasks() %}
    {% set query %}
        SELECT
            task_name,
            workflow_name,
            workflow_schedule
        FROM
            {{ ref('github_actions__tasks') }}
    {% endset %}

    {% set results = run_query(query) %}

    {% if execute and results is not none %}
        {% set results_list = results.rows %}
    {% else %}
        {% set results_list = [] %}
    {% endif %}

    {% set prod_db = target.database.lower().replace('_dev', '') %}

    {% for result in results_list %}
        {% set task_name = result[0] %}
        {% set workflow_name = result[1] %}
        {% set workflow_schedule = result[2] %}

        {% set sql %}
        EXECUTE IMMEDIATE 
        'CREATE OR REPLACE TASK github_actions.{{ task_name }} 
        WAREHOUSE = DBT_CLOUD
        SCHEDULE = \'USING CRON {{ workflow_schedule }} UTC\'
        COMMENT = \'Task to trigger {{ workflow_name }}.yml workflow according to {{ workflow_schedule }}\' AS 
        DECLARE
            rs resultset;
            output string;
        BEGIN
            rs := (SELECT github_actions.workflow_dispatches(\'FlipsideCrypto\', \'{{ prod_db }}-models\', \'{{ workflow_name }}.yml\', NULL):status_code::int AS status_code);
            SELECT LISTAGG($1, \';\') INTO :output FROM TABLE(result_scan(LAST_QUERY_ID())) LIMIT 1;
            CALL SYSTEM$SET_RETURN_VALUE(:output);
        END;'
        {% endset %}

        {% do run_query(sql) %}

        {% if var("START_GHA_TASKS") %}
            {% if target.database.lower() == prod_db %}
                {% set sql %}
                    ALTER TASK github_actions.{{ task_name }} RESUME;
                {% endset %}
                {% do run_query(sql) %}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endmacro %}

{% macro gha_tasks_view() %}
    SELECT
        workflow_name,
        concat_ws(
            '_',
            'TRIGGER',
            UPPER(workflow_name)
        ) AS task_name,
        workflow_schedule
    FROM
        {{ source(
            'github_actions',
            'workflows'
        ) }}
{% endmacro %}

{% macro gha_task_history_view() %}
    {% set query %}
        SELECT
            DISTINCT task_name
        FROM
            {{ ref('github_actions__tasks') }}
    {% endset %}
    {% set results = run_query(query) %}
    {% if execute and results is not none %}
        {% set results_list = results.rows %}
    {% else %}
        {% set results_list = [] %}
    {% endif %}

    WITH task_history_data AS (
        SELECT
            *
        FROM
            ({% for result in results_list %}
            SELECT
                NAME AS task_name, 
                completed_time, 
                return_value, 
                state, 
                database_name, 
                schema_name, 
                scheduled_time, 
                query_start_time
            FROM
                TABLE(information_schema.task_history(scheduled_time_range_start => DATEADD('hour', -24, CURRENT_TIMESTAMP()), task_name => '{{ result[0]}}')) {% if not loop.last %}
                UNION ALL
                {% endif %}
            {% endfor %}) AS subquery
        WHERE
            database_name = '{{ target.database }}' 
            AND schema_name = 'GITHUB_ACTIONS')
        SELECT
            *
        FROM
            task_history_data
{% endmacro %}

{% macro gha_task_schedule_view() %}
    WITH base AS (
        SELECT
            w.workflow_name AS workflow_name,
            w.workflow_schedule AS workflow_schedule,
            w.task_name AS task_name,
            t.timestamp AS scheduled_time
        FROM
            {{ ref('github_actions__tasks') }} AS w
            CROSS JOIN TABLE(
                utils.udf_cron_to_prior_timestamps(
                    w.workflow_name,
                    w.workflow_schedule
                )
            ) AS t
    )
    SELECT
        task_name,
        workflow_name,
        workflow_schedule,
        scheduled_time
    FROM
        base
{% endmacro %}

{% macro gha_task_performance_view() %}
    SELECT
        s.task_name,
        s.workflow_name,
        s.scheduled_time,
        h.return_value
    FROM
        {{ ref('github_actions__task_schedule') }}
        s
        LEFT JOIN {{ ref('github_actions__task_history') }}
        h
        ON s.task_name = h.task_name
        AND TO_TIMESTAMP_NTZ(DATE_TRUNC('minute', s.scheduled_time)) = TO_TIMESTAMP_NTZ(DATE_TRUNC('minute', h.scheduled_time))
        AND h.return_value between 200 and 299
        AND h.state = 'SUCCEEDED'
    ORDER BY
        task_name,
        scheduled_time
{% endmacro %}

{% macro gha_task_current_status_view() %}
    SELECT 
        task_name,
        workflow_name,
        scheduled_time,
        return_value,
        return_value is not null as was_successful
    FROM {{ ref('github_actions__task_performance') }}
    QUALIFY row_number() over (partition by task_name order by scheduled_time desc) = 1
{% endmacro %}

{% macro alter_gha_task(task_name, task_action) %}
    ALTER TASK IF EXISTS github_actions.{{ task_name }} {{ task_action }};
{% endmacro %}