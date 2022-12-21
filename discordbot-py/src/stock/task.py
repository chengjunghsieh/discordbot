import logging
from logging.handlers import TimedRotatingFileHandler

from discord.ext import tasks

from utils import send_discord_webhook

import stock.command
import stock.config


logger = logging.getLogger('discord')
logger.setLevel(logging.INFO)

logname = "logs/stock_task.log"
handler = TimedRotatingFileHandler(logname, when="midnight", interval=1)
handler.suffix = "%Y%m%d"
handler.setFormatter(logging.Formatter('%(asctime)s:%(levelname)s:%(name)s: %(message)s'))
logger.addHandler(handler)


@tasks.loop(seconds=stock.config.INTERVAL_IN_SECONDS)
async def recent_earnings_dates():
    # print('recent_earnings_dates')
    logger.info('check recent_earnings_dates')
    tickers = stock.command.start()
    result = await stock.command.get_recent_earnings_reports(tickers)
    header = "**Recent Eearnings Reports**\n"
    await send_discord_webhook(stock.config.WEBHOOK_URL, stock.config.WEBHOOK_USERDNAME, header + result)


@tasks.loop(seconds=stock.config.INTERVAL_IN_SECONDS)
async def coming_earnings_dates():
    # print('coming_earnings_dates')
    logger.info('check coming_earnings_dates')
    tickers = stock.command.start()
    result = await stock.command.get_coming_earnings_reports(tickers)
    header = "**Coming Eearnings Reports**\n"
    await send_discord_webhook(stock.config.WEBHOOK_URL, stock.config.WEBHOOK_USERDNAME, header + result)


if __name__ == '__main__':
    import asyncio
    loop = asyncio.get_running_loop()
    loop.create_task(recent_earnings_dates())
    loop.create_task(coming_earnings_dates())
    loop.run_forever()
