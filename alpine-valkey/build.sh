#!/usr/bin/env bash
set -euo pipefail

PLATFORMS="linux/amd64,linux/arm64"
DRY_RUN=false

# --- Parse arguments ---
while getopts ":n" opt; do
  case $opt in
    n) DRY_RUN=true ;;
    *) ;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -lt 1 ]]; then
  echo "usage: $0 [-n] <repo>"
  echo "example: $0 -n youruser/valkey"
  exit 1
fi
REPO="$1"

# --- Docker login ---
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
  echo "[DRY RUN] Skipping docker login"
else
  echo "$LOGIN_SECRET" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
fi

# --- Build mode ---
if $DRY_RUN; then
  PUSH_MODE=""
  ATTEST_FLAGS=()
  echo "=========================================="
  echo " DRY RUN MODE: images will NOT be pushed "
  echo "=========================================="
else
  PUSH_MODE="--push"
  ATTEST_FLAGS=(--provenance=true --sbom=true)
fi

# --- Buildx builder ---
BUILDER_NAME="mpb-$(date +%s)"
docker buildx create --driver docker-container --name "$BUILDER_NAME" --use >/dev/null
trap 'docker buildx rm -f "$BUILDER_NAME" >/dev/null 2>&1 || true' EXIT

# --- Build ---
TAG="${REPO}:latest"
echo "==> Building ${TAG}"
docker buildx build \
  --platform "$PLATFORMS" \
  "${ATTEST_FLAGS[@]}" \
  -t "$TAG" \
   --pull \
  $PUSH_MODE \
  .

# --- Done ---
echo
if $DRY_RUN; then
  echo "[DRY RUN COMPLETE] Image built but not pushed: ${TAG}"
else
  echo "[DONE] Image pushed: ${TAG}"
fi
