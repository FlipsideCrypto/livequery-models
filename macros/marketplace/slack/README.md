# Slack Integration for Livequery

A straightforward Slack integration that lets you send exactly what you want to Slack. You construct the payload according to Slack's API spec, and Livequery delivers it.

## Prerequisites & Setup

### Option 1: Webhook Mode (Simpler, No Threading)

**When to use:** Simple notifications without threading support.

**Setup Steps:**
1. Go to [Slack Apps](https://api.slack.com/apps) and create a new app
2. Choose "From scratch" and select your workspace
3. Go to "Incoming Webhooks" and toggle "Activate Incoming Webhooks" to On
4. Click "Add New Webhook to Workspace"
5. Select the channel and click "Allow"
6. Copy the webhook URL (starts with `https://hooks.slack.com/services/...`)
7. Use `slack.webhook_send(url, payload)`

**Limitations:**
- ❌ No threading support (cannot use `slack.post_reply()`)
- ❌ Cannot send to different channels dynamically
- ✅ Simple setup, no bot permissions needed

### Option 2: Web API Mode (Full Features + Threading)

**When to use:** Need threading support, multiple channels, or advanced features.

**Setup Steps:**
1. Go to [Slack Apps](https://api.slack.com/apps) and create a new app
2. Choose "From scratch" and select your workspace
3. Go to "OAuth & Permissions" in the sidebar
4. Under "Scopes" → "Bot Token Scopes", add these permissions:
   - `chat:write` - Send messages
   - `channels:read` - Access public channel information
   - `groups:read` - Access private channel information (if needed)
5. Click "Install to Workspace" at the top
6. Click "Allow" to grant permissions
7. Copy the "Bot User OAuth Token" (starts with `xoxb-...`)
8. **Important:** Invite the bot to your channel:
   - Go to your Slack channel
   - Type `/invite @YourBotName` (replace with your bot's name)
   - Or go to channel settings → Integrations → Add apps → Select your bot
9. Get the channel ID:
   - Right-click your channel name → "Copy Link"
   - Extract the ID from URL: `https://yourworkspace.slack.com/archives/C087GJQ1ZHQ` → `C087GJQ1ZHQ`
10. Use `slack.post_message(token, channel, payload)` and `slack.post_reply()` for threading

**Features:**
- ✅ Threading support with `slack.post_reply()`
- ✅ Send to any channel the bot is invited to
- ✅ More control and flexibility
- ❌ Requires bot setup and channel invitations

## Quick Start

### 1. Add to dbt_project.yml (Recommended)

The easiest way to get Slack notifications for your entire dbt project:

```yaml
# dbt_project.yml
on-run-end:
  - "{{ slack_notify_on_run_end(results) }}"
```

Then configure individual models with Slack settings (see Per-Model Configuration below).

**How it works:**
- ✅ **Per-model notifications** - Each model controls its own Slack settings
- ✅ **Custom message formats** - Models can define completely custom Slack payloads
- ✅ **Flexible triggers** - Different models can notify on success, error, or both
- ✅ **Variable substitution** - Use `{model_name}`, `{status}`, `{execution_time}` in custom messages
- ✅ **Environment overrides** - Models can override global Slack webhook/channel settings
- ✅ **Default fallback** - Models without config are ignored (no spam)

### 2. Per-Model Configuration

Configure Slack notifications individually for each model by adding `slack_config` to the model's `meta` section:

#### Basic Model Configuration

```sql
-- models/critical/dim_customers.sql
{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'notification_mode': 'error_only',  # success_only, error_only, both
            'mention': '@here'  # Optional: notify team members
        }
    }
) }}

SELECT * FROM {{ ref('raw_customers') }}
```

#### Custom Message Format

```sql  
-- models/critical/fact_revenue.sql
{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'notification_mode': 'both',
            'channel': 'C1234567890',  # Override default channel
            'custom_message': {
                'text': '💰 Revenue model {model_name} {status_emoji}',
                'username': 'Revenue Bot',
                'icon_emoji': ':money_with_wings:',
                'attachments': [
                    {
                        'color': 'good' if '{status}' == 'success' else 'danger',
                        'title': 'Critical Revenue Model Alert',
                        'fields': [
                            {'title': 'Model', 'value': '{model_name}', 'short': true},
                            {'title': 'Status', 'value': '{status_emoji} {status}', 'short': true},
                            {'title': 'Environment', 'value': '{environment}', 'short': true},
                            {'title': 'Duration', 'value': '{execution_time}s', 'short': true}
                        ],
                        'footer': 'Revenue Team • {repository}'
                    }
                ]
            }
        }
    }
) }}

SELECT * FROM {{ ref('raw_transactions') }}
```

#### Different Slack Channels per Model

```sql
-- models/marketing/marketing_metrics.sql
{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'channel': '#marketing-alerts',  # Marketing team channel
            'webhook_url': 'https://hooks.slack.com/services/MARKETING/WEBHOOK/URL',
            'notification_mode': 'error_only',
            'mention': '<@U1234567890>'  # Mention specific user by ID
        }
    }
) }}
```

#### Mention Options

You can notify specific people or groups using the `mention` parameter:

```sql
-- Different mention formats
{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'mention': '@here'  # Notify all active members
        }
    }
) }}

{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'mention': '@channel'  # Notify all channel members
        }
    }
) }}

{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'mention': '<@U1234567890>'  # Mention specific user by ID
        }
    }
) }}

{{ config(
    meta={
        'slack_config': {
            'enabled': true,
            'mention': '@username'  # Mention by username (if supported)
        }
    }
) }}
```

#### Available Variables for Custom Messages

Use these variables in your `custom_message` templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `{model_name}` | Model name | `dim_customers` |
| `{status}` | Model status | `success`, `error` |
| `{status_emoji}` | Status emoji | `✅`, `❌` |
| `{environment}` | dbt target | `prod`, `dev` |
| `{repository}` | GitHub repository | `FlipsideCrypto/analytics` |
| `{execution_time}` | Execution seconds | `12.5` |

### 3. Example Notifications

With per-model configuration, each model sends its own notification using Slack's modern Block Kit layout with colored sidebars. Here are some examples:

**Default Model Notification (Success with Mention):**
```
🟢 ┌─────────────────────────────────────┐
   │ Hi @here, ✅ Model: dim_customers   │
   ├─────────────────────────────────────┤
   │ Success execution completed         │
   │                                     │
   │ Environment:        Execution Time: │
   │ prod               12.5s            │
   │                                     │
   │ Repository:                         │
   │ FlipsideCrypto/analytics            │
   │                                     │
   │ dbt via Livequery                   │
   └─────────────────────────────────────┘
```

**Custom Revenue Model Notification (Error):**
```
🔴 ┌─────────────────────────────────────┐
   │ 💰 Revenue model fact_revenue ❌    │
   ├─────────────────────────────────────┤
   │ Critical Revenue Model Alert        │
   │ Model: fact_revenue                 │
   │ Status: ❌ Error                    │
   │ Environment: prod                   │
   │ Duration: 45.2s                     │
   │                                     │
   │ Error Message:                      │
   │ Division by zero in line 23...      │
   │                                     │
   │ Revenue Team • FlipsideCrypto/analytics │
   └─────────────────────────────────────┘
```

**Marketing Model Notification (Success with User Mention):**
```
🟢 ┌─────────────────────────────────────┐
   │ Hi <@U1234567890>, ✅ Model: marketing_metrics │
   ├─────────────────────────────────────┤
   │ Success execution completed         │
   │                                     │
   │ Environment:        Execution Time: │
   │ prod               8.1s             │
   │                                     │
   │ Repository:                         │
   │ FlipsideCrypto/analytics            │
   │                                     │
   │ dbt via Livequery                   │
   └─────────────────────────────────────┘
```

*Note: The colored circles (🟢🔴) represent Slack's colored sidebar. The actual messages will display as rich Block Kit layouts with colored left borders in Slack.*

## Advanced Usage

### Manual Function Calls

For custom use cases, call functions directly:

#### Basic Webhook Message
```sql
SELECT slack.webhook_send(
    'https://hooks.slack.com/services/YOUR/WEBHOOK/URL',
    {
        'text': 'Hello from Livequery!',
        'username': 'Data Bot'
    }
);
```

#### Rich Web API Message with Blocks
```sql
SELECT slack.post_message(
    'xoxb-your-bot-token',
    'C087GJQ1ZHQ',
    {
        'text': 'Pipeline completed!',
        'blocks': [
            {
                'type': 'header',
                'text': {
                    'type': 'plain_text',
                    'text': ':white_check_mark: Pipeline Success'
                }
            },
            {
                'type': 'section',
                'fields': [
                    {'type': 'mrkdwn', 'text': '*Repository:*\nFlipsideCrypto/my-repo'},
                    {'type': 'mrkdwn', 'text': '*Duration:*\n15m 30s'}
                ]
            }
        ]
    }
);
```

#### Threading Example (Web API Only)
```sql
-- First send main message
WITH main_message AS (
    SELECT slack.post_message(
        'xoxb-your-bot-token',
        'C087GJQ1ZHQ',
        {'text': 'Pipeline failed with 3 errors. Details in thread...'}
    ) as response
)
-- Then send threaded replies
SELECT slack.post_reply(
    'xoxb-your-bot-token',
    'C087GJQ1ZHQ',
    main_message.response:data:ts::STRING,  -- Use timestamp from main message
    {'text': 'Error 1: Database connection timeout'}
) as thread_response
FROM main_message;
```

### Conditional Notifications

Add conditions to control when notifications are sent:

```yaml
# dbt_project.yml
on-run-end:
  # Only send notifications in production
  - "{% if target.name == 'prod' %}{{ slack_notify_on_run_end(results) }}{% endif %}"

  # Or use environment variable control
  - "{% if env_var('SEND_SLACK_NOTIFICATIONS', 'false') == 'true' %}{{ slack_notify_on_run_end(results) }}{% endif %}"
```

### Advanced: Custom Message Format

For full control over the message format, use the lower-level functions:

```yaml
on-run-end: |
  {% if execute %}
    {% set status = 'success' if results|selectattr('status', 'equalto', 'error')|list|length == 0 else 'failed' %}

    SELECT slack.webhook_send(
      '{{ env_var("SLACK_WEBHOOK_URL") }}',
      {
        'text': 'dbt run {{ status }}',
        'attachments': [
          {
            'color': '{{ "#36a64f" if status == "success" else "#ff0000" }}',
            'title': 'dbt {{ status|title }}',
            'fields': [
              {'title': 'Models', 'value': '{{ results|length }}', 'short': true},
              {'title': 'Failed', 'value': '{{ results|selectattr("status", "equalto", "error")|list|length }}', 'short': true}
            ]
          }
        ]
      }
    );
  {% endif %}
```

## Configuration Reference

### Global Environment Variables (Optional)

Models can override these global settings. Only set these if you want fallback defaults:

```bash
# Default Slack connection (models can override)
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
# OR  
export SLACK_BOT_TOKEN="xoxb-your-bot-token"
export SLACK_CHANNEL="C087GJQ1ZHQ"

# Optional global settings
export SLACK_BOT_USERNAME="dbt Bot"
export GITHUB_REPOSITORY="your-org/your-repo"
```

### Notification Modes

- **`error_only`** (default) - Only notify on failures
- **`success_only`** - Only notify on successful runs
- **`both`** - Notify on both success and failure

### Mention Options

The `mention` parameter allows you to notify specific users or groups:

- **`@here`** - Notify all active members in the channel
- **`@channel`** - Notify all members in the channel (use sparingly)
- **`<@U1234567890>`** - Mention specific user by Slack user ID (recommended)
- **`<@U1234567890|username>`** - Mention user with display name
- **`@username`** - Mention by username (may not work in all workspaces)

**Note:** To find a user's Slack ID, right-click their profile → "Copy member ID"

## Functions Reference

### `slack.webhook_send(webhook_url, payload)`
Send messages via Slack Incoming Webhooks.

**Parameters:**
- `webhook_url` - Your Slack webhook URL
- `payload` - JSON object following [Slack webhook format](https://api.slack.com/messaging/webhooks)

### `slack.post_message(bot_token, channel, payload)`
Send messages via Slack Web API (chat.postMessage).

**Parameters:**
- `bot_token` - Your Slack bot token (xoxb-...)
- `channel` - Channel ID (C...) or name (#channel)
- `payload` - JSON object following [Slack chat.postMessage format](https://api.slack.com/methods/chat.postMessage)

### `slack.post_reply(bot_token, channel, thread_ts, payload)`
Send threaded replies via Slack Web API.

**Parameters:**
- `bot_token` - Your Slack bot token
- `channel` - Channel ID or name
- `thread_ts` - Parent message timestamp for threading
- `payload` - JSON object following Slack chat.postMessage format

### Validation Functions
- `slack_utils.validate_webhook_url(url)` - Check if webhook URL is valid
- `slack_utils.validate_bot_token(token)` - Check if bot token is valid
- `slack_utils.validate_channel(channel)` - Check if channel format is valid

## Testing Without Spamming Slack

### Built-in Tests
The integration includes comprehensive tests that use mock endpoints instead of real Slack channels:

- **httpbin.org** - Tests HTTP mechanics and payload formatting
- **Validation functions** - Test URL/token/channel format validation
- **Error scenarios** - Test authentication failures and invalid endpoints

### Manual Testing Options

#### 1. Test with httpbin.org (Recommended for Development)
```sql
-- Test webhook functionality without hitting Slack
SELECT slack.webhook_send(
    'https://httpbin.org/post',
    {'text': 'Test message', 'username': 'Test Bot'}
);

-- Verify the request was formatted correctly
-- httpbin.org returns the request data in the response
```

#### 2. Test with webhook.site (Inspect Real Payloads)
```sql
-- Create a unique URL at https://webhook.site/ and use it
SELECT slack.webhook_send(
    'https://webhook.site/your-unique-id',
    {'text': 'Test message with full Slack formatting'}
);

-- View the captured request at webhook.site to see exactly what Slack would receive
```

#### 3. Test Workspace (Real Slack Testing)
Create a dedicated test workspace or use a private test channel:

```sql
-- Use environment variables to switch between test and prod
SELECT slack.webhook_send(
    '{{ env_var("SLACK_TEST_WEBHOOK_URL") }}',  -- Test webhook
    {'text': 'Safe test in dedicated channel'}
);
```

#### 4. Conditional Testing
```yaml
# dbt_project.yml - Only send notifications in specific environments
on-run-end:
  - "{% if target.name == 'prod' %}{{ slack_notify_on_run_end(results) }}{% endif %}"
  - "{% if env_var('SLACK_TESTING_MODE', 'false') == 'true' %}{{ slack_notify_on_run_end(results) }}{% endif %}"
```

### Environment Variables for Testing
```bash
# Production Slack
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/PROD/WEBHOOK"

# Testing alternatives
export SLACK_TEST_WEBHOOK_URL="https://webhook.site/your-unique-id"
export SLACK_HTTPBIN_TEST_URL="https://httpbin.org/post"
export SLACK_TESTING_MODE="true"
```

## How It Works

1. **You construct the payload** - Use Slack's official API documentation to build your JSON
2. **Livequery delivers it** - We handle the HTTP request to Slack
3. **Get the response** - Standard Slack API response with success/error info

## Slack API Documentation

- [Webhook Format](https://api.slack.com/messaging/webhooks) - For webhook_send()
- [chat.postMessage](https://api.slack.com/methods/chat.postMessage) - For post_message()
- [Block Kit](https://api.slack.com/block-kit) - For rich interactive messages
- [Message Formatting](https://api.slack.com/reference/surfaces/formatting) - Text formatting guide

That's it! No complex configurations, no templates to learn. Just Slack's API delivered through Livequery.