FROM debian:stable-slim
LABEL maintainer="docker@llamaq.com"

RUN apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    gosu bc libimage-exiftool-perl ffmpeg imagemagick jpegoptim optipng exiftran \
  && apt-get -y clean && apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

VOLUME /opt/src
VOLUME /opt/temp
VOLUME /opt/dest

ENV PUID=1000 PGID=1000 TZ=Etc/UTC

COPY photius.sh /photius.sh
COPY photius-helper.sh /photius-helper.sh
COPY healthcheck.sh /healthcheck.sh
COPY entrypoint.sh /entrypoint.sh

HEALTHCHECK CMD /healthcheck.sh || exit 1
CMD /entrypoint.sh
