FROM python:3.9-slim
# ENV
COPY . /code
WORKDIR /code
RUN pip3 install pipenv && \
    pipenv install --system --deploy --ignore-pipfile
CMD ["python3", "./src/bot.py"]
