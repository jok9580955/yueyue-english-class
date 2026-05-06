#!/usr/bin/env bash
set -euo pipefail

PROJECT="EnglishSprout.xcodeproj"
SCHEME="EnglishSprout"
BUNDLE_ID="com.liuqingyue.EnglishSprout"
OUTPUT_DIR="$(pwd)/fastlane/screenshots/zh-Hans"

devices=(
  "iPhone 17 Pro Max"
  "iPad Pro 13-inch (M5)"
)

mkdir -p "$OUTPUT_DIR"

app_path_for_destination() {
  local destination="$1"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$destination" -showBuildSettings \
    | awk -F' = ' '
      /TARGET_BUILD_DIR = / { target=$2 }
      /WRAPPER_NAME = / { wrapper=$2 }
      END { print target "/" wrapper }
    '
}

boot_device() {
  local device_name="$1"
  local udid
  udid="$(xcrun simctl list devices available -j | ruby -rjson -e 'name = ARGV.fetch(0); data = JSON.parse(STDIN.read); data.fetch("devices").each_value do |devices|; found = devices.find { |device| device["name"] == name && device["isAvailable"] }; if found; puts found.fetch("udid"); exit; end; end' "$device_name")"
  if [[ -z "$udid" ]]; then
    echo "Missing simulator: $device_name" >&2
    exit 1
  fi

  xcrun simctl boot "$udid" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$udid" -b >&2
  echo "$udid"
}

capture_device() {
  local device_name="$1"
  local destination="platform=iOS Simulator,name=${device_name},OS=26.4"
  local device_slug
  local udid
  local app_path

  device_slug="$(echo "$device_name" | tr '[:upper:] ()' '[:lower:]---' | tr -s '-' | sed 's/-$//')"
  echo "Building for $device_name"
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "$destination" build
  app_path="$(app_path_for_destination "$destination")"

  udid="$(boot_device "$device_name")"
  xcrun simctl uninstall "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl install "$udid" "$app_path"
  xcrun simctl spawn "$udid" defaults write NSGlobalDomain AppleLanguages -array zh-Hans
  xcrun simctl spawn "$udid" defaults write NSGlobalDomain AppleLocale zh_CN
  xcrun simctl spawn "$udid" defaults write "$BUNDLE_ID" childName "钥钥"

  for mode in 1 2 3 4 5; do
    xcrun simctl terminate "$udid" "$BUNDLE_ID" >/dev/null 2>&1 || true
    xcrun simctl spawn "$udid" defaults write "$BUNDLE_ID" ScreenshotMode -int "$mode"
    xcrun simctl launch "$udid" "$BUNDLE_ID" >/dev/null
    sleep 2
    xcrun simctl io "$udid" screenshot "$OUTPUT_DIR/${mode}_${device_slug}.png"
  done
}

for device in "${devices[@]}"; do
  capture_device "$device"
done

find "$OUTPUT_DIR" -type f -name '*.png' | sort
