#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="${APP_NAME:-OpenAVDClient}"
ARCH="${ARCH:-arm64}"
NOTARY_PROFILE="${NOTARY_PROFILE:-OpenAVDClientNotaryProfile}"
VERSION="$(node -p "require('./package.json').version")"
OUTPUT_DIR="$ROOT_DIR/build/dist"
APP_PATH="$OUTPUT_DIR/mac-$ARCH/$APP_NAME.app"
APP_ZIP="$OUTPUT_DIR/$APP_NAME-$VERSION-$ARCH.app.zip"
DMG_STAGE="$OUTPUT_DIR/dmg-stage"
DMG_PATH="$OUTPUT_DIR/$APP_NAME-$VERSION-$ARCH.dmg"

log() {
  printf '▶ %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "macOS is required for signing and notarization"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

developer_id_from_keychain() {
  security find-identity -v -p codesigning | awk -F '"' '/Developer ID Application/ { print $2; exit }'
}

resolve_codesign_id() {
  local identity="${CODESIGN_ID:-${CSC_NAME:-}}"
  if [[ -z "$identity" ]]; then
    identity="$(developer_id_from_keychain)"
  fi
  [[ -n "$identity" ]] || die "no Developer ID Application signing identity found"
  printf '%s' "$identity"
}

derive_team_id() {
  local identity="$1"
  if [[ -n "${TEAM_ID:-}" ]]; then
    printf '%s' "$TEAM_ID"
    return
  fi
  if [[ "$identity" =~ \(([A-Z0-9]{10})\)$ ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
    return
  fi
  die "TEAM_ID is required when it cannot be derived from CODESIGN_ID"
}

electron_builder_identity_name() {
  local identity="$1"
  printf '%s' "${identity#Developer ID Application: }"
}

check_tools() {
  require_macos
  require_cmd bun
  require_cmd node
  require_cmd security
  require_cmd codesign
  require_cmd ditto
  require_cmd hdiutil
  require_cmd spctl
  require_cmd xcrun
  xcrun --find notarytool >/dev/null
  xcrun --find stapler >/dev/null
  log "macOS signing tools are available"
  log "Developer ID identity: $(resolve_codesign_id)"
  if xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    log "notarytool profile '$NOTARY_PROFILE' is available"
  else
    log "notarytool profile '$NOTARY_PROFILE' is not available yet"
  fi
}

store_credentials() {
  require_macos
  require_cmd xcrun

  local identity
  identity="$(resolve_codesign_id)"
  local team_id
  team_id="$(derive_team_id "$identity")"

  [[ -n "${APPLE_ID:-}" ]] || die "APPLE_ID is required"
  [[ -n "${APP_PASSWORD:-}" ]] || die "APP_PASSWORD is required"

  log "Storing notarytool credentials in profile '$NOTARY_PROFILE'"
  xcrun notarytool store-credentials "$NOTARY_PROFILE" \
    --apple-id "$APPLE_ID" \
    --team-id "$team_id" \
    --password "$APP_PASSWORD"
}

ensure_notary_profile() {
  if xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    return
  fi

  if [[ -n "${APPLE_ID:-}" && -n "${APP_PASSWORD:-}" ]]; then
    store_credentials
    return
  fi

  die "notarytool profile '$NOTARY_PROFILE' is unavailable; run 'just macos-store-notary-credentials' with APPLE_ID and APP_PASSWORD"
}

build_signed_app() {
  local identity="$1"
  local electron_builder_identity
  electron_builder_identity="$(electron_builder_identity_name "$identity")"
  log "Installing dependencies with Bun"
  bun install --frozen-lockfile

  log "Building signed macOS $ARCH app with Developer ID identity"
  rm -rf "$OUTPUT_DIR"
  CSC_NAME="$electron_builder_identity" bun run build:mac:dir

  [[ -d "$APP_PATH" ]] || die "expected app bundle was not created: $APP_PATH"
  codesign --verify --deep --strict --verbose=2 "$APP_PATH"
}

notarize_and_staple_app() {
  log "Creating notarization zip for $APP_NAME.app"
  rm -f "$APP_ZIP"
  ditto -c -k --keepParent "$APP_PATH" "$APP_ZIP"

  log "Submitting app bundle for notarization"
  xcrun notarytool submit "$APP_ZIP" --keychain-profile "$NOTARY_PROFILE" --wait

  log "Stapling app notarization ticket"
  xcrun stapler staple "$APP_PATH"
  xcrun stapler validate "$APP_PATH"
}

create_signed_dmg() {
  local identity="$1"
  log "Creating signed DMG"
  rm -rf "$DMG_STAGE" "$DMG_PATH"
  mkdir -p "$DMG_STAGE"
  cp -R "$APP_PATH" "$DMG_STAGE/"
  ln -s /Applications "$DMG_STAGE/Applications"

  hdiutil create \
    -volname "$APP_NAME $VERSION" \
    -srcfolder "$DMG_STAGE" \
    -format UDZO \
    -ov \
    "$DMG_PATH" >/dev/null

  codesign --force --timestamp --sign "$identity" "$DMG_PATH"
  codesign --verify --verbose=2 "$DMG_PATH"
}

notarize_and_staple_dmg() {
  log "Submitting DMG for notarization"
  xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

  log "Stapling DMG notarization ticket"
  xcrun stapler staple "$DMG_PATH"
  xcrun stapler validate "$DMG_PATH"
}

assess_outputs() {
  log "Assessing notarized app with Gatekeeper"
  spctl --assess --type execute -vvvv "$APP_PATH"

  log "Assessing notarized DMG with Gatekeeper"
  spctl --assess --type open --context context:primary-signature -vvvv "$DMG_PATH"
}

release() {
  check_tools
  ensure_notary_profile

  local identity
  identity="$(resolve_codesign_id)"

  build_signed_app "$identity"
  notarize_and_staple_app
  create_signed_dmg "$identity"
  notarize_and_staple_dmg
  assess_outputs

  log "Release complete: $DMG_PATH"
}

case "${1:-release}" in
  check)
    check_tools
    ;;
  store-credentials)
    store_credentials
    ;;
  release)
    release
    ;;
  *)
    die "usage: $0 [check|store-credentials|release]"
    ;;
esac
