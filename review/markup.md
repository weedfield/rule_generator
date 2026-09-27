---
name: markup
applyTo: "**/*.{html,ejs}"
---
## 目的
マークアップの規約違反と、変更に伴う不整合を防ぐ

## ルール
- MARKUP-01 img タグに width と height を指定している
- MARKUP-02 js- クラスは通常のクラスの後ろに付けている（例：`<div class="location-header js-accordion-open">`）
- MARKUP-03 スタイルが当たっていないクラスがない（js- クラスは対象外）
- MARKUP-04 同じ画面に類似のパーツがある場合、実装を合わせている（同じファイル・同じ画面のテンプレートの範囲で確認する）
- MARKUP-05 HTML の変更で不要になった CSS / JS が残っていない（削除・変更されたクラス名で検索して確認する）

## 対象外
- DOM 構造（入れ子・見出しレベル・不要ラッパー・id 重複など） → dom-structure
- HTML Validator のエラー → 手動確認（manual.md）
- CSS の書き方 → css / css-guideline
