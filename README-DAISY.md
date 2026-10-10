# Daisy WLOC · 个人部署说明

本仓库为 [cyberhandyman/wloc-spoofer-en](https://github.com/cyberhandyman/wloc-spoofer-en) 的个人 Fork；底层项目来自 Yu9191/wloc，保留上游源码与署名。仅个人测试使用，**仓库已公开但不保存个人选点坐标**（选点页的持久化值保存在 iPhone Shadowrocket 端）。

## 已配置

- 个人 Shadowrocket 模块：`https://raw.githubusercontent.com/Daisyhu668/wloc-spoofer-en/refs/heads/main/modules/wloc.module`
- 脚本已指向本仓库：`dist/wloc.js`、`dist/wloc-settings.js`，不再引用上游 Raw 地址。
- Cloudflare Worker 名：`daisy-wloc-picker`（在 `worker/wrangler.jsonc` 中配置）。**Worker 还须在自己的 Cloudflare 账号部署；GitHub Fork 不等于上线。**
- 其余 Worker 选点页面和地图坐标解析 API 沿用原项目。

## 让 Muse 在 Cloudflare 部署

请使用本仓库 `worker/` 目录作为部署根目录，执行：

```bash
cd worker
npm install
npx wrangler login
npm run deploy
```

登录/授权必须由账号本人进行。部署后记录真实 URL（形如 `https://daisy-wloc-picker.<account-subdomain>.workers.dev`），请勿凭猜测给出地址；运行 `bash scripts/check-deployment.sh <real-worker-url>` 验证。

## iOS 快捷指令

请参见 [docs/DAISY-SHORTCUTS.md](docs/DAISY-SHORTCUTS.md)。原项目「设置位置」快捷指令可能调用上游 `/api/parse`，需要把其域名替换成部署后自己的 Worker 域名；不要修改设备写入接口 `https://gs-loc.apple.com/wloc-settings/save`。

## 仍然需要排查的故障

网页能成功保存坐标，只验证 `WLOC Settings` 写入，不代表 `Apple WLOC` 响应脚本命中。iOS 26+ 有缓存问题；系统也可能优先使用真实 GPS。详见 [docs/DAISY-DIAGNOSTICS.md](docs/DAISY-DIAGNOSTICS.md)。
