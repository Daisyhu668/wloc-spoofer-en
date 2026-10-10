# WLOC Daisy｜交给 Muse 的完整背景与部署任务书

> **2026-10-10 线上 500 故障追加说明（必读）：** 用户现有 Worker 是 https://daisy-wloc-picker.coolkiy.workers.dev/ ，Muse 报告 HTTP 500。GPT 已提交一个**不依赖外部模块、同时支持选点页面与 /api/parse 的完整单文件版**到 [worker/wloc-standalone.js](../worker/wloc-standalone.js)。请优先阅读 [docs/DAISY-CLOUDFLARE-500-FIX.md](./DAISY-CLOUDFLARE-500-FIX.md)，直接用该文件部署，不要再将上游的 `worker/wloc-worker.js` 误当完整版本，因为它没有 `/api/parse`；也不要把特定压缩包尾部 `export{te as default};` 当作源码完整性标准。Cloudflare 的线上部署尚未被 GPT 验证。Muse 的 GitHub App 无写权限无碍：GPT 已经通过 GitHub 连接成功提交这些文件。


> 更新时间：2026-10-10。此文件是目前唯一应采用的正式执行说明，优先于 Google Drive 内旧版 ZIP、旧版 `MUSE-HANDOFF.md` 和曾经暂定的 `wloc-private` 仓库名。
>
> **Muse 的定位：执行工程师。** 请在用户已授权的浏览器、GitHub 和 Cloudflare 账户中直接完成可做的步骤；只在需要登录授权或 iPhone 端确认时向用户提出最少的操作要求。不用重新讨论项目是否值得做，也不要重新创建仓库。

## 一、用户背景、原先怎么使用、现在为什么需要部署

用户使用 **iPhone（iOS 26.4.2）+ Shadowrocket（小火箭）**，通过 WLOC 模块修改 Apple Wi-Fi／基站网络定位的返回坐标。原来长期成功的使用流程是：

1. Shadowrocket 开启代理、WLOC 模块及 HTTPS 解密。
2. 用户在苹果地图长按选一个目标地点 → 分享给「设置地理位置 / wloc Set Location」快捷指令。
3. 快捷指令提取地图链接，必要时通过 Worker 的 `/api/parse` 解析经纬度及中国大陆 GCJ-02 → WGS84 坐标换算。
4. 快捷指令或在线选点页请求 `https://gs-loc.apple.com/wloc-settings/save`，被 Shadowrocket 的请求脚本 `wloc-settings.js` 拦截，保存到手机端持久化存储。
5. 待苹果定位服务请求 `https://gs-loc.apple.com/clls/wloc` 或 `gs-loc-cn.apple.com` 的同一路径时，`wloc.js` 修改网络定位响应，地图有机会采用目标位置。
6. 用户也希望有一键清除并恢复真实定位的指令。

**当前故障**：之前通过「苹果地图 → 分享 → 快捷指令」可修改位置，现在无法改变苹果地图当前定位；用户进一步测试，发现**在线选点页面能显示坐标储存成功，但是苹果地图定位没有变化**。因此不能把问题只归咎于快捷指令，也不能认为 Worker 上线会自动修复。旧项目 `Yu9191/wloc` 的某些远程链接先前访问失败，影响长期可靠性；且上游 README 明确提示 iOS 26+ 可能出现 `locationd` 内存缓存，GPS 优先级也可能覆盖网络定位。

**用户真正想要的最终体验**：不再依赖第三方公共页面请求额度或随时变化的脚本；自己拥有 GitHub 模块及 Cloudflare Worker；在 iPhone 仍然只需「地图选点 → 分享 → 快捷指令」，并能一键清除位置；尽量稳定、可维护、免费、少操作。先解决功能，避免无意义的美化。

## 二、已经完成的工作（Muse 请勿重复）

- 用户 GitHub 帐号：`Daisyhu668`。用户已在 GitHub 点 Fork，**实际仓库名为 `wloc-spoofer-en`**，不是之前拟定的 `wloc-private`。
- **真实仓库**：https://github.com/Daisyhu668/wloc-spoofer-en （Public；main 分支；用户对该仓库拥有 Admin/Push 权限）。
- 上游来源：https://github.com/cyberhandyman/wloc-spoofer-en ，其为早期 `Yu9191/wloc` 的衍生版本。
- GPT 已把个人化配置真实推送到该仓库：首个配置提交 `8b1629ce90808bb7316da2d35a718c727f575a0a`；后续还添加了项目执行说明。仓库 `main` 是当前权威版本。
- **已存在的 Shadowrocket 模块**：https://raw.githubusercontent.com/Daisyhu668/wloc-spoofer-en/refs/heads/main/modules/wloc.module
- 模块内的两个 `script-path` 都已指向用户自己的 `dist/wloc.js`、`dist/wloc-settings.js`；上述三个 GitHub Raw 文件均已核实可获取。
- `worker/wrangler.jsonc` 已将 Worker 名设置为 `daisy-wloc-picker`，但**目前还没有用户账号下实际部署成功的 Worker URL**。
- 仓库内文档：`README-DAISY.md`、`docs/DAISY-SHORTCUTS.md`、`docs/DAISY-DIAGNOSTICS.md`；部署验证脚本 `scripts/check-deployment.sh`。
- Google Drive 已存在 `WLOC-Daisy` 文件夹（https://drive.google.com/drive/folders/16JADtyqenmUniXLSwslucZZk_6kujSES），其中有前期交付包，但由于仓库名称已确定，**不要将旧 ZIP 覆盖进当前仓库**。请以本 GitHub 的当前 main 分支为准。

## 三、Muse 应按顺序执行的任务

### A. Cloudflare Worker 上线（首要）

1. 使用用户已授权的 Cloudflare 账号登录；如需手动 OAuth，请用户直接在官方页面完成。严禁要求用户在聊天里发送密码、私钥、API Token 或 Cloudflare 凭证。
2. 从 **上述用户 GitHub 仓库**拉代码，不要重新 Fork；部署目录是 `worker/`，入口是 `worker/src/index.js`，配置是 `worker/wrangler.jsonc`，Worker 名 `daisy-wloc-picker`。
3. 支持终端时执行：
   ```bash
   git clone https://github.com/Daisyhu668/wloc-spoofer-en.git
   cd wloc-spoofer-en/worker
   npm install
   npx wrangler login
   npm run deploy
   ```
   如采用 Cloudflare 控制台 GitHub 集成，请确认工作目录、入口和构建/部署命令，不要误将 `modules/wloc.module` 当成 Worker JS 上传。
4. 部署后从 Cloudflare 控制台拿到 **真实** `https://...workers.dev` 域名。不要根据名称猜 URL，也不要把上游 `wloc-spoofer.cyberhandyman.workers.dev` 当成用户专属网址。
5. 实际验证首页 `GET /` 能显示选点页面，接口 `GET /api/parse` 可解析 Apple Maps 分享链接。可测试：
   ```text
   /api/parse?u=https%3A%2F%2Fmaps.apple.com%2F%3Fll%3D51.5074%2C-0.1278&format=json
   ```
   应返回约 `{"lat":51.5074,"lon":-0.1278}`；不要把这里的示例坐标当成用户真实位置。项目的 `scripts/check-deployment.sh` 可做辅助验收。
6. 如果 Worker 部署失败，在控制台收集明确的构建日志和报错，并在能确认原因时直接修复配置、重部署；不要未经测试就报告成功。

### B. 将个人快捷指令接到用户自己的 Worker

原作者可确认的指令：
- Set Location：https://www.icloud.com/shortcuts/182f3a014597468eb1b15b99261cdf22
- Clear & Restore：https://www.icloud.com/shortcuts/0352d53ed79849d382f50e9adf050662

1. 检查两个指令真实的动作及 URL，特别是 `/api/parse` 调用、分享表单输入类型、写入/恢复动作。不要只凭文档假定脚本结构。
2. 给用户建立自己的快捷指令副本（拟命名「Daisy 设置位置」「Daisy 恢复定位」）。在用来解析分享链接的请求 URL 中，将 **公共 Worker 域名**替换为刚部署的用户专属 Worker 域名；保留 `/api/parse` 的路径、`format=json` 与解析逻辑。
3. **不要将** `https://gs-loc.apple.com/wloc-settings/save` **改成 Worker 域名**。该地址是 Shadowrocket 中写入坐标的本机 MITM 钩子，不属于 Worker 接口。
4. 苹果地图中应可使用「长按选点 → 分享 → Daisy 设置位置」；清理指令应正确清除持久化位置而不是写入某个假坐标。若生成私人 iCloud 快捷指令分享链接，必须实际生成并测试，不能虚构。
5. 若 Muse 没有 iOS 设备控制权限，请留下能在 iPhone 快捷指令编辑器逐步执行的具体修改清单，不能冒称已经安装。

### C. Shadowrocket 装载与定位有效性验证

1. 在 iPhone Shadowrocket **停用旧 WLOC 模块**，避免新旧规则同时生效，导入用户专属模块 Raw 地址（见上）。启用当前模块。
2. 核实 Shadowrocket 代理开关、HTTPS 解密开关、受信任的 CA 证书、MITM 主机 `gs-loc.apple.com` 和 `gs-loc-cn.apple.com`。
3. 先通过在线选点或快捷指令保存一个测试坐标；重新查询设备端持久化坐标，确认 `WLOC Settings` 保存动作成功。
4. 再单独查看 **`Apple WLOC`** 响应规则有没有命中 `/clls/wloc`、脚本是否报告成功 patch。只有设置脚本命中，不代表定位修改脚本生效。
5. 若 `Apple WLOC` 从未命中，重点检查请求是否发出、MITM/分流/代理是否拦截、Script 日志和脚本错误；若已成功修改响应但苹果地图仍不变，按上游说明先重新启动 iPhone 清除 iOS 26+ 定位服务缓存，之后仍需考虑硬件 GPS 优先级。不要保证任何环境都能强制覆盖 GPS。
6. 验证恢复位置指令、停用模块及必要的重启流程。不要在完成测试前判定故障已解决。

## 四、交付标准（必须有证据）

请 Muse 最终给用户一份简要验收表：

| 项目 | 应提交证据 |
|---|---|
| GitHub | 仓库链接、当前 Commit SHA、模块及 dist 脚本 Raw URL |
| Cloudflare | 实际 `workers.dev` URL、控制台部署成功截图/记录 |
| 接口 | 首页访问结果、`/api/parse` 测试 URL、实际 HTTP 状态和 JSON |
| 快捷指令 | 两条个人指令修改情况；有真实 iCloud 共享链接则给链接，没有就提供设备端剩余动作 |
| Shadowrocket | 模块启用及 MITM 检查、设置脚本和 WLOC 响应脚本分别的日志结果 |
| 实际定位 | 苹果地图是否改变；如果没有，准确指出失败环节，不把 Worker 上线等同定位生效 |

## 五、工作原则与权限

- 只修改此 WLOC 仓库，不要动用户的其他 GitHub 项目。保持上游代码署名与原有开源许可（如果存在）；更新前检查差异。
- 不需要购买域名、升级付费 Cloudflare 套餐或申请额外收费资源；先使用免费 `workers.dev`。
- 不在 GitHub 仓库和公开 Issue 上传账号凭证、私人位置信息或未脱敏日志。
- 如果遇到需要人操作的授权页面，指出精确的按钮和网页即可；授权完成后继续执行。
- 在 ChatGPT 和 Muse 之间无需实时消息接口；**以本 GitHub 文档和最新 Commit 作为跨工具交接依据**。

**当前阶段结论：仓库已经创建并写入配置；Cloudflare 发布、手机端快捷指令更新、定位有效性验证尚未完成。**
