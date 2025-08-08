# GitHub Actions Slack Notifications

This directory contains a fast dbt macro system for sending intelligent Slack notifications from GitHub Actions workflows with AI-powered failure analysis.

## Features

- **⚡ Fast Execution**: Pure SQL dbt macro (no Python overhead)
- **🤖 AI-Powered Analysis**: Automatic failure analysis using Cortex or Claude AI
- **💬 Rich Slack Messages**: Beautiful Block Kit formatted notifications with color-coded sidebars
- **🧵 Auto-Threading**: Detailed job logs posted as threaded replies
- **🎨 Custom Bot Appearance**: Custom names, emojis, and avatars
- **🔗 Dual Delivery Methods**: Support for both webhooks and bot tokens
- **📊 Comprehensive Details**: Job failures, logs, and actionable links

## Quick Setup

The `failed_gha_slack_alert` macro is ready to use immediately - no deployment required!

### Setup Options

#### Option 1: Bot Token Method (Recommended)

1. Create a Slack bot with `chat:write` permissions
2. Get the channel ID from Slack (e.g., `C1234567890` - not channel name)
3. Store bot token in Livequery vault at `_FSC_SYS/SLACK/intelligence`
4. Add this step to your GitHub Actions workflow:

```yaml
- name: Notify Slack on Failure
  if: failure()
  run: |
    dbt run-operation failed_gha_slack_alert --vars '{
      "owner": "${{ github.repository_owner }}",
      "repo": "${{ github.event.repository.name }}",
      "run_id": "${{ github.run_id }}",
      "slack_channel": "C1234567890"
    }' --target dev
```

#### Option 2: Webhook Method (Simple Setup)

1. Create a Slack webhook URL in your workspace
2. Store webhook URL in Livequery vault at `_FSC_SYS/SLACK/alerts`
3. Add this step to your GitHub Actions workflow:

```yaml
- name: Notify Slack on Failure
  if: failure()
  run: |
    dbt run-operation failed_gha_slack_alert --vars '{
      "owner": "${{ github.repository_owner }}",
      "repo": "${{ github.event.repository.name }}",
      "run_id": "${{ github.run_id }}",
      "webhook_secret_name": "alerts"
    }' --target dev
```

## Configuration Options

### Core Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `owner` | string | ✅ | GitHub repository owner |
| `repo` | string | ✅ | GitHub repository name |
| `run_id` | string | ✅ | GitHub Actions run ID |
| `slack_channel` | string | ✅* | Slack channel ID (e.g., 'C1234567890') - required for bot token method |
| `webhook_secret_name` | string | ✅* | Webhook vault secret name - required for webhook method |

### AI & Analysis

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enable_ai_analysis` | boolean | `true` | Enable AI failure analysis |
| `ai_provider` | string | `'cortex'` | AI provider: `'cortex'` (Snowflake built-in AI) |
| `model_name` | string | `'mistral-large'` | **Required for Cortex**: `'mistral-large'`, `'mistral-7b'`, `'llama2-70b-chat'`, `'mixtral-8x7b'` |
| `ai_prompt` | string | `''` | Custom AI analysis prompt (leave empty for default) |

### Threading & Appearance

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enable_auto_threading` | boolean | `false` | Auto-post detailed job logs as thread replies |
| `username` | string | `'GitHub Actions Bot'` | Custom bot display name |
| `icon_emoji` | string | `':github:'` | Bot emoji (e.g., `:robot_face:`, `:stellar:`) |
| `icon_url` | string | `none` | Bot avatar URL (overrides icon_emoji) |
| `bot_secret_name` | string | `'intelligence'` | Name of bot token secret in vault |

## Usage Examples

### Basic Notification

```bash
dbt run-operation failed_gha_slack_alert --vars '{
  "owner": "FlipsideCrypto",
  "repo": "streamline-snowflake",
  "run_id": "16729602656",
  "slack_channel": "C087GJQ1ZHQ"
}' --target dev
```

### AI Analysis with Custom Bot

```bash
dbt run-operation failed_gha_slack_alert --vars '{
  "owner": "FlipsideCrypto",
  "repo": "streamline-snowflake",
  "run_id": "16729602656",
  "slack_channel": "C087GJQ1ZHQ",
  "enable_ai_analysis": true,
  "ai_provider": "cortex",
  "model_name": "mistral-7b",
  "username": "CI/CD Alert Bot",
  "icon_emoji": ":robot_face:"
}' --target dev
```

### Auto-Threading with Custom Prompt

```bash
dbt run-operation failed_gha_slack_alert --vars '{
  "owner": "FlipsideCrypto",
  "repo": "streamline-snowflake",
  "run_id": "16729602656",
  "slack_channel": "C087GJQ1ZHQ",
  "enable_ai_analysis": true,
  "ai_provider": "cortex",
  "model_name": "mixtral-8x7b",
  "ai_prompt": "Focus on dependency issues and provide quick fixes:",
  "enable_auto_threading": true,
  "username": "Pipeline Monitor",
  "icon_emoji": ":stellar:"
}' --target dev
```

### Webhook Method

```bash
dbt run-operation failed_gha_slack_alert --vars '{
  "owner": "FlipsideCrypto",
  "repo": "streamline-snowflake",
  "run_id": "16729602656",
  "webhook_secret_name": "prod-alerts",
  "enable_ai_analysis": true,
  "ai_provider": "cortex",
  "model_name": "mistral-large",
  "username": "Production Monitor",
  "icon_emoji": ":package:"
}' --target dev
```

### GitHub Actions Integration

```yaml
- name: Notify Slack on Failure
  if: failure()
  run: |
    dbt run-operation failed_gha_slack_alert --vars '{
      "owner": "${{ github.repository_owner }}",
      "repo": "${{ github.event.repository.name }}",
      "run_id": "${{ github.run_id }}",
      "slack_channel": "C087GJQ1ZHQ",
      "enable_ai_analysis": true,
      "ai_provider": "cortex",
      "model_name": "mistral-large",
      "enable_auto_threading": true,
      "username": "GitHub Actions",
      "icon_emoji": ":github:"
    }' --target dev
```

## Message Format

### Failure Messages Include

- **🔴 Red Sidebar**: Visual failure indicator
- **Header**: Repository name with failure indicator (❌)
- **Basic Info**: Run ID, failed job count, workflow name
- **🤖 AI Analysis**: Intelligent failure analysis with common patterns, root causes, and action items
- **🔗 Action Button**: Direct link to workflow run
- **🧵 Threading** (if enabled): Individual job details and logs as thread replies

### Success Messages Include

- **🟢 Green Sidebar**: Visual success indicator
- **Header**: Repository name with success indicator (✅)
- **Basic Info**: Run ID, workflow name, success status
- **🔗 Action Button**: Direct link to workflow run

## AI Analysis

The macro supports Snowflake's Cortex AI for intelligent failure analysis:

### Cortex (Default)

- Uses Snowflake's built-in Cortex AI
- **Requires `model_name` parameter** to specify which model to use
- Available models: `'mistral-large'`, `'mistral-7b'`, `'llama2-70b-chat'`, `'mixtral-8x7b'`
- Automatically analyzes logs and provides insights
- Custom prompts supported via `ai_prompt` parameter

Enable AI analysis with:

```yaml
"enable_ai_analysis": true,
"ai_provider": "cortex",
"model_name": "mistral-large",  # Required!
"ai_prompt": "Focus on the most critical issues:"  # Optional
```

## Environment Variables & Vault Setup

### Webhook Method

- `SLACK_WEBHOOK_URL`: Your Slack webhook URL (GitHub secret)

### Bot Token Method

- **No environment variables required!**
- Bot tokens are stored in Livequery vault at: `_FSC_SYS/SLACK/{bot_secret_name}`
- Channel ID provided as parameter in macro call

### Vault Paths for Bot Tokens

Store your bot tokens in these vault locations:

- `prod/livequery/slack/intelligence` (default)
- `prod/livequery/alerts` (custom)
- `prod/livequery/<your bot's name>` (custom)

** The `_FSC/SYS/..` will not work anymore, because we are not able to access studio to store `CREDENTIALS` anymore. So the context + `_FSC/SYS/...` is deprecated. It's in the sql code for backward compatability.

### How to Get Slack Channel IDs

1. **Right-click method**: Right-click channel → Copy → Copy link (ID is in URL)
2. **API method**: Use `conversations.list` endpoint
3. **App method**: Channel IDs appear in URLs like `/C1234567890/`

### Security Notes

- Never hardcode secrets in your workflow files
- Use GitHub's encrypted secrets for webhook URLs
- Bot tokens automatically managed through Livequery vault system
- Channel IDs are not sensitive and can be stored in code

## Troubleshooting

### Common Issues

1. **No notification sent**: Check webhook URL or channel ID parameter
2. **Invalid channel ID**: Must use channel ID (C1234567890), not name (#channel)
3. **AI analysis missing**: Ensure GitHub Actions integration is properly set up
4. **Message formatting issues**: Verify JSON syntax in custom_message parameter
5. **Bot permissions**: Ensure bot has `chat:write` scope for target channel
6. **Vault access**: Verify bot token stored at correct vault path

### Debug Mode

Add this step before the notification to debug issues:

```yaml
- name: Debug Notification
  run: |
    echo "Owner: ${{ github.repository_owner }}"
    echo "Repo: ${{ github.event.repository.name }}"
    echo "Run ID: ${{ github.run_id }}"
    echo "Channel: C1234567890"  # Your actual channel ID
```

### Channel ID Validation

Test if your channel ID is valid:

```sql
SELECT slack_utils.validate_channel('C1234567890') as is_valid;
-- Should return true for valid channel IDs
```

## Integration with Livequery

This macro integrates with Livequery's marketplace UDFs:

- **`slack_utils.post_webhook()`**: For webhook-based notifications
- **`slack.post_message()`** & **`slack.post_reply()`**: For bot token messaging with threading
- **`github_actions.tf_failure_analysis_with_ai()`**: For AI-powered failure analysis

### UDF Function Signatures

```sql
-- Webhook (backward compatible)
slack_utils.post_webhook(webhook_secret_name, payload)

-- Bot messaging (new parameter-based)
slack.post_message(channel_id, payload, bot_secret_name)
slack.post_reply(channel_id, thread_ts, payload, bot_secret_name)

-- Or use 2-parameter versions (uses 'intelligence' bot token)
slack.post_message(channel_id, payload)
slack.post_reply(channel_id, thread_ts, payload)
```

Ensure these UDFs are deployed before using the notification macro.

## Performance & Benefits

### ⚡ **Lightning Fast Execution**

- **Pure SQL**: No Python interpreter overhead
- **Direct UDF calls**: Leverages Livequery's optimized marketplace functions
- **Single transaction**: All operations in one dbt run-operation call
- **Instant feedback**: Real-time execution with immediate Slack delivery

### 🎯 **Production Ready**

- **Reliable**: Battle-tested with GitHub Actions workflows
- **Scalable**: Handles multiple failed jobs with threading
- **Secure**: Vault-based credential management
- **Flexible**: Supports both webhook and bot token methods

### 🤖 **Intelligent Analysis**

- **AI-Powered**: Cortex and Claude integration for failure analysis
- **Actionable Insights**: Common patterns, root causes, and prioritized action items
- **Context-Aware**: Includes job names, workflow details, and error logs
- **Formatted for Slack**: Optimized mrkdwn formatting for better readability

The `failed_gha_slack_alert` macro provides enterprise-grade Slack notifications with zero deployment overhead and lightning-fast performance.

## Examples Repository

See [our examples repository](https://github.com/FlipsideCrypto/livequery-examples) for complete workflow configurations and advanced usage patterns.
