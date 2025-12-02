ARG PYTHON_VERSION="3.12"
ARG GO2RTC_VERSION="1.9.12@sha256:baef0aa19d759fcfd31607b34ce8eaf039d496282bba57731e6ae326896d7640"
ARG UV_VERSION="0.9.14@sha256:fef8e5fb8809f4b57069e919ffcd1529c92b432a2c8d8ad1768087b0b018d840"

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