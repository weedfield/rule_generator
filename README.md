# Copilot レビュー観点管理

## 概要

ローカルの Copilot(VS Code の Copilot Chat / Copilot CLI)で、レビュー観点を
プロジェクトごとに効かせるための仕組み。

レビュー観点をブロックに分割して管理し、プロジェクトごとに必要なブロックを組み合わせて、
各リポジトリのローカルに配置する。配置先はコミット対象から外れるため、チーム共有
リポジトリを汚さない。

- 観点を `blocks/` にブロック単位で配置
- `projects.txt` に「プロジェクト → 適用ブロック」を定義
- `apply.sh` が対象リポジトリのローカルに 1 枚に組み立てて配置
  - 配置先: `.github/skills/personal-review/SKILL.md`
  - `.git/info/exclude` に登録するのでコミットも共有もされない

## 構成
    apply.sh       # 呼び出し口。node apply.js を実行
    apply.js       # ロジック本体(Node、依存なし)
    projects.txt   # プロジェクトごとの割り当て設定
    blocks/        # レビュー観点ブロック
    README.md

前提: Node が必要(`node` にパスが通っていること)。

このフォルダはレビュー対象リポジトリの外(例 `~/copilot-rules`)に置く。
プロジェクトを再 clone しても影響を受けない。

## 使い方

### 1. 配置

全プロジェクトは同一の親ディレクトリ(ROOT)配下にある前提。ROOT は環境変数で指定する。

    export COPILOT_RULES_ROOT="$HOME/_workspace"   # 未設定なら ~/_workspace

### 2. 割り当て設定(projects.txt)

    *: block1, block2, ...            # 全プロジェクト共通(既定セット)
    <プロジェクト名>: blockA, blockB   # そのプロジェクトへの追加分
    <プロジェクト名>: blockA, -block1  # "-名前" で共通ブロックを個別に外す
    !<プロジェクト名>                   # そのプロジェクトを配布対象から除外

- 実効ブロック =「`*` の共通」+「その行の追加分」-「`-` の除外」(重複は自動除去)
- プロジェクト名は ROOT 直下のフォルダ名(絶対パスを書かないのでマシン非依存)
- 専用行が無いプロジェクトは `*` だけが適用される
- `!名前` はどのコマンドでも反映されない(全体・`--block`・名指しのいずれも対象外)

### 3. 実行

    ./apply.sh                           # ROOT 直下の全 git リポジトリに反映(新規もここで拾う)
    ./apply.sh fm          # 指定したプロジェクトに反映(名前 or パス)
    ./apply.sh --block security perf     # 指定ブロックのいずれかを含むプロジェクトに反映(複数可)
    ./apply.sh --block testing,security  # カンマ区切りも可

典型フロー:

- 新規プロジェクトを ROOT に clone → `./apply.sh`(`*` の共通が自動で乗る)
- 共通観点を直した → `./apply.sh` か `./apply.sh --block <直したブロック...>`(影響先だけ)
- 固有観点を直した → `./apply.sh <名前>`

### 4. VS Code の設定

Skill ファイルの読み込みを有効にしておく
(必要に応じて `github.copilot.chat.codeGeneration.useInstructionFiles` などの設定と併用する)。

## 注意

- 配置先を既にチームが git 管理している場合、`apply.sh` は上書きせず該当先だけスキップする。
- Copilot は AI なので毎回すべてを完璧には守らない。観点は具体的に、盛りすぎない。
- `blocks/project-*.md` の `<< >>` は各プロジェクトの観点で埋めて使う。
# rule_generator
