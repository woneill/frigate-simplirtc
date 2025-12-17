ARG PYTHON_VERSION="3.12"
ARG GO2RTC_VERSION="1.9.13@sha256:f394f6329f5389a4c9a7fc54b09fdec9621bbb78bf7a672b973440bbdfb02241"
ARG UV_VERSION="0.9.18@sha256:5713fa8217f92b80223bc83aac7db36ec80a84437dbc0d04bbc659cae030d8c9"

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