#!/usr/bin/env bash
set -euo pipefail

# Scripts/create_dmg.sh — Đóng gói macOS App thành file .dmg có kéo thả Applications

APP_PATH="${1:-AI Usage Dashboard.app}"
OUTPUT_DMG="${2:-AI-Usage-Dashboard-macOS-Universal.dmg}"
VOLUME_NAME="${3:-AI Usage Dashboard}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: Không tìm thấy ứng dụng tại $APP_PATH" >&2
  exit 1
fi

echo "==> Chuẩn bị thư mục staging DMG..."
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Tạo file DMG: $OUTPUT_DMG..."
rm -f "$OUTPUT_DMG"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$OUTPUT_DMG"

echo "==> Đóng gói DMG thành công: $OUTPUT_DMG"
