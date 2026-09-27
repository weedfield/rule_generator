#!/usr/bin/env bash
#
# manual-check.sh — push 前の手動確認フック（LLM は使わない）
# デプロイ先: ~/.review/tools/manual-check.sh
#
# pre-push フックから呼び出す。push 対象の差分に応じて manual.md の確認項目を
# 1 つずつ質問し、NG が 1 つでもあれば push を中止する。
# `git push --no-verify` による回避は許容する（フック自体が呼ばれないため）。
#
# 比較範囲:
#   - 既存ブランチの push は、push 対象のコミット範囲で判定する
#   - 新規ブランチのときだけ、/dev/tty で比較の起点を質問する
#     （main / develop / master のうち存在するもの / 直前のコミット(prev) / その他）

set -u

# ===== 設定（環境に合わせて変更する） =====

# 手動確認項目ファイル
MANUAL_MD="${MANUAL_MD:-$HOME/.review/manual.md}"

# 差分キーワード（初期値は運用に合わせて調整する）
LOG_KEYWORDS='beacon|サイカタ|saika|suit|s_code|catalyst|stmt'
VWO_KEYWORDS='vwo|VWO|variation|Variation'

# 各条件を常に該当扱いにする（1 で有効）
FORCE_CSS=0
FORCE_MARKUP=0
FORCE_IMAGE=0
FORCE_DELETE=0
FORCE_LOG=0
FORCE_VWO=0

# =========================================

ZERO="0000000000000000000000000000000000000000"

abort() {
  echo "" >/dev/tty 2>/dev/null || true
  echo "手動確認が中断されたため push を中止します。" >/dev/tty 2>/dev/null || true
  exit 1
}
trap abort INT

# 起点指定 → 開始コミットを解決（見つからなければ空を返す）
resolve_start() {
  local base="$1" start=""
  case "$base" in
    prev)
      start=$(git rev-parse --verify -q "HEAD~1" || true) ;;
    *)
      if ! git rev-parse --verify -q "${base}^{commit}" >/dev/null 2>&1; then
        printf ''; return 0
      fi
      if git show-ref --verify -q "refs/heads/$base" \
         || git rev-parse --verify -q "refs/remotes/$base^{commit}" >/dev/null 2>&1 \
         || git rev-parse --verify -q "refs/remotes/origin/$base^{commit}" >/dev/null 2>&1; then
        start=$(git merge-base "$base" HEAD 2>/dev/null || true)
      else
        start=$(git rev-parse --verify -q "${base}^{commit}" || true)
      fi ;;
  esac
  printf '%s' "$start"
}

# 新規ブランチ時に /dev/tty で比較の起点を選ばせ、起点トークンを標準出力に返す
prompt_base() {
  local fd_ok=1
  exec 4</dev/tty 2>/dev/null || fd_ok=0
  if [ "$fd_ok" = 0 ]; then
    echo "手動確認のため、ターミナルから git push してください。" >&2
    return 1
  fi
  local choices=()
  local b
  for b in main develop master; do
    git show-ref --verify -q "refs/heads/$b" && choices+=("$b")
  done
  choices+=("prev")
  {
    echo ""
    echo "新規ブランチです。比較の起点を選んでください："
    local i=1 c
    for c in "${choices[@]}"; do
      case "$c" in
        prev) echo "  $i) 直前のコミット（prev）" ;;
        *)    echo "  $i) $c" ;;
      esac
      i=$((i+1))
    done
    echo "  $i) その他（入力）"
  } >/dev/tty
  local other_no=$(( ${#choices[@]} + 1 ))
  local n other
  while true; do
    printf '  > ' >/dev/tty
    read -r n <&4 || { exec 4<&-; return 1; }
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#choices[@]}" ]; then
      printf '%s' "${choices[$((n-1))]}"; exec 4<&-; return 0
    elif [ "$n" = "$other_no" ]; then
      printf '起点を入力（ブランチ名 / prev / コミット）: ' >/dev/tty
      read -r other <&4 || { exec 4<&-; return 1; }
      printf '%s' "$other"; exec 4<&-; return 0
    else
      echo "  番号を入力してください。" >/dev/tty
    fi
  done
}

# ----- 1. 確認範囲を特定 -----
ranges=()
while read -r local_ref local_sha remote_ref remote_sha; do
  [ -z "${local_sha:-}" ] && continue
  [ "$local_sha" = "$ZERO" ] && continue   # ブランチ削除は確認不要
  if [ "${remote_sha:-$ZERO}" = "$ZERO" ]; then
    # 新規ブランチ: 起点を質問して merge-base / コミットから
    base=$(prompt_base) || exit 1
    start=$(resolve_start "$base")
    if [ -z "$start" ]; then
      echo "起点 '$base' が見つかりません。" >&2
      exit 1
    fi
    ranges+=("$start..$local_sha")
  else
    # 既存ブランチ: 今までどおり push 対象の範囲
    ranges+=("$remote_sha..$local_sha")
  fi
done

range_label="${ranges[*]:-（対象コミットなし）}"

# 確認すべきコミットがなければ通す
if [ ${#ranges[@]} -eq 0 ]; then
  exit 0
fi

# ----- 差分の収集 -----
changed_files=""
deleted_files=""
diff_text=""
for r in "${ranges[@]}"; do
  changed_files+=$'\n'"$(git diff --name-only "$r" 2>/dev/null)"
  deleted_files+=$'\n'"$(git diff --name-only --diff-filter=D "$r" 2>/dev/null)"
  diff_text+=$'\n'"$(git diff "$r" 2>/dev/null)"
done

# ----- 2. 該当する条件を判定 -----
conds=""
add_cond() { case " $conds " in *" $1 "*) ;; *) conds="$conds $1" ;; esac; }

{ [ "$FORCE_CSS" = 1 ]    || printf '%s\n' "$changed_files" | grep -qiE '\.(css|scss)$'; }                 && add_cond css
{ [ "$FORCE_MARKUP" = 1 ] || printf '%s\n' "$changed_files" | grep -qiE '\.(html|jsp)$'; }                 && add_cond markup
{ [ "$FORCE_IMAGE" = 1 ]  || printf '%s\n' "$changed_files" | grep -qiE '\.(png|jpe?g|gif|svg|webp)$'; }   && add_cond image
{ [ "$FORCE_DELETE" = 1 ] || [ -n "$(printf '%s' "$deleted_files" | tr -d '[:space:]')" ]; }               && add_cond delete
{ [ "$FORCE_LOG" = 1 ]    || printf '%s\n' "$diff_text" | grep -qiE "$LOG_KEYWORDS"; }                      && add_cond log
{ [ "$FORCE_VWO" = 1 ]    || printf '%s\n' "$diff_text" | grep -qiE "$VWO_KEYWORDS"; }                      && add_cond vwo

# ----- manual.md から質問を抽出 -----
if [ ! -f "$MANUAL_MD" ]; then
  echo "警告: $MANUAL_MD が見つからないため手動確認をスキップします。" >&2
  exit 0
fi

cond_active() { case " $conds " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

questions=()
while IFS= read -r line; do
  case "$line" in ""|\#*) continue ;; esac
  if [[ "$line" =~ ^-[[:space:]]*\[always\][[:space:]]*(.*)$ ]]; then
    questions+=("${BASH_REMATCH[1]}")
  elif [[ "$line" =~ ^-[[:space:]]*\[when:[[:space:]]*([^]]*)\][[:space:]]*(.*)$ ]]; then
    whenlist="${BASH_REMATCH[1]}"
    text="${BASH_REMATCH[2]}"
    hit=0
    IFS=',' read -ra parts <<< "$whenlist"
    for p in "${parts[@]}"; do
      p="$(printf '%s' "$p" | tr -d '[:space:]')"
      [ -z "$p" ] && continue
      if cond_active "$p"; then hit=1; break; fi
    done
    # 条件を複数書いた場合は「いずれか」を満たせば質問する
    [ "$hit" = 1 ] && questions+=("$text")
  fi
done < "$MANUAL_MD"

# 質問がなければ通す
if [ ${#questions[@]} -eq 0 ]; then
  exit 0
fi

# ----- 端末がなければ中止（GUI からの push など） -----
if ! exec 3</dev/tty 2>/dev/null; then
  echo "手動確認のため、ターミナルから git push してください。" >&2
  exit 1
fi

# ----- 3. 1 項目ずつ質問（入力は /dev/tty から） -----
echo "" >/dev/tty
echo "比較範囲: $range_label" >/dev/tty
echo "=== push 前の手動確認（o=OK / n=NG / s=対象外） ===" >/dev/tty
ng=()
for q in "${questions[@]}"; do
  while true; do
    printf '\n[確認] %s\n  > ' "$q" >/dev/tty
    if ! read -r ans <&3; then
      abort
    fi
    case "$ans" in
      o|O) break ;;
      s|S) break ;;
      n|N) ng+=("$q"); break ;;
      *)   printf '  o / n / s のいずれかを入力してください。\n' >/dev/tty ;;
    esac
  done
done

# ----- 4. 結果 -----
if [ ${#ng[@]} -gt 0 ]; then
  echo "" >/dev/tty
  echo "=== NG 項目があるため push を中止します ===" >/dev/tty
  for q in "${ng[@]}"; do echo "  - $q" >/dev/tty; done
  exit 1
fi

echo "" >/dev/tty
echo "手動確認 OK。push を続行します。" >/dev/tty
exit 0
