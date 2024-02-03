# Docker images
Several docker images for my projects. All of them are prepared for building with buildx.

## alpine-multi-base
Alpine 3.19 based image with:
- Setting UTF-8 as default eoncoding
- mimalloc2 - memory manager for improving performance of memory allocations
- Adding default user for running applications as non-root
- AMD64 and ARM64 support (multiplatfrom image)

https://hub.docker.com/repository/docker/viktortassi/alpine-multi-base/general

## alpine-jre
Image based on above, adding slim LTS jres. See tags on the DockerHub page
- JRE 11
- JRE 17
- JRE 21

https://hub.docker.com/repository/docker/viktortassi/alpine-jre/general

## alpine-redis
Image based on **alpine-multi-slim**. Persistency disabled by default, started as non-root

https://hub.docker.com/repository/docker/viktortassi/alpine-redis/general
