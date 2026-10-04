#!/usr/bin/env bash
# Phase 7 N6 — production build with a checked environment.
#
#   tool/build_release.sh .env.production android   # → build/app/outputs/bundle/release/app-release.aab
#   tool/build_release.sh .env.production apk       # → build/app/outputs/flutter-apk/app-release.apk
#   tool/build_release.sh .env.production ios       # → build/ios/ipa (needs Xcode signing set up)
#
# The app reads bsmart/.env (bundled as an asset; Gradle and AppDelegate read MAPS_API_KEY from it
# too), so the script swaps the given env file in for the build and always restores your dev .env.
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE="${1:?usage: tool/build_release.sh <env file> <android|apk|ios>}"
TARGET="${2:?usage: tool/build_release.sh <env file> <android|apk|ios>}"
[ -f "$ENV_FILE" ] || { echo "✗ $ENV_FILE not found" >&2; exit 1; }

value() { grep -E "^$1=" "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'"; }
fail() { echo "✗ $*" >&2; exit 1; }

API=$(value API_BASE_URL)
MAPS=$(value MAPS_API_KEY)
SOCKET=$(value SOCKET_URL || true)
[[ "$API" == https://* ]] || fail "API_BASE_URL must be https:// (release builds block cleartext http): '$API'"
[[ "$API" =~ (localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.) ]] && fail "API_BASE_URL points at a dev machine: '$API'"
[ -n "$SOCKET" ] && [[ "$SOCKET" != https://* ]] && fail "SOCKET_URL must be https:// when set: '$SOCKET'"
[ -n "$MAPS" ] || fail "MAPS_API_KEY is empty (maps would be blank)"
if [ -f .env ] && [ "$MAPS" = "$(grep -E '^MAPS_API_KEY=' .env | cut -d= -f2-)" ] && [ "$ENV_FILE" != ".env" ]; then
  echo "⚠ MAPS_API_KEY is the same as in your dev .env — make sure that key is restricted to the app (see RELEASE_CHECKLIST.md)"
fi
if [ "$TARGET" != ios ] && [ ! -f android/key.properties ]; then
  echo "⚠ android/key.properties missing — this build will be signed with the DEBUG key (Google Play rejects it)"
fi

BACKUP=""
if [ -f .env ] && [ "$ENV_FILE" != ".env" ]; then
  BACKUP=$(mktemp)
  cp .env "$BACKUP"
fi
restore() { if [ -n "$BACKUP" ]; then mv "$BACKUP" .env; echo "↺ dev .env restored"; fi; }
trap restore EXIT
[ "$ENV_FILE" != ".env" ] && cp "$ENV_FILE" .env

echo "→ building $TARGET against $API"
case "$TARGET" in
  android) flutter build appbundle --release ;;
  apk) flutter build apk --release ;;
  ios) flutter build ipa --release ;;
  *) fail "unknown target '$TARGET' (android|apk|ios)" ;;
esac
