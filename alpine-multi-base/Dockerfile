ARG ALPINE_VERSION=""
FROM alpine:$ALPINE_VERSION

ARG USER=default
ARG UID=1001
ARG GID=1001
RUN addgroup -S $USER -g $GID && adduser -S $USER -u $UID -G $USER

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC

RUN apk update && apk upgrade --no-cache && \
    apk --no-cache add tzdata su-exec gcompat mimalloc2 && \
    apk -v cache clean && \
    ln -s /usr/lib/libmimalloc-secure.so.2 /lib/libmimalloc.so

ENV MIMALLOC_LARGE_OS_PAGES=1 LD_PRELOAD=/lib/libmimalloc.so

RUN echo "UTC" > /etc/timezone
RUN cp /usr/share/zoneinfo/UTC /etc/localtime

USER default