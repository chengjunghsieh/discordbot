FROM elixir:1.12.3-alpine

RUN mix local.hex --force && \
    mix local.rebar --force

ENV APP_HOME /app
RUN mkdir $APP_HOME
COPY . $APP_HOME
WORKDIR $APP_HOME

ENV MIX_ENV=prod

# Compile the project
RUN mix do deps.get --only $MIX_ENV, deps.compile

CMD ["mix", "run", "--no-halt"]