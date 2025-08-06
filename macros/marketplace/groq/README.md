# Groq API Integration

This directory contains Snowflake UDFs for integrating with the Groq API, providing fast inference with various open-source language models.

## Available Models

- **llama3-8b-8192**: Meta Llama 3 8B model with 8K context (Very Fast)
- **llama3-70b-8192**: Meta Llama 3 70B model with 8K context (Fast, better quality)
- **gemma-7b-it**: Google Gemma 7B instruction-tuned (Instruction following)

**Note**: Check [Groq's documentation](https://console.groq.com/docs/models) for the latest available models, or query the live model list with:

```sql
-- Get current list of available models
SELECT groq_utils.list_models();

-- Get details about a specific model  
SELECT groq_utils.get_model_info('llama3-8b-8192');
```

## Setup

1. Get your Groq API key from [https://console.groq.com/keys](https://console.groq.com/keys)

2. Store the API key in Snowflake secrets:
   - **System users**: Store under `_FSC_SYS/GROQ`
   - **Regular users**: Store under `vault/groq/api`

3. Deploy the Groq marketplace functions:
   ```bash
   dbt run --models groq__ groq_utils__groq_utils
   ```

**Note**: Groq functions automatically use the appropriate secret path based on your user type.

## Functions

### `groq.chat_completions(messages, [model], [max_tokens], [temperature], [top_p], [frequency_penalty], [presence_penalty])`

Send messages to Groq for chat completion.

### `groq.quick_chat(user_message, [system_message])`

Quick single or system+user message chat.

**Note**: All functions use the `GROQ_API_KEY` environment variable for authentication.

### `groq.extract_response_text(groq_response)`

Extract text content from Groq API responses.

### `groq_utils.post_api(path, body)`

Low-level HTTP POST to Groq API endpoints.

### `groq_utils.get_api(path)`

Low-level HTTP GET to Groq API endpoints.

### `groq_utils.list_models()`

List all available models from Groq API.

### `groq_utils.get_model_info(model_id)`

Get information about a specific model.

## Examples

### Basic Chat
```sql
-- Simple chat with default model (llama3-8b-8192)
SELECT groq.chat_completions(
  [{'role': 'user', 'content': 'Explain quantum computing in simple terms'}]
);

-- Quick chat shorthand
SELECT groq.quick_chat('What is the capital of France?');
```

### Chat with System Prompt
```sql
-- Chat with system prompt using quick_chat
SELECT groq.quick_chat(
  'You are a helpful Python programming assistant.',
  'How do I create a list comprehension?'
);

-- Full chat_completions with system message
SELECT groq.chat_completions(
  [
    {'role': 'system', 'content': 'You are a data scientist expert.'},
    {'role': 'user', 'content': 'Explain the difference between supervised and unsupervised learning'}
  ]
);
```

### Different Models
```sql
-- Use the larger, more capable model
SELECT groq.chat_completions(
  [{'role': 'user', 'content': 'Write a Python function to calculate fibonacci numbers'}],
  'llama3-70b-8192',
  500  -- max_tokens
);

-- Use the larger model for better quality
SELECT groq.chat_completions(
  [{'role': 'user', 'content': 'Analyze this complex problem...'}],
  'llama3-70b-8192'
);
```

### Custom Parameters
```sql
-- Fine-tune response generation
SELECT groq.chat_completions(
  [{'role': 'user', 'content': 'Generate creative story ideas'}],
  'llama3-8b-8192',  -- model
  300,                -- max_tokens
  0.8,                -- temperature (more creative)
  0.9,                -- top_p
  0.1,                -- frequency_penalty (reduce repetition)
  0.1                 -- presence_penalty (encourage new topics)
);
```


### Extract Response Text
```sql
-- Get just the text content from API response
WITH chat_response AS (
  SELECT groq.quick_chat('Hello, how are you?') as response
)
SELECT groq.extract_response_text(response) as message_text
FROM chat_response;
```

### Conversational Chat
```sql
-- Multi-turn conversation
SELECT groq.chat_completions([
  {'role': 'system', 'content': 'You are a helpful coding assistant.'},
  {'role': 'user', 'content': 'I need help with SQL queries'},
  {'role': 'assistant', 'content': 'I\'d be happy to help with SQL! What specific query are you working on?'},
  {'role': 'user', 'content': 'How do I join two tables with a LEFT JOIN?'}
]);
```

### Model Comparison
```sql
-- Compare responses from different models
WITH responses AS (
  SELECT 
    'llama3-8b-8192' as model,
    groq.extract_response_text(
      groq.chat_completions([{'role': 'user', 'content': 'Explain machine learning'}], 'llama3-8b-8192', 100)
    ) as response
  UNION ALL
  SELECT 
    'llama3-70b-8192' as model,
    groq.extract_response_text(
      groq.chat_completions([{'role': 'user', 'content': 'Explain machine learning'}], 'llama3-70b-8192', 100)
    ) as response
)
SELECT * FROM responses;
```

### Batch Processing
```sql
-- Process multiple questions
WITH questions AS (
  SELECT * FROM VALUES
    ('What is Python?'),
    ('What is JavaScript?'),
    ('What is SQL?')
  AS t(question)
)
SELECT 
  question,
  groq.extract_response_text(
    groq.quick_chat(question, 'You are a programming tutor.')
  ) as answer
FROM questions;
```

### Get Available Models
```sql
-- List all available models with details
SELECT 
  model.value:id::STRING as model_id,
  model.value:object::STRING as object_type,
  model.value:created::INTEGER as created_timestamp,
  model.value:owned_by::STRING as owned_by
FROM (
  SELECT groq_utils.list_models() as response
),
LATERAL FLATTEN(input => response:data) as model
ORDER BY model_id;

-- Check if a specific model is available
WITH models AS (
  SELECT groq_utils.list_models() as response
)
SELECT 
  CASE 
    WHEN ARRAY_CONTAINS('llama3-70b-8192'::VARIANT, response:data[*]:id) 
    THEN 'Model is available'
    ELSE 'Model not found'
  END as availability
FROM models;
```

### GitHub Actions Integration Example
```sql
-- Example of how this is used in GitHub Actions failure analysis
SELECT 
  run_id,
  groq.extract_response_text(
    groq.quick_chat(
      CONCAT('Analyze this failure: Job=', job_name, ' Error=', error_logs),
      'You are analyzing CI/CD failures. Provide concise root cause analysis.'
    )
  ) as ai_analysis
FROM my_failed_jobs
WHERE run_id = '12345678';
```

## Error Handling

The functions include built-in error handling. Check for errors in responses:

```sql
WITH response AS (
  SELECT groq.quick_chat('Hello') as result
)
SELECT 
  CASE 
    WHEN result:error IS NOT NULL THEN result:error:message::STRING
    ELSE groq.extract_response_text(result)
  END as final_response
FROM response;
```

## Performance Tips

1. **Model Selection**: Use `llama3-8b-8192` for fast, simple tasks and `llama3-70b-8192` for complex reasoning
2. **Token Limits**: Set appropriate `max_tokens` to control costs and response length  
3. **Temperature**: Use lower values (0.1-0.3) for factual tasks, higher (0.7-1.0) for creative tasks
4. **Stay Updated**: Check Groq's model documentation regularly as they add new models and deprecate others

## Integration with GitHub Actions

This Groq integration is used by the GitHub Actions failure analysis system in `slack_notify` macro:

```sql
-- In your GitHub Actions workflow
dbt run-operation slack_notify --vars '{
  "owner": "your-org",
  "repo": "your-repo",
  "run_id": "12345678",
  "ai_provider": "groq",
  "enable_ai_analysis": true
}'
```