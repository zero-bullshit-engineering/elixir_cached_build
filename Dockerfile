FROM elixir:1.8.1-alpine as built
RUN mix local.hex --force && mix local.rebar --force
ADD .depscache/ /app/
RUN cd /app && mix deps.get && mix deps.compile && MIX_ENV=test mix deps.compile && MIX_ENV=prod mix deps.compile


FROM elixir:1.8.1-alpine as compiled
RUN mix local.hex --force && mix local.rebar --force
ADD . /app
COPY --from=built /app/_build /app/_build
COPY --from=built /app/deps /app/deps
RUN cd /app && mix compile && MIX_ENV=test mix compile && MIX_ENV=prod mix compile


FROM elixir:1.8.1-alpine as test
RUN mix local.hex --force && mix local.rebar --force
COPY --from=compiled /app /app
RUN cd /app && mix test > out


FROM elixir:1.8.1-alpine as credo
RUN mix local.hex --force && mix local.rebar --force
COPY --from=compiled /app /app
RUN cd /app && mix credo > out


FROM elixir:1.8.1-alpine as release
# waiting for shit
RUN mix local.hex --force && mix local.rebar --force

COPY --from=test /app/out /test_output
COPY --from=credo /app/out /credo_output

COPY --from=compiled /app /app
RUN cd /app && MIX_ENV=prod mix release


FROM alpine
RUN apk --update add bash libgcc
COPY --from=release /app/_build/prod/rel/cachetest /app
ENTRYPOINT /app/bin/cachetest foreground
