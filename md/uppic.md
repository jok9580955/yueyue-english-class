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

## 上传记录

2026-05-06 已生成并上传 `zh-Hans` 截图：

- iPhone 17 Pro Max：5 张，尺寸 `1320x2868`
- iPad Pro 13-inch (M5)：5 张，尺寸 `2064x2752`

Fastlane 已返回：

- `Successfully uploaded all screenshots`
- `Successfully uploaded screenshots to App Store Connect`

App Store Connect API 核验结果：

- `APP_IPHONE_67`: 5
- `APP_IPAD_PRO_3GEN_129`: 5

当前仅上传中文截图。`en-US` metadata 已存在但没有英文截图，这是当前版本的已知警告，不影响中文截图上传结果。
