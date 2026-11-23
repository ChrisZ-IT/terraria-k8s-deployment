FROM debian:stable-slim

ENV DEBIAN_FRONTEND noninteractive

RUN <<EOF
set -e
apt-get update && apt-get upgrade -y
apt-get install -y --no-install-recommends curl ca-certificates unzip jq
apt-get autoremove -y && apt-get autoclean
rm -rf /var/lib/apt/lists/*
EOF

RUN useradd --no-log-init -u 1026 -g 100 -m -s /usr/sbin/nologin serviceuser

USER 1026:100

WORKDIR /home/serviceuser
