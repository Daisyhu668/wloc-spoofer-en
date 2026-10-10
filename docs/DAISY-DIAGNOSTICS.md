# Daisy WLOC · 定位未变化时的故障诊断

目前已知：Safari 在线选点显示保存成功，但苹果地图定位未变化。

1. Shadowrocket 停用旧的 WLOC 模块，避免旧脚本/新脚本同命中；启用本仓库的 `modules/wloc.module`。
2. 确认启用 HTTPS 解密并完全信任 CA 证书，解密主机包括 `gs-loc.apple.com`、`gs-loc-cn.apple.com`。
3. 在选点页保存后**刷新查询已保存坐标**，排除网页只是单次提示成功。
4. 使用 Shadowrocket 请求日志和脚本日志区分 `WLOC Settings`（写入）与 `Apple WLOC`（拦截 `/clls/wloc` 响应）。没有后者日志，首先查系统有没有发起 WLOC 请求、是否走 VPN、解密是否命中。
5. 若确实有已修改响应，但地图不变，则按上游说明重启 iPhone 清理 iOS 26+ `locationd` 缓存，开启 VPN 后测试；GPS 硬件可能仍占优。
6. 关闭模块并按原仓库清除指令复原时，iOS 26+ 可能仍须重启。

说明：Cloudflare Worker 只负责选点页面和 `/api/parse`，自部署并不能改变 iOS 系统是否发出 WLOC 请求或采纳 Wi-Fi/基站坐标。不要把 Worker 部署成功写成定位已修复。

只记录域名、HTTP 状态码、脱敏脚本日志和运行结果；不要在公开 Issue 中上传个人坐标历史、账号密码或 API Token。
