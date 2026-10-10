# Muse 执行任务：Daisy WLOC Cloudflare 上线与快捷指令

**请直接执行任务，不要再次 Fork 或新建 GitHub 仓库，也不要使用 Google Drive 旧版 ZIP 内的 `wloc-private` 地址。**

## 已由 ChatGPT 完成（2026-10-10）

- 仓库：**https://github.com/Daisyhu668/wloc-spoofer-en**（Public，Owner Daisyhu668，main 分支）
- 个性化代码已提交，首个自定义 Commit：`8b1629ce90808bb7316da2d35a718c727f575a0a`。
- Shadowrocket 模块：`https://raw.githubusercontent.com/Daisyhu668/wloc-spoofer-en/refs/heads/main/modules/wloc.module`
- 模块引用的 `dist/wloc.js` 与 `dist/wloc-settings.js` 已在本人仓库，GitHub 连接确认可读取。
- `worker/wrangler.jsonc` 已设 Worker 名：`daisy-wloc-picker`。
- 查看 `README-DAISY.md`、`docs/DAISY-SHORTCUTS.md`、`docs/DAISY-DIAGNOSTICS.md`，不要替换成旧网盘 ZIP 内容。

## 你负责 Cloudflare 实际部署

1. 在用户授权的 Cloudflare 账号内登录（必要时请用户完成浏览器授权；**不要要求用户发送密码、私钥或 API Token**）。
2. 直接使用此仓库源码，部署根目录为 `worker/`；不可只部署根目录下的 `modules/`。
3. Wrangler 推荐命令：
   ```bash
   git clone https://github.com/Daisyhu668/wloc-spoofer-en.git
   cd wloc-spoofer-en/worker
   npm install
   npx wrangler login
   npm run deploy
   ```
   若在 Cloudflare 控制台连接 GitHub，确认 Worker 的入口为 `worker/src/index.js`，与 `worker/wrangler.jsonc` 配置一致，部署时工作目录为 `worker/`。
4. 真正发布后复制 Cloudflare 显示的 `https://...workers.dev` 地址，不要凭命名猜测 Cloudflare 子域名。
5. 实际请求 `GET /`，确认返回选点页；请求 `GET /api/parse?u=https%3A%2F%2Fmaps.apple.com%2F%3Fll%3D51.5074%2C-0.1278&format=json`，应返回 `lat≈51.5074`、`lon≈-0.1278`。项目附有 `scripts/check-deployment.sh` 可统一检查。
6. 明确提交：Worker 公开地址、部署状态和测试结果；若失败给出原始错误摘要及建议修复。

## 快捷指令

原开发者真实链接：
- 设置位置 https://www.icloud.com/shortcuts/182f3a014597468eb1b15b99261cdf22
- 清除恢复 https://www.icloud.com/shortcuts/0352d53ed79849d382f50e9adf050662

iPhone 的用户副本中，将设置位置指令中解析链接用的 `wloc-spoofer.cyberhandyman.workers.dev` 域名换成**实际部署成功的** Worker 域名，只改域名不改 `/api/parse` 路径和参数。不要改 `https://gs-loc.apple.com/wloc-settings/save`：它属于 Shadowrocket 本机坐标存储入口。清除指令要核实内部实现，保持原有透传恢复逻辑。

**没有实际操作 iPhone 就不能声称已创建可安装的个人快捷指令链接。** 用户可以在手机上完成导入和编辑，Muse 如有已授权手机自动化环境才可协助直接操作。

## 最终设备验收

Safari 选点页面保存坐标 ≠ Apple Maps 定位改变。须查看 Shadowrocket 的 `WLOC Settings` 与 `Apple WLOC` 两个脚本的分别命中情况。定位响应仍不变需检查 HTTPS 解密证书、代理、iOS 26+ 缓存、GPS 优先级等。绝不声称 Cloudflare Worker 一上线，网络定位就已经成功生效。

请向用户回报：① Worker URL；② GitHub 当前 Commit；③ 解析接口实际响应；④ 两条快捷指令完成情况；⑤ iPhone 端尚需的明确步骤。
