#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="ThreeFingerMiddle"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
MODULES_DIR="$ROOT_DIR/Modules"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR"

swiftc \
  -O \
  -module-cache-path "$BUILD_DIR/module-cache" \
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
codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "$APP_DIR"
