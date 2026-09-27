---
name: js
applyTo: "**/*.js"
---
## 目的
壊れやすい実装と、規約違反を防ぐ

## ルール
- JS-01 JS で取得する class / id に js- の接頭辞が付いている
- JS-02 parent()・siblings()・children() など、DOM の構造に左右される実装になっていない
- JS-03 is-hidden などの定数に定義されている値は、定数を使っている（定数ファイルの場所：TBD）
- JS-04 options の中身を JSDoc で記載している
- JS-05 jQuery オブジェクトを格納した変数名は $ で始めている（例：$variable）
- JS-06 グローバルを汚染していない
- JS-07 不要な ifExists がない（ifExists がなく、要素がない状態でもエラーが発生しなければ不要。または ifExists を外してもグローバル変数がなければ不要）
- JS-08 多重送信を防止している
- JS-09 if 文の {} を省略していない（処理が 1 行でも省略しない） [linter候補]
- JS-10 未使用の変数には _（アンダースコア）を前に付けている [linter候補]

## 対象外
- ロジックの誤り（条件分岐・null/undefined・境界・非同期・イベント多重登録など） → js-logic
- XSS・eval などのセキュリティ → security
- console.log などのデバッグコード → cleanup
