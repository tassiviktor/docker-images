# Docker images

### Overview

This repository provides two layered Docker base images designed for lightweight, multi-platform builds:

1. **`viktortassi/alpine-multi-base`**
   → Minimal, multi-architecture Alpine Linux base with UTF-8, timezone, and `mimalloc` preinstalled.
   It serves as a secure, reproducible foundation for all higher-level images.

2. **`viktortassi/alpine-java`**
   → Java-enabled images built **on top of** `alpine-multi-base`, providing OpenJDK runtimes (JRE/JDK)
   for Alpine versions `3.19–3.22` and Java LTS versions `17`, `21`, and (optionally) `25`.

Both image families are built for **`linux/amd64`** and **`linux/arm64`** architectures.

---

### Alpine Multi Base

**Purpose:**

* Provides a consistent, secure Alpine base image
* Includes `mimalloc` allocator and `su-exec` for privilege drops
* Default user: `default` (UID 1001)
* UTF-8 and timezone preconfigured

---

### Alpine Java

**Tags:**

```
viktortassi/alpine-java:<alpine>-<java><type>
Examples:
  viktortassi/alpine-java:3.21-17jre
  viktortassi/alpine-java:3.21-17jdk
  viktortassi/alpine-java:3.22-21jdk
```

**Available combinations:**

| Alpine    | Java | Type    | Example tag  |
| --------- | ---- | ------- | ------------ |
| 3.19–3.22 | 17   | jre/jdk | `3.22-17jre` |
| 3.19–3.22 | 21   | jre/jdk | `3.21-21jdk` |
| (testing) | 25   | jre/jdk | `3.22-25jre` |

---

### Runtime Optimization (already included)

All Java images include tuned defaults for containerized environments:

```bash
-XX:InitialRAMPercentage=40
-XX:MinRAMPercentage=40
-XX:MaxRAMPercentage=70
-XX:+UseStringDeduplication
```

These flags make the JVM automatically size its heap relative to the container’s memory limit (not the host), providing a safe and efficient default behavior inside Docker or Kubernetes.

You can override or extend these in your app image:

```dockerfile
ENV JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -XX:ActiveProcessorCount=2"
```

---

### Local testing

Start an interactive shell:

```bash
docker run -it --rm viktortassi/alpine-multi-base:3.21 /bin/sh
```

Or test a Java image:

```bash
docker run -it --rm viktortassi/alpine-java:3.21-17jre java -version
```

### License

All content and Dockerfiles are distributed under the MIT License unless otherwise noted.

## alpine-redis
Image, based on **alpine-multi-slim**. Persistency disabled by default and will be started as non-root

https://hub.docker.com/repository/docker/viktortassi/alpine-redis/general
