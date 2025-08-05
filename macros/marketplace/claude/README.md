# Claude API Integration

Anthropic's Claude AI integration for sophisticated text analysis, content generation, and reasoning tasks. This integration provides access to Claude's advanced language models through Snowflake UDFs.

## Available Models

- **Claude 3.5 Sonnet**: Latest and most capable model for complex tasks
- **Claude 3 Opus**: Powerful model for demanding use cases  
- **Claude 3 Sonnet**: Balanced performance and speed
- **Claude 3 Haiku**: Fast and efficient for simple tasks

Check [Anthropic's documentation](https://docs.anthropic.com/claude/docs/models-overview) for the latest available models.

## Setup

1. Get your Claude API key from [Anthropic Console](https://console.anthropic.com/)

2. Store the API key in Snowflake secrets under `_FSC_SYS/CLAUDE`

3. Deploy the Claude marketplace functions:
   ```bash
   dbt run --models claude__ claude_utils__claude_utils
   ```

## Functions

### `claude_utils.post(path, body)`
Make POST requests to Claude API endpoints.

### `claude_utils.get(path)`  
Make GET requests to Claude API endpoints.

### `claude_utils.delete_method(path)`
Make DELETE requests to Claude API endpoints.

### `claude.chat_completions(messages[, model, max_tokens, temperature])`
Send messages to Claude for chat completion.

### `claude.extract_response_text(claude_response)`
Extract text content from Claude API responses.

## Examples

### Basic Chat
```sql
-- Simple conversation with Claude
SELECT claude.chat_completions([
  {'role': 'user', 'content': 'Explain quantum computing in simple terms'}
]);
```

### Chat with System Prompt
```sql
-- Chat with system message and conversation history
SELECT claude.chat_completions([
  {'role': 'system', 'content': 'You are a helpful data analyst.'},
  {'role': 'user', 'content': 'How do I optimize this SQL query?'},
  {'role': 'assistant', 'content': 'I can help you optimize your SQL query...'},
  {'role': 'user', 'content': 'SELECT * FROM large_table WHERE date > "2023-01-01"'}
]);
```

### Text Analysis
```sql
-- Analyze text sentiment and themes
SELECT claude.chat_completions([
  {'role': 'user', 'content': 'Analyze the sentiment and key themes in this customer feedback: "The product is okay but customer service was terrible. Took forever to get help."'}
]);
```

### Code Generation
```sql
-- Generate Python code
SELECT claude.chat_completions([
  {'role': 'user', 'content': 'Write a Python function to calculate the moving average of a list of numbers'}
]);
```

### Extract Response Text
```sql
-- Get just the text content from Claude's response
WITH claude_response AS (
  SELECT claude.chat_completions([
    {'role': 'user', 'content': 'What is machine learning?'}
  ]) as response
)
SELECT claude.extract_response_text(response) as answer
FROM claude_response;
```

### Batch Text Processing
```sql
-- Process multiple texts
WITH texts AS (
  SELECT * FROM VALUES
    ('Great product, highly recommend!'),
    ('Terrible experience, would not buy again'),
    ('Average quality, nothing special')
  AS t(feedback)
)
SELECT 
  feedback,
  claude.extract_response_text(
    claude.chat_completions([
      {'role': 'user', 'content': CONCAT('Analyze sentiment (positive/negative/neutral): ', feedback)}
    ])
  ) as sentiment
FROM texts;
```

### Different Models
```sql
-- Use specific Claude model
SELECT claude.chat_completions(
  [{'role': 'user', 'content': 'Write a complex analysis of market trends'}],
  'claude-3-opus-20240229',  -- Use Opus for complex reasoning
  2000,  -- max_tokens
  0.3    -- temperature
);
```

## Integration with GitHub Actions

This Claude integration is used by the GitHub Actions failure analysis system:

```sql
-- Analyze GitHub Actions failures with Claude
SELECT claude.extract_response_text(
  claude.chat_completions([
    {'role': 'user', 'content': CONCAT(
      'Analyze this CI/CD failure and provide root cause analysis: ',
      error_logs
    )}
  ])
) as ai_analysis
FROM github_failures;
```

## Error Handling

Check for errors in Claude responses:

```sql
WITH response AS (
  SELECT claude.chat_completions([
    {'role': 'user', 'content': 'Hello Claude'}
  ]) as result
)
SELECT
  CASE 
    WHEN result:error IS NOT NULL THEN result:error:message::STRING
    ELSE claude.extract_response_text(result)
  END as final_response
FROM response;
```

## Best Practices

1. **Use appropriate models**: Haiku for simple tasks, Opus for complex reasoning
2. **Set token limits**: Control costs with reasonable `max_tokens` values
3. **Temperature control**: Lower values (0.1-0.3) for factual tasks, higher (0.7-1.0) for creative tasks
4. **Context management**: Include relevant conversation history for better responses
5. **Error handling**: Always check for API errors in responses

## Rate Limiting

Claude API has usage limits based on your plan. The functions automatically handle rate limiting through Livequery's retry mechanisms.

## Security

- API keys are securely stored in Snowflake secrets
- All communication uses HTTPS encryption
- No sensitive data is logged or cached

## API Documentation

- [Claude API Reference](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [Model Comparison](https://docs.anthropic.com/claude/docs/models-overview)
- [Usage Guidelines](https://docs.anthropic.com/claude/docs/use-case-guides)