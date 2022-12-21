import aiohttp
from discord import Webhook, AsyncWebhookAdapter


async def send_discord_webhook(webhook_url, webhook_username, content):
    async with aiohttp.ClientSession() as session:
        webhook = Webhook.from_url(webhook_url, adapter=AsyncWebhookAdapter(session))
        await webhook.send(content, username=webhook_username)
