---
name: dom-structure
applyTo: "**/*.{html,jsp}"
---
## 目的
不適切な DOM 構造を防ぐ

## ルール
- DOM-01 入れ子のルール違反（a の中に a や button、p の中に div、ul / ol の直下が li 以外）
- DOM-02 見出しレベルの飛びや順序の誤り
- DOM-03 不要なラッパー要素（役割もスタイルもない div の多重の入れ子）
- DOM-04 内容に合ったマークアップ（並んだ項目は ul / ol、表形式のデータは table）
- DOM-05 id の重複

## 対象外
- 要素の選び方（button / a など） → accessibility（A11Y-03）
- HTML Validator → 手動確認
