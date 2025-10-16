# Build stage
FROM hexpm/elixir:1.17.3-erlang-27.1.2-alpine-3.20.3 AS build

# Instala dependências de build
RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

# Instala Hex e Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Define ambiente de produção
ENV MIX_ENV=prod

# Copia arquivos de dependências
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copia configurações e código
COPY config config
COPY lib lib
COPY priv priv

# Compila o projeto
RUN mix compile

# Build release
RUN mix release

# Runtime stage
FROM alpine:3.20.3

# Instala dependências runtime
RUN apk add --no-cache libstdc++ openssl ncurses-libs libgcc

WORKDIR /app

# Copia a release do build stage
COPY --from=build /app/_build/prod/rel/zenith ./

# Cria usuário não-root
RUN addgroup -g 1000 zenith && \
    adduser -D -u 1000 -G zenith zenith && \
    chown -R zenith:zenith /app

USER zenith

ENV HOME=/app
ENV MIX_ENV=prod
ENV PORT=8080

EXPOSE 8080

CMD ["bin/zenith", "start"]