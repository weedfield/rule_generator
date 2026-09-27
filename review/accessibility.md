---
name: accessibility
applyTo: "**/*.{html,ejs,js}"
---
## 目的
スクリーンリーダーやキーボードの利用者が操作できない実装を防ぐ

## ルール
- A11Y-01 img に内容を表す alt がある（装飾目的の画像は alt=""）
- A11Y-02 フォーム部品に label が紐づいている（label の for と入力の id、または aria-label）
- A11Y-03 見た目ではなく意味に合った要素を使っている（押下は button、遷移は a など）
- A11Y-04 クリック可能な要素がキーボードでも操作できる（div / span にクリックを付ける場合は、role とキーボード対応がある）
- A11Y-05 アイコンのみのボタン・リンクに、読み上げ用のテキスト（aria-label など）がある

## 対象外
- 入れ子・見出しレベル・内容に合ったマークアップなどの DOM 構造 → dom-structure
- テキストと背景のコントラスト → 手動確認（manual.md）
- cursor: pointer → css
