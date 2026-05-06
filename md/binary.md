# 上传二进制

## 上传结果

- 2026-05-06 已上传 Version `1.0` / Build `2`。
- App Store Connect 已显示该构建，`processing_state` 为 `VALID`。
- App Store Connect 版本 `1.0` 已选择 Build `2`。
- Build `1` 已经用过；本次只递增 `CURRENT_PROJECT_VERSION` 到 `2`，`MARKETING_VERSION` 仍为 `1.0`。

## 归档

```bash
xcodebuild -project EnglishSprout.xcodeproj \
  -scheme EnglishSprout \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /private/tmp/EnglishSprout.xcarchive \
  -allowProvisioningUpdates \
  archive
```

## 上传

```bash
xcodebuild -exportArchive \
  -archivePath /private/tmp/EnglishSprout.xcarchive \
  -exportPath /private/tmp/EnglishSprout-export \
  -exportOptionsPlist scripts/export_options_app_store.plist \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$APP_STORE_CONNECT_API_KEY_KEYFILEPATH" \
  -authenticationKeyID "$APP_STORE_CONNECT_API_KEY_ID" \
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_API_KEY_ISSUER_ID"
```

默认 key 可使用：

```bash
export APP_STORE_CONNECT_API_KEY_ID="JD5G4LG5XN"
export APP_STORE_CONNECT_API_KEY_ISSUER_ID="f68594d0-23a9-480d-8f1d-6c84b40bf664"
export APP_STORE_CONNECT_API_KEY_KEYFILEPATH="/Users/ll/Desktop/AuthKey_JD5G4LG5XN.p8"
```

如果 App Store Connect 提示 build number 已用过，只递增 `CURRENT_PROJECT_VERSION`，不要随便改 `MARKETING_VERSION`。
