# 上传截图

## 前置检查

- 已生成 `fastlane/screenshots`。
- 每个 locale 的截图都必须由对应语言的 App 运行生成。
- 不要把一个语言的截图复制到另一个语言目录。
- 上传前检查每个 locale 的 iPhone 和 iPad 截图数量。

## 命令

```bash
/opt/homebrew/bin/fastlane ios uppic
```

如果 Apple 返回临时 `500`，让 Fastlane 重试，最终以 `Successfully uploaded screenshots to App Store Connect` 为完成标志。
