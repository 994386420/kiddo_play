#!/bin/sh
set -eu

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 <APPLE_TEAM_ID> <BUNDLE_ID>" >&2
  exit 1
fi

if [ "${2:-}" = "" ]; then
  echo "Usage: $0 <APPLE_TEAM_ID> <BUNDLE_ID>" >&2
  echo "Example: $0 ABCD123456 com.cw.kiddo.play" >&2
  exit 1
fi

TEAM_ID="$1"
BUNDLE_ID="$2"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SIGNING_FILE="$PROJECT_ROOT/ios/Flutter/Signing.xcconfig"

cat > "$SIGNING_FILE" <<EOF
APP_BUNDLE_IDENTIFIER = $BUNDLE_ID
APP_DEVELOPMENT_TEAM = $TEAM_ID
EOF

echo "Updated $SIGNING_FILE"
