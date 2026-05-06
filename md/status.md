# 钥钥的英语课上架状态

更新时间：2026-05-06

## 已完成

- SwiftUI iPhone / iPad 通用工程已创建。
- Bundle ID：`com.liuqingyue.EnglishSprout`
- App 显示名：`钥钥的英语课`
- 版本号：`1.0`
- Build：`1`
- 开发团队：`QFZ87PFLK4`
- 设备支持：iPhone + iPad
- App Icon 已接入：`EnglishSprout/Resources/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png`
- iPhone 17 Pro Max 模拟器构建通过。
- iPad Pro 13-inch 模拟器构建通过。
- 本机已发现 App Store Connect API key 文件：
  - `/Users/ll/Desktop/AuthKey_JD5G4LG5XN.p8`
  - `/Users/ll/Desktop/AuthKey_8SW8Y424Z3.p8`
- Fastlane 上传骨架已创建：
  - `fastlane/Appfile`
  - `fastlane/Deliverfile`
  - `fastlane/Fastfile`
- 二进制上传导出配置已创建：`scripts/export_options_app_store.plist`
- 首版 App Store 文案已创建：
  - `fastlane/metadata/zh-Hans`
  - `fastlane/metadata/en-US`
- 隐私政策和技术支持静态页已生成：
  - `docs/privacy.html`
  - `docs/support.html`

## 当前产品内容

- 面向 2-6 岁宝宝的英语启蒙。
- 包含动物、食物、家庭、颜色、玩具、自然、身体、动作 8 个主题。
- 包含 24 张统一风格儿童词卡图片。
- 包含点读、故事、气泡点点、影子配对、节奏拍词、字母小火车、小测、学习记录、家长中心。
- 支持修改宝宝名字，例如改成“安安”后显示“安安的英语课”。

## 待完成

- 补齐 `Localizable.xcstrings`，为后续多语言截图做准备。
- 接入 `ScreenshotMode`，让截图脚本可以稳定打开指定页面。
- 发布公开隐私政策和技术支持 URL。
- 将隐私和支持 URL 写入 `fastlane/metadata/<locale>/privacy_url.txt` 和 `support_url.txt`。
- 生成 App Store 截图。
- 配置并验证 Fastlane 上传 lanes。
- 上传 metadata。
- 上传 screenshots。
- 归档并上传二进制包。
- 在 App Store Connect 完成年龄分级、隐私问卷、价格、可用地区、版权和审核信息。

## 下一步建议

先做 `Localizable.xcstrings` 和 `ScreenshotMode`，再生成截图。商店文案可以先上传，但正式截图前必须确认截图可见文字已经本地化。
