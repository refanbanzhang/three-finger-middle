#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="ThreeFingerMiddle"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
MODULES_DIR="$ROOT_DIR/Modules"
MODULE_CACHE_DIR="${SWIFT_MODULE_CACHE_DIR:-$BUILD_DIR/module-cache}"

python3 "$ROOT_DIR/scripts/generate_icons.py"

rm -rf "$APP_DIR"
rm -rf "$MODULE_CACHE_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

swiftc \
  -O \
  -module-cache-path "$MODULE_CACHE_DIR" \
  -I "$MODULES_DIR" \
  -F /System/Library/PrivateFrameworks \
  -framework AppKit \
  -framework ApplicationServices \
  -framework CoreGraphics \
  -framework IOKit \
  -framework MultitouchSupport \
  "$ROOT_DIR/Sources/main.swift" \
  -o "$MACOS_DIR/$APP_NAME"

cp "$ROOT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$ROOT_DIR/Resources/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
cp "$ROOT_DIR/Resources/MenuBarIcon/menu-bar-full-template-master.png" "$RESOURCES_DIR/menu-bar-full-template-master.png"
codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "$APP_DIR"
