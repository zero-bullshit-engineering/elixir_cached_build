FROM elixir as build
RUN mix local.hex --force && mix local.rebar --force
ADD .depscache/ /app/
RUN cd /app && mix deps.get && mix deps.compile && MIX_ENV=test mix deps.compile && MIX_ENV=prod mix deps.compile


FROM elixir 
RUN mix local.hex --force && mix local.rebar --force
ADD . /app
COPY --from=build /app/_build /app/_build
COPY --from=build /app/deps /app/deps
RUN cd /app && mix compile
