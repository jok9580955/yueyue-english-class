# 隐私和支持页面

已生成本地页面：

- `docs/privacy.html`
- `docs/support.html`

上传 App Store metadata 前，需要把这两个页面发布到公开 URL，例如 GitHub Pages。

发布后，把最终 URL 写入每个 locale：

- `fastlane/metadata/zh-Hans/privacy_url.txt`
- `fastlane/metadata/zh-Hans/support_url.txt`
- `fastlane/metadata/en-US/privacy_url.txt`
- `fastlane/metadata/en-US/support_url.txt`

不要在不知道公开域名时写假 URL。
