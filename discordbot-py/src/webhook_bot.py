"""Tasks:
1. every 5 minutes, trigger hololive_schedule to get streaming
2. check if there are streams will onair in next 5 minutes
3. push the stream to channel
"""
import asyncio
import logging
from datetime import datetime
from logging.handlers import TimedRotatingFileHandler

from discord.ext import tasks

from utils import send_discord_webhook

from hololive import hololive_schedule
import hololive.task
import hololive.config

import stock.task


logger = logging.getLogger('discord')
logger.setLevel(logging.INFO)

logname = "logs/webhook_bot.log"
handler = TimedRotatingFileHandler(logname, when="midnight", interval=1)
handler.suffix = "%Y%m%d"
handler.setFormatter(logging.Formatter('%(asctime)s:%(levelname)s:%(name)s: %(message)s'))
logger.addHandler(handler)

@tasks.loop(seconds=hololive.config.INTERVAL_IN_SECONDS)
async def push_hololive_schedule():
    logger.info('Start checking upcoming stream!')
    result = await hololive_schedule.main()
    for i in result:
        await send_discord_webhook(hololive.config.WEBHOOK_URL, hololive.config.WEBHOOK_USERDNAME, str(i))
        logger.info(f'Pushed {len(result)} events!')


async def main():
    print('start webhook bot')
    logger.info('Start Webhook Bot.')
    # await push_hololive_schedule.start()

    await stock.task.start()


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logger.info('Close Hololive Schedule Bot.')
