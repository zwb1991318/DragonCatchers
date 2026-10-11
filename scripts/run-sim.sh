#!/usr/bin/env bash
# 生成工程、编译，并在 iPhone 模拟器上启动游戏。
# 用法：scripts/run-sim.sh            （默认 iPhone 18 Pro Max）
#       DEVICE="iPhone 15" scripts/run-sim.sh
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${DEVICE:-iPhone 18 Pro Max}"
BUNDLE_ID="com.zwb1991318.DragonCatchers"

# 同名模拟器可能有多个系统版本，选系统版本最新的那个
UDID="$(xcrun simctl list devices available -j | python3 -c '
import json, re, sys
name = sys.argv[1]
devices = json.load(sys.stdin)["devices"]
# 按数字比较版本号，避免 iOS-9 排在 iOS-27 后面
version = lambda rt: tuple(int(n) for n in re.findall(r"\d+", rt))
found = sorted((version(rt), d["udid"]) for rt, ds in devices.items() if "iOS" in rt for d in ds if d["name"] == name)
print(found[-1][1] if found else "")
' "$DEVICE")"
if [ -z "$UDID" ]; then
  echo "找不到模拟器：$DEVICE" >&2
  exit 1
fi

xcodegen generate --quiet
xcodebuild -project DragonCatchers.xcodeproj -scheme DragonCatchers \
  -destination "id=$UDID" -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO -quiet build

APP="build/Build/Products/Debug-iphonesimulator/DragonCatchers.app"
xcrun simctl boot "$UDID" 2>/dev/null || true
# Xcode 27 起 Simulator.app 被 DeviceHub.app 取代，两个都试一下
open -a Simulator 2>/dev/null || open -a DeviceHub 2>/dev/null || true
xcrun simctl install "$UDID" "$APP"
xcrun simctl launch "$UDID" "$BUNDLE_ID"
echo "已在 ${DEVICE}（${UDID}）上启动"
