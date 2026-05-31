FROM hexpm/elixir:1.17.3-erlang-27.2.1-alpine-3.21.3 AS build

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod && mix deps.compile

COPY assets assets
COPY priv priv

RUN npm install --prefix assets --no-audit --no-fund
RUN npm run deploy --prefix assets
RUN mix phx.digest

COPY lib lib
RUN mix compile

RUN mix release

FROM alpine:3.21 AS app

RUN apk add --no-cache openssl ncurses-libs libstdc++

WORKDIR /app

COPY --from=build /app/_build/prod/rel/ai_chatbot ./

CMD ["bin/ai_chatbot", "start"]
