FROM viktortassi/alpine-multi-base:latest

USER root

RUN apk add --no-cache valkey valkey-cli

RUN valkey-cli --version && valkey-server --version

RUN mkdir -p /var/lib/valkey && chown -R default:default /var/lib/valkey

RUN rm -rf /root/.cache /var/cache/apk/* /tmp/* /var/tmp/*

EXPOSE 6379

# Healthcheck: shell form, because of pipe
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD sh -c 'valkey-cli -h 127.0.0.1 -p 6379 ping --raw | grep -q "^PONG$" || exit 1'

CMD ["valkey-server", "--save", "", "--appendonly", "no"]

USER default
