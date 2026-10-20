---
name: telegram-bot
description: "Create and deploy Telegram bots with Node.js Telegraf or Python python-telegram-bot covering BotFather token, long polling, webhook, Markdown HTML formatting, inline reply keyboards, media uploads, conversation state, Stripe payment invoices, command handlers, rate limit 429 backoff, secure Railway Docker deployment. Use when building telegram bot chatbot botfather token webhook polling sendmessage inlinekeyboard replykeyboard media photo video document conversation state payment invoice pre_checkout_query rate limit 429 retry deployment railway vercel docker secrets validate webhook secret token commands start help."
---

# Telegram Bot Builder

Create and run a Telegram bot. Use this guide when you need to build a bot from scratch, add interactive keyboards, handle media or payments, set up a webhook, or deploy the bot to production.

## When to Use
- New bot project or adding Telegram to an existing app
- Need polling for development or webhook for production
- Require inline keyboards, callback queries, or custom reply keyboards
- Sending photos, videos, documents, or media groups
- Implementing payments or Telegram Stars
- Managing groups, channels, or forum topics
- Deploying with Docker, PM2, serverless, or systemd

## Authentication
- Obtain a token from **@BotFather**.
- Token format: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`.
- Store the token in an environment variable, never commit it.

```bash
# .env file
BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
```

All API calls use the base URL `https://api.telegram.org/bot<TOKEN>/METHOD_NAME`.

## Receiving Updates
### Long Polling (development)
```javascript
// Node.js – node-telegram-bot-api
const TelegramBot = require('node-telegram-bot-api');
const bot = new TelegramBot(process.env.BOT_TOKEN, { polling: true });
```
```python
# Python – python-telegram-bot
from telegram.ext import Application
import os
app = Application.builder().token(os.getenv('BOT_TOKEN')).build()
app.run_polling()
```
### Webhook (production)
- Requires a public HTTPS URL (ports 443, 80, 88, or 8443).
- Set a secret token to verify requests.
```javascript
bot.setWebHook('https://yourdomain.com/webhook', { secret_token: 'YOUR_SECRET' });
```
- In your webhook handler, verify the `X-Telegram-Bot-Api-Secret-Token` header.

## Message Formatting
- Use `sendMessage` with **HTML** or **MarkdownV2** parse mode.
- HTML tags: `<b>`, `<i>`, `<code>`, `<pre>`, `<a href="url">`, `<tg-spoiler>`.
- MarkdownV2 requires escaping special characters.
- Prefer HTML for easier escaping.

## Keyboards & Interactive Elements
### Inline Keyboard (attached to a message)
```javascript
bot.sendMessage(chatId, 'Choose:', {
  reply_markup: {
    inline_keyboard: [
      [{ text: 'Option A', callback_data: 'a' }, { text: 'Option B', callback_data: 'b' }],
      [{ text: 'Visit Site', url: 'https://example.com' }]
    ]
  }
});
```
- `callback_data` max 64 bytes.
- Always call `answerCallbackQuery` after handling a button.

### Reply Keyboard (custom input panel)
```javascript
bot.sendMessage(chatId, 'Menu:', {
  reply_markup: {
    keyboard: [[{ text: '📊 Stats' }, { text: '⚙️ Settings' }]],
    resize_keyboard: true,
    one_time_keyboard: true
  }
});
```

## Sending Media
```javascript
// Photo (file_id, URL, or upload)
bot.sendPhoto(chatId, 'https://example.com/photo.jpg', { caption: 'A photo' });

// Document upload
const fs = require('fs');
bot.sendDocument(chatId, fs.createReadStream('./file.pdf'), { caption: 'Report' });

// Media group (2‑10 items)
bot.sendMediaGroup(chatId, [
  { type: 'photo', media: 'https://example.com/1.jpg', caption: 'First' },
  { type: 'photo', media: 'https://example.com/2.jpg' }
]);
```
- Three file sources: `file_id`, HTTP URL, multipart upload.
- Limits: 50 MB upload, 20 MB download via Bot API.

## Conversation State
- Use a state machine for multi‑step flows.
### Node.js
```javascript
const state = new Map(); // key: chatId, value: { step, data }
```
- Store state in memory, Redis, or a database.
### Python
```python
from telegram.ext import ConversationHandler
# Define states and handlers as per library docs
```

## Error Handling & Rate Limits
- **429 Too Many Requests**: read `retry_after` from response, wait that many seconds, then retry.
- **403 Forbidden**: user blocked the bot or removed it from a chat.
- **400 Bad Request**: invalid parameters; inspect `description` field.
- **409 Conflict**: another instance is polling with the same token.
- Rate limits: ~30 messages/second to different chats, ~20 messages/minute to the same group. Implement exponential back‑off.

## Bot Commands
- Register commands for the Telegram menu.
```javascript
bot.setMyCommands([
  { command: 'start', description: 'Start the bot' },
  { command: 'help', description: 'Show help' },
  { command: 'settings', description: 'Bot settings' }
]);
```
- Commands can be scoped to users, chats, or languages using `BotCommandScope`.

## Payments & Monetization
- Enable payments via BotFather and obtain a **provider token**.
```javascript
bot.command('buy', (ctx) => {
  ctx.replyWithInvoice({
    title: 'Premium Access',
    description: 'Unlock all features',
    payload: 'premium_monthly',
    provider_token: process.env.PAYMENT_TOKEN,
    currency: 'USD',
    prices: [{ label: 'Premium', amount: 999 }]
  });
});

bot.on('successful_payment', async (ctx) => {
  await activatePremium(ctx.from.id);
  ctx.reply('🎉 Premium activated!');
});
```
- Alternative revenue models: freemium, subscription, per‑use, ads, affiliate links.
- Enforce usage limits for free tier.
```javascript
async function checkUsage(userId) {
  const usage = await getUsage(userId);
  const premium = await isPremium(userId);
  if (!premium && usage >= 10) {
    return { allowed: false, message: 'Daily limit reached. Upgrade?' };
  }
  return { allowed: true };
}
```

## Deployment Options
- **PM2**: `pm2 start bot.js --name telegram-bot`
- **Docker**: Build an image with Node.js or Python runtime, expose port 443 for webhook.
- **Serverless**: Deploy webhook handler to Vercel, AWS Lambda, or Cloudflare Workers.
- **Systemd**: Create a service file to run the bot on a VPS.

## Security Checklist
- Store `BOT_TOKEN` and any payment/provider tokens in environment variables.
- Validate `X-Telegram-Bot-Api-Secret-Token` on webhook requests.
- Restrict `allowed_updates` to only the update types you need.
- Verify user IDs for admin‑only commands.
- Apply per‑user rate limiting.
- Sanitize all user‑provided text before storing or forwarding.
- Use HTTPS for webhook endpoints.
- Keep dependencies up‑to‑date.

## Common Anti‑Patterns
- **Blocking operations**: Acknowledge the user immediately, then process in background.
- **Missing error handling**: Add a global error handler that logs the error and replies with a friendly message.
- **Spamming**: Limit messages, respect user preferences, and avoid unsolicited promotions.

## Quick Start Templates
### Node.js (npm)
```bash
mkdir my-bot && cd my-bot
npm init -y
npm install node-telegram-bot-api dotenv
echo "BOT_TOKEN=your_token_here" > .env
```
### Python (pip)
```bash
mkdir my-bot && cd my-bot
python -m venv venv && source venv/bin/activate
pip install python-telegram-bot python-dotenv
echo "BOT_TOKEN=your_token_here" > .env
```

## Related skills

Load these when the task spans more than this skill.

- [`node`](../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`twilio`](../twilio/SKILL.md) — Implements Twilio communication features: sending SMS, performing phone/email verification with Verify, and bu…
