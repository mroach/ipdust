# This is a multi-stage Dockerfile

################################################################################
# == Base
# Elixir base image for running development server and tools and
# for building a production release
FROM elixir:1.8-alpine AS phoenix_base

RUN mix do local.hex --force, local.rebar --force

# Need inotify for watchers to work
# Need git since the rdap dependency is only on github
RUN apk --no-cache add inotify-tools git

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config/ ./config
COPY lib/ ./lib
COPY priv/ ./priv
COPY test/ ./test

CMD mix do deps.get, phx.server

################################################################################
# == Production release builder
#
# This will use distillery to create a tarball of binaries and static files
# needed to run the app. Then we only need those files in a container for
# the app to run. We don't need Elixir, Erlang, anything else.
FROM phoenix_base AS release_builder

ENV MIX_ENV prod

COPY rel/ ./rel

RUN mix release --env=prod


################################################################################
# == Production runnable image
#
# Final production-ready image. Only contains the app binaries and static assets
FROM alpine:latest AS ipdust_prod

ENV MIX_ENV prod
ENV PORT 4000

EXPOSE 4000

# bash and openssl are required to run the release
RUN apk add --no-cache bash openssl

WORKDIR /app

COPY --from=release_builder /app/_build/prod/rel/ipdust/ .

CMD ["bin/ipdust", "foreground"]
