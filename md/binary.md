# 上传二进制

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
