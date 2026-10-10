# Daisy WLOC · 快捷指令配置

目前仅提供原开发者实际发布的 iCloud 指令链接，**没有伪造新的 iCloud 安装链接**：

- [wloc Set Location](https://www.icloud.com/shortcuts/182f3a014597468eb1b15b99261cdf22)
- [wloc Clear & Restore Location](https://www.icloud.com/shortcuts/0352d53ed79849d382f50e9adf050662)

## 设置位置

1. iPhone「快捷指令」中导入 `wloc Set Location`，保留一个个人副本，可命名为「Daisy 设置位置」。
2. 在编辑器中查找原公共地址 `wloc-spoofer.cyberhandyman.workers.dev`，将其替换为 **Cloudflare 部署完成后显示的真实域名**（特别是 `/api/parse`）。不要修改路径、`format=json`、参数解析逻辑。
3. **保留** `https://gs-loc.apple.com/wloc-settings/save`；这是 Shadowrocket 的本机写入钩子，不是 Cloudflare Worker 接口。
4. 确保指令在共享表单显示，接受 URL、文本。打开苹果地图，长按选点 → 分享 → 选择「Daisy 设置位置」。
5. 首次提示网络授权时核实域名，再允许访问。

## 恢复位置

导入 `wloc Clear & Restore Location` 为个人副本，核实是否引用上游 Worker；若有仅替换 Worker 主机名。保持清除/透传逻辑，不要错误地写入一个固定位置冒充恢复。

## 独立验证三层

- Worker 返回正确 `lat/lon`：只证明分享链接解析成功。
- 选点页回读到新坐标：证明设备端保存动作成功。
- Shadowrocket 日志显示 `Apple WLOC` 对 `/clls/wloc` 有响应命中且发生修改，随后地图位置变化：才是实际生效。GPS 优先和 iOS 缓存仍可能阻碍。

在没有用户 iPhone 访问权限时，无法直接安装快捷指令或生成真实的私人 iCloud 共享链接。
