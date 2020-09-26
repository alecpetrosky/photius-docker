FROM debian:stable-slim
LABEL maintainer="docker@alecpetrosky.com"

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    gosu bc libimage-exiftool-perl ffmpeg imagemagick jpegoptim optipng exiftran \
  && apt-get -y clean && apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

VOLUME /opt/src
VOLUME /opt/temp
VOLUME /opt/dest

ARG BUILD_VERSION
ENV PHOTIUS_VERSION=${BUILD_VERSION:-UNKNOWN_RELEASE}

ENV PUID=1000 PGID=1000 TZ=Etc/UTC \
  PHOTIUS_SKIP_PICTURES=0 \
  PHOTIUS_SKIP_VIDEOS=0 \
  PHOTIUS_FAILURE_THRESHOLD=300 \
  PHOTIUS_RENAME_PROCESSINGDATE=0 \
  PHOTIUS_RENAME_DATETIMEORIGINAL=0

COPY photius.sh /photius.sh
COPY photius-helper.sh /photius-helper.sh
COPY healthcheck.sh /healthcheck.sh
COPY entrypoint.sh /entrypoint.sh

HEALTHCHECK CMD /healthcheck.sh || exit 1
CMD /entrypoint.sh
