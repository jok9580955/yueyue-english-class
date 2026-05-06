# 注入隐私和支持 URL

当 `docs/privacy.html` 和 `docs/support.html` 已经发布到公开网页后，执行：

```bash
printf '%s\n' 'https://你的域名/privacy.html' > fastlane/metadata/zh-Hans/privacy_url.txt
printf '%s\n' 'https://你的域名/support.html' > fastlane/metadata/zh-Hans/support_url.txt
printf '%s\n' 'https://你的域名/privacy.html' > fastlane/metadata/en-US/privacy_url.txt
printf '%s\n' 'https://你的域名/support.html' > fastlane/metadata/en-US/support_url.txt
```

再运行：

```bash
/opt/homebrew/bin/fastlane ios upmeta
```
