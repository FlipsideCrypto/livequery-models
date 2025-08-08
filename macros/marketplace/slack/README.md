# Slack Integration for Livequery

A straightforward Slack integration that uses secure vault-stored credentials. You construct the payload according to Slack's API spec, and Livequery delivers it using credentials stored in the vault.

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
7. Store the webhook URL in the vault under a secret name (e.g., 'alerts', 'notifications')
8. Use `slack_utils.post_webhook(secret_name, payload)`

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
8. Store the bot token in the vault (Livequery handles this automatically)
9. **Important:** Invite the bot to your channel:
   - Go to your Slack channel
   - Type `/invite @YourBotName` (replace with your bot's name)
   - Or go to channel settings → Integrations → Add apps → Select your bot
10. Get the channel ID:
    - Right-click your channel name → "Copy Link"
    - Extract the ID from URL: `https://yourworkspace.slack.com/archives/C087GJQ1ZHQ` → `C087GJQ1ZHQ`
11. Use `slack.post_message(channel, payload)` and `slack.post_reply()` for threading

**Features:**
- ✅ Threading support with `slack.post_reply()`
- ✅ Send to any channel the bot is invited to
- ✅ More control and flexibility
- ❌ Requires bot setup and channel invitations

## Quick Start

### Basic Webhook Message
```sql
-- Send a simple message via webhook
SELECT slack_utils.post_webhook(
    'alerts',  -- Secret name in vault
    {
        'text': 'Hello from Livequery!',
        'username': 'Data Bot'
    }
);
```

### Web API Message
```sql
-- Send message to a channel
SELECT slack.post_message(
    'C087GJQ1ZHQ',  -- Channel ID
    {
        'text': 'Pipeline completed!',
        'blocks': [
            {
                'type': 'header',
                'text': {
                    'type': 'plain_text',
                    'text': ':white_check_mark: Pipeline Success'
                }
            }
        ]
    }
);
```

### Threading Example
```sql
-- First send main message
WITH main_message AS (
    SELECT slack.post_message(
        'C087GJQ1ZHQ',
        {'text': 'Pipeline failed with 3 errors. Details in thread...'}
    ) as response
)
-- Then send threaded reply
SELECT slack.post_reply(
    'C087GJQ1ZHQ',
    main_message.response:data:ts::STRING,  -- Use timestamp from main message
    {'text': 'Error 1: Database connection timeout'}
) as thread_response
FROM main_message;
```

## Functions Reference

### `slack_utils.post_webhook(secret_name, payload)`
Send messages via Slack Incoming Webhooks using vault-stored webhook URL.

**Parameters:**
- `secret_name` - Name of webhook secret stored in vault (e.g., 'alerts', 'notifications')
- `payload` - JSON object following [Slack webhook format](https://api.slack.com/messaging/webhooks)

**Example:**
```sql
SELECT slack_utils.post_webhook(
    'notifications',
    {
        'text': 'dbt run completed successfully',
        'username': 'dbt Bot',
        'icon_emoji': ':white_check_mark:'
    }
);
```

### `slack.post_message(channel, payload)`
Send messages via Slack Web API (chat.postMessage) using vault-stored bot token.

**Parameters:**
- `channel` - Channel ID (C...) or name (#channel)
- `payload` - JSON object following [Slack chat.postMessage format](https://api.slack.com/methods/chat.postMessage)

**Example:**
```sql
SELECT slack.post_message(
    'C087GJQ1ZHQ',
    {
        'text': 'Model update complete',
        'attachments': [
            {
                'color': 'good',
                'title': 'Success',
                'fields': [
                    {'title': 'Models', 'value': '15', 'short': true},
                    {'title': 'Duration', 'value': '2m 30s', 'short': true}
                ]
            }
        ]
    }
);
```

### `slack.post_reply(channel, thread_ts, payload)`
Send threaded replies via Slack Web API using vault-stored bot token.

**Parameters:**
- `channel` - Channel ID or name
- `thread_ts` - Parent message timestamp for threading
- `payload` - JSON object following Slack chat.postMessage format

**Example:**
```sql
SELECT slack.post_reply(
    'C087GJQ1ZHQ',
    '1698765432.123456',  -- Parent message timestamp
    {'text': 'Additional details in this thread'}
);
```

### `slack.webhook_send(secret_name, payload)`
Alias for `slack_utils.post_webhook()` - sends webhook messages using vault-stored URL.

**Parameters:**
- `secret_name` - Name of webhook secret stored in vault
- `payload` - JSON object following Slack webhook format

### Validation Functions
- `slack_utils.validate_webhook_url(url)` - Check if webhook URL format is valid
- `slack_utils.validate_bot_token(token)` - Check if bot token format is valid
- `slack_utils.validate_channel(channel)` - Check if channel format is valid

## Vault Configuration

### Webhook Secrets
Store your webhook URLs in the vault with meaningful names:
- `alerts` - For critical alerts
- `notifications` - For general notifications
- `marketing` - For marketing team updates

### Bot Token
The bot token is automatically managed by Livequery and stored securely in the vault. You don't need to provide it in function calls.

## Testing Without Spamming Slack

### Built-in Tests
The integration includes comprehensive tests that verify functionality without hitting real Slack channels.

### Manual Testing Options

#### 1. Test with httpbin.org (Recommended for Development)
```sql
-- Test webhook functionality without hitting Slack
-- (Note: This bypasses vault and uses direct URL for testing)
SELECT slack_utils.post_webhook(
    'test-httpbin',  -- Create test secret pointing to httpbin.org
    {'text': 'Test message', 'username': 'Test Bot'}
);
```

#### 2. Test Workspace (Real Slack Testing)
Create a dedicated test workspace or use a private test channel:
- Store test webhook URLs in vault with names like `test-alerts`
- Use test channel IDs for `post_message()` calls
- Set up separate vault secrets for testing vs production

## Advanced Usage

### Rich Message Formatting
```sql
-- Advanced Block Kit message
SELECT slack.post_message(
    'C087GJQ1ZHQ',
    {
        'text': 'Data Pipeline Report',
        'blocks': [
            {
                'type': 'header',
                'text': {
                    'type': 'plain_text',
                    'text': '📊 Daily Data Pipeline Report'
                }
            },
            {
                'type': 'section',
                'fields': [
                    {'type': 'mrkdwn', 'text': '*Environment:*\nProduction'},
                    {'type': 'mrkdwn', 'text': '*Models Run:*\n25'},
                    {'type': 'mrkdwn', 'text': '*Duration:*\n12m 34s'},
                    {'type': 'mrkdwn', 'text': '*Status:*\n✅ Success'}
                ]
            },
            {
                'type': 'actions',
                'elements': [
                    {
                        'type': 'button',
                        'text': {'type': 'plain_text', 'text': 'View Logs'},
                        'url': 'https://your-logs-url.com'
                    }
                ]
            }
        ]
    }
);
```

### Error Handling
```sql
-- Check response for errors
WITH slack_result AS (
    SELECT slack_utils.post_webhook(
        'alerts',
        {'text': 'Test message'}
    ) as response
)
SELECT 
    response:ok::BOOLEAN as success,
    response:error::STRING as error_message,
    CASE 
        WHEN response:ok::BOOLEAN THEN 'Message sent successfully'
        ELSE 'Failed: ' || response:error::STRING
    END as status
FROM slack_result;
```

## How It Works

1. **Secure credential storage** - Webhook URLs and bot tokens are stored in Livequery's vault
2. **You construct the payload** - Use Slack's official API documentation to build your JSON
3. **Livequery delivers it** - We handle authentication and HTTP requests to Slack
4. **Get the response** - Standard Slack API response with success/error info

## Slack API Documentation

- [Webhook Format](https://api.slack.com/messaging/webhooks) - For webhook messages
- [chat.postMessage](https://api.slack.com/methods/chat.postMessage) - For Web API messages
- [Block Kit](https://api.slack.com/block-kit) - For rich interactive messages
- [Message Formatting](https://api.slack.com/reference/surfaces/formatting) - Text formatting guide

That's it! Secure, simple Slack integration with vault-managed credentials.