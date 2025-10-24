#!/usr/bin/env bash
set -euo pipefail

# Alpine versions to build
VERSIONS=(3.19 3.20 3.21 3.22)
JAVA_VERSIONS=(17 21 25)
JAVA_TYPES=(-jre-headless -jdk)

# Supported platforms
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
  echo "usage: $0 [-n] <repo> [buildnum_dir]"
  echo "example: $0 -n your_repository/alpine-multi-base .buildnums"
  echo "  -n : dry run (build only, no push or increment)"
  exit 1
fi

IMAGE_REPO="$1"
BUILDNUM_DIR="${2:-.buildnums}"

# Login from environment
: "${DOCKERHUB_USERNAME:?Set DOCKERHUB_USERNAME!}"
if [[ -n "${DOCKERHUB_TOKEN:-}" ]]; then
  LOGIN_SECRET="$DOCKERHUB_TOKEN"
elif [[ -n "${DOCKERHUB_PASSWORD:-}" ]]; then
  LOGIN_SECRET="$DOCKERHUB_PASSWORD"
else
  echo "Error: Set your DOCKERHUB_TOKEN or DOCKERHUB_PASSWORD"
  exit 2
fi

# If dry run, skip login
if $DRY_RUN; then
  echo "[DRY RUN] Login skipped (simulating)"
else
  echo "$LOGIN_SECRET" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
fi

# Select push or load mode
if $DRY_RUN; then
  PUSH_MODE=""
else
  PUSH_MODE="--push"
fi

# Manage build numbers
mkdir -p "$BUILDNUM_DIR"

buildnum_file_for() {
  local v="$1"
  echo "${BUILDNUM_DIR}/.buildnum-${v}"
}

read_buildnum() {
  local file; file="$(buildnum_file_for "$1")"
  if [[ -f "$file" ]] && grep -Eq '^[0-9]+$' "$file"; then
    cat "$file"
  else
    echo 0
  fi
}

write_buildnum() {
  local v="$1" num="$2"
  local file; file="$(buildnum_file_for "$v")"
  echo "$num" > "$file"
}

# Determine highest version for the :latest tag
LATEST_VERSION="$(printf '%s\n' "${VERSIONS[@]}" | sort -V | tail -n1)"

# Dry-run banner
if $DRY_RUN; then
  echo "=========================================="
  echo " DRY RUN MODE: images will NOT be pushed "
  echo "=========================================="
fi

# Build loop
for ALPINE_VERSION in "${VERSIONS[@]}"; do
  CURRENT_NUM="$(read_buildnum "$ALPINE_VERSION")"
  NEXT_NUM=$((CURRENT_NUM + 1))

  TAG_BASE="${IMAGE_REPO}:${ALPINE_VERSION}"
  TAG_SEQ="${IMAGE_REPO}:${ALPINE_VERSION}.${NEXT_NUM}"

  TAGS=(-t "$TAG_BASE" -t "$TAG_SEQ")
  if [[ "$ALPINE_VERSION" == "$LATEST_VERSION" ]]; then
    TAGS+=(-t "${IMAGE_REPO}:latest")
  fi

  echo "==> Building ${ALPINE_VERSION} (tags: ${TAGS[*]//-t /})"

  docker buildx build \
    --platform "$PLATFORMS" \
    --provenance=true \
    --sbom=true \
    "${TAGS[@]}" \
    --build-arg "ALPINE_VERSION=${ALPINE_VERSION}" \
    --pull \
    $PUSH_MODE \
    .

  if $DRY_RUN; then
    echo "[DRY RUN] Skipped buildnum increment for ${ALPINE_VERSION}"
  else
    write_buildnum "$ALPINE_VERSION" "$NEXT_NUM"
  fi
done

# Final summary
echo
if $DRY_RUN; then
  echo "[DRY RUN COMPLETE] No build numbers were updated."
else
  echo "Ready. Build numbers are:"
  for v in "${VERSIONS[@]}"; do
    echo "  ${v}: $(read_buildnum "$v")"
  done
fi
