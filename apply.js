#!/usr/bin/env node
'use strict';
//
// Copilot レビュー観点を projects.txt に従って各リポジトリのローカルへ配置する。
//   配置先: <repo>/.github/skills/personal-review/SKILL.md
//   .git/info/exclude に登録するのでコミット・共有はされない。
//   ROOT(プロジェクトの親)= $COPILOT_RULES_ROOT、未設定なら ~/_workspace
//
// 使い方:
//   apply.sh                    ROOT 直下の全 git リポジトリへ反映(新規もここで拾う)
//   apply.sh <名前 or パス>      指定した1プロジェクトへ反映
//   apply.sh --block <名前...>   指定ブロックのいずれかを含むプロジェクトだけへ反映(複数可)
//

const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');

// ===== 定数 =====

const RULES_DIR = __dirname;
const BLOCKS_DIR = path.join(RULES_DIR, 'blocks');
const PROJECTS_FILE = path.join(RULES_DIR, 'projects.txt');
const TARGET_REL_PATH = '.github/skills/personal-review/SKILL.md';
const ROOT = process.env.COPILOT_RULES_ROOT || path.join(os.homedir(), '_workspace');

// ===== ヘルパー =====

function error(message) { console.error(`ERROR: ${message}`); process.exit(1); }
function warn(message) { console.error(`WARN: ${message}`); }

function readTextOr(filePath, fallback = '') {
  try { return fs.readFileSync(filePath, 'utf8'); } catch { return fallback; }
}

function expandHome(inputPath) {
  return inputPath.startsWith('~') ? path.join(os.homedir(), inputPath.slice(1)) : inputPath;
}

// プロジェクト名(またはパス)を実際のリポジトリパスへ
function resolveRepoPath(projectName) {
  return projectName.includes('/') || projectName.startsWith('~')
    ? expandHome(projectName)
    : path.join(ROOT, projectName);
}

// git を実行して標準出力を返す(失敗時は null)
function runGit(args) {
  try { return execFileSync('git', args, { stdio: ['ignore', 'pipe', 'ignore'] }).toString(); }
  catch { return null; }
}

// そのパスがリポジトリで git 追跡されているか
function isTracked(repoPath, relPath) {
  return runGit(['-C', repoPath, 'ls-files', '--error-unmatch', relPath]) !== null;
}

// ===== 設定ファイル(projects.txt)=====

// text を解釈して { commonBlocks, extraBlocksByProject, excludedProjects } を返す
function parseConfig(text) {
  let commonBlocks = [];
  const extraBlocksByProject = new Map();
  const excludedProjects = new Set();

  for (const rawLine of text.split('\n')) {
    const line = rawLine.replace(/#.*/, '').trim();     // コメント・空白を除去
    if (!line) continue;

    if (line.startsWith('!')) {                          // "!名前" = 配布対象から除外
      const name = line.slice(1).trim();
      if (name) excludedProjects.add(name);
      continue;
    }
    if (!line.includes(':')) continue;                   // 以降は "名前: ブロック,…" のみ

    const separator = line.indexOf(':');
    const name = line.slice(0, separator).trim();
    const blocks = line.slice(separator + 1).split(',').map((s) => s.trim()).filter(Boolean);
    if (name === '*') commonBlocks = blocks;             // "*" = 全プロジェクト共通
    else extraBlocksByProject.set(name, blocks);         // それ以外 = そのプロジェクトの追加分
  }
  return { commonBlocks, extraBlocksByProject, excludedProjects };
}

const config = parseConfig(readTextOr(PROJECTS_FILE));

// トークン列を解決:「-名前」は除外指定。順序を保ち重複を除いた配列を返す
function resolveBlocks(tokens) {
  const excluded = new Set();
  const seen = new Set();
  const result = [];
  for (const rawToken of tokens) {
    const token = rawToken.trim();
    if (!token) continue;
    if (token.startsWith('-')) excluded.add(token.slice(1));
    else if (!seen.has(token)) { seen.add(token); result.push(token); }
  }
  return result.filter((name) => !excluded.has(name));
}

// そのプロジェクトに実際に適用されるブロック =「共通 + 追加 − 除外」
function effectiveBlocks(projectName) {
  const extra = config.extraBlocksByProject.get(projectName) || [];
  return resolveBlocks([...config.commonBlocks, ...extra]);
}

// ===== 配置 =====

// ブロック群を連結して、配置ファイルの中身(文字列)を作る
function buildContent(blocks) {
  const lines = [
    '---',
    'name: personal-review',
    'description: レビュー観点をまとめたローカル用の Copilot Skill。コード品質、セキュリティ、アクセシビリティ、要件の整合性を確認する。',
    '---',
    '',
    '# Personal Review',
    '',
    '<!-- 自動生成(copilot-rules)。ローカル専用・コミット禁止。blocks/ を編集して再実行すること。 -->',
    '',
  ];
  for (const blockName of blocks) {
    const blockFile = path.join(BLOCKS_DIR, `${blockName}.md`);
    if (!fs.existsSync(blockFile)) { warn(`ブロックが見つかりません: ${blockFile}`); continue; }
    lines.push(fs.readFileSync(blockFile, 'utf8').trimEnd(), '', '');
  }
  return lines.join('\n');
}

// .git/info/exclude に1行追加(共有 .gitignore は触らない)
function appendToExclude(repoPath, relPath) {
  const excludeFile = path.join(repoPath, '.git', 'info', 'exclude');
  const current = readTextOr(excludeFile);
  if (current.split('\n').map((l) => l.trim()).includes(relPath)) return;
  const prefix = current === '' || current.endsWith('\n') ? '' : '\n';
  fs.appendFileSync(excludeFile, prefix + relPath + '\n');
}

function skip(message) { warn(message); return false; }

// 1プロジェクトへ配置する。配置できたら true、条件を満たさずスキップなら false。
function applyToProject(projectName) {
  const repoPath = resolveRepoPath(projectName);
  const blocks = effectiveBlocks(projectName);

  if (blocks.length === 0) return skip(`適用ブロックなし: ${projectName}`);
  if (!fs.existsSync(path.join(repoPath, '.git'))) return skip(`git リポジトリでない: ${repoPath}`);
  if (isTracked(repoPath, TARGET_REL_PATH)) return skip(`配置先が既に git 管理下: ${repoPath}`);

  const targetPath = path.join(repoPath, TARGET_REL_PATH);
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  fs.writeFileSync(targetPath, buildContent(blocks));
  appendToExclude(repoPath, TARGET_REL_PATH);

  console.log(`OK: ${projectName}  [${blocks.join(' ')}]`);
  return true;
}

// ===== プロジェクト探索 =====

// ROOT 直下の git リポジトリ名を列挙(!除外を除く)
function listProjects() {
  if (!fs.existsSync(ROOT)) error(`ROOT が存在しません: ${ROOT}`);
  return fs.readdirSync(ROOT, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && fs.existsSync(path.join(ROOT, entry.name, '.git')))
    .map((entry) => entry.name)
    .filter((name) => !config.excludedProjects.has(name));
}

// ===== コマンド =====

// blockFilter が空なら全プロジェクト。指定があれば、そのいずれかを実効に含むプロジェクトだけ。
function applyToAll(blockFilter) {
  for (const blockName of blockFilter) {
    if (!fs.existsSync(path.join(BLOCKS_DIR, `${blockName}.md`)))
      warn(`そのブロックは存在しません(タイプミス?): ${blockName}`);
  }
  let applied = 0;
  for (const projectName of listProjects()) {
    const matches = blockFilter.length === 0
      || blockFilter.some((name) => effectiveBlocks(projectName).includes(name));
    if (matches && applyToProject(projectName)) applied++;
  }
  console.log(`---- ${applied} 件に反映しました(ROOT=${ROOT})`);
}

// 引数を解釈して対応するコマンドを実行
function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) return applyToAll([]);           // 引数なし = 全プロジェクト

  if (args[0] === '--block') {                             // --block <名前...> = 影響先だけ
    const blockFilter = args.slice(1)
      .flatMap((arg) => arg.split(','))                    // スペースでもカンマでも区切れる
      .map((name) => name.trim())
      .filter(Boolean);
    if (blockFilter.length === 0) error('--block にブロック名を1つ以上指定してください');
    return applyToAll(blockFilter);
  }

  if (args[0].startsWith('--')) error(`不明なオプション: ${args[0]}`);

  const projectName = path.basename(args[0]);             // それ以外 = プロジェクト1件
  if (config.excludedProjects.has(projectName))
    return warn(`${projectName} は除外指定のため反映しません(projects.txt の "!${projectName}" を外すと対象になります)`);
  if (!applyToProject(projectName)) error(`反映できませんでした: ${args[0]}`);
  console.log('---- 1 件');
}

main();
