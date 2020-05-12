# This is a multi-stage Dockerfile

################################################################################
# == Base
# Elixir base image for running development server and tools and
# for building a production release
ARG elixir_ver=1.10

FROM elixir:${elixir_ver}-alpine AS base

RUN mix do local.hex --force, local.rebar --force

# Need inotify for watchers to work
# Need git since the rdap dependency is only on github
RUN apk --no-cache add \
      inotify-tools \
      git \
      bash \
      curl

# read in mix.exs to set the paths for dependencies and build output.
# for local development on non-Linux hosts, this circumvents an I/O bottleneck
# and allows for easily testing against multiple versions of Elixir.
ENV MIX_DEPS_PATH=/opt/mix/deps \
    MIX_BUILD_PATH_ROOT=/opt/mix/build \
    MIX_ENV=dev \
    PS1="\u@\h:\w \$ "

WORKDIR /opt/app
VOLUME /opt/app

COPY mix.exs mix.lock ./

RUN mix do deps.get, deps.compile

COPY config/ ./config
COPY lib/ ./lib
COPY priv/ ./priv
COPY test/ ./test
COPY VERSION ./

CMD ["mix", "do", "deps.get,", "phx.server"]


################################################################################
# == Production release builder
#
# This will use distillery to create a tarball of binaries and static files
# needed to run the app. Then we only need those files in a container for
# the app to run. We don't need Elixir, Erlang, anything else.
FROM base AS release_builder

ENV MIX_ENV=prod \
    MIX_BUILD_PATH=/opt/mix/build/prod

ARG maxmind_license

RUN curl -Lfo priv/geoip/GeoLite2-City.tar.gz \
    "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${maxmind_license}&suffix=tar.gz"

RUN curl -Lfo priv/geoip/GeoLite2-ASN.tar.gz \
    "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${maxmind_license}&suffix=tar.gz"

RUN mix release


################################################################################
# == Production runnable image
#
# Final production-ready image. Only contains the app binaries and static assets
FROM alpine:latest AS release

ARG git_commit=unknown
ARG app_version=unknown

LABEL git.commit=${git_commit} \
      app.version=${app_version}

EXPOSE 80

# bash and openssl are required to run the release
RUN apk add --no-cache bash openssl

WORKDIR /opt/app

COPY --from=release_builder /opt/mix/build/prod/rel/ipdust/ .

CMD ["bin/ipdust", "start"]
