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
- GitHub 仓库已创建：`https://github.com/jok9580955/yueyue-english-class`
- GitHub Pages 已启用：`https://jok9580955.github.io/yueyue-english-class/`
- 隐私和支持 URL 已写入 metadata：
  - `privacy_url.txt`
  - `support_url.txt`
- Metadata 已上传到 App Store Connect，并通过 API 核验：
  - App ID：`6766852992`
  - Bundle ID：`com.liuqingyue.EnglishSprout`
  - Version：`1.0`
  - State：`PREPARE_FOR_SUBMISSION`
  - `en-US` 版本文案字段非空
  - `zh-Hans` 版本文案字段非空
  - `en-US` 和 `zh-Hans` 的隐私 URL 非空
- 截图模式已接入：`ScreenshotMode` 在 `ContentView.init()` 读取 `UserDefaults`。
- `zh-Hans` App Store 截图已生成并上传到 App Store Connect：
  - iPhone：5 张，`APP_IPHONE_67`
  - iPad：5 张，`APP_IPAD_PRO_3GEN_129`
- 截图在线数量已通过 App Store Connect API 核验。

## 当前产品内容

- 面向 2-6 岁宝宝的英语启蒙。
- 包含动物、食物、家庭、颜色、玩具、自然、身体、动作 8 个主题。
- 包含 24 张统一风格儿童词卡图片。
- 包含点读、故事、气泡点点、影子配对、节奏拍词、字母小火车、小测、学习记录、家长中心。
- 支持修改宝宝名字，例如改成“安安”后显示“安安的英语课”。

## 待完成

- 补齐 `Localizable.xcstrings`，为后续多语言截图做准备。
- 为 `en-US` 生成独立英文截图，或保留当前仅中文截图的发布策略。
- 归档并上传二进制包。
- 在 App Store Connect 完成年龄分级、隐私问卷、价格、可用地区、版权和审核信息。

## 下一步建议

下一步可以归档并上传二进制包。若要补英文截图，需要先补齐 `Localizable.xcstrings`，再按英文环境重新生成截图。
