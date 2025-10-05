ARG PYTHON_VERSION="3.12"
ARG GO2RTC_VERSION="1.9.10@sha256:95ce2ab22f2c7d8eb4dae42e0856b8480daf22c7c632f4a0489d442caf2df158"
ARG UV_VERSION="0.8.23@sha256:94390f20a83e2de83f63b2dadcca2efab2e6798f772edab52bf545696c86bdb4"

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