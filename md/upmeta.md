# 上传文案

## 前置检查

- `fastlane/Fastfile` 存在。
- `fastlane/metadata/zh-Hans` 和 `fastlane/metadata/en-US` 已有文案。
- 上传前补齐每个 locale 的：
  - `privacy_url.txt`
  - `support_url.txt`
- 本机默认 App Store Connect key：
  - `/Users/ll/Desktop/AuthKey_JD5G4LG5XN.p8`

## 命令

```bash
/opt/homebrew/bin/fastlane ios upmeta
```

如果是首个版本，并且 App Store Connect 需要创建审核联系人记录，可在命令前通过环境变量传入：

```bash
APP_REVIEW_FIRST_NAME="..." \
APP_REVIEW_LAST_NAME="..." \
APP_REVIEW_PHONE="..." \
APP_REVIEW_EMAIL="..." \
/opt/homebrew/bin/fastlane ios upmeta
```

不要把审核联系人或 `.p8` 私钥内容写入项目文件。

## 上传记录

2026-05-06 已使用 App Review 联系人环境变量运行 `/opt/homebrew/bin/fastlane ios upmeta`，Fastlane 成功完成。

App Store Connect API 核验结果：

- `en-US` description、keywords、promotional text、support URL 非空。
- `zh-Hans` description、keywords、promotional text、support URL 非空。
- `en-US` name、subtitle、privacy URL 非空。
- `zh-Hans` name、subtitle、privacy URL 非空。
