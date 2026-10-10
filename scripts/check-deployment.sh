#!/usr/bin/env bash
set -euo pipefail
WORKER_BASE="${1:-}"
if [[ "$WORKER_BASE" != https://* ]]; then
  echo 'Usage: bash scripts/check-deployment.sh https://your-worker.workers.dev' >&2
  exit 2
fi
WORKER_BASE="${WORKER_BASE%/}"
ROOT='https://raw.githubusercontent.com/Daisyhu668/wloc-spoofer-en/refs/heads/main'
for URL in "$ROOT/modules/wloc.module" "$ROOT/dist/wloc.js" "$ROOT/dist/wloc-settings.js" "$WORKER_BASE/"; do
  CODE="$(curl -LsS -o /dev/null -w '%{http_code}' "$URL")"
  printf '%s %s\n' "$CODE" "$URL"
  [[ "$CODE" == "200" ]] || exit 1
done
python3 - "$WORKER_BASE" <<'PY'
import json, sys, urllib.parse, urllib.request
base=sys.argv[1]
query=urllib.parse.urlencode({'u':'https://maps.apple.com/?ll=51.5074,-0.1278','format':'json'})
with urllib.request.urlopen(base+'/api/parse?'+query, timeout=25) as r:
    data=json.load(r)
print('Map parse response:',data)
assert abs(float(data['lat'])-51.5074)<0.00001
assert abs(float(data['lon'])+0.1278)<0.00001
print('PASS: GitHub files and Worker endpoints respond; iPhone location NOT verified')
PY
