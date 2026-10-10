# Daisy WLOC Worker deployment

This directory is the Cloudflare Builds root (Path: `/worker`).

Production settings:
- GitHub: `Daisyhu668/wloc-spoofer-en`
- Branch: `main`
- Deploy command: `npx wrangler deploy`
- Wrangler entry: `wloc-standalone.js`
- Existing worker name: `daisy-wloc-picker`

Git-triggered deploy requested after Cloudflare repository was connected on 2026-10-10.

Health check: `https://daisy-wloc-picker.coolkiy.workers.dev/health`.
Expected `build` value: `daisy-standalone-20261010`.

Important: The Cloudflare GitHub integration must be authorized and connected in the user's Cloudflare dashboard. A successful GitHub commit alone does not prove the Worker has deployed or fixed iPhone network location spoofing.
