FROM viktortassi/alpine-multi-base:latest

USER root

RUN apk update && apk add --no-cache valkey && apk -v cache clean

RUN valkey-cli --version && valkey-server --version

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 6379
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD valkey-cli ping | grep -q PONG || exit 1

CMD ["valkey-server", "--save", "", "--appendonly", "no"]

USER default
