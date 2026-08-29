#!/usr/bin/env bash

set -eu

readonly VERSION="v1.0.1"
readonly BASE_URL="https://raw.githubusercontent.com/hoperswz/agent-dev-workflow/${VERSION}"
readonly LANGUAGE="${1:-zh}"
readonly TARGET_NAME="AGENTS.md"

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

printf 'Agent Dev Workflow %s\n\n' "$VERSION"

command -v git >/dev/null 2>&1 || fail "Git is required but was not found."
command -v curl >/dev/null 2>&1 || fail "curl is required but was not found."

GIT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || \
  fail "current directory is not inside a Git repository."

if [ "$(cd "$GIT_ROOT" && pwd -P)" != "$(pwd -P)" ]; then
  fail "run this command from the root of your Git repository."
fi

readonly TARGET="$(pwd -P)/${TARGET_NAME}"

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  fail "AGENTS.md already exists. Existing file was not modified."
fi

case "$LANGUAGE" in
  zh)
    SOURCE="AGENTS.md"
    ;;
  en)
    SOURCE="AGENTS.en.md"
    ;;
  *)
    fail "unsupported language '${LANGUAGE}'. Supported languages: zh, en."
    ;;
esac

readonly SOURCE
readonly URL="${BASE_URL}/${SOURCE}"
TEMP_FILE="$(mktemp "${TARGET}.tmp.XXXXXX")" || \
  fail "could not create a temporary file in the repository root."

cleanup() {
  if [ -n "${TEMP_FILE:-}" ] && [ -e "$TEMP_FILE" ]; then
    rm -f -- "$TEMP_FILE"
  fi
}

trap cleanup EXIT HUP INT TERM

printf 'Installing %s as AGENTS.md...\n' "$SOURCE"

curl -fsSL "$URL" -o "$TEMP_FILE" || fail "download failed. No target file was created."
[ -s "$TEMP_FILE" ] || fail "downloaded file is empty. No target file was created."
chmod 0644 "$TEMP_FILE"

if ! ln "$TEMP_FILE" "$TARGET" 2>/dev/null; then
  fail "could not create AGENTS.md. The target may have been created by another process."
fi

rm -f -- "$TEMP_FILE"
TEMP_FILE=""
trap - EXIT HUP INT TERM

printf '\n✓ AGENTS.md installed successfully.\n'
printf '  Version: %s\n' "$VERSION"
printf '  Language: %s\n' "$LANGUAGE"
printf '  Path: %s\n' "$TARGET"
