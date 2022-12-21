import asyncio

import importlib
import os
import sys

from discord.ext import commands

import hololive.task

import stock.command
import stock.task

ROOT_PATH = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(ROOT_PATH)
config = importlib.import_module('config', ROOT_PATH)

# logger = logging.getLogger('discord')
# logger.setLevel(logging.DEBUG)
# handler = logging.FileHandler(filename='discord.log', encoding='utf-8', mode='w')
# handler.setFormatter(logging.Formatter('%(asctime)s:%(levelname)s:%(name)s: %(message)s'))
# logger.addHandler(handler)

########################################################
#  Discord Bot Setup
########################################################
bot = commands.Bot(command_prefix='!')
@bot.event
async def on_ready():
    stock.command.start()
    print('Bot is ready!')


@bot.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.errors.CheckFailure):
        await ctx.send('You do not have the correct role for this command.')


@bot.command(name='commands',
             help='!commands',
             description='Get all commands usages')
async def get_all_commands(ctx):
    try:
        resp = "```\n"
        resp += '\n'.join(map(lambda i: '{}\n{}\n'.format(i.help, i.description), bot.commands))
        resp += "```\n"
    except Exception as e:
        resp = str(e)
    await ctx.send(resp)


########################################################
#  Stock Commands
########################################################
@bot.command(name="add-tickers",
             help=("Add tickers separated by spaces\n"
                   "!add-tickers <ticker_1> <ticker_2> ..."),
             description="Add tickers to be tracked")
async def add_tickers(ctx, *args):
    resp = stock.command.add_tickers(args)
    await ctx.send(resp)


@bot.command(name="remove-ticker",
             help="!remove-ticker <ticker>",
             description="Remove tracked ticker")
async def remove_ticker(ctx, *args):
    resp = stock.command.remove_tickers(args)
    await ctx.send(resp)


@bot.command(name="tickers",
             help="!tickers",
             description="Get tracked tickers")
async def get_all_symbols(ctx):
    resp = stock.command.get_all_symbols()
    await ctx.send(resp)


@bot.command(name="coming-earnings-dates",
             help="!coming-earnings-dates",
             description="Get tracked tickers' coming earings dates within 7 days")
async def get_coming_earnings_reports(ctx):
    resp = await stock.command.get_coming_earnings_reports()
    await ctx.send(resp)


@bot.command(name="recent-earnings-dates",
             help="!recent-earnings-dates",
             description="Get tracked tickers' recent earings dates within 7 days")
async def get_recent_earnings_reports(ctx):
    resp = await stock.command.get_recent_earnings_reports()
    await ctx.send(resp)


@bot.command(name="get-earnings-dates",
             help="!get-earnings-dates <ticker>",
             description="Get ticker's earings dates")
async def get_earnings_dates(ctx, ticker):
    resp = await stock.command.get_earings_dates(ticker)
    await ctx.send(resp)


if __name__ == '__main__':
    stock.task.coming_earnings_dates.start()
    # stock.task.recent_earnings_dates.start()
    hololive.task.push_hololive_schedule.start()
    bot.run(config.DISCORD_TOKEN)
