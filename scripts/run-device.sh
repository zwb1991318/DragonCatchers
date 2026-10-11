#!/usr/bin/env bash
# 生成工程、编译，并安装到用数据线连接的 iPhone 上启动游戏。
# 用法：scripts/run-device.sh                 （自动选第一台连接的真机）
#       DEVICE_ID=<UDID> scripts/run-device.sh
# 免费 Apple ID 签名的 App 7 天后失效，重新运行本脚本即可。
set -euo pipefail
cd "$(dirname "$0")/.."

BUNDLE_ID="com.zwb1991318.DragonCatchers"

if [ -z "${DEVICE_ID:-}" ]; then
  DEVICE_ID="$(xcrun devicectl list devices 2>/dev/null | awk '/physical/ && /connected|available/ { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9A-F]{8}-[0-9A-F]{16}$/) { print $i; exit } }')"
fi
if [ -z "$DEVICE_ID" ]; then
  echo "找不到已连接的 iPhone：请用数据线连接手机并解锁" >&2
  exit 1
fi

xcodegen generate --quiet
xcodebuild -project DragonCatchers.xcodeproj -scheme DragonCatchers \
  -destination "id=${DEVICE_ID}" -derivedDataPath build \
  -allowProvisioningUpdates -quiet build

APP="build/Build/Products/Debug-iphoneos/DragonCatchers.app"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"
xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID"
echo "已在真机（${DEVICE_ID}）上启动"
