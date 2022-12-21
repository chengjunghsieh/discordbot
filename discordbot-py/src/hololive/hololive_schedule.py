import asyncio
import requests

from datetime import datetime, timedelta, timezone, tzinfo
from functools import partial, reduce
from typing import Optional, List
from bs4 import BeautifulSoup

from hololive import config

TARGET = 'https://schedule.hololive.tv/simple'

class StreamEvent:
    def __init__(self, streamer, sched_time, stream_url):
        self.streamer = streamer
        self.sched_time = sched_time
        self.stream_url = stream_url

    def __str__(self):
        time_str = to_string(utc2jst(self.sched_time))
        return f'{self.streamer}の配信, {time_str}\n{self.stream_url}'

    def __repr__(self):
        time_str = to_string(utc2jst(self.sched_time))
        return f'{self.streamer}の配信, {time_str}\n{self.stream_url}'


def to_string(obj):
    if isinstance(obj, datetime):
        return obj.strftime("%Y-%m-%dT%H:%M:%S %Z")


def utc2jst(t):
    t += timedelta(hours=9)
    t = t.replace(tzinfo=timezone(timedelta(hours=9)))
    return t

def build_sched_time(datestr, timestr) -> datetime:
    '''
    input time are JST
    ret: time in UTC
    '''
    current_year = (datetime.utcnow() + timedelta(hours=9)).year
    t = datetime.strptime(f'{current_year}/{datestr} {timestr}', '%Y/%m/%d %H:%M')
    t -= timedelta(hours=9)
    return t


def check(t):
    current_time = datetime.utcnow()
    current_time = current_time.replace(second=0, microsecond=0)
    delta = t - current_time
    return delta >= timedelta(seconds=0) and delta < timedelta(seconds=config.INTERVAL_IN_SECONDS)


def parse_schedule(results) -> List:
    sched_date = ''
    events = []

    def update_sched_date(result) -> Optional[str]:
        div_date = result.find(class_="holodule")
        if div_date:
            new_date = div_date.text.strip().split('\r\n')[0]
            return new_date


    def get_sched_events(result, fun) -> List[StreamEvent]:
        a = result.find_all('a')

        def f(acc, i):
            if not i:
                return acc
            link = i['href'].strip()
            tmp = i.text.strip().split(' ')
            sched_time, streamer, *_ = list(filter(None, tmp))
            sched_time = sched_time.strip()
            sched_time = fun(sched_time)
            streamer = streamer.strip().split(' ')[0]
            if check(sched_time):
                acc.append(StreamEvent(streamer=streamer, sched_time=sched_time, stream_url=link))
            return acc

        events = reduce(lambda acc, i: f(acc, i), a, [])
        return events

    for result in results:
        sched_date = update_sched_date(result) or sched_date
        fun = partial(build_sched_time, sched_date)
        events += get_sched_events(result, fun)

    return events


def fetch():
    page = requests.get(TARGET)
    return page


async def main():
    loop = asyncio.get_running_loop()
    page = await loop.run_in_executor(None, fetch)
    soup = BeautifulSoup(page.content, 'html.parser')
    results = soup.find_all(class_='container')
    events = parse_schedule(results)
    return events


if __name__ == '__main__':
    result = asyncio.run(main())
    print(result)
