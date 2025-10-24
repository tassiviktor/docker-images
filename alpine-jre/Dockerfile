ARG ALPINE_VERSION=""
FROM viktortassi/alpine-multi-base:$ALPINE_VERSION

ARG ALPINE_VERSION
ARG JAVA_PACKAGE

USER root

RUN apk update && apk upgrade --no-cache && \
    apk --no-cache add $JAVA_PACKAGE && \
    apk -v cache clean

# --- JVM defaults for containers ---
ENV JAVA_TOOL_OPTIONS="\
  -XX:InitialRAMPercentage=40 \
  -XX:MinRAMPercentage=40 \
  -XX:MaxRAMPercentage=70 \
  -XX:+UseStringDeduplication"

USER default

RUN java -version
