FROM elixir:1.14-alpine as builder

WORKDIR /app

COPY . .

RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get && \
  MIX_ENV=prod mix release

# ---

FROM alpine:3.17

RUN apk update && \
  apk add --no-cache libstdc++ libgcc glib libc6-compat ncurses openssl

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/stanley_stella/ /app/

EXPOSE 4000

CMD ["./bin/stanley_stella", "start"]
