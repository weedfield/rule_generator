---
name: security
---
## 目的
情報漏えいと、攻撃につながる実装を防ぐ

## ルール
- SEC-01 API キー・トークンなどの秘匿情報がハードコードされていない [linter候補]
- SEC-02 ユーザー入力や外部データを、サニタイズせずに innerHTML / html() などへ渡していない（XSS）
- SEC-03 target="_blank" の外部リンクに rel="noopener"（必要に応じて noreferrer）が付いている [linter候補]
- SEC-04 eval / new Function など、危険な動的実行を使っていない [linter候補]
