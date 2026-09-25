#!/usr/bin/env bash
# 呼び出し口。実ロジックは apply.js(Node)にある。
# 使い方は apply.js のヘッダ / README を参照。
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v node >/dev/null 2>&1 || { echo "ERROR: node が必要です(apply.js の実行に使用)" >&2; exit 1; }
exec node "$DIR/apply.js" "$@"
