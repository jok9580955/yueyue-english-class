# 钥钥的英语课生产上架步骤

## 1. 状态扫描

- 检查 bundle id、版本号、build、签名团队、iPhone/iPad 支持。
- 检查 `fastlane/metadata`、`fastlane/screenshots`、隐私/支持 URL、截图模式和本地化。
- 当前状态记录在 `md/status.md`。

## 2. 凭证配置

- 默认使用本机 App Store Connect key：
  - Key ID：`JD5G4LG5XN`
  - Issuer ID：`f68594d0-23a9-480d-8f1d-6c84b40bf664`
  - Key file：`/Users/ll/Desktop/AuthKey_JD5G4LG5XN.p8`
- 不要把 `.p8` 私钥内容写入项目、文档、Git 或聊天记录。
- 如果换电脑，优先把 `.p8` 安全复制到同一路径；路径不同则用环境变量覆盖。

## 3. 图标

- 已完成：`AppIcon.appiconset` 已有 1024x1024 图标。
- 每次换图标后都要重新构建一次，确认 Xcode 接受资源目录。

## 4. 商店文案

- 文案目录：`fastlane/metadata`
- 首批 locale：
  - `zh-Hans`
  - `en-US`
- 上传前检查 Apple 字段长度限制。

## 5. 隐私和支持页面

- 生成公开的 privacy/support 页面。
- 写入每个 metadata locale：
  - `privacy_url.txt`
  - `support_url.txt`
- 上传 metadata 前，URL 不能为空。

## 6. 本地化和截图模式

- 创建并补齐 `Localizable.xcstrings`。
- 在初始化阶段读取 `UserDefaults.standard.integer(forKey: "ScreenshotMode")`。
- 不用 `ProcessInfo.arguments` 控制截图页面。
- 不在 `.onAppear` 中切换截图页面。

## 7. 生成截图

- 先做少量 locale 的视觉烟测。
- 确认截图中文字是真正本地化，不是只存在于 strings 文件。
- 再批量生成 iPhone 和 iPad 截图。

## 8. 上传

- 上传文案：确认 metadata 完整后运行 Fastlane metadata lane。
- 上传截图：确认截图数量、尺寸和语言后运行 Fastlane screenshot lane。
- 上传二进制：Release archive 后用 App Store Connect API key 上传。

## 9. 上架前检查

- App Store Connect 上 metadata 非空。
- 截图数量正确。
- 最新 build 状态为 `VALID`。
- 隐私政策、技术支持、年龄分级、价格、地区、版权、审核备注都已填写。

## 10. 提交审核

只有在明确说“提交审核”或“送审”时才执行。上传文案、截图或二进制不等于允许提交审核。
