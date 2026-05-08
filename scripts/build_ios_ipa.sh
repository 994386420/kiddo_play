#!/bin/sh
set -eu

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SIGNING_FILE="$PROJECT_ROOT/ios/Flutter/Signing.xcconfig"
EXPORT_METHOD="${1:-app-store}"

if [ ! -f "$SIGNING_FILE" ]; then
  echo "Missing $SIGNING_FILE. Run scripts/configure_ios_signing.sh <APPLE_TEAM_ID> <BUNDLE_ID> first." >&2
  exit 1
fi

TEAM_ID="$(awk -F'= ' '/APP_DEVELOPMENT_TEAM/ {print $2}' "$SIGNING_FILE" | tr -d '[:space:]')"
BUNDLE_ID="$(awk -F'= ' '/APP_BUNDLE_IDENTIFIER/ {print $2}' "$SIGNING_FILE" | tr -d '[:space:]')"

if [ -z "$TEAM_ID" ]; then
  echo "APP_DEVELOPMENT_TEAM is empty in $SIGNING_FILE." >&2
  echo "Run scripts/configure_ios_signing.sh <APPLE_TEAM_ID> <BUNDLE_ID> first." >&2
  exit 1
fi

if [ -z "$BUNDLE_ID" ]; then
  echo "APP_BUNDLE_IDENTIFIER is empty in $SIGNING_FILE." >&2
  echo "Run scripts/configure_ios_signing.sh <APPLE_TEAM_ID> <BUNDLE_ID> first." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
flutter build ipa --release --export-method="$EXPORT_METHOD"
