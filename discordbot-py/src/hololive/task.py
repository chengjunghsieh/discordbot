import logging
from logging.handlers import TimedRotatingFileHandler

from discord.ext import tasks

from utils import send_discord_webhook

from hololive import hololive_schedule
import hololive.config


logger = logging.getLogger('discord')
logger.setLevel(logging.INFO)

logname = "logs/hololive_schedule.log"
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


async def start():
    await push_hololive_schedule.start()


if __name__ == '__main__':
    import asyncio
    asyncio.run(start())
