ARG PYTHON_VERSION="3.12"
ARG GO2RTC_VERSION="1.9.9@sha256:7d31dcb73633310e80497c431f4534c81ed55ec0708db3262bc56918e654bba5"
ARG UV_VERSION="0.8.15@sha256:a5727064a0de127bdb7c9d3c1383f3a9ac307d9f2d8a391edc7896c54289ced0"

FROM alexxit/go2rtc:${GO2RTC_VERSION} AS go2rtc
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM python:${PYTHON_VERSION}-alpine

# go2rtc dependencies
RUN apk add --no-cache tini ffmpeg ffplay bash curl jq alsa-plugins-pulse font-droid git
COPY --from=go2rtc /usr/local/bin/go2rtc /usr/local/bin/go2rtc

# uv to install simplirtc
COPY --from=uv /uv /uvx /bin/
ENV PATH=/root/.local/bin:$PATH
RUN uv tool install git+https://github.com/gilliginsisland/simplirtc.git

ENTRYPOINT ["/sbin/tini", "--"]
VOLUME /config
WORKDIR /config

CMD ["go2rtc", "-config", "/config/go2rtc.yaml"]