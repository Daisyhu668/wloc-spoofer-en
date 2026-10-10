# Cloudflare Worker 500：Daisy 修复步骤（2026-10-10）

> **最新建议（2026-10-10）：优先用 Cloudflare 官方 GitHub 集成部署，避免手工复制。** 本仓库 `worker/wrangler.jsonc` 已在 commit `98a60987f68e4ccc72835f971a5e1b1ada6f96fa` 切换为 `main: wloc-standalone.js`，名称保持 `daisy-wloc-picker`。在 Cloudflare 已有 Worker 的 **Settings → Builds → Connect** 中连接 `Daisyhu668/wloc-spoofer-en`，Branch `main`，Root directory `worker`，Build command 留空，Deploy command `npx wrangler deploy`。授权 GitHub App 读取这个仓库即可；连接后按 Cloudflare 页面触发首轮部署或由用户在 GitHub 推送提交触发。无需重新建 Worker。故障页面的 Ray ID `a4852e46a87fa9c6` 可用于日志排查。官方说明：https://developers.cloudflare.com/workers/ci-cd/builds/ 。


用户线上 Worker：**https://daisy-wloc-picker.coolkiy.workers.dev/**

**当前状况：** Muse 报告线上返回 HTTP 500。代码仓库可读写，但 ChatGPT 没有用户 Cloudflare 账号的直接编辑/发布权限，因此这里的单文件验证不能替代线上部署。

## 为什么不能照搬之前的单文件 worker/wloc-worker.js

- `worker/src/index.js` 功能完整，提供选点首页及 `/api/parse`，但依赖 `hono/tiny`、`worker/src/page.js` 和 `worker/src/parse.js`。直接只复制 `index.js` 到 Cloudflare Edit code 会丢失依赖。
- 上游 `worker/wloc-worker.js` 是纯单文件选点页，**没有 `/api/parse`**；即使粘贴后首页可用，苹果地图快捷指令的链接解析也会失效。
- Muse 之前提到的特定尾部 `export{te as default};` 是某次压缩后 bundle 的形态；**不能以此判断其他合法 Worker 脚本是否完整**。

## 现在请使用已提交的完整版单文件

**唯一推荐源文件：**
https://raw.githubusercontent.com/Daisyhu668/wloc-spoofer-en/refs/heads/main/worker/wloc-standalone.js

文件约 36 KB，包含完整选点页面、Apple/高德等地图链接解析、GCJ02/WGS84 转换、`/health`、`/api/parse`；不包含 `import`、不依赖 Hono，不需 npm 安装，也不需要 KV 或数据库。

**本地代码结构已使用 JS 运行时验证**：`/health` 返回 200；`/` 返回 200 HTML；伦敦 Apple Maps 测试链接解析返回 200 和正确 JSON；上海 Apple Maps 链接转换返回 200 JSON；缺少输入返回 422。**尚未在用户 Cloudflare Worker 实际发布。**

### 方案 A：Cloudflare 在线代码编辑器

1. 登录 https://dash.cloudflare.com/ → Workers & Pages → `daisy-wloc-picker` → Edit code。
2. 在 Chrome 打开上面的 **Raw 完整源码 URL**（不是 GitHub HTML 页面），确保文件开头出现 `/** Daisy WLOC - Standalone Cloudflare Worker`、中段含 `const BUILD_ID = "daisy-standalone-20261010"` 和 `/api/parse`；它的末尾为 `getPageHtml` 的函数闭合，不会以压缩包的 `export{te as default};` 结尾。
3. 全选复制 Raw 文本。返回 Cloudflare 编辑器，先备份原代码，再选中旧代码全部替换，检查代码没有被富文本改写。点击 **Save and Deploy**。
4. 部署后逐项验证：
   - https://daisy-wloc-picker.coolkiy.workers.dev/health —— HTTP 200，JSON `{"ok":true,"build":"daisy-standalone-20261010",...}`。
   - https://daisy-wloc-picker.coolkiy.workers.dev/ —— HTTP 200，页面可打开。
   - https://daisy-wloc-picker.coolkiy.workers.dev/api/parse?u=https%3A%2F%2Fmaps.apple.com%2F%3Fll%3D51.5074%2C-0.1278&format=json —— HTTP 200，应有 `lat=51.5074, lon=-0.1278`。
5. 若继续 HTTP 500，不要再反复粘贴：查看 Workers → `daisy-wloc-picker` → Observability → Logs，把最新异常栈、部署版本和请求路径发回来，排除部署到错误 Worker、路由、语法或运行时错误。

### 方案 B：Wrangler 从仓库直接部署（更可靠）

在可安装 Node.js 的 Mac 或 Muse 终端执行：
```bash
git clone https://github.com/Daisyhu668/wloc-spoofer-en.git
cd wloc-spoofer-en/worker
npx wrangler login
npx wrangler deploy --config wrangler.standalone.jsonc
```
`wrangler.standalone.jsonc` 已配置入口 `wloc-standalone.js`；这样直接构建上传源码，避免浏览器手工复制导致损坏。Cloudflare 的 OAuth 必须由用户在自己浏览器授权。

## 上线后两条快捷指令

安装上游指令副本后，修改 **`/api/parse` 公共 Worker 域名** 到 `daisy-wloc-picker.coolkiy.workers.dev`：
- 设置：https://www.icloud.com/shortcuts/182f3a014597468eb1b15b99261cdf22
- 恢复：https://www.icloud.com/shortcuts/0352d53ed79849d382f50e9adf050662

**不要修改 `https://gs-loc.apple.com/wloc-settings/save`**，这是设备端 Shadowrocket 拦截保存地址。

## 最终验收不是只看 Worker 200

网页保存坐标后仍须区分 Shadowrocket 的 `WLOC Settings` 写入是否成功，`Apple WLOC` 响应脚本是否命中并修改，iOS 26+ 是否存在缓存，GPS 是否仍以真实定位为主。未经手机端验证，不要声称定位修改已经生效。
