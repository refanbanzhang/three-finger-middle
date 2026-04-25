#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="ThreeFingerMiddle"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
DMG_ROOT="$BUILD_DIR/dmg-root"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
MODULE_CACHE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/three-finger-middle-module-cache.XXXXXX")"

trap 'rm -rf "$MODULE_CACHE_DIR" "$DMG_ROOT"' EXIT

SWIFT_MODULE_CACHE_DIR="$MODULE_CACHE_DIR" "$ROOT_DIR/build.sh" >/dev/null

rm -rf "$DMG_ROOT" "$DMG_PATH"
mkdir -p "$DMG_ROOT"

cp -R "$APP_DIR" "$DMG_ROOT/"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH" >/dev/null

echo "$DMG_PATH"
