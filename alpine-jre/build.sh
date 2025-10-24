#!/usr/bin/env bash
set -euo pipefail

BUILDER_NAME="multiarch"

# Alpine base versions
ALPINE_VERSIONS=(3.19 3.20 3.21 3.22)

# Java LTS versions
JAVA_VERSIONS=(17 21) #25 will be added when ready

# Java package suffixes (-jre-headless => tag:jre, -jdk => tag:jdk)
JAVA_TYPES=(-jre-headless -jdk)

# Platforms
PLATFORMS="linux/amd64,linux/arm64"

# Parse options
DRY_RUN=false
while getopts ":n" opt; do
  case $opt in
    n) DRY_RUN=true ;;
    *) ;;
  esac
done
shift $((OPTIND - 1))

# Parameters
if [[ $# -lt 1 ]]; then
  echo "usage: $0 [-n] <repo>"
  echo "example: $0 -n your_username/alpine-java"
  echo "  -n : dry run (build only, no push)"
  exit 1
fi

# --- Buildx builder check ---
BUILDER_NAME="${BUILDER_NAME:-multiarch}"

if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  echo "[ERROR] Buildx builder '$BUILDER_NAME' not found."
  echo "Please create it manually, e.g.:"
  echo "  docker buildx create --name $BUILDER_NAME --driver docker-container --use"
  exit 3
fi

docker buildx use "$BUILDER_NAME"
echo "[INFO] Using buildx builder: $BUILDER_NAME"

IMAGE_REPO="$1"

# Docker login
: "${DOCKERHUB_USERNAME:?Set DOCKERHUB_USERNAME!}"
if [[ -n "${DOCKERHUB_TOKEN:-}" ]]; then
  LOGIN_SECRET="$DOCKERHUB_TOKEN"
elif [[ -n "${DOCKERHUB_PASSWORD:-}" ]]; then
  LOGIN_SECRET="$DOCKERHUB_PASSWORD"
else
  echo "Error: Set DOCKERHUB_TOKEN or DOCKERHUB_PASSWORD"
  exit 2
fi

if $DRY_RUN; then
  echo "[DRY RUN] Login skipped (simulating)"
else
  echo "$LOGIN_SECRET" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
fi

# Build mode
if $DRY_RUN; then
  PUSH_MODE=""
  ATTEST_FLAGS=()
else
  PUSH_MODE="--push"
  ATTEST_FLAGS=(--provenance=true --sbom=true)
fi

# Map suffix → tag fragment
type_tag_fragment() {
  case "$1" in
    -jre-headless) echo "jre" ;;
    -jdk)          echo "jdk" ;;
    *)             echo "${1#-}" ;;
  esac
}

# Banner
if $DRY_RUN; then
  echo "=========================================="
  echo " DRY RUN MODE: images will NOT be pushed "
  echo "=========================================="
fi

# Build matrix
for ALPINE_VERSION in "${ALPINE_VERSIONS[@]}"; do
  for JV in "${JAVA_VERSIONS[@]}"; do
    for JT in "${JAVA_TYPES[@]}"; do
      TAG_KIND="$(type_tag_fragment "$JT")"      # jre / jdk
      TAG="${IMAGE_REPO}:${ALPINE_VERSION}-${JV}${TAG_KIND}"
      JAVA_PACKAGE="openjdk${JV}${JT}"

      echo "==> Building ${TAG}"
      docker buildx build \
        --platform "$PLATFORMS" \
        "${ATTEST_FLAGS[@]}" \
        -t "$TAG" \
        --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
        --build-arg "JAVA_PACKAGE=${JAVA_PACKAGE}" \
        --pull \
        --label "org.opencontainers.image.title=Alpine Java Runtime" \
        --label "org.opencontainers.image.description=Alpine Java Runtime for build and for run" \
        --label "org.opencontainers.image.version=${ALPINE_VERSION}-${JV}${TAG_KIND}" \
        --label "org.opencontainers.image.source=https://github.com/tassiviktor/docker-images" \
        --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --label "org.opencontainers.image.licenses=Unlicense" \
        --label "org.opencontainers.image.base.name=viktortassi/alpine-multi-base:${ALPINE_VERSION}" \
        $PUSH_MODE \
        .
    done
  done
done

echo
echo "All combinations built successfully."
if $DRY_RUN; then
  echo "[DRY RUN COMPLETE] No images were pushed."
else
  echo "[DONE] All images pushed to ${IMAGE_REPO}."
fi
