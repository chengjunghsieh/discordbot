import asyncio

from datetime import datetime
from lib2to3.pygram import Symbols
from typing import List, Tuple
import os
import re

import numpy as np
import pandas as pd
import yfinance as yf
# import yahoo_fin.stock_info as si


PATH = os.path.dirname(os.path.abspath(__file__))
bkfile = os.path.join(PATH, 'stock.bk')


tickers = {}

############################################################
#  API
############################################################

def start():
    with open(bkfile, 'r') as f:
        line = f.readline().strip()
        if line:
            s = line.split(',')
            for i in s:
                t = yf.Ticker(i)
                tickers[t.ticker] = t

    return tickers

"""
add_tickers(symbols :: Tuple) :: {:ok, nil} | {:error, reason}
"""
def add_tickers(symbols: Tuple):
    """
    @symbols
    Steps:
    1. fetch stocks information, name, symbol, earning date, ... (need to check)
    2. write to stocks.pickle
    3. add to tracking map
    """
    def sanitize(i):
        pattern = re.compile(r'[A-Za-z]+')
        s = re.findall(pattern, i)
        return s[0]

    try:
        response = []
        for i in symbols:
            i = sanitize(i)
            if not i: continue
            t = yf.Ticker(i)
            tickers[t.ticker] = t
            response.append(i)

        with open(bkfile, 'w') as f:
            s = tickers.keys()
            content = ','.join(s)
            f.write(content)

        return '[Add] ' + ' '.join(response)
    except Exception as e:
        return str(e)


def remove_ticker(symbol: str):
    try:
        if symbol in tickers:
            del tickers[symbol]
    except Exception as e:
        return str(e)

    return get_all_symbols()


async def get_earings_dates(symbol):
    def f(ticker):
        try:
            return ticker.earnings_dates
        except Exception as e:
            return e

    ticker = yf.Ticker(symbol)
    loop = asyncio.get_running_loop()
    result =  await loop.run_in_executor(None, lambda ticker=ticker: f(ticker))
    return str(result)


"""
add_tickers(tickers :: List(Stock)) :: [String.t()]
"""
def get_all_symbols() -> str:
    dt = pd.DataFrame({'Ticker': tickers.keys()})
    return str(dt)



"""
>>> aapl = yf.Ticker('AAPL')
>>> aapl.earnings_dates
                           EPS Estimate  Reported EPS  Surprise(%)
Earnings Date
2023-04-26 06:00:00-04:00           NaN           NaN          NaN
2023-01-25 05:00:00-05:00           NaN           NaN          NaN
2022-10-26 16:00:00-04:00           NaN           NaN          NaN
2022-07-28 16:00:00-04:00          1.16           NaN          NaN
2022-04-28 12:00:00-04:00          1.43          1.52       0.0644
...                                 ...           ...          ...
1994-01-21 00:00:00-05:00          0.01          0.01       0.0376
1993-10-15 00:00:00-04:00           NaN           NaN       1.5868
1993-07-16 00:00:00-04:00          0.03           NaN      -0.8891
1993-04-20 00:00:00-04:00          0.04          0.03      -0.0895
1993-01-16 00:00:00-05:00          0.05          0.05       0.0068

>>> r.index.dtype
datetime64[ns, America/New_York]    # need to clear localize
"""


def _get_earnings_dates_within_range(earnings_dates, base_date, lo, hi):
    """
    @earings_dates: pandas.DataFrame
    @base_ddate: np.datetime64
    @diff: np.timedelta64
    """
    return earnings_dates[(earnings_dates.tz_localize(None).index - base_date <= hi) & (earnings_dates.tz_localize(None).index - base_date >= lo)]


def _get_today():
    today = datetime.utcnow()
    today = today.replace(hour=0, minute=0, second=0, microsecond=0)
    return today


async def _get_earnings_reports(tickers=tickers):
    def f(ticker):
        try:
            return ticker.earnings_dates
        except Exception as e:
            return e

    loop = asyncio.get_running_loop()
    tasks = []
    for key, ticker in tickers.items():
        tasks.append(loop.run_in_executor(None, lambda ticker=ticker: (ticker.ticker, f(ticker))))

    results = await asyncio.gather(*tasks, return_exceptions=True)
    return results


async def get_recent_earnings_reports(tickers=tickers):
    today = _get_today()
    today = np.datetime64(today, 'ns')

    hi = np.timedelta64(0)
    lo = np.timedelta64(-7, 'D')


    try:
        results = await _get_earnings_reports(tickers=tickers)

        response = []
        for k, r in results:
            if isinstance(r, Exception):
                response.append('{}:\n{}\n'.format(k, r))
                continue
            d = _get_earnings_dates_within_range(r, today, lo, hi)
            if not d.empty:
                response.append('{}:\n{}\n'.format(k, d))


        return '\n'.join(response) + '\nTotal: {}'.format(len(response))
    except Exception as e:
        return str(e)


async def get_coming_earnings_reports(tickers=tickers):
    today = _get_today()
    today = np.datetime64(today, 'ns')

    lo = np.timedelta64(0)
    hi = np.timedelta64(7, 'D')

    try:
        results = await _get_earnings_reports(tickers)

        response = []
        for k, r in results:
            if isinstance(r, Exception):
                response.append('{}:\n{}\n'.format(k, r))
                continue
            d = _get_earnings_dates_within_range(r, today, lo, hi)
            if not d.empty:
                response.append('{}:\n{}\n'.format(k, d))

        return '\n'.join(response) + '\nTotal: {}'.format(len(response))
    except Exception as e:
        return str(e)
