FROM viktortassi/alpine-multi-base:latest

USER root

# Valkey telepítés
RUN apk add --no-cache valkey valkey-cli

# Opcionális: sanity check build közben
RUN valkey-cli --version && valkey-server --version

# (Ha nem rootként futtatod) gondoskodj az adatkönyvtár jogosultságairól
# Megjegyzés: az Alpine csomag tipikusan /var/lib/valkey-t használ.
RUN mkdir -p /var/lib/valkey && chown -R default:default /var/lib/valkey

EXPOSE 6379

# Healthcheck: shell form, mert van pipe
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD sh -c 'valkey-cli -h 127.0.0.1 -p 6379 ping --raw | grep -q "^PONG$" || exit 1'

# A szerver indulási parancsa/argumentumai (PID1-ként fut)
CMD ["valkey-server", "--save", "", "--appendonly", "no"]

# Futtatás nem-rootként (ha ezt akarod)
USER default
